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
    case tabSelected
    case tabNoSelected
    case tabBar
    case blue
}

extension DP_Colors {
    
    var color: UIColor {
        switch self {

        case .base: return UIColor(hexString: "#272c49")
        case .border: return UIColor(hexString: "#700000")
        case .white: return UIColor(hexString: "#FFFFFF")
        case .tabSelected: return UIColor(hexString: "#efeef9")
        case .tabNoSelected: return UIColor(hexString: "#43457f")
        case .tabBar: return UIColor(hexString: "#24283c")
        case .blue: return UIColor(hexString: "#0044FF")
        }
    }
}
