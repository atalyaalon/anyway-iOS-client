//
//  Extensions.swift
//  Anyway
//
//  Created by Aviel Gross on 3/24/15.
//  Copyright (c) 2015 Hasadna. All rights reserved.
//

import Foundation


//extension UIButton {
//    @IBInspectable var borderWidth: CGFloat {
//        get { return layer.borderWidth }
//        set { layer.borderWidth = newValue
//            layer.borderColor = titleLabel?.textColor.cgColor ?? layer.borderColor
//        }
//    }
//}

extension CLLocationCoordinate2D {
    var humanDescription: String {
        return "\(latitude),\(longitude)"
    }
}

extension MKMapView {
    func visibleAnnotations() -> [MKAnnotation] {
        
        var visibleAnots = [MKAnnotation]()
        let selfRegion = self.region
        
        for anot in self.annotations {
            if MKCoordinateRegionContainsPoint(selfRegion, anot.coordinate) {
                visibleAnots.append(anot)
            }
        }
        
        return visibleAnots
    }
}

extension CGSize {
    init(squareSide side: CGFloat) {
        self.init()
        width = side
        height = side
    }
}

extension UIView{
    func elevate(elevation: Double) {
        self.layer.masksToBounds = false
        self.layer.shadowColor = UIColor.black.cgColor //Color().black.CGColor
        self.layer.shadowOffset = CGSize(width: 0, height: elevation)

        if elevation >= 0.0 {
            self.layer.shadowRadius = CGFloat(elevation)
        } else {
            self.layer.shadowRadius = -CGFloat(elevation)
        }
        self.layer.shadowOpacity = 0.24
    }
}
