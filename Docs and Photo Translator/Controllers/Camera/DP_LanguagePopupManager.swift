//
//  DP_LanguagePopupManager.swift
//  Docs and Photo Translator
//
//  Created by Aleksandr on 30.07.2024.
//

import UIKit
import MLKitTranslate

final class DP_LanguagePopupManager: NSObject {
    
    private var view: UIView!
    private var popapView: DP_PopUpLangView?
    var isCreaded: Bool = false
    var eventHandler: Block<()>?
 //   private var action: Selector!
    
    init(view: UIView) {
    //    self.action = action
        self.view = view
        super.init()
        
    }
    
    func dp_createView(currentLang: TranslateLanguage?, originalLang: TranslateLanguage?) {
        if popapView == nil {
            let currentNameLang = DP_TranslateManager.shared.dp_getNameLang(lang: currentLang) ?? "non"
            let originalNameLang = DP_TranslateManager.shared.dp_getNameLang(lang: originalLang) ?? "non"
  
            popapView = DP_PopUpLangView(frame: CGRect(x: 20, y: view.safeAreaInsets.top + 20, width: view.bounds.width - 40, height: 42),
                                             firstText: originalNameLang,
                                             secondText: currentNameLang)
            guard let popapView = popapView else { return }
            view.addSubview(popapView)
           
            popapView.changeButton?.addTarget(self, action: #selector(dp_changeLang), for: .touchUpInside)
            
            UIView.animate(withDuration: 0.5, delay: 0.0) { [weak self] in
                guard let self = self,
                let popapView = self.popapView else { return }
                popapView.alpha = 1.0
            }
            isCreaded = true
        }
    }
    
    func dp_removePopapMenuView(_ duration: CGFloat = 0.5) {
        UIView.animate(withDuration: duration, delay: 0) { [weak self] in
            guard let self = self,
                    let popapView = self.popapView else { return }
            popapView.alpha = 0.0
        } completion: { [weak self] completion in
            guard let self = self,
                    let popapView = self.popapView else { return }
            if completion {
                popapView.removeFromSuperview()
                self.popapView = nil
                self.isCreaded = false
            }
        }
    }
    
    @objc func dp_changeLang() {
        eventHandler?(())
    }
}
