//
//  LoginViewController.swift
//  SimpleChat
//
//  Created by 😉 on 6/2/15.
//  Copyright (c) 2015 BobDog. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!


    @IBAction func login(sender: AnyObject) {

        let username = usernameField.text
        let password = passwordField.text

        if (count(username) != 0 && count(password) != 0) {
            let defaults = NSUserDefaults.standardUserDefaults()
            defaults.setObject(username, forKey: "username")
            defaults.setObject(password, forKey: "password")
            defaults.synchronize()

            hideLogin()
        }
    }

    func hideLogin() {
        dismissViewControllerAnimated(true, completion: { () -> Void in
            AppDelegate.this().connect()
        })
    }

}
