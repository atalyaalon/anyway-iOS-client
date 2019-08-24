//
//  UIStoryboard+Anyway.swift
//  Anyway
//
//  Created by Yigal Omer on 24/08/2019.
//  Copyright © 2019 Hasadna. All rights reserved.
//

import UIKit


extension UIStoryboard {
    class var main: UIStoryboard {
        return UIStoryboard(name: "Main", bundle: nil)
    }

    class var splash: UIStoryboard {
        return UIStoryboard(name: "CustomSplash", bundle: nil)
    }
}

