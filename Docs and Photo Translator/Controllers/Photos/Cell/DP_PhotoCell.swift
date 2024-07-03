//
//  DP_PhotoCell.swift
//  Docs and Photo Translator
//
//  Created by Aleksandr on 24.06.2024.
//

import UIKit
import MLKitTranslate

class DP_PhotoCell: UITableViewCell, ReusableCell {

    @IBOutlet private weak var photoImage: UIImageView!
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var dateLabel: UILabel!
    @IBOutlet private weak var containerView: DP_BaseCell!
    
    func dp_configure(model: DP_PhotoModel) {
        dateLabel.text = model.date
  
        do {
            let data = try Data(contentsOf: model.path)
            photoImage.image = UIImage(data: data)
        } catch {
            photoImage.image = UIImage(named: "defaultPhoto")
        }
  
        DP_TranslateManager.shared.dp_translateTag { [weak self] rezText in
            self?.nameLabel.text = "to \(rezText)"
        }
    }
}
