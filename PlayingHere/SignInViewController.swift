//
//  SignInViewController.swift
//  PlayingHere
//
//  Created by Matt Condon on 2/20/16.
//  Copyright © 2016 mattc. All rights reserved.
//

import UIKit
import SnapKit

class SignInViewController: UIViewController {

  lazy var signInButton : UIButton = {
    let button = UIButton()
    button.backgroundColor = .blueColor()
    button.setTitle("Login with Spotify", forState: .Normal)
    button.setTitleColor(.whiteColor(), forState: .Normal)
    return button
  }()

  override func viewDidLoad() {
    super.viewDidLoad()

    let title = UILabel()
    title.text = "PlayingHere"
    title.font = UIFont.systemFontOfSize(40)
    view.addSubview(title)
    title.snp_makeConstraints { make in
      make.centerX.equalTo(view)
      make.top.equalTo(view).offset(200)
    }

    signInButton.addTarget(self, action: "loginWithSpotify", forControlEvents: .TouchUpInside)
    view.addSubview(signInButton)
    signInButton.snp_makeConstraints { make in
      make.bottom.left.right.equalTo(view)
      make.height.equalTo(80)
    }
  }

  func loginWithSpotify() {
    let loginUrl = SPTAuth.defaultInstance().loginURL

    UIApplication.sharedApplication().performSelector("openURL:", withObject: loginUrl, afterDelay: 0.1)
  }

  override func didReceiveMemoryWarning() {
      super.didReceiveMemoryWarning()
      // Dispose of any resources that can be recreated.
  }
}
