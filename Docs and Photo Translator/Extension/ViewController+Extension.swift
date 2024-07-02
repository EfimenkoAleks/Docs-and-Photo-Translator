//
//  ViewController+Extension.swift
//  Docs and Photo Translator
//
//  Created by Aleksandr on 02.07.2024.
//

import UIKit

extension UIViewController {
        
  func removeChild() {
    self.children.forEach {
      $0.willMove(toParent: nil)
      $0.view.removeFromSuperview()
      $0.removeFromParent()
    }
  }
}
