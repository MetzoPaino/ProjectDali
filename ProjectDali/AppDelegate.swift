//
//  AppDelegate.swift
//  ProjectDali
//
//  Created by William Robinson on 27/06/2015.
//  Copyright © 2015 William Robinson. All rights reserved.
//

import UIKit
import HealthKit
import WatchConnectivity

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, WCSessionDelegate {

    var window: UIWindow?
    let healthStore = HKHealthStore()
    let dataModel = DataModel()
    
    
//    let session = WCSession.defaultSession()

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        
        
        let masterNavigationViewController = self.window!.rootViewController as! UINavigationController
        let masterViewController = masterNavigationViewController.topViewController as! ViewController
        masterViewController.dataModel = self.dataModel
        
        // If can support Apple Watch, create session
        
//        if (WCSession.isSupported()) {
//            
////            let session = WCSession.defaultSession()
//            session.delegate = self
//            session.activateSession()
//            
//            if session.paired == false {
//                
//                // User hasn't paired a watch
//            }
//            
//            if session.watchAppInstalled == false {
//                
//                // User doesn't have watch app installed
//            }
//        }
        
        
        
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        dataModel.saveData()
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        dataModel.saveData()
    }
    
    // MARK: - Save NSUserDefaults
    
    func saveData() {
        dataModel.saveData()
    }
    
    // MARK: - HealthKit Delegate

    func applicationShouldRequestHealthAuthorization(application: UIApplication) {
        self.healthStore.handleAuthorizationForExtensionWithCompletion {
            success, error in
            
            if error != nil {
                print("applicationShouldRequestHealthAuthorization \(error)")
            }
        }
    }
    
    // MARK: - WatchConnectivity Delegate
    
//    func sessionWatchStateDidChange(session: WCSession) {
//        
//        // Paired state of Apple Watch has changed
//        // Possible if user installs, uninstalls watch app
//    }
    
    
}

