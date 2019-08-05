//
//  UIButton+Anyway.swift
//  Anyway
//
//  Created by Yigal Omer on 05/08/2019.
//  Copyright © 2019 Hasadna. All rights reserved.
//

import UIKit

extension UIButton {
    class func questionnaireButton(frame: CGRect, title: String, action: Selector? = nil) -> UIButton {
        let button = UIButton(frame: frame)
        button.clipsToBounds = true
        button.setTitleColor(UIColor.white, for: UIControl.State.normal)
        button.backgroundColor = UIColor.lightGray
        button.cornerRadius = 4
        button.tintColor = UIColor.black
        button.setTitle(title, for: UIControl.State.normal)
        if action != nil {
            button.addTarget(self, action:action!, for: .touchUpInside)
        }
        //button.layer.cornerRadius = button_1.frame.width/2.0
        //button.layer.borderColor = UIColor.whiteColor().CGColor
        //button.layer.borderWidth = 2.0
        return button
    }
}
