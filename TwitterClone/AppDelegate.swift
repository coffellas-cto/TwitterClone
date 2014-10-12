//
//  AppDelegate.swift
//  TwitterClone
//
//  Created by Alex G on 06.10.14.
//  Copyright (c) 2014 Alexey Gordiyenko. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    //var avatarImagesDictionary = Dictionary<String, NSData>()

    var window: UIWindow?
    var tabBarController = UITabBarController()
    
    // MARK: Public Methods
    // Core Data Manipulation
    
    func saveCachedImageForUrl(urlString: String?, data: NSData?) {
        if (urlString == nil) || (data == nil) {
            return
        }
        
        if cachedImageExistsForUrl(urlString) {
            //println("Image for URL \(urlString) exists!")
            return
        }
        
        var cachedImage: CachedImage = NSEntityDescription.insertNewObjectForEntityForName("CachedImage", inManagedObjectContext: self.managedObjectContext!) as CachedImage
        cachedImage.url = urlString
        cachedImage.data = data
        self.saveContext()
    }
    
    func cachedImageForUrl(urlString: String?) -> NSData? {
        if let urlString = urlString {
            if let fetchRequest = fetchRequestCommon(urlString) {
                var error: NSError?
                if let results = self.managedObjectContext?.executeFetchRequest(fetchRequest, error: &error) as NSArray? {
                    return (results.firstObject as? CachedImage)?.data
                }
            }
        }
        
        return nil
    }
    
    private func cachedImageExistsForUrl(urlString: String?) -> Bool {
        if let urlString = urlString {
            if let fetchRequest = fetchRequestCommon(urlString) {
                var error: NSError?
                return self.managedObjectContext?.countForFetchRequest(fetchRequest, error: &error) != 0
            }
        }
        
        return false
    }
    
    private func fetchRequestCommon(urlString: String) -> NSFetchRequest? {
        var fetchRequest = NSFetchRequest(entityName: "CachedImage")
        fetchRequest.predicate = NSPredicate(format: "url = %@", urlString)
        return fetchRequest
    }
    // MARK: Default Methods
    
    func customizeAppearance() {
        UINavigationBar.appearance().barTintColor = UIColor(red: 48 / 255, green: 48 / 255, blue: 47 / 255, alpha: 1)
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor(), NSFontAttributeName: UIFont(name: "HelveticaNeue-Thin", size: 20)]
        UINavigationBar.appearance().tintColor = UIColor.whiteColor()
        UIBarButtonItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.whiteColor(), NSFontAttributeName: UIFont(name: "HelveticaNeue-Light", size: 16)], forState: .Normal)
        UITabBar.appearance().barTintColor = UIColor(red: 48 / 255, green: 48 / 255, blue: 47 / 255, alpha: 1)
        UITabBar.appearance().tintColor = UIColor.whiteColor()
        UITabBarItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.whiteColor(), NSFontAttributeName: UIFont(name: "HelveticaNeue-Light", size: 14)], forState: .Normal)
        
        UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.LightContent
    }


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        customizeAppearance()
        
        window = UIWindow(frame: UIScreen.mainScreen().bounds)
        window?.backgroundColor = UIColor.redColor()
        
        var homeNavVC = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle()).instantiateViewControllerWithIdentifier("TIMELINE_NAV_VC") as? UINavigationController
        homeNavVC?.tabBarItem = UITabBarItem(title: "Timeline", image: UIImage(named: "tabbaritem_timeline"), tag: 0)
        var userNavVC = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle()).instantiateViewControllerWithIdentifier("TIMELINE_NAV_VC") as? UINavigationController
        userNavVC?.tabBarItem = UITabBarItem(title: "You", image: UIImage(named: "tabbaritem_you"), tag: 1)
        var userVC = userNavVC?.topViewController as TweetHomeViewController
        userVC.mode = .User
        userVC.title = "You"
        
        let launchView = NSBundle.mainBundle().loadNibNamed("LaunchScreen", owner: self, options: nil).first as? UIView
        var aboutVC = UIViewController()
        aboutVC.view = launchView!
        aboutVC.tabBarItem = UITabBarItem(title: "About", image: UIImage(named: "tabbaritem_info"), tag: 1)
                
        tabBarController.viewControllers = [homeNavVC!, userNavVC!, aboutVC]
        window?.rootViewController = tabBarController
        
        window?.makeKeyAndVisible()
        
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
    }

    func applicationDidEnterBackground(application: UIApplication) {
    }

    func applicationWillEnterForeground(application: UIApplication) {
    }

    func applicationDidBecomeActive(application: UIApplication) {
    }

    func applicationWillTerminate(application: UIApplication) {
        self.saveContext()
    }

    // MARK: - Core Data stack

    lazy var applicationDocumentsDirectory: NSURL = {
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls[urls.count-1] as NSURL
    }()

    lazy var managedObjectModel: NSManagedObjectModel = {
        let modelURL = NSBundle.mainBundle().URLForResource("TwitterClone", withExtension: "momd")!
        return NSManagedObjectModel(contentsOfURL: modelURL)
    }()

    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator? = {
        var coordinator: NSPersistentStoreCoordinator? = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent("TwitterClone.sqlite")
        var error: NSError? = nil
        var failureReason = "There was an error creating or loading the application's saved data."
        if coordinator!.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: nil, error: &error) == nil {
            coordinator = nil
            // Report any error we got.
            let dict = NSMutableDictionary()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
            dict[NSLocalizedFailureReasonErrorKey] = failureReason
            dict[NSUnderlyingErrorKey] = error
            error = NSError.errorWithDomain("YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            NSLog("Unresolved error \(error), \(error!.userInfo)")
            abort()
        }
        
        return coordinator
    }()

    lazy var managedObjectContext: NSManagedObjectContext? = {
        let coordinator = self.persistentStoreCoordinator
        if coordinator == nil {
            return nil
        }
        var managedObjectContext = NSManagedObjectContext()
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        if let moc = self.managedObjectContext {
            var error: NSError? = nil
            if moc.hasChanges && !moc.save(&error) {
                NSLog("Unresolved error \(error), \(error!.userInfo)")
                abort()
            }
        }
    }

}

