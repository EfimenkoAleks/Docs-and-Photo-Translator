//
//  DP_ViewVithGradient.swift
//  Docs and Photo Translator
//
//  Created by Aleksandr on 24.07.2024.
//

import UIKit

class DP_ViewVithGradient: DP_BaseGradientView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        createView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        createView()
    }
    
    private func createView() {

        roundAllCorners(frame.width / 2)
    }
}
