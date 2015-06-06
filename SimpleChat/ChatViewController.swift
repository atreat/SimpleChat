//
//  ChatViewController.swift
//  SimpleChat
//
//  Created by 😉 on 6/2/15.
//  Copyright (c) 2015 BobDog. All rights reserved.
//

import UIKit

class ChatViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, MessageDelegate {

    @IBOutlet weak var inputField: UITextField!
    @IBOutlet weak var tableView: UITableView!

    var buddies : [String] = []
    var messages   : [Envelope] = []


    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "ChatCell")
        inputField.autoresizingMask = .FlexibleWidth

        title = buddies.first

        navigationController?.setNavigationBarHidden(false, animated: true)
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if count(buddies) == 0 {
            dismissViewControllerAnimated(true, completion: { () -> Void in
                let alert = UIAlertView(title: "Room Empty", message: "There is no one here.", delegate: "", cancelButtonTitle: "OK")
            })
        }

        AppDelegate.this().messageDelegate = self

    }

    @IBAction func sendPressed(sender: UIButton) {

        let message = inputField.text
        if count(message.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())) != 0 {
            inputField.text = ""
            let me = NSUserDefaults.standardUserDefaults().stringForKey("username")
            let e = Envelope(sender: me!, recipient: buddies.first! , body: message)
            messages.append(e)

            AppDelegate.this().sendMessage(message, recipient: buddies.first!)

            tableView.reloadData()
        }

    }

// MARK: UITableViewDataSource
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return count(messages)
    }

    // Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
    // Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ChatCell", forIndexPath: indexPath) as! UITableViewCell

        let envelope = messages[indexPath.item]
        cell.textLabel?.text = envelope.body

        if envelope.sender == NSUserDefaults.standardUserDefaults().stringForKey("username") {
            cell.textLabel?.textAlignment = .Right
        }

        return cell
    }

// MARK: MessageDelegate
    func didReceiveMessage(envelope: Envelope) {
        messages.append(envelope)
        tableView.reloadData()
    }
}
