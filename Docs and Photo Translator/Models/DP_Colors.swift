//
//  DP_Colors.swift
//  Docs and Photo Translator
//
//  Created by Aleksandr on 19.06.2024.
//

import UIKit

enum DP_Colors {
    case base
    case border
    case white
    case black
    case tabSelected
    case tabNoSelected
    case tabBar
    case blue
    case gradientTop
    case gradientBottom
    case blueColor
    case gradientItemTabBottom
}

extension DP_Colors {
    
    var color: UIColor {
        switch self {

        case .blueColor: return UIColor(hexString: "#0B4EFF")
        case .gradientItemTabBottom: return UIColor(hexString: "#3E73FF")
        case .gradientTop: return UIColor(hexString: "#FCFCFE")
        case .gradientBottom: return UIColor(hexString: "#A3BFF3")
        case .base: return UIColor(hexString: "#F2F2F7")
        case .border: return UIColor(hexString: "#700000")
        case .white: return UIColor(hexString: "#FFFFFF")
        case .black: return UIColor(hexString: "#000000")
        case .tabSelected: return UIColor(hexString: "#efeef9")
        case .tabNoSelected: return UIColor(hexString: "#43457f")
        case .tabBar: return UIColor(hexString: "#FFFFFF").withAlphaComponent(0.6)
        case .blue: return UIColor(hexString: "#0044FF")
        }
    }
}
