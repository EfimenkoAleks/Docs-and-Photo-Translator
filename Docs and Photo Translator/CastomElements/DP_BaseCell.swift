//
//  DP_BaseCell.swift
//  Docs and Photo Translator
//
//  Created by Aleksandr on 24.06.2024.
//

import UIKit

class DP_BaseCell: UIView {
    
    override init (frame : CGRect) {
        super.init(frame : frame)
        
        addBehavior(radius: 16, corners: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        addBehavior(radius: 16, corners: nil)
    }
    
    func addBehavior(radius: CGFloat? = nil, corners: CACornerMask? = nil) {
        backgroundColor = DP_Colors.white.color.withAlphaComponent(0.1)
      
        if let radius = radius {
            layer.cornerRadius = radius
        }
        if let corners = corners {
            layer.maskedCorners = corners
        }
        layer.masksToBounds = true
    }
    
    func clearBehavior() {
        backgroundColor = UIColor.clear
        layer.borderColor = UIColor.clear.cgColor
    }
}
