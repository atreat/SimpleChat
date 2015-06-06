//
//  ViewController.swift
//  SimpleChat
//
//  Created by 😉 on 5/28/15.
//  Copyright (c) 2015 BobDog. All rights reserved.
//

import UIKit

class BuddyListViewController: UITableViewController, XMPPStreamDelegate, BuddyStatusDelegate {

    var xmppStream: XMPPStream?
    var onlineBuddies: [String] = []

    private var selectedBuddy: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        AppDelegate.this().chatDelegate = self
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "BuddyCell")
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        if let user = NSUserDefaults.standardUserDefaults().stringForKey("username") {
            self.navigationItem.leftBarButtonItem?.title = user
        }
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        let user = NSUserDefaults.standardUserDefaults().stringForKey("username")
        if (user == nil) {
            showLogin()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "toChat") {
            let cVc = segue.destinationViewController as! ChatViewController
            if let bud  = selectedBuddy {
                cVc.buddies.append(bud)
            }
        }
    }

    func showLogin() {
        performSegueWithIdentifier("toLogin", sender: self)
    }

// MARK: BuddyStatusDelegate

    func newBuddyOnline(buddy: String) {
        onlineBuddies.append(buddy)
        onlineBuddies.sort { (a: String, b: String) -> Bool in
            return a < b
        }
        tableView.reloadData()
    }

    func buddyWentOffline(buddy: String) {
        if let i = find(onlineBuddies, buddy) {
            onlineBuddies.removeAtIndex(i)
        }
        tableView.reloadData()  
    }


// MARK: UITableViewDelegate

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCellWithIdentifier("BuddyCell", forIndexPath: indexPath) as! UITableViewCell
        cell.textLabel?.text = onlineBuddies[indexPath.item]

        return cell
    }

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return onlineBuddies.count
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        // perform segue to chat with buddy
        selectedBuddy = onlineBuddies[indexPath.item]
        performSegueWithIdentifier("toChat", sender: self)

    }

    override func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        selectedBuddy = nil
    }

// MARK: UITableViewDataSource

}

