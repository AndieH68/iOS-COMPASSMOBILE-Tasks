//
//  AppDelegate.swift
//  COMPASSMOBILE
//
//  Created by Andrew Harper on 11/01/2016.
//  Copyright © 2016 HYDOP E.C.S. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    /// set orientations you want to be allowed in this property by default
    var orientationLock = UIInterfaceOrientationMask.all
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        var result: Bool = false
        var message: String = String()
        
        (result, message) = Utility.copyFile("COMPASSDB.sqlite")
        
        if(!result)
        {
            Session.DatabasePresent = false
            Session.DatabaseMessage = message
         
            return false
        }
        else
        {
            Session.DatabasePresent = true
            Session.DatabaseMessage = String()
            
            _ = ModelManager.getInstance().CheckDatabaseStructure()
            
            let defaults = UserDefaults.standard
            Session.Server = defaults.object(forKey: "Server") as? String ?? String()
            Session.UseBlueToothProbe = defaults.bool(forKey: "UseBlueToothProbe")
            Session.UseTaskTiming = defaults.bool(forKey: "TaskTimng")
            Session.UseTemperatureProfile = defaults.bool(forKey: "TemperatureProfile")
            Session.RememberFilterSettings = defaults.bool(forKey: "RememberFilterSettings")
            Session.FilterOnTasks = defaults.bool(forKey: "FilterOnTasks")
            
            if(Session.RememberFilterSettings)
            {
                Session.FilterSiteId = defaults.object(forKey: "FilterSiteId") as? String ?? nil
                Session.FilterSiteName = defaults.object(forKey: "FilterSiteName") as? String ?? nil
                Session.FilterPropertyId = defaults.object(forKey: "FilterPropertyId") as? String ?? nil
                Session.FilterPropertyName = defaults.object(forKey: "FilterPropertyName") as? String ?? nil
                Session.FilterFrequency = defaults.object(forKey: "FilterFrequency") as? String ?? nil
                Session.FilterPeriod = defaults.object(forKey: "FilterPeriod") as? String ??  String?(DueCalendarMonthText)
                
                Session.FilterJustMyTasks = defaults.bool(forKey: "FilterJustMyTasks")
                
                Session.FilterAssetGroup = defaults.object(forKey: "FilterAssetGroup") as? String ?? nil
                Session.FilterTaskName = defaults.object(forKey: "FilterTaskName") as? String ?? nil
                Session.FilterAssetType = defaults.object(forKey: "FilterAssetType") as? String ?? nil
                Session.FilterLocationGroup = defaults.object(forKey: "FilterLocationGroup") as? String ?? nil
                Session.FilterLocation = defaults.object(forKey: "FilterLocation") as? String ?? nil
                Session.FilterAssetNumber = defaults.object(forKey: "FilterAssetNumber") as? String ?? nil
               
            }
            
            Session.OrganisationId = "00000000-0000-0000-0000-000000000000"
        }
        return true
    }

    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool{
        
        if (sourceApplication != nil && sourceApplication! == "com.apple.mobilesafari")
        {
            print("Calling Application Bundle ID: \(sourceApplication!)")
            print("URL scheme:\(url.scheme!)")
            print("URL query: \(url.query!)")
            
            let operativeId: String = url.value(for: "operativeId")!
            let taskId: String = url.value(for: "taskId")!
            
            
            //validate the operative
            let operative: Operative? = ModelManager.getInstance().getOperative(operativeId)
            
            if (operative == nil)
            {
                return false
            }
            
            //validate the task
            let task: Task? = ModelManager.getInstance().getTask(taskId)
            
            if (task == nil)
            {
                return false
            }
            
            Session.OperativeId = operative?.RowId
            Session.OrganisationId = operative?.OrganisationId
            Session.TaskId = taskId
            
            if let window = self.window{
                let currentViewController = window.rootViewController
                
                
                if (currentViewController is MainViewController)
                {
                    currentViewController!.performSegue(withIdentifier: "TaskSegue", sender: self)
                }
                else if (currentViewController is TaskViewController)
                {
                    _ = currentViewController?.navigationController?.popViewController(animated: true)
                    //Utility.invokeAlertMethod(currentViewController!, title: "Task open", message: TaskOpenMessage, delegate: nil)
                }
                else
                {

                    return false
                }
            }

            return true
        }
        else
        {
            print("Calling Application Bundle ID: \(sourceApplication!)")
            return false
        }
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
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }

    // MARK: - Core Data stack

    lazy var applicationDocumentsDirectory: URL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "COM.HYDROP.COMPASSMOBILE" in the application's documents Application Support directory.`
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return urls[urls.count-1]
    }()

    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = Bundle.main.url(forResource: "COMPASSMOBILE", withExtension: "momd")!
        return NSManagedObjectModel(contentsOf: modelURL)!
    }()

    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.appendingPathComponent("SingleViewCoreData.sqlite")
        var failureReason = "There was an error creating or loading the application's saved data."
        do {
            try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: nil)
        } catch {
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data" as AnyObject?
            dict[NSLocalizedFailureReasonErrorKey] = failureReason as AnyObject?

            dict[NSUnderlyingErrorKey] = error as NSError
            let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
            abort()
        }
        
        return coordinator
    }()

    lazy var managedObjectContext: NSManagedObjectContext = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        if managedObjectContext.hasChanges {
            do {
                try managedObjectContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
                abort()
            }
        }
    }
    
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return self.orientationLock
    }

}

