//
//  CoordinatorProtocol.swift
//  Docs and Photo Translator
//
//  Created by Aleksandr on 19.06.2024.
//

import UIKit

protocol Coordinator {
    var navigationController: UINavigationController? { get set }
    var cildren: [Coordinator] { get set }
}
