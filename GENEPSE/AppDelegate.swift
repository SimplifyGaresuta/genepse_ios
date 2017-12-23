//
//  AppDelegate.swift
//  GENEPSE
//
//  Created by 岩見建汰 on 2017/11/18.
//  Copyright © 2017年 Kenta. All rights reserved.
//

import UIKit
import CoreLocation
import Alamofire
import SwiftyJSON

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, CLLocationManagerDelegate {

    var window: UIWindow?
    var user_id: Int?
    var data: DetailData?
    var locationManager = CLLocationManager()

    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        locationManager.requestAlwaysAuthorization()
        locationManager.delegate = self
        locationManager.startUpdatingLocation()

        if launchOptions?[UIApplicationLaunchOptionsKey.location] != nil {
            locationManager.startMonitoringSignificantLocationChanges()
        }
        
        CallUpdateLocationAPI(location: locationManager.location)
        
        if DBMethod().RecordCount(User.self) == 0 {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let signupVC = storyboard.instantiateViewController(withIdentifier: "SignUp")

            self.window?.rootViewController = signupVC
            self.window?.makeKeyAndVisible()
        }else {
            guard let user_id = DBMethod().GetUserID(User.self)?.user_id else{return false}
            self.user_id = user_id
        }
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        if CLLocationManager.significantLocationChangeMonitoringAvailable() {
            locationManager.startMonitoringSignificantLocationChanges()
        }
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
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    // MARK: CLLocationManagerDelegate
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        CallUpdateLocationAPI(location: locations.last)
    }
    
    func CallUpdateLocationAPI(location: CLLocation?) {
        if location != nil && DBMethod().RecordCount(User.self) != 0 {
            guard let user_id = DBMethod().GetUserID(User.self)?.user_id else{return}
            
            let urlString: String = API.host.rawValue + API.v1.rawValue + API.locations.rawValue + String(user_id)
            
            let req_dict = [
                Key.latitude.rawValue: Double(location!.coordinate.latitude),
                Key.longitude.rawValue: Double(location!.coordinate.longitude)
            ]
            
            Alamofire.request(urlString, method: .put, parameters: req_dict, encoding: JSONEncoding(options: [])).responseJSON { (response) in
                print("****** Location Update Results******")
                let object = response.result.value
                let json = JSON(object)
                print("Location Update results: ", json)
                print("Location req_dict: ", req_dict)
                print("****** Location Update Results******")
            }
        }
    }
}

