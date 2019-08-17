//
//  LanguageViewController.swift
//  Anyway
//
//  Created by Aviel Gross on 1/25/16.
//  Copyright © 2016 Hasadna. All rights reserved.
//

import UIKit
import MaterialComponents.MaterialButtons

class LanguageViewController: UIViewController {

    @IBOutlet weak var closeButton: MDCFlatButton!
    static let segueFromSplit = "choose language segue"

    override func viewDidLoad() {
        super.viewDidLoad()
        closeButton.setTitle("CLOSE".localized, for: UIControl.State.normal)
        
    }

    @IBAction func closeTapped(_ sender: Any) {
        dismiss(animated: true) { }
    }
    
    @IBAction func actionLanguage(_ sender: UIButton) {
        defer{
            presentingViewController?.dismiss(animated: true, completion: nil)
        }
        
        guard let title = sender.titleLabel?.text
            else {return}
        
        switch title.lowercased() {
            case "עברית": ManualLocalizationWorker.currentLocal = AppLocal.Hebrew
            case "english": fallthrough
            default: ManualLocalizationWorker.currentLocal = AppLocal.English
        }
        
    }

}
