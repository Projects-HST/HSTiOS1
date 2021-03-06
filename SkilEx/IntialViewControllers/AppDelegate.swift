//
//  AppDelegate.swift
//  SkilEx
//
//  Created by Happy Sanz Tech on 03/05/19.
//  Copyright © 2019 Happy Sanz Tech. All rights reserved.
//

import UIKit
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate,UNUserNotificationCenterDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // Override point for customization after application launch.
        Thread.sleep(forTimeInterval: 1.0)
        GlobalVariables.shared.user_master_id = UserDefaults.standard.string(forKey: "user_master_id") ?? ""
         print(GlobalVariables.shared.user_master_id)
         if GlobalVariables.shared.user_master_id.isEmpty != true
         {
           let mainStoryboard:UIStoryboard = UIStoryboard(name: "MainView", bundle: nil)
           let homePage = mainStoryboard.instantiateViewController(withIdentifier: "tabbarcontroller") as! Tabbarcontroller
           self.window?.rootViewController = homePage
        }
        
        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).backgroundColor = .white
        application.registerForRemoteNotifications()
        registerForPushNotifications()
        registerNotificationCategories()
        UNUserNotificationCenter.current().delegate = self
        ReachabilityManager.shared.startMonitoring()
        UITextViewWorkaround.unique.executeWorkaround()
        return true
    }
    
    // Permission For Push Notification
    func registerForPushNotifications() {
        UNUserNotificationCenter.current() // 1
            .requestAuthorization(options: [.alert, .sound, .badge]) { // 2
                [weak self] granted, error in
                
                print("Permission granted: \(granted)")
                guard granted else { return }
                self?.getNotificationSettings()
        }
    }
    
    func getNotificationSettings() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            print("Notification settings: \(settings)")
            guard settings.authorizationStatus == .authorized else { return }
            DispatchQueue.main.async {
                UIApplication.shared.registerForRemoteNotifications()
            }
        }
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        // Stops monitoring network reachability status changes
        ReachabilityManager.shared.stopMonitoring()
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        // Starts monitoring network reachability status changes
        ReachabilityManager.shared.startMonitoring()
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func registerNotificationCategories() {
        let openBoardAction = UNNotificationAction(identifier: UNNotificationDefaultActionIdentifier, title: "Open Board", options: UNNotificationActionOptions.foreground)
        let contentAddedCategory = UNNotificationCategory(identifier: "content_added_notification", actions: [openBoardAction], intentIdentifiers: [], hiddenPreviewsBodyPlaceholder: "", options: .customDismissAction)
        UNUserNotificationCenter.current().setNotificationCategories([contentAddedCategory])
    }

    // Genrate Device Token
    func application( _ application: UIApplication,didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data)
    {
        let tokenParts = deviceToken.map { data in String(format: "%02.2hhx", data) }
        let device_Token = tokenParts.joined()
        UserDefaults.standard.saveDeviceToken(deviceToken: device_Token)
        print("Device Token: \(String(describing: device_Token))")
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        defer {
            completionHandler()
        }

        /// Identify the action by matching its identifier.
        guard response.actionIdentifier == UNNotificationDefaultActionIdentifier else { return }

        /// Perform the related action
        print("Open board tapped from a notification!")

        /// .. deeplink into the board
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void)
    {
        completionHandler([.alert, .badge, .sound])
    }
    
    func application(_ application: UIApplication,didFailToRegisterForRemoteNotificationsWithError error: Error)
    {
        print("Failed to register: \(error)")
    }
    
}

var preferredStatusBarStyle: UIStatusBarStyle {
    return .lightContent
}


