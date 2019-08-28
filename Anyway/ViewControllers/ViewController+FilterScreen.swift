//
//  ViewController+FilterScreen.swift
//  Anyway
//
//  Created by Aviel Gross on 2/1/16.
//  Copyright © 2016 Hasadna. All rights reserved.
//

import Foundation

extension ViewController: FilterScreenDelegate {

    func didCancel() {
        dismiss(animated: true, completion: nil)
    }
    
    func didSave(filter: Filter) {
        dismiss(animated: true) {
            self.filter = filter
            self.updateInfoIfPossible(self.map, filterChanged: true)
        }
    }
    
}
