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
 
        let screen = UIScreen.main.bounds
        let view = DP_BaseGradientView(frame: CGRect(x: 0, y: 0, width: screen.width, height: 120))
        insertSubview(view, at: 0)
        tintColor = DP_Colors.white.color
        unselectedItemTintColor = DP_Colors.black.color
      
        let image = UIImage.imageWithGradient(from: DP_Colors.blueColor.color,
                                              to: DP_Colors.gradientItemTabBottom.color,
                                              with: CGRect(x: 0, y: 0, width: 44, height: 44))
        selectionIndicatorImage = image.withRoundedCorners(radius: 22)
    }
    
    // MARK: - Actions
    @objc func middleButtonAction(sender: UIButton) {
        didTapButton?(())
    }
}
