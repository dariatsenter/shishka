//
//  AppDelegate.swift
//  Shishka
//
//  Created by Daria Tsenter on 8/14/18.
//  Copyright © 2018 DariaTsenter. All rights reserved.
//

import UIKit
import Firebase
import GoogleSignIn
import Sparrow

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, GIDSignInDelegate {

    var window: UIWindow?
    
    var youtubeConnected: Bool? {
        didSet {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "youtubeConnectedNotification"), object: nil)
        }
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        SPLaunchAnimation.asTwitter(onWindow: self.window!)
        
        FirebaseApp.configure()
        GIDSignIn.sharedInstance().clientID = "10127282178-fdgo695gv7p2v1teaokenhmntfqvjbs1.apps.googleusercontent.com"
        GIDSignIn.sharedInstance().delegate = self
        let scope: NSString = "https://www.googleapis.com/auth/youtube.readonly"
        let currentScopes: NSArray = GIDSignIn.sharedInstance()?.scopes as! NSArray
        GIDSignIn.sharedInstance().scopes = currentScopes.adding(scope)
        return true
    }
    
    //call the handleURL method of the GIDSignIn instance, which will properly handle the URL that your application receives at the end of the authentication process.
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        return GIDSignIn.sharedInstance().handle(url as URL?,
                                                 sourceApplication: options[UIApplicationOpenURLOptionsKey.sourceApplication] as? String,
                                                 annotation: options[UIApplicationOpenURLOptionsKey.annotation])
    }
    
    //to run on iOS 8 and older
    func application(_ application: UIApplication,
                     open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        var _: [String: AnyObject] = [UIApplicationOpenURLOptionsKey.sourceApplication.rawValue: sourceApplication as AnyObject,
                                            UIApplicationOpenURLOptionsKey.annotation.rawValue: annotation as AnyObject]
        return GIDSignIn.sharedInstance().handle(url as URL,
                                                    sourceApplication: sourceApplication,
                                                    annotation: annotation)
    }
    
    //handle the google sign-in process
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!,
              withError error: Error!) {
        if let error = error {
            print("\(error.localizedDescription)")
        } else {
            // Perform any operations on signed in user here.
            let userId = user.userID                  // For client-side use only!
            let idToken = user.authentication.idToken // Safe to send to the server
            let fullName = user.profile.name
            let givenName = user.profile.givenName
            let familyName = user.profile.familyName
            let email = user.profile.email
            print("so auth token ? \(user.authentication.accessToken)")
            UserDefaults.standard.set(user.authentication.accessToken, forKey: "youtubeAccessToken")
            UserDefaults.standard.set(user.authentication.refreshToken,forKey: "youtubeRefreshToken")
            
            // testing result of API request
            let stringURL = String(format: "https://www.googleapis.com/youtube/v3/subscriptions?part=snippet&mine=true&key=AIzaSyCC1wUIxkgIgJxSdmkzP-kYEFiBzhutvuQ")
            let myURL = URL(string: stringURL)
            var myRequest = URLRequest(url: myURL!)
            myRequest.addValue("Bearer \(user.authentication.accessToken!)", forHTTPHeaderField: "Authorization")
            print("so the API request is \(String(describing: myRequest.allHTTPHeaderFields))")
            handleRequest(originalRequest: myRequest)
            self.youtubeConnected = true
        }
        }
    }
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!,
              withError error: Error!) {
        // Perform any operations when the user disconnects from app here.
        // ...
    }

func setInitialBartersandEvents() {
    let settings = FirestoreSettings()
    Firestore.firestore().settings = settings
    let db = Firestore.firestore()
    let userID : String = (Auth.auth().currentUser?.uid)!
    print("in setNumberOfEventsAndBarters of ProfileViewController userID is \(userID)")
    let docRef = db.collection("users").document(userID)
}
    
    func handleRequest(originalRequest: URLRequest) {
        let session = URLSession.shared
        let task = session.dataTask(with: originalRequest, completionHandler:
        { (data: Data?, response: URLResponse?, error: Error?) in
            // this is where the completion handler code goes
            if let responseData = String(data: data!, encoding: String.Encoding.utf8) {
                print("subscriptions response \(responseData)")
            }
            if let error = error {
                print(error)
            }
        })
        task.resume()
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
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


