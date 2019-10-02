//
//  FirstLaunch.swift
//  Anyway
//
//  Created by Yigal Omer on 24/08/2019.
//  Copyright © 2019 Hasadna. All rights reserved.
//

import UIKit

class FirstLaunch {

    let userDefaults: UserDefaults = .standard

    let wasLaunchedBefore: Bool
    var isFirstLaunch: Bool {
        //return true
       return !wasLaunchedBefore
    }

    init() {
        let key = "il.org.hasadna.Anyway.FirstLaunch.WasLaunchedBefore"
        let wasLaunchedBefore = userDefaults.bool(forKey: key)
        self.wasLaunchedBefore = wasLaunchedBefore
        if !wasLaunchedBefore {
            userDefaults.set(true, forKey: key)
        }
    }
}
