//
//  QuestionBarViewController.swift
//  Anyway
//
//  Created by Yigal Omer on 30/08/2019.
//  Copyright © 2019 Hasadna. All rights reserved.
//

import UIKit
//import Spring

class QuestionBarViewController: UIViewController {

    @IBOutlet weak var modalView: UIView! //SpringView!

    override func viewDidLoad() {
        super.viewDidLoad()
        //modalView.velocity = 0.6
//        modalView.animation = "squeezeUp"
//        modalView.duration = 1.0
//        modalView.damping = 0.8
        modalView.layer.cornerRadius = 22
        modalView.backgroundColor = UIColor.lightGray.withAlphaComponent(0.825)

        /*

         case SlideLeft = "slideLeft"
         case SlideRight = "slideRight"
         case SlideDown = "slideDown"
         case SlideUp = "slideUp"
         case SqueezeLeft = "squeezeLeft"
         case SqueezeRight = "squeezeRight"
         case SqueezeDown = "squeezeDown"
         case SqueezeUp = "squeezeUp"
         case FadeIn = "fadeIn"
         case FadeOut = "fadeOut"
         case FadeOutIn = "fadeOutIn"
         case FadeInLeft = "fadeInLeft"
         case FadeInRight = "fadeInRight"
         case FadeInDown = "fadeInDown"
         case FadeInUp = "fadeInUp"
         case ZoomIn = "zoomIn"
         case ZoomOut = "zoomOut"
         case Fall = "fall"
         case Shake = "shake"
         case Pop = "pop"
         case FlipX = "flipX"
         case FlipY = "flipY"
         case Morph = "morph"
         case Squeeze = "squeeze"
         case Flash = "flash"
         case Wobble = "wobble"
         case Swing = "swing"
 */
        // Do any additional setup after loading the view.
    }


    @IBAction func closeButtonPressed(_ sender: AnyObject) {
        //dismiss(animated: true, completion: nil)

//        modalView.animation = "fadeOut"
//        modalView.duration = 2.0
//        modalView.damping = 0.8
//
//        modalView.animate()

        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
            self.dismiss(animated: true, completion: nil)
        }

        // UIApplication.shared.sendAction(#selector(SpringViewController.maximizeView(_:)), to: nil, from: self, for: nil)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)

        // UIApplication.shared.sendAction(#selector(SpringViewController.minimizeView(_:)), to: nil, from: self, for: nil)
//        modalView.animation = "squeezeUp"
//        modalView.duration = 1.0
//        modalView.damping = 0.8
//        modalView.curve = "easeInOut"
//        modalView.animate()
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
