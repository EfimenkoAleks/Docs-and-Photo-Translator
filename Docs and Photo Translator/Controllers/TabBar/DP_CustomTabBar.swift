//
//  DP_CustomTabBar.swift
//  Docs and Photo Translator
//
//  Created by Aleksandr on 19.06.2024.
//

import UIKit

class SM_CustomTabBar: UITabBar {
    
    // MARK: - Variables
    var didTapButton: Block<()>?
    var tabAppearance: Block<()>?
    
    override var frame: CGRect {
        didSet {
            if frame != .zero {
                tabAppearance?(())
            }
        }
    }
    
    // MARK: - View Lifecycle

    override func layoutSubviews() {
        super.layoutSubviews()
 
        tintColor = DP_Colors.white.color
        unselectedItemTintColor = DP_Colors.black.color
      
        let image = UIImage.imageWithGradient(from: DP_Colors.blueColor.color,
                                              to: DP_Colors.gradientItemTabBottom.color,
                                              with: CGRect(x: 0, y: 0, width: 44, height: 44))
        selectionIndicatorImage = image.withRoundedCorners(radius: 22)
    }
    
    func dp_setGradient(frame: CGRect) -> CAGradientLayer {
        let colorTop =  DP_Colors.gradientTop.color.cgColor
        let colorBottom = DP_Colors.gradientBottom.color.cgColor
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [colorTop, colorBottom]
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 0.0, y: 0.5)
      //  let screen = UIScreen.main.bounds
        gradientLayer.frame = frame
        
        return gradientLayer
 //       self.view.layer.insertSublayer(gradientLayer, at:0)
    }
    
    // MARK: - Actions
    @objc func middleButtonAction(sender: UIButton) {
        didTapButton?(())
    }
}
