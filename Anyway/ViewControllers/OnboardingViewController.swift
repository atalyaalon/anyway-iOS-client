//
//  OnboardingViewController.swift
//  Anyway
//
//  Created by Yigal Omer on 02/10/2019.
//  Copyright © 2019 Hasadna. All rights reserved.
//

import UIKit

class OnboardingViewController: UIViewController {

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = true
        

    }
    
    @IBAction func onReportNowPressed(_ sender: AnyObject) {
        
        
        let reportIncidentViewController:ReportIncidentViewController = UIStoryboard.main.instantiateViewController(withIdentifier: "ReportIncidentViewController") as UIViewController as! ReportIncidentViewController
  
        // Vreate Main VC and main Module
        let mainViewController:MainViewController = UIStoryboard.main.instantiateViewController(withIdentifier: "MainViewController") as UIViewController as! MainViewController
        
         let mainViewModel = MainViewModel(viewController: mainViewController)
         mainViewController.mainViewModel = mainViewModel

        self.navigationController?.pushViewController(mainViewController, animated: false)
        
        //Set the delegate in order that if user pushes MAP it will be able to select a place, a delegate is exist
        reportIncidentViewController.delegate = mainViewController.mainViewModel as? ReportIncidentViewControllerDelegate
               
        
        self.navigationController?.pushViewController(reportIncidentViewController, animated: true)
        
    }
    
    @IBAction func onContinuePressed(_ sender: AnyObject) {
        
        let mainViewController:MainViewController = UIStoryboard.main.instantiateViewController(withIdentifier: "MainViewController") as UIViewController as! MainViewController
        
        let mainViewModel = MainViewModel(viewController: mainViewController)
        mainViewController.mainViewModel = mainViewModel
        self.navigationController?.pushViewController(mainViewController, animated: false)
        
    }
    
    
    
  

}
