//
//  AppDelegate.swift
//  PangeaApp
//
//  Created by Larisa Clemenceau on 11/08/25.
//

import UIKit
import StripePaymentSheet

@main
class AppDelegate: UIResponder, UIApplicationDelegate {



    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        STPAPIClient.shared.publishableKey = "pk_test_51RWP9SRJC2fhvSRIg4Hu7MExUGWlRb4019sctM0z0G07y2OiEgsGNcrfuJk4ssgCXCslLl5K2MB8LKwTLrcGDHDF00LH4mFUXB"
            return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

