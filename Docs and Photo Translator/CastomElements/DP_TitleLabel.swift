//
//  DP_TitleLabel.swift
//  Docs and Photo Translator
//
//  Created by Aleksandr on 19.06.2024.
//

import UIKit

final class DP_TitleLabel: UILabel {
    
    init(title: String, color: UIColor? = nil) {
        let frame: CGRect = CGRect(x: 0, y: 0, width: 250, height: 44)
        super.init(frame: frame)
        dp_setTitle(title: title, color: color)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
       
    }
    
    func dp_setTitle(title: String, color: UIColor? = nil) {
        text = title
        font = UIFont.systemFont(ofSize: 22, weight: .medium)
        textAlignment = .center
        textColor = .white
        if let color = color {
            textColor = color
        }
    }
}
