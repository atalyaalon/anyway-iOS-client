//
//  TopDrawer.swift
//  Anyway
//
//  Created by Yigal Omer on 30/08/2019.
//  Copyright © 2019 Hasadna. All rights reserved.
//

import Foundation
import UIKit

public class TopDrawer: UIView {

    private var drawerHeight: CGFloat?
    private var _isVisible: Bool = true
    private var textlayer: CATextLayer?
    private var borderLayer : CAShapeLayer?

    private lazy var panGestureRecognizer: UIPanGestureRecognizer = {
        return UIPanGestureRecognizer(target: self, action: #selector(self.didPanDrawer(_:)))
    }()

    public convenience init(backgroundColor: UIColor) {
        self.init()
        self.backgroundColor = backgroundColor
    }


    public init(text: String? = nil, drawerHeight: CGFloat? = nil) {
        //self.labelText = text
        super.init(frame: .zero)
        if let drawerHeight = drawerHeight {
            self.drawerHeight = drawerHeight
        }else{
            self.drawerHeight =  Constants.minimumVisibleHeight
        }
        setupView(labelText: text)

    }

    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
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
         //setupView()
        let newFrame: CGRect = visible ? startingFrame() : hiddenFrame()

        UIView.animate(
            withDuration: 0.8,
            delay: 0.0,
            usingSpringWithDamping: 2.0,
            initialSpringVelocity: 0.75,
            options: .curveEaseOut,
            animations: {
                self.frame = newFrame
                self.layoutIfNeeded()
                self._isVisible = visible
            }
            ) { _ in
                //self._isVisible.toggle()
                //self._isVisible = visible
            }

    }
}

private extension TopDrawer {

    func setupView(labelText: String? = nil) {

//        frame = CGRect(
//            x: 0.0,
//            y: -(Constants.height - (self.drawerHeight ?? Constants.minimumVisibleHeight) ),// Constants.minimumVisibleHeight),
//            width: UIScreen.main.bounds.size.width,
//            height: Constants.height
//        )
        
        
        frame = CGRect(
            x: 0.0,
            y: 0.0, //self.drawerHeight ?? Constants.minimumVisibleHeight,
            width: UIScreen.main.bounds.size.width,
            height: self.drawerHeight ?? Constants.height
        )
        
        
        //frame = startingFrame()
        backgroundColor = UIColor.lightGray.withAlphaComponent(0.825)

//        if let sublayers = layer.sublayers {
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
            byRoundingCorners: [.bottomLeft, .bottomRight],
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
            borderLayer.lineWidth = 1.0
            borderLayer.strokeColor = UIColor.darkGray.cgColor
            borderLayer.fillColor = UIColor.clear.cgColor
            layer.addSublayer(borderLayer)
        }

        textlayer = CATextLayer()
        guard let textlayer = textlayer  else { return }
        //var textHeightOfset:CGFloat = 100.0
        var textHeightOfset:CGFloat = (120/3)*2 + 10
        if self.drawerHeight == nil  ||  self.drawerHeight == 120 {
            //textHeightOfset = 50.0
            textHeightOfset = 120/2 - 18/2
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
            y: -Constants.height,
            width: UIScreen.main.bounds.size.width,
            height: Constants.height
        )
    }

    func startingFrame() -> CGRect {
        return CGRect(
            x: 0.0,
           //  y: -(Constants.height - (self.drawerHeight ?? Constants.minimumVisibleHeight)),
            //y: self.drawerHeight ?? Constants.minimumVisibleHeight,
            y:0.0,
            width: UIScreen.main.bounds.size.width,
            height: Constants.height
        )
    }

    func fullFrame() -> CGRect {
        return CGRect(
            x: 0.0,
            y: 0.0,
            width: UIScreen.main.bounds.size.width,
            height: Constants.height
        )
    }
}

private extension TopDrawer {
    struct Constants {
        //static let height: CGFloat = UIScreen.main.bounds.size.height - Constants.minimumVisibleHeight
        static let height: CGFloat = 120.0
        static let cornerRadius: CGFloat = 22.0
        static let minimumVisibleHeight: CGFloat = 120.0
    }
}


