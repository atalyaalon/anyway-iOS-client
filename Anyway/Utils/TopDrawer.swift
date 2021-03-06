//
//  TopDrawer.swift
//  Anyway
//
//  Created by Yigal Omer on 30/08/2019.
//  Copyright © 2019 Hasadna. All rights reserved.
//

import Foundation
import UIKit

enum DrawerType: Int {
    case top = 0
    case buttom = 1
}

public class TopDrawer: UIView {

    private var drawerHeight: CGFloat?
    private var _isVisible: Bool = false
    private var textlayer: CATextLayer?
    private var borderLayer : CAShapeLayer?
    private var drawerType: DrawerType!
    
    private let drawerBackgroundColor = UIColor.lightGray.withAlphaComponent(0.825)

    private lazy var panGestureRecognizer: UIPanGestureRecognizer = {
        return UIPanGestureRecognizer(target: self, action: #selector(self.didPanDrawer(_:)))
    }()

//    public convenience init(backgroundColor: UIColor) {
//        self.init()
//        self.backgroundColor = backgroundColor
//    }

    init(frame: CGRect, drawerType: DrawerType = .buttom) {
        super.init(frame: frame)
        self.drawerType = drawerType
        self.frame = hiddenFrame()
        
        setupView()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.frame = hiddenFrame()
        self.drawerType = .buttom
        setupView()
    }
    
    
    public func setText(text: String, drawerHeight: CGFloat? = nil){
        if let drawerHeight = drawerHeight {
            self.drawerHeight = drawerHeight
        }
        setupView(labelText: text)
    }
    
    public func setVisibility(visible: Bool) {
        if _isVisible && visible {
            return
        }
        if !_isVisible && !visible {
            return
        }
        self._isVisible = visible
        //setupView()
        //var newFrame: CGRect = visible ? startingFrame() : hiddenFrame()
        var newFrame: CGRect = self.frame
        
        UIView.animate(
            withDuration: 0.8,
            delay: 0.0,
            usingSpringWithDamping: 2.0,
            initialSpringVelocity: 0.75,
            options: .curveEaseOut,
            animations: {
                if visible {
                    if ( self.drawerType == .buttom) {
                       newFrame.origin.y -= Config.BIG_DRAWER_HEIGHT * 2 //300
                    } else {
                        newFrame.origin.y += Config.BIG_DRAWER_HEIGHT //150
                    }
                }
                else{
                    if ( self.drawerType == .buttom) {
                        newFrame.origin.y += Config.BIG_DRAWER_HEIGHT * 2 //300
                    }else{
                        newFrame.origin.y -= Config.BIG_DRAWER_HEIGHT
                    }
                }
                
                self.frame = newFrame
                self.layoutIfNeeded()
                //self._isVisible = visible
        },
            completion:  { _ in
                //self._isVisible.toggle()
                //self._isVisible = visible
        })
        
    }
    

}

private extension TopDrawer {

