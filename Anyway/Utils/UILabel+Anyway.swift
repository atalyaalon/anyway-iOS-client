//
//  UILabel+Anyway.swift
//  Anyway
//
//  Created by Yigal Omer on 05/08/2019.
//  Copyright © 2019 Hasadna. All rights reserved.
//

import UIKit

extension UILabel {
    class func questionnaireLabel(frame: CGRect, text: String) -> UILabel {
        let label = UILabel(frame: frame)

        label.text = text
        label.textColor = UIColor.black
        label.textAlignment = NSTextAlignment.center
        label.font = UIFont.systemFont(ofSize: 14)

        return label
    }
}
