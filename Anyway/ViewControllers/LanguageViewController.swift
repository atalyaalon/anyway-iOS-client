//
//  LanguageViewController.swift
//  Anyway
//
//  Created by Aviel Gross on 1/25/16.
//  Copyright © 2016 Hasadna. All rights reserved.
//

import UIKit

class LanguageViewController: UIViewController {

    static let segueFromSplit = "choose language segue"
    
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
