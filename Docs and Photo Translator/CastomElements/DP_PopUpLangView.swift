//
//  DP_PopUpLangView.swift
//  Docs and Photo Translator
//
//  Created by Aleksandr on 23.07.2024.
//

import UIKit

class DP_PopUpLangView: DP_BaseGradientView {
    
    var changeButton: UIButton?
    
    init(frame: CGRect, firstText: String, secondText: String) {
        super.init(frame: frame)
        
        createView(firstText: firstText, secondText: secondText)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func createView(firstText: String, secondText: String) {

        changeButton = UIButton()
        changeButton?.isUserInteractionEnabled = true
        changeButton?.setImage(UIImage(named: "repeat"), for: .normal)
        changeButton?.backgroundColor = UIColor.clear
        changeButton?.translatesAutoresizingMaskIntoConstraints = false
        
        guard let changeButton = changeButton else { return }
        
        addSubview(changeButton)
        
        NSLayoutConstraint.activate([
            changeButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            changeButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            changeButton.heightAnchor.constraint(equalToConstant: 44),
            changeButton.widthAnchor.constraint(equalToConstant: 44)
        ])
       
        let firstLangLb = UILabel()
        firstLangLb.text = firstText
        firstLangLb.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
        firstLangLb.textColor = UIColor.black
        firstLangLb.backgroundColor = .clear
        firstLangLb.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(firstLangLb)
        NSLayoutConstraint.activate([
            firstLangLb.centerYAnchor.constraint(equalTo: centerYAnchor),
            firstLangLb.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 40)
        ])
        
        let secondLangLb = UILabel()
        secondLangLb.text = secondText
        secondLangLb.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
        secondLangLb.textColor = UIColor.black
        secondLangLb.backgroundColor = .clear
        secondLangLb.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(secondLangLb)
        NSLayoutConstraint.activate([
            secondLangLb.centerYAnchor.constraint(equalTo: centerYAnchor),
            secondLangLb.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -40)
        ])
        
        roundAllCornersWithBorders(9.0, borderColors: .darkGray, borderWith: 0.5)
    }
}
