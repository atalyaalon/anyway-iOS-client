//
//  InsetLabel.swift
//  Anyway
//
//  Created by Aviel Gross on 2/24/15.
//  Copyright (c) 2015 Hasadna. All rights reserved.
//

import UIKit

class InsetLabel: UILabel {
    
    @IBInspectable var insetVertical: CGFloat = 8 {
        didSet{
            insets.bottom = insetVertical
            insets.top = insetVertical
        }
    }
    
    @IBInspectable var insetHorizontal: CGFloat = 8 {
        didSet{
            insets.left = insetHorizontal
            insets.right = insetHorizontal
        }
    }
    
    var insets: UIEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
    

    override func drawText(in rect: CGRect) {
        return super.drawText(in: rect.inset(by:insets))
    }
    
    override func textRect(forBounds bounds: CGRect, limitedToNumberOfLines numberOfLines: Int) -> CGRect {
        
        var rect = super.textRect(forBounds: bounds.inset(by:insets), limitedToNumberOfLines: numberOfLines)
        
        
        rect.origin.x -= insets.left
        rect.origin.y -= insets.top
        rect.size.width  += (insets.left + insets.right);
        rect.size.height += (insets.top + insets.bottom);
        
        return rect
    }
}
