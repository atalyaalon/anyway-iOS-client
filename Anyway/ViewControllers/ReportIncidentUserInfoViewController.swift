//
//  ReportIncidentUserInfoViewController.swift
//  Anyway
//
//  Created by Yigal Omer on 03/10/2019.
//  Copyright © 2019 Hasadna. All rights reserved.
//

import UIKit
import Eureka

class ReportIncidentUserInfoViewController: FormViewController {

    private var firstName: String?
    private var lastName: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //self.navigationController?.isNavigationBarHidden = false

        setupForm()
    }
    internal func setupForm() {

          form += [userSection()]
      }
      
      
      
      fileprivate func userSection() -> Section {
              
          return Section("פרטים אישיים")
            
            
                       <<< TextRow(){ row in
                           row.title = "שם פרטי"
                           row.placeholder = "הכנס שם פרטי"
                       }
                       <<< PhoneRow(){
                           $0.title = "שם משפחה"
                           $0.placeholder = "And numbers here"
                      }
//
//          <<< DateInlineRow() {
//              $0.title = local("FILTER_ROW_date_start")
//             // $0.value = filter.startDate
//          }.onChange{ [weak self] row in
//              guard let d = row.value else {return}
//              //self?.filter.startDate = d
//          }
//
//          <<< DateInlineRow() {
//              $0.title = local("FILTER_ROW_date_end")
//             // $0.value = filter.endDate
//          }.onChange{ [weak self] row in
//              guard let d = row.value else {return}
//              //self?.filter.endDate = d
//          }
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