    func setupView(labelText: String? = nil) {
        
        //frame = startingFrame()
        //frame = hiddenFrame()
        backgroundColor = drawerBackgroundColor

//        if let sublayers = layer.sublayers {// crash!!
//            for sublayer in sublayers {
//                sublayer.removeFromSuperlayer()
//            }
//        }
        if textlayer != nil {
            textlayer?.removeFromSuperlayer()
        }
        
        if borderLayer != nil {
            borderLayer?.removeFromSuperlayer()
        }

        // Keep the drawer at the top of the visible hierarchy
        layer.zPosition = CGFloat(Float.greatestFiniteMagnitude)
        layer.masksToBounds = true

        let maskPath = UIBezierPath(
            roundedRect: bounds,
            //byRoundingCorners: [.bottomLeft, .bottomRight],// FOR TOP
            byRoundingCorners: self.drawerType == .buttom ? [.topLeft, .topRight] :[.bottomLeft, .bottomRight] , 
            cornerRadii: CGSize(
                width: Constants.cornerRadius,
                height: Constants.cornerRadius
            )
        )

        let maskLayer = CAShapeLayer()
        maskLayer.frame = bounds
        maskLayer.path = maskPath.cgPath
        layer.mask = maskLayer

        borderLayer = CAShapeLayer()
        if let borderLayer = borderLayer {
            borderLayer.frame = bounds
            borderLayer.path = maskPath.cgPath
            borderLayer.lineWidth = 3.0
            borderLayer.strokeColor = UIColor.darkGray.cgColor
            borderLayer.fillColor = UIColor.clear.cgColor
            layer.addSublayer(borderLayer)
        }

        textlayer = CATextLayer()
        guard let textlayer = textlayer  else { return }
        //var textHeightOfset:CGFloat = 100.0
        var textHeightOfset:CGFloat = (120/3)*2 + 30
        if self.drawerHeight == nil  ||  self.drawerHeight == 120 {
            //textHeightOfset = 50.0
            textHeightOfset = 150/2 - 18/2 + 20
        }
        //let stingWidth:CGFloat = labelText?.widthOfString(usingFont : UIFont.systemFont(ofSize: 16)) ?? 0 + 0
        textlayer.frame = CGRect(x: 0, y:frame.height - textHeightOfset, width: frame.width , height: 18)
        textlayer.fontSize = 16
        textlayer.alignmentMode = .center
        textlayer.string = labelText
        textlayer.isWrapped = true
        textlayer.cornerRadius = 5
        textlayer.truncationMode = .end
        textlayer.backgroundColor = UIColor.clear.cgColor //.withAlphaComponent(0.4).cgColor
        textlayer.foregroundColor = UIColor.black.cgColor

        layer.addSublayer(textlayer)

        let grooveSize: CGSize = CGSize(width: 24.0, height: 2.125)

        for index in 0 ..< 2 {
            let x: CGFloat = (bounds.size.width / 2.0) - (grooveSize.width / 2.0)
            let y: CGFloat = bounds.size.height - (grooveSize.height * 3.025) - (CGFloat(index) * (grooveSize.height * 2.5))

            let linePath = UIBezierPath()
            linePath.move(to: CGPoint(x: x, y: y))
            linePath.addLine(to: CGPoint(x: x + grooveSize.width, y: y))

            let shapeLayer = CAShapeLayer()
            shapeLayer.path = linePath.cgPath
            shapeLayer.strokeColor = UIColor.black.withAlphaComponent(0.625).cgColor
            shapeLayer.lineWidth = grooveSize.height
            shapeLayer.fillColor = UIColor.clear.cgColor

           // layer.addSublayer(shapeLayer)
        }

        addGestureRecognizer(panGestureRecognizer)
    }


    @objc func didPanDrawer(_ gestureRecognizer: UIPanGestureRecognizer) {
        if [.began, .changed].contains(gestureRecognizer.state) {
            let translation = gestureRecognizer.translation(in: self)
            let centerPoint: CGPoint = CGPoint(
                x: gestureRecognizer.view!.center.x,
                y: gestureRecognizer.view!.center.y + translation.y
            )

            // Don't allow view to be dragged so far down that it detaches from
            // the top, nor too far up that it can't be touch-dragged back down
            if centerPoint.y < (gestureRecognizer.view!.frame.size.height / 2.0) &&
                centerPoint.y > (((gestureRecognizer.view!.frame.size.height / 2.0) - Constants.minimumVisibleHeight) * -1.0) {
                gestureRecognizer.view!.center = centerPoint
            } else {
                gestureRecognizer.view!.center = CGPoint(
                    x: gestureRecognizer.view!.center.x,
                    y: gestureRecognizer.view!.center.y
                )
            }

            gestureRecognizer.setTranslation(CGPoint.zero, in: self)
        }
    }
}

private extension TopDrawer {
    
    

    
    func hiddenFrame() -> CGRect {
        return CGRect(
            x: 0.0,
            y: self.drawerType == .buttom ? UIScreen.main.bounds.size.height + Config.BIG_DRAWER_HEIGHT :-Config.BIG_DRAWER_HEIGHT,
            width: UIScreen.main.bounds.size.width,
            height:Config.BIG_DRAWER_HEIGHT
        )
    }
  
//    // FOR TOP
//    func hiddenFrame() -> CGRect {
//        return CGRect(
//            x: 0.0,
//            y: -150.0,
//            width: UIScreen.main.bounds.size.width,
//            height:150.0
//        )
//    }
    
    //FOR DOWN
//        func hiddenFrame() -> CGRect {
//            return CGRect(
//                x: 0.0,
//                y: UIScreen.main.bounds.size.height + Config.BIG_DRAWER_HEIGHT,
//                width: UIScreen.main.bounds.size.width,
//                height:Config.BIG_DRAWER_HEIGHT
//            )
//        }

    
    
//
//    func startingFrame() -> CGRect {
//        return CGRect(
//            x: 0.0,
//            // y:0.0, //FOR TOP
//            y:UIScreen.main.bounds.size.height - (self.drawerHeight ?? Constants.minimumVisibleHeight),// FOR DOWN
//            width: UIScreen.main.bounds.size.width,
//            height: self.drawerHeight ?? Constants.height
//        )
//    }


}

private extension TopDrawer {
    struct Constants {
        //static let height: CGFloat = UIScreen.main.bounds.size.height - Constants.minimumVisibleHeight
        static let height: CGFloat = 120.0
        static let cornerRadius: CGFloat = 22.0
        static let minimumVisibleHeight: CGFloat = 120.0
    }
}


