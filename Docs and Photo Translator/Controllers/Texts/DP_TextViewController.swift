//
//  DP_TextViewController.swift
//  Docs and Photo Translator
//
//  Created by Aleksandr on 20.06.2024.
//

import UIKit
import MLKitTranslate

typealias DP_TextViewControllerExtension = DP_TextViewController

class DP_TextViewController: DP_BaseViewController {
    
    @IBOutlet private var inputTextView: UITextView!
     @IBOutlet private var outputTextView: UITextView!
     @IBOutlet private var statusTextView: UITextView!
     @IBOutlet private var inputPicker: UIPickerView!
     @IBOutlet private var outputPicker: UIPickerView!
     @IBOutlet private var sourceDownloadDeleteButton: UIButton!
     @IBOutlet private var targetDownloadDeleteButton: UIButton!
    @IBOutlet private weak var translateButton: UIButton!
    
    @IBOutlet private weak var topConstant: NSLayoutConstraint!
    @IBOutlet private weak var bottomConstant: NSLayoutConstraint!
    
    var coordinator: DP_TextCoordinatorProtocol?
    private var pickerManager: DP_TextPicker?
    private var inputLang: TranslateLanguage = TranslateLanguage.english
    private var outputLang: TranslateLanguage = DP_TranslateManager.shared.currentLanguages ?? TranslateLanguage.english

    override func viewDidLoad() {
        super.viewDidLoad()

        dp_configUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        isSmallBackButtonEnabled = false
        dp_setGradient()
      super.viewWillAppear(animated)
        
        dp_addRoundToNavBar()
    }
    
    @IBAction func didTapSwap() {
      let inputSelectedRow = inputPicker.selectedRow(inComponent: 0)
      inputPicker.selectRow(outputPicker.selectedRow(inComponent: 0), inComponent: 0, animated: false)
      outputPicker.selectRow(inputSelectedRow, inComponent: 0, animated: false)
      inputTextView.text = outputTextView.text
        pickerManager?.dp_reset()
        self.setDownloadDeleteButtonLabels(inputLanguage: inputLang, outputLanguage: outputLang)
    }
    
    @IBAction func didTapDownloadDeleteSourceLanguage() {
      self.handleDownloadDelete(picker: inputPicker, button: self.sourceDownloadDeleteButton)
    }

    @IBAction func didTapDownloadDeleteTargetLanguage() {
      self.handleDownloadDelete(picker: outputPicker, button: self.targetDownloadDeleteButton)
    }

    @IBAction func listDownloadedModels() {
      let msg =
        "Downloaded models: "
        + ModelManager.modelManager()
        .downloadedTranslateModels
        .map { model in Locale.current.localizedString(forLanguageCode: model.language.rawValue)! }
        .joined(separator: ", ")
      self.statusTextView.text = msg
    }
}

private extension DP_TextViewControllerExtension {
    
    func dp_configUI() {
        dp_createPickerManager()
        dp_initStartComponent()
        dp_hideKeyboardWhenTappedAround()
        dp_addNavButtons()
    }
    
