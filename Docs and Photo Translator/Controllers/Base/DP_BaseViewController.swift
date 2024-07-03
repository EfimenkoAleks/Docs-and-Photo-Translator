//
//  DP_BaseViewController.swift
//  Docs and Photo Translator
//
//  Created by Aleksandr on 19.06.2024.
//

import UIKit

class DP_BaseViewController: UIViewController {
    
    var loader: DP_BaseLoader?
    var customTitleLabel: DP_TitleLabel?
    var isSmallBackButtonEnabled: Bool = true
    
    lazy var menuHandler: UIActionHandler = { [weak self] action in
        guard let self = self else { return }
        switch action.title {
        case "Select language":
            self.dp_choiseLang()
        case "Privacy Policy":
            self.dp_privacyPolicy()
        default:
            break
        }
    }
    
    init() {
        super.init(nibName: nil, bundle: nil)
        
        dp_setBackground()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dp_setupNavigationBar()
        //      sm_hideKeyboardWhenTappedAround()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        dp_setSmallBackButton()
    }
    
    func dp_choiseLang() {}
    func dp_privacyPolicy() {}
    
    func dp_getTextField(textField: String) {}
    
    func dp_deleteInAlert() {}
    
    @objc func dp_dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc func dp_didTapSetings() {}
 
    @objc func dp_backButtonAction() {
        //    navigationController?.popViewController(animated: true)
    }
    
    @objc func dp_didTapRightNavButton() {}
    
    @objc func dp_didTapCastButton() {}
    
    @objc func dp_didTapAirPlayButton() {}
    
    func dp_setBackground() {
        self.view.backgroundColor = DP_Colors.base.color
    }
    
    func dp_createTitle(_ title: String) {
        navigationItem.titleView = DP_TitleLabel(title: title)
    }
    
    func dp_createMenu() {
        let barButtonMenu = UIMenu(title: "", children: [
            UIAction(title: NSLocalizedString("Select language", comment: ""), image: UIImage(systemName: "list.bullet.rectangle.portrait"), handler: menuHandler),
            UIAction(title: NSLocalizedString("Privacy Policy", comment: ""), image: UIImage(systemName: "lock.shield"), handler: menuHandler),
        ])
        let navButton = UIBarButtonItem(title: "Menu", style: .plain, target: self, action: nil)
        navButton.tintColor = .white
        
        navigationItem.rightBarButtonItem = navButton
        navigationItem.rightBarButtonItem?.menu = barButtonMenu
    }
    
    private func dp_setSmallBackButton() {
        if isSmallBackButtonEnabled {
            var backButton: UIButton {
                let button = UIButton()
                let image = UIImageView()
                image.image = UIImage(named: "arrovBack")
                image.contentMode = .center
                button.widthAnchor.constraint(equalToConstant: 30).isActive = true
                button.heightAnchor.constraint(equalToConstant: 30).isActive = true
                button.setImage(image.image, for: .normal)
                button.addTarget(self, action: #selector(dp_backButtonAction), for: .touchUpInside)
                return button
            }
            
            navigationItem.setLeftBarButton(UIBarButtonItem(customView: backButton), animated: false)
        }
    }
    
    func dp_createRightNavBarItems(image: String, action: Selector) {
        
        guard let buttonImage = UIImage(systemName: image)?.withRenderingMode(.alwaysTemplate) else { return }
        
        let navButton = UIBarButtonItem(image: buttonImage, style: .plain, target: self, action: action)
        navButton.tintColor = .white
        
        if self.navigationItem.rightBarButtonItems == nil {
            self.navigationItem.setRightBarButtonItems([navButton], animated: true)
        } else {
            self.navigationItem.rightBarButtonItems?.append(navButton)
        }
    }
    
    func dp_createRightNavBarItemWithText(title: String, hightFont: CGFloat, color: UIColor = .white) {
        let font = UIFont.systemFont(ofSize: hightFont, weight: .medium)
        let style = UINavigationBarAppearance()
        style.buttonAppearance.normal.titleTextAttributes = [.font: font]
        navigationItem.standardAppearance = style
        let rightBarButtonItem = UIBarButtonItem.init(title: title, style: .plain, target: self, action: #selector(dp_didTapRightNavButton))
        rightBarButtonItem.tintColor = color
        navigationItem.rightBarButtonItem = rightBarButtonItem
    }
    
    func dp_addLoader() {
        let frame = UIScreen.main.bounds
        loader = DP_BaseLoader(frame: CGRect(x: 0, y: 44, width: frame.width, height: frame.height))
        
        guard let loader = loader else { return }
        view.addSubview(loader)
    }
    
    func dp_removeLoader() {
        loader?.removeFromSuperview()
    }
    
    func dp_createRightNavBarItemWithImage(imageName: String) {
        let rightBarButtonItem = UIBarButtonItem.init(image: UIImage(named: imageName), style: .plain, target: self, action: #selector(dp_didTapRightNavButton))
        self.navigationItem.rightBarButtonItem = rightBarButtonItem
    }
    
    func dp_createRightSetingsNavBarItem() {
        let img =  UIImage(systemName:  "line.3.horizontal")?.withRenderingMode(.alwaysTemplate)
        let rightBarButtonItem = UIBarButtonItem.init(image: img, style: .plain, target: self, action: #selector(dp_didTapSetings))
        rightBarButtonItem.tintColor = .white
        
        self.navigationItem.leftBarButtonItem = rightBarButtonItem
    }
    
    func dp_presentAlert(title: String = "", message: String = "") {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel))
        self.present(alert, animated: true)
    }
    
    private func dp_setupNavigationBar() {
        
        let appearence = UINavigationBarAppearance()
        appearence.backgroundColor = .white
        appearence.titleTextAttributes = [
            NSAttributedString.Key.foregroundColor : UIColor.white,
            NSAttributedString.Key.font : UIFont.systemFont(ofSize: 22, weight: .semibold)]
        
        navigationController?.navigationBar.scrollEdgeAppearance = appearence
        navigationController?.navigationBar.standardAppearance = appearence
        
        navigationController?.navigationBar.tintColor = UIColor.white
        //    self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
    }
    
    func dp_hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dp_dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
}
