//
//  DP_BaseLoader.swift
//  Docs and Photo Translator
//
//  Created by Aleksandr on 19.06.2024.
//

import UIKit

final class DP_BaseLoader: UIView {
    
    var louder: UIActivityIndicatorView?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        dp_createView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func dp_createView() {
        let popapView = UIView()
        popapView.backgroundColor = .black.withAlphaComponent(0.8)
        popapView.alpha = 1
        popapView.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(popapView)
        NSLayoutConstraint.activate([
            popapView.leadingAnchor.constraint(equalTo: leadingAnchor),
            popapView.trailingAnchor.constraint(equalTo: trailingAnchor),
            popapView.topAnchor.constraint(equalTo: topAnchor),
            popapView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        louder = UIActivityIndicatorView(style: .large)
        louder?.translatesAutoresizingMaskIntoConstraints = false
        
        guard let louder = louder else { return }
        popapView.addSubview(louder)
        NSLayoutConstraint.activate([
            louder.centerYAnchor.constraint(equalTo: popapView.centerYAnchor, constant: -50),
            louder.centerXAnchor.constraint(equalTo: popapView.centerXAnchor)
        ])
        louder.startAnimating()
    }
}
