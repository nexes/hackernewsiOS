//
//  AppDelegate.swift
//  HackerNews
//
//  Created by Joe Berria on 5/3/17.
//  Copyright © 2017 Joe Berria. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    static var delegate: AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
    }
    
    static var mainViewContext: NSManagedObjectContext {
        let container = (UIApplication.shared.delegate as! AppDelegate).persistentContainer
        return container.viewContext
    }
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "FavoritesModel")
        
        container.loadPersistentStores(completionHandler: {(description, error) -> Void in
            if let err = error as NSError? {
                print("Error loading persistentStore \(err)")
            }
        })
        
        return container
    }()
    
    
    func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        guard let splitViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "mainSplitViewController") as? UISplitViewController else {
            completionHandler(false)
            return
        }
        
        guard let navigationController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "mainNavigationViewController") as? UINavigationController else {
            completionHandler(false)
            return
        }
        
        guard let tabBarController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "mainTabBarViewController") as? UITabBarController else {
            completionHandler(false)
            return
        }
        
        switch shortcutItem.type {
            case "com.jberria.beststories":
            tabBarController.selectedIndex = 2
            
            case "com.jberria.newstories":
            tabBarController.selectedIndex = 1
            
            case "com.jberria.favoritestories":
            tabBarController.selectedIndex = 3
            
        default:
            completionHandler(false)
            return
        }

        splitViewController.viewControllers[0] = navigationController
        navigationController.viewControllers[0] = tabBarController
        window?.rootViewController = splitViewController
        
        completionHandler(true)
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        return true
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
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        saveContext()
    }
    
    func saveContext() {
        let context = persistentContainer.viewContext

        if context.hasChanges {
            do {
                
                try context.save()
                
            } catch let err as NSError {
                print("error saving to core data \(err.debugDescription)")
            }
        }
    }
}

