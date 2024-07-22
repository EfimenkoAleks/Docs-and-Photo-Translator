//
//  DP_ChoiceLangManager.swift
//  Docs and Photo Translator
//
//  Created by Aleksandr on 02.07.2024.
//

import UIKit
import MLKitTranslate

typealias DP_ChoiceLangManagerExtension = DP_ChoiceLangManager

class DP_ChoiceLangManager: NSObject {
    
  //  var eventHandler: Block<()>?
    private var picker: UIPickerView
   
    init(_ picker: UIPickerView) {

        self.picker = picker
        super.init()
      
        picker.dataSource = self
        picker.delegate = self

        dp_choice()
        picker.setValue(DP_Colors.black.color, forKeyPath: "textColor")
    }
}

extension DP_ChoiceLangManagerExtension {
    
    func dp_choice() {
        if let language = DP_TranslateManager.shared.currentLanguages {
            picker.selectRow(
             DP_TranslateManager.shared.allLanguages.firstIndex(of: language) ?? 0, inComponent: 0, animated: false)
        } else {
            picker.selectRow(
             DP_TranslateManager.shared.allLanguages.firstIndex(of: TranslateLanguage.english) ?? 0, inComponent: 0, animated: false)
        }
    }
}

extension DP_ChoiceLangManagerExtension: UIPickerViewDataSource, UIPickerViewDelegate {
    
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
   //     let inputLanguage = DP_TranslateManager.shared.allLanguages[picker.selectedRow(inComponent: 0)]
   //     DP_TranslateManager.shared.currentLanguages = inputLanguage
    }
}
