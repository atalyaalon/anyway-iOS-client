//
//  KeyboardObserver.swift
//  Figure8
//
//  Created by Yigal Omer on 15/08/2019.
//  Copyright © 2019 Hasadna. All rights reserved.
//


import Foundation
import UIKit

public class KeyboardObserver {
    public typealias AnimationCallback = (_ height: CGFloat) -> Void

    let notificationCenter: NotificationCenter

    public var willAnimateKeyboard: AnimationCallback?

    public var animateKeyboard: AnimationCallback?

    public var currentKeyboardHeight: CGFloat?

    public init() {
        notificationCenter = NotificationCenter.default
    }

    deinit {
        stop()
    }

    public func start() {
        stop()

        notificationCenter.addObserver(self, selector: #selector(keyboardNotification(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(keyboardNotification(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    public func stop() {
        notificationCenter.removeObserver(self)
    }

    @objc func keyboardNotification(_ notification: Notification) {
        let isShowing = notification.name == UIResponder.keyboardWillShowNotification

        if let userInfo = (notification as NSNotification).userInfo,
            let height = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.height,
            let duration: TimeInterval = (userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue,
            let animationCurveRawNSN = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber {

            var correctedHeight = isShowing ? height : 0
            if #available(iOS 11.0, *) {
                if isShowing, let window = UIApplication.shared.delegate?.window, let unwrappedWindow = window {
                    correctedHeight = height - unwrappedWindow.safeAreaInsets.bottom
                }
            }

            willAnimateKeyboard?(correctedHeight)

            UIView.animate(withDuration: duration,
                           delay: TimeInterval(0),
                           options: UIView.AnimationOptions(rawValue: animationCurveRawNSN.uintValue),
                           animations: { [weak self] in
                            self?.animateKeyboard?(correctedHeight)
                },
                           completion: nil
            )

            currentKeyboardHeight = correctedHeight
        }
    }
}
