//
//  DP_ChoiceLanguageViewController.swift
//  Docs and Photo Translator
//
//  Created by Aleksandr on 02.07.2024.
//

import UIKit
import MLKitTranslate

typealias DP_ChoiceLanguageViewControllerExtension = DP_ChoiceLanguageViewController

class DP_ChoiceLanguageViewController: DP_BaseViewController {

    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var languagePicker: UIPickerView!
    
    var eventHandlerBack: Block<()>?
    private var manager: DP_ChoiceLangManager?
    private var helper: DP_ChoiceLangHelper = DP_ChoiceLangHelper()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        dp_configureUI()
        dp_createManager()
    }

    @IBAction func sm_didTapBackButton(_ sender: UIButton) {
        dp_checkDefaultLanguage()
    }
}

private extension DP_ChoiceLanguageViewControllerExtension {
    
    func dp_configureUI() {
        nameLabel.text = "Select language for translation"
        NotificationCenter.default.addObserver(
          self, selector: #selector(remoteModelDownloadDidComplete(notification:)),
          name: .mlkitModelDownloadDidSucceed, object: nil)
        NotificationCenter.default.addObserver(
          self, selector: #selector(remoteModelDownloadDidComplete(notification:)),
          name: .mlkitModelDownloadDidFail, object: nil)
    }
    
    @objc
    func remoteModelDownloadDidComplete(notification: NSNotification) {
      let userInfo = notification.userInfo!
      guard
        let remoteModel =
          userInfo[ModelDownloadUserInfoKey.remoteModel.rawValue] as? TranslateRemoteModel
      else {
        return
      }
      weak var weakSelf = self
      DispatchQueue.main.async {
        guard let strongSelf = weakSelf else {
          print("Self is nil!")
          return
        }
        let languageName = Locale.current.localizedString(
          forLanguageCode: remoteModel.language.rawValue)!
        if notification.name == .mlkitModelDownloadDidSucceed {
            strongSelf.dp_dismissWithLang()
        } else {
            strongSelf.nameLabel.text = "Select language for translation"
            strongSelf.dp_removeLoader()
            strongSelf.dp_presentAlert(title: "An error occurred, please select another language")
        }
        strongSelf.dp_isDownloadLanguage()
      }
    }
    
    func dp_dismissWithLang() {
        dp_removeLoader()
        dp_dismiss()
        eventHandlerBack?(())
    }
    
    func dp_createManager() {
        manager = DP_ChoiceLangManager(languagePicker)
    }
    
    func dp_dismiss() {
        self.dismiss(animated: true)
    }
    
    func dp_checkDefaultLanguage() {
        dp_addLoader()
        nameLabel.text = "Loading language ..."
        handleDownloadDelete()
        
        helper.dp_setStartLang(DP_TranslateManager.shared.currentLanguages?.rawValue ?? "")
    }
    
    func handleDownloadDelete() {
        let language = DP_TranslateManager.shared.allLanguages[languagePicker.selectedRow(inComponent: 0)]
      if language == .english {
          DP_TranslateManager.shared.currentLanguages = .english
        return
      }
        if language == DP_TranslateManager.shared.currentLanguages {
            dp_dismissWithLang()
            return
        }
        DP_TranslateManager.shared.currentLanguages = language
 
      let model = DP_TranslateManager.shared.model(forLanguage: language)
      let modelManager = ModelManager.modelManager()
      let languageName = Locale.current.localizedString(forLanguageCode: language.rawValue)!
      if modelManager.isModelDownloaded(model) {
        modelManager.deleteDownloadedModel(model) { error in
          self.dp_isDownloadLanguage()
        }
      } else {
        let conditions = ModelDownloadConditions(
          allowsCellularAccess: true,
          allowsBackgroundDownloading: true
        )
        modelManager.download(model, conditions: conditions)
      }
    }
    
    func dp_isDownloadLanguage() {
        let outputLanguage = DP_TranslateManager.shared.allLanguages[languagePicker.selectedRow(inComponent: 0)]

      if DP_TranslateManager.shared.isLanguageDownloaded(outputLanguage) {
  
      } else {
 
      }
    }
}
