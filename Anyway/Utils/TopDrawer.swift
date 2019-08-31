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


    public var isVisible: Bool {
        get { return _isVisible }
        set {
            guard newValue != _isVisible else { return }
            toggleVisibility()
        }
    }
    public func setText(text: String, drawerHeight: CGFloat? = nil){
        if let drawerHeight = drawerHeight {
            self.drawerHeight = drawerHeight
        }
        setupView(labelText: text)
    }

    private var drawerHeight: CGFloat?

    private var _isVisible: Bool = true

    //private var yesButton = CAShapeLayer()
    private var textlayer: CATextLayer?


    private lazy var panGestureRecognizer: UIPanGestureRecognizer = {
        return UIPanGestureRecognizer(target: self, action: #selector(self.didPanDrawer(_:)))
    }()

    public convenience init(backgroundColor: UIColor) {
        self.init()
        self.backgroundColor = backgroundColor
    }

//    public convenience init(text: String) {
//        self.init()
//        self.labelText = text
//    }
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


//    required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
    public func setVisibility(visible: Bool) {
        if _isVisible && visible {
            return
        }
        if !_isVisible && !visible {
            return
        }
        let newFrame: CGRect = visible ? startingFrame() : hiddenFrame()

        UIView.animate(
            withDuration: 1.2,
            delay: 0.0,
            usingSpringWithDamping: 2.0,
            initialSpringVelocity: 0.75,
            options: .curveEaseOut,
            animations: {
                self.frame = newFrame
                self.layoutIfNeeded()
        }
        ) { _ in
            self._isVisible.toggle()
        }

    }

    public func toggleVisibility() {
        let newFrame: CGRect = !_isVisible ? startingFrame() : hiddenFrame()

        UIView.animate(
            withDuration: 0.5,
            delay: 0.0,
            usingSpringWithDamping: 2.0,
            initialSpringVelocity: 0.75,
            options: .curveEaseInOut,
            animations: {
                self.frame = newFrame
                self.layoutIfNeeded()
            }
        ) { _ in
            self._isVisible.toggle()
        }
    }
}

private extension TopDrawer {

    func setupView(labelText: String? = nil) {

        frame = CGRect(
            x: 0.0,
            y: -(Constants.height - (self.drawerHeight ?? Constants.minimumVisibleHeight) ),// Constants.minimumVisibleHeight),
            width: UIScreen.main.bounds.size.width,
            height: Constants.height
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

        let borderLayer = CAShapeLayer()
        borderLayer.frame = bounds
        borderLayer.path = maskPath.cgPath
        borderLayer.lineWidth = 1.0
        borderLayer.strokeColor = UIColor.darkGray.cgColor
        borderLayer.fillColor = UIColor.clear.cgColor
        layer.addSublayer(borderLayer)

        textlayer = CATextLayer()
        guard let textlayer = textlayer  else { return }
        var textHeightOfset:CGFloat = 100.0
        if self.drawerHeight == nil  ||  self.drawerHeight == 120 {
            textHeightOfset = 50.0
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





        //let yesButton = CAShapeLayer()
//        yesButton.path = UIBezierPath(roundedRect: CGRect(x: 100, y: frame.height - 80, width: 40, height: 40), cornerRadius: 6).cgPath
//        yesButton.fillColor = UIColor.red.cgColor
//        yesButton.shadowOpacity = 0.7
//        yesButton.shadowRadius = 10.0
//        yesButton.contents = UIImage(named: "user")?.cgImage
        //layer.addSublayer(yesButton)

//        let animation = CAKeyframeAnimation()
//        animation.keyPath = "transform.scale"
//        animation.values = [0, 0.2*1, -0.2*1, 0.2*1, 0]
//        animation.keyTimes = [0, 0.2, 0.4, 0.6, 0.8, 1]
//        //animation.timingFunction = getTimingFunction(curve: curve)
//        animation.duration = CFTimeInterval(3)
//        animation.isAdditive = true
//        animation.repeatCount = 1
//        animation.beginTime = CACurrentMediaTime()
//        yesButton.add(animation, forKey: "pop")


        

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

            layer.addSublayer(shapeLayer)
        }

        //addGestureRecognizer(panGestureRecognizer)
    }

//    override public func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView?{
//        if  ((yesButton.path?.contains(point))!){
//            print("tuoch button - event \(event) \(event?.type) \(event?.subtype) ")
//        }
//
//        return self
//    }

//    override public func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        let touch = touches.first
//
//        let point = (touch?.location(in: self))!
//
//        if  ((yesButton.path?.contains(point))!){
//            print("tuoch button - event \(event) \(event?.type) \(event?.subtype) ")
//
//        }
////
////        guard let point = touch?.location(in: imageView) else { return }
////        guard let sublayers = imageView.layer.sublayers as? [CAShapeLayer] else { return }
////
////        for layer in sublayers {
////            if let path = layer.path, path.contains(point) {
////                print(layer)
////            }
////        }
//    }

//    override func hitTest(point: CGPoint, withEvent event: UIEvent?) -> UIView? {
//        return self.path.containsPoint(point) ? self : nil
//    }

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
            y: -(Constants.height - (self.drawerHeight ?? Constants.minimumVisibleHeight)),
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
        static let height: CGFloat = UIScreen.main.bounds.size.height - Constants.minimumVisibleHeight
        static let cornerRadius: CGFloat = 22.0
        static let minimumVisibleHeight: CGFloat = 120.0
    }
}


