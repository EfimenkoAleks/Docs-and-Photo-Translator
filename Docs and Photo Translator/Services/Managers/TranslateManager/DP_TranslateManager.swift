//
//  DP_TranslateManager.swift
//  Docs and Photo Translator
//
//  Created by Aleksandr on 26.06.2024.
//

import UIKit
import MLKitTranslate
import MLKitLanguageID

enum TranslateLangEvents {
    case success(String)
    case noLanguage
}

final class DP_TranslateManager: NSObject {
    
    static let shared: DP_TranslateManager = DP_TranslateManager()
    
    var languages: [TranslateLanguage] = []
    var currentLanguages: TranslateLanguage?
    var originalLanguages: TranslateLanguage?
    private var preferens: DP_PreferencesProtocol = DP_Preferences()
    
     var translator: Translator!
     let locale = Locale.current
     lazy var allLanguages = TranslateLanguage.allLanguages().sorted {
       return locale.localizedString(forLanguageCode: $0.rawValue)!
         < locale.localizedString(forLanguageCode: $1.rawValue)!
     }
    
    override init() {
        super.init()
        
        guard let lang = preferens.dp_getStartLang() else { return }
        currentLanguages = TranslateLanguage(rawValue: lang)
    }
    
    func setOptionTranslate(inputLang: TranslateLanguage, outputLang: TranslateLanguage) {
        let options = TranslatorOptions(sourceLanguage: inputLang, targetLanguage: outputLang)
          DP_TranslateManager.shared.translator = Translator.translator(options: options)
    }
    
    func dp_identityLanguage(text: String, completion: @escaping (String?) -> Void) {
        let text2 = text.removingCharacters(inCharacterSet: CharacterSet.punctuationCharacters)
        let option = LanguageIdentificationOptions(confidenceThreshold: 0.7)
        let languageId = LanguageIdentification.languageIdentification(options: option)

        languageId.identifyPossibleLanguages(for: text2) { (identifiedLanguages, error) in
          if let error = error {
            print("Failed with error: \(error)")
            return
          }
          guard let identifiedLanguages = identifiedLanguages,
            !identifiedLanguages.isEmpty,
                identifiedLanguages[0].languageTag != "und"
          else {
            print("No language was identified")
              completion(nil)
            return
          }

           
          print("Identified Languages:\n" +
            identifiedLanguages.map {
              String(format: "(%@, %.2f)", $0.languageTag, $0.confidence)
              }.joined(separator: "\n"))
            completion(identifiedLanguages[0].languageTag)
        }
    }
    
    func getText(_ text: String, originalLanguage: TranslateLanguage = .english, completion: @escaping (TranslateLangEvents) -> Void) {
        
        let text2 = text.removingCharacters(inCharacterSet: CharacterSet.punctuationCharacters)
        
//        identityLanguage(text: text2) { [weak self] rez in
            guard //let self = self,
            //      let tegLanguage = rez,
                  let currentLang = self.currentLanguages else { return }
     
    
            let inputLanguage = originalLanguage //TranslateLanguage(rawValue: tegLanguage)
            
            guard self.isLanguageDownloaded(currentLang) else { return }
            
            guard self.isLanguageDownloaded(inputLanguage) else {
                completion(.noLanguage)
                return
            }
                
                self.setOptionTranslate(inputLang: inputLanguage, outputLang: currentLang)
              
                self.translate(inputText: text2) { rezText in
                    completion(.success(rezText))
                }
            
     //   }
    }
    
    func dp_getNameLang(lang: TranslateLanguage?) -> String? {
        guard let curLang = lang,
              let textTag = Locale.current.localizedString(forLanguageCode: curLang.rawValue) else { return nil }
        
        return textTag
    }
    
    func dp_translateTag(lang: TranslateLanguage?, completion: @escaping (String) -> Void) {
        guard let curLang = lang,
              let textTag = Locale.current.localizedString(forLanguageCode: curLang.rawValue) else { return }
         
        
        getText(textTag) { rez in
            switch rez {
            case.success(let text):
                completion(text)
                
            case .noLanguage:
                completion("")
            }
        }
    }


     func model(forLanguage: TranslateLanguage) -> TranslateRemoteModel {
       return TranslateRemoteModel.translateRemoteModel(language: forLanguage)
     }

     func isLanguageDownloaded(_ language: TranslateLanguage) -> Bool {
       let model = self.model(forLanguage: language)
       let modelManager = ModelManager.modelManager()
       return modelManager.isModelDownloaded(model)
     }

    func translate(inputText: String, completion: @escaping (String) -> Void) {
         
         guard let translatorForDownloading = self.translator else { return }

       translatorForDownloading.downloadModelIfNeeded { error in
         guard error == nil else {
             return completion("Failed to ensure model downloaded with error \(error!)")
         }
    //     self.setDownloadDeleteButtonLabels()
         if translatorForDownloading == self.translator {
           translatorForDownloading.translate(inputText) { result, error in
             guard error == nil else {
                 completion("Failed with error \(error!)")
               return
             }
             if translatorForDownloading == self.translator {
                 completion(result ?? "Failed with error")
             }
           }
         }
       }
     }

    func dp_downloadModel(language: TranslateLanguage, completion: @escaping () -> Void) {
        let model = model(forLanguage: language)
        let modelManager = ModelManager.modelManager()
        modelManager.deleteDownloadedModel(model) { error in
            completion()
        }
    }
    
    func dp_deletedModel(language: TranslateLanguage) {
        let model = model(forLanguage: language)
        let modelManager = ModelManager.modelManager()
        let conditions = ModelDownloadConditions(
          allowsCellularAccess: true,
          allowsBackgroundDownloading: true
        )
        modelManager.download(model, conditions: conditions)
    }
}
