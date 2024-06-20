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
    
    func dp_getTextField(textField: String) {}
    
    func dp_deleteInAlert() {}

    @objc func dp_dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc func dp_didTapSetings() {}
    
//    @objc func sm_didTapTitle() {
//        let child = SM_CastViewController()
//        child.modalPresentationStyle = .fullScreen
//        child.isModalInPresentation = true
//        child.preferredContentSize = view.frame.size
//        self.present(child, animated: true)
//    }
    
    @objc func dp_backButtonAction() {
        navigationController?.popViewController(animated: true)
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
    
//    func sm_createTapTitle(_ title: String) {
//        customTitleLabel = DP_TitleLabel(title: title)
//        guard let customTitleLabel = customTitleLabel else { return }
//
//        let hStack = UIStackView(arrangedSubviews: [customTitleLabel])
//        hStack.alignment = .center
//        navigationItem.titleView = hStack
//        let tap = UITapGestureRecognizer(target: self, action: #selector(sm_didTapTitle))
//        navigationItem.titleView?.isUserInteractionEnabled = true
//        navigationItem.titleView?.addGestureRecognizer(tap)
//    }
    
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

        guard let buttonImage = UIImage(named: image) else { return }

        let navButton = UIBarButtonItem(image: buttonImage, style: .plain, target: self, action: action)
        
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
        let rightBarButtonItem = UIBarButtonItem.init(image: UIImage(named: "setings"), style: .plain, target: self, action: #selector(dp_didTapSetings))
        self.navigationItem.rightBarButtonItem = rightBarButtonItem
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
    
    func dp_showBottomSheet(title1: String, title2: String) {
      
        let actSheet = UIAlertController()
        let rename = UIAlertAction(title: title1, style: .default) { [weak self] _ in
            self?.dp_renameItem()
        }
        let delete = UIAlertAction(title: title2, style: .destructive) { [weak self] _ in
            self?.dp_deleteItem()
        }
        let cancel = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        
        let subview = (actSheet.view.subviews.first?.subviews.first?.subviews.first!)! as UIView
            subview.layer.cornerRadius = 1
        subview.backgroundColor = UIColor(hexString: "#252525").withAlphaComponent(0.9)
        
        actSheet.addAction(rename)
        actSheet.addAction(delete)
        actSheet.addAction(cancel)
        
        self.present(actSheet, animated: true, completion: nil)
    }
    
    func dp_renameItem() {
            let alControl = UIAlertController(title: "Rename", message: nil, preferredStyle: .alert)
        alControl.addTextField()

            let done = UIAlertAction(title: "Done", style: .default) { [weak self] _ in
                let answer = alControl.textFields![0]
                self?.dp_getTextField(textField: answer.text ?? "")
            }
            let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)

        alControl.addAction(done)
        alControl.addAction(cancel)

            present(alControl, animated: true)
    }
    
    func dp_deleteItem() {
        let actSheet = UIAlertController(title: "Are you sure you want to delete this draw?", message: nil, preferredStyle: .actionSheet)
    
        let delete = UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            self?.dp_deleteInAlert()
        }
        let cancel = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        
        let subview = (actSheet.view.subviews.first?.subviews.first?.subviews.first!)! as UIView
            subview.layer.cornerRadius = 1
        subview.backgroundColor = UIColor(hexString: "#252525").withAlphaComponent(0.9)
        
        actSheet.addAction(delete)
        actSheet.addAction(cancel)
        
        self.present(actSheet, animated: true, completion: nil)
    }
}
