//
//  InfoViewController.swift
//  Anyway
//
//  Created by Aviel Gross on 4/27/15.
//  Copyright (c) 2015 Hasadna. All rights reserved.
//

import UIKit
import MaterialComponents.MaterialButtons

class InfoViewController: UIViewController {

    @IBOutlet weak var langButton: MDCFlatButton!
    @IBOutlet weak var infoLabelText: UILabel! {
        didSet{
            infoLabelText.text = infoLabelText.text?.stringByForcingWritingDirectionRTL()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        langButton.setTitle("LANGUAGE".localized, for: UIControl.State.normal)
        infoLabelText.text = "ANYWAY_TEXT".localized
    }
    
    @IBAction func dismissAction() {
        //dismiss(animated: true) { }
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func moroInfoLinkAction() {
        
    }
    
}
