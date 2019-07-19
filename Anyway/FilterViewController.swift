//
//  FilterViewController.swift
//  Anyway
//
//  Created by Aviel Gross on 2/1/16.
//  Copyright © 2016 Hasadna. All rights reserved.
//

import UIKit
import Eureka

protocol FilterScreenDelegate: class {
    func didCancel(_ vc: FilterViewController, filter: Filter)
    func didSave(_ vc: FilterViewController, filter: Filter)
}

class FilterViewController: FormViewController {
    
    static let segueId = "open filter segue"
    
    var filter: Filter!
    
    weak var delegate: FilterScreenDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        assert(filter != nil, "Filter is nil!")
        setupForm(filter)
    }

    @IBAction func actionSave(_ sender: UIBarButtonItem) {
        delegate?.didSave(self, filter: filter)
    }
    
    @IBAction func actionCancel(_ sender: UIBarButtonItem) {
        delegate?.didCancel(self, filter: filter)
    }
    
}
