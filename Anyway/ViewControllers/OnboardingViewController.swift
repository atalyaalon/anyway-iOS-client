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
        
        
        let ReportIncidentViewController:ReportIncidentViewController = UIStoryboard.main.instantiateViewController(withIdentifier: "ReportIncidentViewController") as UIViewController as! ReportIncidentViewController
  
        let MainViewController:MainViewController = UIStoryboard.main.instantiateViewController(withIdentifier: "MainViewController") as UIViewController as! MainViewController

        self.navigationController!.pushViewController(MainViewController, animated: false)
          
        self.navigationController!.pushViewController(ReportIncidentViewController, animated: true)
        
        
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
