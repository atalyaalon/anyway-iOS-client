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
    private var sendToMonicipality: Bool?
    private var id: String?
    private var email: String?
    private var phoneNumber: String?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //self.navigationController?.isNavigationBarHidden = false

        setupForm()
    }
    internal func setupForm() {

        navigationOptions = RowNavigationOptions.Disabled
        //form += [userSection()]
         userSection()
    }
      
      
 
      
    private func userSection() {// -> Section {
        
        // return Section("פרטים אישיים")
        //return Section("")
        form +++ Section("")
            <<< SwitchRow("report") {
                $0.title = "דווח לרשות העירונית"
                $0.value = false
            }.onChange{ [weak self] row in
                guard let sendToMonicipality = row.value else {return}
                self?.sendToMonicipality = sendToMonicipality
                
                self?.setAllCelltextColorAccordingtoSwitch()
                //self?.tableView.reloadData()
            }
            
            
            
            <<< TextRow("firstName"){ row in
                row.title = "שם פרטי"
                row.add(rule: RuleRequired())
                //row.placeholder = "הכנס שם פרטי  "
            }.onChange{ [weak self] row in
                guard let firstName = row.value else {return}
                self?.firstName = firstName
            }
            <<< TextRow("lastName"){row in
                row.title = "שם משפחה"
                row.add(rule: RuleRequired())
                // $0.placeholder = "הכנס שם משפחה  "
            }.onChange{ [weak self] row in
                guard let lastName = row.value else {return}
                self?.lastName = lastName
            }
            
            <<< PhoneRow("id"){
                $0.title = "תעודת זהות"
                $0.add(rule: RuleRequired())
                //$0.placeholder = "הכנס תעודת זהות"
            }.onChange{ [weak self] row in
                guard let id = row.value else {return}
                self?.id = id
            }
            
            <<< EmailRow("email"){
                $0.title = "דואר אלקטרוני"
                $0.add(rule: RuleRequired())
                //$0.placeholder = "הכנס דואר אלטרוני  "
            }.onChange{ [weak self] row in
                guard let email = row.value else {return}
                self?.email = email
            }
            <<< PhoneRow("phone"){
                $0.title = "מספר טלפון"
                $0.add(rule: RuleRequired())
                //$0.placeholder = "הכנס מספר טלפון"
            }.onChange{ [weak self] row in
                guard let phoneNumber = row.value else {return}
                self?.phoneNumber = phoneNumber
            }
            
            
            //
            //                        +++ Section("שלח את פרטי המפגע") { section in
            //                               section.header?.height = { 40 }
            //                               section.footer?.height = { 40 }
            //                           }
            +++ Section("") { section in
                section.header?.height = { 50 }
                section.footer?.height = { 40 }
            }
            
            <<< ButtonRow(){ row in
                row.title = "שלח"
                
                
                // $0.disabled =  Condition.function( $0.section?.form?.validate().count == 0)
                row.cellUpdate { cell, row in
                    cell.textLabel?.textColor = UIColor.white
                    cell.backgroundColor =  UIColor.init(hexString: "3764BC")
                    //                                let count = row.section?.form?.validate().count
                    print ( " in cellUpdate -   row.isDisabled  = \( row.isDisabled )" )
                    cell.backgroundColor = row.isDisabled ? UIColor.lightGray : UIColor.init(hexString: "3764BC")
                    //                                if  !(self.sendToMonicipality ?? false ){
                    //                                         // print ( "in cellUpdate - count = \(count) \(self.sendToMonicipality)"
                    //                                    cell.backgroundColor = UIColor.init(hexString: "3764BC")
                    //                                }else if count != 0 &&  self.sendToMonicipality ?? false {
                    //                                    cell.backgroundColor = UIColor.init(hexString: "3764BC")
                    //                                                   //print ( "2in cellUpdate - count = \(count) \(self.sendToMonicipality)")
                    //
                    //                                }
                    //                                else{
                    //                                   cell.backgroundColor =  UIColor.lightGray
                    //                                }
                }
                row.disabled = Condition.function(
                    form.allRows.flatMap { $0.tag }, // All row tags
                    { _ in
                        let count = row.section?.form?.validate().count
                        //row.section?.form?.validate().count == 0
                        if  !(self.sendToMonicipality ?? false) {
                            print ( "1in row.disabled - count = \(count) \(self.sendToMonicipality)")
                            return false
                        }else  if  count != 0 &&  self.sendToMonicipality ?? false {
                            print ( "2in row.disabled - count = \(count) \(self.sendToMonicipality)")
                            return true
                        }
                        else{
                            print ( "3in row.disabled - count = \(count) \(self.sendToMonicipality)")
                            return false
                        }
                        
                }) // Form has no validation errors
                
                row.onCellSelection { [weak self] (cell, row) in
                    //print("validating errors: \(row.section?.form?.validate().count)")
                    if row.section?.form?.validate().count == 0{
                        print("form is valid")
                    }
                    else{
                        print("form is NOT valid")
                    }
                }
                
        }
    }
    
    private func setAllCelltextColorAccordingtoSwitch() {
        
        let rowFirstName: TextRow? = self.form.rowBy(tag: "firstName")
        let rowLastName: TextRow? = self.form.rowBy(tag: "lastName")
        let rowid: PhoneRow? = self.form.rowBy(tag: "id")
        let rowEmail: EmailRow? = self.form.rowBy(tag: "email")
        let rowPhone: PhoneRow? = self.form.rowBy(tag: "phone")
        
        if self.sendToMonicipality ?? false {
            rowFirstName?.cell.titleLabel?.textColor = .red
            rowLastName?.cell.titleLabel?.textColor = .red
            rowid?.cell.titleLabel?.textColor = .red
            rowEmail?.cell.titleLabel?.textColor = .red
            rowPhone?.cell.titleLabel?.textColor = .red
        }
        else{
            rowFirstName?.cell.titleLabel?.textColor = .black
            rowLastName?.cell.titleLabel?.textColor = .black
            rowid?.cell.titleLabel?.textColor = .black
            rowEmail?.cell.titleLabel?.textColor = .black
            rowEmail?.cell.titleLabel?.textColor = .black
            rowPhone?.cell.titleLabel?.textColor = .black
        }
    }

}
