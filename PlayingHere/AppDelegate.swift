//
//  AppDelegate.swift
//  PlayingHere
//
//  Created by Matt Condon on 2/20/16.
//  Copyright © 2016 mattc. All rights reserved.
//

import UIKit
let clientId = "YOUR_CLIENT_ID"

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?

  var session : SPTSession?
  var player : SPTAudioStreamingController?


  func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {

    window = UIWindow(frame: UIScreen.mainScreen().bounds)

    if let window = window {
      window.backgroundColor = UIColor.whiteColor()
      window.rootViewController = SignInViewController()
      window.makeKeyAndVisible()
    }

    SPTAuth.defaultInstance().clientID = clientId
    SPTAuth.defaultInstance().redirectURL = NSURL(string: "playinghere://authorize")
    SPTAuth.defaultInstance().requestedScopes = [
      SPTAuthStreamingScope,
      SPTAuthUserReadPrivateScope,
      SPTAuthPlaylistModifyPublicScope,
      SPTAuthPlaylistReadPrivateScope,
      SPTAuthPlaylistModifyPrivateScope
    ]

    return true
  }

  func application(app: UIApplication, openURL url: NSURL, options: [String : AnyObject]) -> Bool {
    if SPTAuth.defaultInstance().canHandleURL(url) {
      SPTAuth.defaultInstance().handleAuthCallbackWithTriggeredAuthURL(url, callback: { (error, session) -> Void in
        if error != nil {
          print(error)
          return
        }

        self.window?.rootViewController = ViewController(session: session)
      })

      return true
    }

    return false
  }

  func applicationWillResignActive(application: UIApplication) {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
  }

  func applicationDidEnterBackground(application: UIApplication) {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
  }

  func applicationWillEnterForeground(application: UIApplication) {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
  }

  func applicationDidBecomeActive(application: UIApplication) {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
  }

  func applicationWillTerminate(application: UIApplication) {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
  }


}

