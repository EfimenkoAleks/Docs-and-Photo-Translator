//
//  DP_TabBarItem.swift
//  Docs and Photo Translator
//
//  Created by Aleksandr on 19.06.2024.
//

import UIKit

class DP_TabBarItem: UITabBarItem {
    
    override init() {
        super.init()
    }
    
    convenience init(inTitle: String, inImage: String, inSelectedImage: String, inTag: Int) {
        
        self.init()
        title = inTitle
        image = UIImage(named: inImage)
        selectedImage = UIImage(named: inSelectedImage)
        tag = inTag
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
