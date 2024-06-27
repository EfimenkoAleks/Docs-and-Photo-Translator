//
//  DP_TextViewController.swift
//  Docs and Photo Translator
//
//  Created by Aleksandr on 20.06.2024.
//

import UIKit
import MLKit

typealias DP_TextViewControllerExtension = DP_TextViewController

class DP_TextViewController: DP_BaseViewController {
    
    @IBOutlet var inputTextView: UITextView!
     @IBOutlet var outputTextView: UITextView!
     @IBOutlet var statusTextView: UITextView!
     @IBOutlet var inputPicker: UIPickerView!
     @IBOutlet var outputPicker: UIPickerView!
     @IBOutlet var sourceDownloadDeleteButton: UIButton!
     @IBOutlet var targetDownloadDeleteButton: UIButton!
    
    var coordinator: DP_TextCoordinatorProtocol?

    override func viewDidLoad() {
        super.viewDidLoad()

        dp_configUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        isSmallBackButtonEnabled = false
      super.viewWillAppear(animated)
    }
    
    @IBAction func didTapSwap() {
      let inputSelectedRow = inputPicker.selectedRow(inComponent: 0)
      inputPicker.selectRow(outputPicker.selectedRow(inComponent: 0), inComponent: 0, animated: false)
      outputPicker.selectRow(inputSelectedRow, inComponent: 0, animated: false)
      inputTextView.text = outputTextView.text
      pickerView(inputPicker, didSelectRow: 0, inComponent: 0)
      self.setDownloadDeleteButtonLabels()
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
        initStartComponent()
    }
    
    func initStartComponent() {
       inputPicker.dataSource = self
       outputPicker.dataSource = self
       inputPicker.selectRow(
        DP_TranslateManager.shared.allLanguages.firstIndex(of: TranslateLanguage.english) ?? 0, inComponent: 0, animated: false)
       outputPicker.selectRow(
        DP_TranslateManager.shared.allLanguages.firstIndex(of: TranslateLanguage.spanish) ?? 0, inComponent: 0, animated: false)
       inputPicker.delegate = self
       outputPicker.delegate = self
       inputTextView.delegate = self
       inputTextView.accessibilityIdentifier = "inputTextView"
       inputTextView.returnKeyType = .done
       pickerView(inputPicker, didSelectRow: 0, inComponent: 0)
       setDownloadDeleteButtonLabels()

       outputTextView.accessibilityIdentifier = "outputTextView"
       sourceDownloadDeleteButton.accessibilityIdentifier = "InputModelButton"
       statusTextView.accessibilityIdentifier = "statusTextView"
        inputTextView.text = ""
        outputTextView.text = ""
        statusTextView.text = "..."

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
          strongSelf.statusTextView.text =
            "Download succeeded for \(languageName)"
        } else {
          strongSelf.statusTextView.text =
            "Download failed for \(languageName)"
        }
        strongSelf.setDownloadDeleteButtonLabels()
      }
    }
    
    func setDownloadDeleteButtonLabels() {
        let inputLanguage = DP_TranslateManager.shared.allLanguages[inputPicker.selectedRow(inComponent: 0)]
        let outputLanguage = DP_TranslateManager.shared.allLanguages[outputPicker.selectedRow(inComponent: 0)]
      if DP_TranslateManager.shared.isLanguageDownloaded(inputLanguage) {
        self.sourceDownloadDeleteButton.setTitle("Delete Model", for: .normal)
      } else {
        self.sourceDownloadDeleteButton.setTitle("Download Model", for: .normal)
      }
      self.sourceDownloadDeleteButton.isHidden = inputLanguage == .english
      if DP_TranslateManager.shared.isLanguageDownloaded(outputLanguage) {
        self.targetDownloadDeleteButton.setTitle("Delete Model", for: .normal)
      } else {
        self.targetDownloadDeleteButton.setTitle("Download Model", for: .normal)
      }
      self.targetDownloadDeleteButton.isHidden = outputLanguage == .english
    }
    
    func handleDownloadDelete(picker: UIPickerView, button: UIButton) {
        let language = DP_TranslateManager.shared.allLanguages[picker.selectedRow(inComponent: 0)]
      if language == .english {
        return
      }
      button.setTitle("working...", for: .normal)
      let model = DP_TranslateManager.shared.model(forLanguage: language)
      let modelManager = ModelManager.modelManager()
      let languageName = Locale.current.localizedString(forLanguageCode: language.rawValue)!
      if modelManager.isModelDownloaded(model) {
        self.statusTextView.text = "Deleting \(languageName)"
        modelManager.deleteDownloadedModel(model) { error in
          self.statusTextView.text = "Deleted \(languageName)"
          self.setDownloadDeleteButtonLabels()
        }
      } else {
        self.statusTextView.text = "Downloading \(languageName)"
        let conditions = ModelDownloadConditions(
          allowsCellularAccess: true,
          allowsBackgroundDownloading: true
        )
        modelManager.download(model, conditions: conditions)
      }
    }
}

extension DP_TextViewControllerExtension: UITextViewDelegate, UIPickerViewDataSource,
                               UIPickerViewDelegate {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
      return 1
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int)
      -> String?
    {
        return Locale.current.localizedString(forLanguageCode: DP_TranslateManager.shared.allLanguages[row].rawValue)
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return DP_TranslateManager.shared.allLanguages.count
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let inputLanguage = DP_TranslateManager.shared.allLanguages[inputPicker.selectedRow(inComponent: 0)]
        let outputLanguage = DP_TranslateManager.shared.allLanguages[outputPicker.selectedRow(inComponent: 0)]
      self.setDownloadDeleteButtonLabels()
      let options = TranslatorOptions(sourceLanguage: inputLanguage, targetLanguage: outputLanguage)
        DP_TranslateManager.shared.translator = Translator.translator(options: options)
        self.setDownloadDeleteButtonLabels()
        DP_TranslateManager.shared.translate(inputText: inputTextView.text) { [weak self] zerText in
            self?.outputTextView.text = zerText
        }
    }

    func textView(
      _ textView: UITextView, shouldChangeTextIn range: NSRange,
      replacementText text: String
    ) -> Bool {
      // Hide the keyboard when "Done" is pressed.
      // See: https://stackoverflow.com/questions/26600359/dismiss-keyboard-with-a-uitextview
      if text == "\n" {
        textView.resignFirstResponder()
        return false
      }
      return true
    }

    func textViewDidChange(_ textView: UITextView) {
        self.setDownloadDeleteButtonLabels()
        DP_TranslateManager.shared.translate(inputText: textView.text) { [weak self] zerText in
            self?.outputTextView.text = zerText
        }
    }

    // Make all text selected when the text view is activated for editing, so that the newly
    // input context will override the existing content.
    func textViewDidBeginEditing(_ textView: UITextView) {
      textView.selectedTextRange = textView.textRange(
        from: textView.beginningOfDocument, to: textView.endOfDocument)
    }
}
