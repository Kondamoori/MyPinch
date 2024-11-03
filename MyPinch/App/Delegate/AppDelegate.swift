//
//  AppDelegate.swift
//  MyPinch
//
//  Created by Kondamoori, S. (Srinivasarao) on 21/10/2024.
//

import UIKit

@UIApplicationMain
final class MyPinchAppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    var appCoordinator: AppCoordinator?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        let window = UIWindow(frame: UIScreen.main.bounds)
        self.window = window
        
        let appCoordinator = AppCoordinator(window: window, appConfiguration: AppConfiguration.default)
        window.rootViewController = appCoordinator.start()
        
        self.appCoordinator = appCoordinator
        
        window.makeKeyAndVisible()
        return true
    }
}
