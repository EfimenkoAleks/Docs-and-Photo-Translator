//
//  DP_PolicyViewController.swift
//  Docs and Photo Translator
//
//  Created by Aleksandr on 03.07.2024.
//

import UIKit
import WebKit

struct DP_PolisityModel {
    var title: String
    var url: URL
}

class DP_PolicyViewController: DP_BaseViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var webView: WKWebView!
    private var url: URL
    private var titleLb: String
    
    init(model: DP_PolisityModel) {
        self.url = model.url
        titleLb = model.title
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleLabel.text = titleLb
        let myRequest = URLRequest(url: url)
        webView.load(myRequest)
    }

    @IBAction func dpDidTapDismiss(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}
