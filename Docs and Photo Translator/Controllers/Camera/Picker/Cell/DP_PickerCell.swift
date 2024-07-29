//
//  DP_PickerCell.swift
//  Docs and Photo Translator
//
//  Created by Aleksandr on 28.07.2024.
//

import UIKit

class DP_PickerCell: UICollectionViewCell, ReusableCell {

    @IBOutlet private weak var image: UIImageView!
    @IBOutlet private weak var blueView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    
        blueView.layer.cornerRadius = blueView.frame.width / 2
        blueView.layer.masksToBounds = true
        
        image.layer.cornerRadius = 8
        image.layer.masksToBounds = true
    }

    func sm_configure(_ model: DP_Pickture) {
        do {
            guard let icon = model.image else { return }
            let data = try Data(contentsOf: icon)
            image.image = UIImage(data: data)
        } catch {
            image.image = UIImage(named: "defaultPhoto")
        }
        blueView.isHidden = !model.isSelected
    }
}
