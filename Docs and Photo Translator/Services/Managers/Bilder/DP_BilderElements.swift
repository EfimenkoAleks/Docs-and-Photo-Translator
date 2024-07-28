//
//  DP_BilderElements.swift
//  Docs and Photo Translator
//
//  Created by Aleksandr on 24.07.2024.
//

import UIKit

class DP_BilderElements {
    
    static let shared: DP_BilderElements = DP_BilderElements()
   
    func dp_buttonWithImage(_ image: String) -> UIButton {
        let button = UIButton()
        button.isUserInteractionEnabled = true
        button.setImage(UIImage(named: image), for: .normal)
        button.backgroundColor = UIColor.clear
        button.translatesAutoresizingMaskIntoConstraints = false
        
        return button
    }
    
    func dp_imageView() -> UIImageView {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        view.backgroundColor = UIColor.clear
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }
}
