//
//  AppDelegate.swift
//  Anyway
//
//  Created by Aviel Gross on 2/16/15.
//  Copyright (c) 2015 Hasadna. All rights reserved.
//

import UIKit
import GoogleMaps

class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    private let GOOGLE_MAPS_API_KEY: String = "AIzaSyASfw9p93gn1kEfp6uQdWjYVmX6tJVQVPQ"


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        ManualLocalizationWorker.overrideCurrentLocal()
        self.setupGoogleServices()
        
        // Root vc must be a UINavigationController
        if  let navVC = self.window?.rootViewController as? UINavigationController {

            var viewController: UIViewController

            if FirstLaunch().isFirstLaunch {
                
                 viewController = UIStoryboard.main.instantiateViewController(withIdentifier: "OnboardingViewController")
                
            } else {
                
                 viewController = UIStoryboard.main.instantiateViewController(withIdentifier: "MainViewController") as UIViewController as! MainViewController
                 let mainViewModel = MainViewModel(viewController: viewController as? MainViewInput)
                (viewController as! MainViewController).mainViewModel = mainViewModel
            }
            navVC.pushViewController(viewController, animated: false)
        }
        

//        self.window = UIWindow(frame: UIScreen.main.bounds)
//        var viewController: UIViewController
//        if FirstLaunch().isFirstLaunch {
//             viewController = UIStoryboard.main.instantiateViewController(withIdentifier: "OnboardingViewController")
//        } else {
//            viewController = UIStoryboard.main.instantiateInitialViewController()!
//        }
//        self.window?.rootViewController = viewController
//        self.window?.makeKeyAndVisible()
        return true
    }


    private func setupGoogleServices() {
        //GMSPlacesClient.provideAPIKey(Config.sharedInstance.GOOGLE_PLACES_API_KEY)
        GMSServices.provideAPIKey(GOOGLE_MAPS_API_KEY)
        
      }
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

