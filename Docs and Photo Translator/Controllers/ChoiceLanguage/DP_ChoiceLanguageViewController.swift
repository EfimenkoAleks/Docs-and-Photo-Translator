//
//  DP_ChoiceLanguageViewController.swift
//  Docs and Photo Translator
//
//  Created by Aleksandr on 02.07.2024.
//

import UIKit

typealias DP_ChoiceLanguageViewControllerExtension = DP_ChoiceLanguageViewController

class DP_ChoiceLanguageViewController: DP_BaseViewController {

    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var languagePicker: UIPickerView!
    
    var eventHandlerBack: Block<()>?
    private var manager: DP_ChoiceLangManager?
    private var helper: DP_ChoiceLangHelper = DP_ChoiceLangHelper()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        dp_configureUI()
        dp_createManager()
    }

    @IBAction func sm_didTapBackButton(_ sender: UIButton) {
        dp_checkDefaultLanguage()
        dp_dismiss()
        eventHandlerBack?(())
    }
}

private extension DP_ChoiceLanguageViewControllerExtension {
    
    func dp_configureUI() {
        nameLabel.text = "Select language for translation"
    }
    
    func dp_createManager() {
        manager = DP_ChoiceLangManager(languagePicker)
    }
    
    func dp_dismiss() {
        self.dismiss(animated: true)
    }
    
    func dp_checkDefaultLanguage() {
        if DP_TranslateManager.shared.currentLanguages == nil {
            DP_TranslateManager.shared.currentLanguages = .english
        }
        helper.dp_setStartLang(DP_TranslateManager.shared.currentLanguages?.rawValue ?? "")
    }
}
