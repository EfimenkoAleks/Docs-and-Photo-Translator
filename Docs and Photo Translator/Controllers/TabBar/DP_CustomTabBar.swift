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
    
    public lazy var dp_middleButton: UIButton! = {
        let dp_middleButton = UIButton(frame: CGRect(x: 0, y: 0, width: 56, height: 56))
        dp_middleButton.backgroundColor = DP_Colors.blue.color
        dp_middleButton.setImage(UIImage(systemName: "camera"), for: .normal)
        dp_middleButton.tintColor = .white
        dp_middleButton.layer.cornerRadius = dp_middleButton.frame.size.width / 2
        dp_middleButton.addTarget(self, action: #selector(self.middleButtonAction), for: .touchUpInside)

        self.addSubview(dp_middleButton)

        return dp_middleButton
    }()
    
    // MARK: - View Lifecycle

    override func layoutSubviews() {
        super.layoutSubviews()
        
        dp_middleButton.center = CGPoint(x: frame.width / 2, y: -5)
        self.tintColor = DP_Colors.tabSelected.color
        self.unselectedItemTintColor = DP_Colors.tabNoSelected.color
    }
    
    // MARK: - Actions
    @objc func middleButtonAction(sender: UIButton) {
        didTapButton?(())
    }
    
    // MARK: - HitTest
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        guard !clipsToBounds && !isHidden && alpha > 0 else { return nil }

        return self.dp_middleButton.frame.contains(point) ? self.dp_middleButton : super.hitTest(point, with: event)
    }
}