    func dp_addNavButtons() {
        self.navigationItem.rightBarButtonItems = []
        dp_createRightNavBarItems(image: "square.and.arrow.up", action: #selector(dp_didTapShare))
    }
    
    @objc func dp_didTapShare() {
        coordinator?.dp_eventOccurred(with: .share(outputTextView.text))
    }
    
    func dp_createPickerManager() {
        pickerManager = DP_TextPicker(inputPicker: inputPicker, outputPicker: outputPicker)
        
        pickerManager?.eventHandler = { [weak self] langs in
            self?.inputLang = langs.0
            self?.outputLang = langs.1
            self?.dp_translate()
        }
    }
    
    func dp_initStartComponent() {
        inputTextView.layer.cornerRadius = 16
        inputTextView.layer.borderColor = DP_Colors.blueColor.color.cgColor
        inputTextView.layer.borderWidth = 0.5
        inputTextView.layer.masksToBounds = true
        inputTextView.delegate = self
        inputTextView.accessibilityIdentifier = "inputTextView"
        inputTextView.returnKeyType = .done
        inputTextView.text = ""
        
        outputTextView.layer.cornerRadius = 16
        outputTextView.layer.borderColor = DP_Colors.blueColor.color.cgColor
        outputTextView.layer.borderWidth = 0.5
        outputTextView.layer.masksToBounds = true
        outputTextView.delegate = self
        outputTextView.accessibilityIdentifier = "outputTextView"
        outputTextView.text = ""
      
        setDownloadDeleteButtonLabels(inputLanguage: inputLang, outputLanguage: outputLang)
       sourceDownloadDeleteButton.accessibilityIdentifier = "InputModelButton"
       statusTextView.accessibilityIdentifier = "statusTextView"
        statusTextView.text = "..."

       NotificationCenter.default.addObserver(
         self, selector: #selector(remoteModelDownloadDidComplete(notification:)),
         name: .mlkitModelDownloadDidSucceed, object: nil)
       NotificationCenter.default.addObserver(
         self, selector: #selector(remoteModelDownloadDidComplete(notification:)),
         name: .mlkitModelDownloadDidFail, object: nil)
     }
    
    func dp_translate() {
        self.setDownloadDeleteButtonLabels(inputLanguage: inputLang, outputLanguage: outputLang)
          DP_TranslateManager.shared.setOptionTranslate(inputLang: inputLang, outputLang: outputLang)
        self.setDownloadDeleteButtonLabels(inputLanguage: inputLang, outputLanguage: outputLang)
          DP_TranslateManager.shared.translate(inputText: inputTextView.text) { [weak self] zerText in
              self?.outputTextView.text = zerText
          }
    }
    
    @objc func remoteModelDownloadDidComplete(notification: NSNotification) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.dp_removeLoader()
        }
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
          strongSelf.statusTextView.text =
            "Download succeeded for \(languageName)"
        } else {
          strongSelf.statusTextView.text =
            "Download failed for \(languageName)"
        }
          strongSelf.setDownloadDeleteButtonLabels(inputLanguage: strongSelf.inputLang, outputLanguage: strongSelf.outputLang)
      }
    }
    
    func setDownloadDeleteButtonLabels(inputLanguage: TranslateLanguage, outputLanguage: TranslateLanguage) {
      if DP_TranslateManager.shared.isLanguageDownloaded(inputLanguage) {
        self.sourceDownloadDeleteButton.setTitle("Delete Model", for: .normal)
          sourceDownloadDeleteButton.titleLabel?.font = UIFont.systemFont(ofSize: 12)
          sourceDownloadDeleteButton.tintColor = DP_Colors.black.color
      } else {
        self.sourceDownloadDeleteButton.setTitle("Download Model", for: .normal)
          sourceDownloadDeleteButton.titleLabel?.font = UIFont.systemFont(ofSize: 12)
          sourceDownloadDeleteButton.tintColor = DP_Colors.black.color
      }
      self.sourceDownloadDeleteButton.isHidden = inputLanguage == .english
        
      if DP_TranslateManager.shared.isLanguageDownloaded(outputLanguage) {
        self.targetDownloadDeleteButton.setTitle("Delete Model", for: .normal)
          targetDownloadDeleteButton.titleLabel?.font = UIFont.systemFont(ofSize: 12)
          targetDownloadDeleteButton.tintColor = DP_Colors.black.color
      } else {
        self.targetDownloadDeleteButton.setTitle("Download Model", for: .normal)
          targetDownloadDeleteButton.titleLabel?.font = UIFont.systemFont(ofSize: 12)
          targetDownloadDeleteButton.tintColor = DP_Colors.black.color
      }
      self.targetDownloadDeleteButton.isHidden = outputLanguage == .english
    }

    func handleDownloadDelete(picker: UIPickerView, button: UIButton) {
        dp_addLoader()
        let language = DP_TranslateManager.shared.allLanguages[picker.selectedRow(inComponent: 0)]
        guard let languageName = Locale.current.localizedString(forLanguageCode: language.rawValue) else { return }
        if DP_TranslateManager.shared.isLanguageDownloaded(language) {
            self.statusTextView.text = "Deleting \(languageName)"
            DP_TranslateManager.shared.dp_downloadModel(language: language) { [weak self] in
                guard let self = self else { return }
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    self.dp_removeLoader()
                    self.statusTextView.text = "Deleted \(languageName)"
                    self.setDownloadDeleteButtonLabels(inputLanguage: self.inputLang, outputLanguage: self.outputLang)
                }
            }
        } else {
            self.statusTextView.text = "Downloading \(languageName)"
            DP_TranslateManager.shared.dp_deletedModel(language: language)
        }
    }
}

extension DP_TextViewControllerExtension: UITextViewDelegate {

    func textView(
      _ textView: UITextView, shouldChangeTextIn range: NSRange,
      replacementText text: String
    ) -> Bool {
      if text == "\n" {
        textView.resignFirstResponder()
        return false
      }
      return true
    }

    func textViewDidChange(_ textView: UITextView) {
        self.setDownloadDeleteButtonLabels(inputLanguage: inputLang, outputLanguage: outputLang)
        DP_TranslateManager.shared.translate(inputText: textView.text) { [weak self] zerText in
            self?.outputTextView.text = zerText
        }
    }

    // Make all text selected when the text view is activated for editing, so that the newly
    // input context will override the existing content.
    func textViewDidBeginEditing(_ textView: UITextView) {
      textView.selectedTextRange = textView.textRange(
        from: textView.beginningOfDocument, to: textView.endOfDocument)
        
        if textView == outputTextView {
            topConstant.constant -= 200
            bottomConstant.constant += 200
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView == outputTextView {
            topConstant.constant += 200
            bottomConstant.constant -= 200
        }
    }
}
