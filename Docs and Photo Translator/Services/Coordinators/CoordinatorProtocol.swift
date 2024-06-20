//
//  CoordinatorProtocol.swift
//  Docs and Photo Translator
//
//  Created by Aleksandr on 19.06.2024.
//

import UIKit

protocol DP_Coordinator {
    var navigationController: UINavigationController? { get set }
    var cildren: [DP_Coordinator] { get set }
}
