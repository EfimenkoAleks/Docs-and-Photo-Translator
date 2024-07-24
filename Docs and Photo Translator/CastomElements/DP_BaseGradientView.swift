//
//  DP_BaseGradientView.swift
//  Docs and Photo Translator
//
//  Created by Aleksandr on 24.07.2024.
//

import UIKit

class DP_BaseGradientView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        createView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        createView()
    }
    
    private func createView() {
        
        setGradient(colorTop: UIColor(hexString: "#FCFCFE"), colorBottom: UIColor(hexString: "#A3BFF3"), frame: CGRect(x: 0, y: 0, width: frame.width, height: frame.height))
        
                let popapView = UIView()
        popapView.backgroundColor = .white.withAlphaComponent(0.6)
                popapView.translatesAutoresizingMaskIntoConstraints = false

                addSubview(popapView)
                NSLayoutConstraint.activate([
                    popapView.centerXAnchor.constraint(equalTo: centerXAnchor),
                    popapView.centerYAnchor.constraint(equalTo: centerYAnchor),
                    popapView.heightAnchor.constraint(equalToConstant: frame.height),
                    popapView.widthAnchor.constraint(equalToConstant: frame.width)
                ])
    }
}
