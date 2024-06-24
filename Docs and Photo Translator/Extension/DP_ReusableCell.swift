//
//  DP_ReusableCell.swift
//  Docs and Photo Translator
//
//  Created by Aleksandr on 24.06.2024.
//

import UIKit

typealias DP_ReusableCell = ReusableCell

protocol ReusableCell {
    static var nib: UINib { get }
}

extension DP_ReusableCell {
    static var nib: UINib {
        return UINib(nibName: String(describing: self), bundle: nil)
    }
}

