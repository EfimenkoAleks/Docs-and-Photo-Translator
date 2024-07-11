//
//  DP_TextPicker.swift
//  Docs and Photo Translator
//
//  Created by Aleksandr on 11.07.2024.
//

import UIKit
import MLKitTranslate

typealias DP_TextPickerExtension = DP_TextPicker

class DP_TextPicker: NSObject {
    
    var eventHandler: Block<(TranslateLanguage, TranslateLanguage)>?
    private var inputPicker: UIPickerView
    private var outputPicker: UIPickerView
   
    init(inputPicker: UIPickerView, outputPicker: UIPickerView) {

        self.inputPicker = inputPicker
        self.outputPicker = outputPicker
        super.init()

        dp_choice()
    }
}

extension DP_TextPickerExtension {
    
    func dp_reset() {
        pickerView(inputPicker, didSelectRow: 0, inComponent: 0)
    }
    
    func dp_choice() {
        inputPicker.dataSource = self
        outputPicker.dataSource = self
        inputPicker.selectRow(
         DP_TranslateManager.shared.allLanguages.firstIndex(of: TranslateLanguage.english) ?? 0, inComponent: 0, animated: false)
        outputPicker.selectRow(
         DP_TranslateManager.shared.allLanguages.firstIndex(of: DP_TranslateManager.shared.currentLanguages ?? TranslateLanguage.english) ?? 0, inComponent: 0, animated: false)
        inputPicker.delegate = self
        outputPicker.delegate = self
        pickerView(inputPicker, didSelectRow: 0, inComponent: 0)
//        setDownloadDeleteButtonLabels()
    }
}

extension DP_TextPickerExtension: UIPickerViewDataSource, UIPickerViewDelegate {
    
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
        eventHandler?((inputLanguage, outputLanguage))
//      self.setDownloadDeleteButtonLabels()
//        DP_TranslateManager.shared.setOptionTranslate(inputLang: inputLanguage, outputLang: outputLanguage)
//        self.setDownloadDeleteButtonLabels()
//        DP_TranslateManager.shared.translate(inputText: inputTextView.text) { [weak self] zerText in
//            self?.outputTextView.text = zerText
//        }
    }
}
