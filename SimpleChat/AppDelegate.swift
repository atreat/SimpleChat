//
//  AppDelegate.swift
//  SimpleChat
//
//  Created by 😉 on 5/28/15.
//  Copyright (c) 2015 BobDog. All rights reserved.
//

import UIKit


struct Envelope {
    var sender: String
    var recipient: String
    var body: String
}


protocol BuddyStatusDelegate {

    func newBuddyOnline(buddy: String)
    func buddyWentOffline(buddy: String)
}

protocol MessageDelegate {
    func didReceiveMessage(envelope: Envelope)
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, XMPPStreamDelegate, XMPPReconnectDelegate {

    var window: UIWindow?
    var xStream: XMPPStream?

    var chatDelegate : BuddyStatusDelegate?
    var messageDelegate : MessageDelegate?

    class func this() -> AppDelegate {
        return UIApplication.sharedApplication().delegate as! AppDelegate
    }

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
        disconnect()
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

        connect()
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

// MARK: XMPP
    func setupStream() {
        xStream = XMPPStream()

        xStream!.hostName = "air.local"
        xStream!.hostPort = 5222

        let xmppReconnect = XMPPReconnect()
        xmppReconnect.activate(xStream)
        xmppReconnect.addDelegate(self, delegateQueue: dispatch_get_main_queue())

        xStream!.addDelegate(self, delegateQueue: dispatch_get_main_queue())
    }

    func goOnline() {
        if xStream == nil {
            setupStream()
        }

        xStream!.sendElement(XMPPPresence())
    }

    func goOffline() {
        if xStream == nil {
            setupStream()
        }
        xStream!.sendElement(XMPPPresence(type: "unaivalable"))
    }


    func connect() -> Bool {
        setupStream()

        if let stream = xStream {

            if stream.isConnected() {
                return true
            }

            let jid = NSUserDefaults.standardUserDefaults().stringForKey("username")
            let password = NSUserDefaults.standardUserDefaults().stringForKey("password")
            if jid == nil || password == nil {
                return false
            }

            stream.myJID = XMPPJID.jidWithString("\(jid!)@\(stream.hostName)")
            var error : NSError?
            let result = stream.connectWithTimeout(10.0, error: &error)
            if result {
                NSLog("Stream configured for connection: \(result)")
            } else if let e = error {
                NSLog("Error connecting to stream: \(e)")
                return false
            }
            
            return true
        }

        return false
    }

    func disconnect() {
        goOffline()
        xStream?.disconnect()
    }

    func sendMessage(body: String, recipient: String) {

        if let stream = xStream {
            let message = XMPPMessage(type: "chat", to: XMPPJID.jidWithString(recipient))
            message.addBody(body)
            stream.sendElement(message)
        }
    }

// MARK: XMPPStreamDelegate

    func xmppStreamDidConnect(sender: XMPPStream!) {
        NSLog("Did connect!")
        let password = NSUserDefaults.standardUserDefaults().stringForKey("password")
        if password == nil {
            NSLog("No password")
            return
        }

        var error: NSError?
        if sender.authenticateWithPassword(password!, error: &error) {

        } else if let e = error {
            NSLog("Error connecting to stream: \(e)")
        }
    }

    func xmppStreamDidDisconnect(sender: XMPPStream!, withError error: NSError!) {
        NSLog("Did disconnect with error: \(error)")
    }

    func xmppStreamDidAuthenticate(sender: XMPPStream!) {
        NSLog("Did authenticate with user: \(sender.myJID.user)")
        goOnline()
    }

    func xmppStream(sender: XMPPStream!, didNotAuthenticate error: DDXMLElement!) {
        NSLog("did not authenticate because of error: \(error)")
    }

    func xmppStreamConnectDidTimeout(sender: XMPPStream!) {
        NSLog("Did Timeout!")
    }

    func xmppStream(sender: XMPPStream!, didReceivePresence presence: XMPPPresence!) {

        let fromUser = presence.from().user
        let type = presence.type()

        if (fromUser) != sender.myJID.user {
            if presence.type() == "available" {
                chatDelegate?.newBuddyOnline("\(fromUser)@\(presence.from().domain)")
                NSLog("presence is available")
            } else if presence.type() == "unavailable" {
                chatDelegate?.buddyWentOffline("\(fromUser)@\(presence.from().domain)")
                NSLog("presence is unavailable")
            }
        }

    }

    func xmppStream(sender: XMPPStream!, didReceiveMessage message: XMPPMessage!) {

        let type = message.type()
        let from = message.fromStr()
        if let body = message.body() {
            if messageDelegate != nil {
                messageDelegate!.didReceiveMessage(Envelope(sender: from, recipient: sender.myJID.user, body: body))
            }
        }

        NSLog("Did receive message: \(message)")
    }

    func xmppStream(sender: XMPPStream!, didReceiveError error: DDXMLElement!) {
        NSLog("Stream received error: \(error)")
    }

    func xmppStreamWillConnect(sender: XMPPStream!) {
        NSLog("Will connect")
    }

    func xmppStream(sender: XMPPStream!, socketDidConnect socket: GCDAsyncSocket!) {
        NSLog("Socket Did Connect")
    }

    func xmppStream(sender: XMPPStream!, didFailToSendMessage message: XMPPMessage!, error: NSError!) {
        NSLog("Did fail to send message: \(error)")
    }

    func xmppStreamDidStartNegotiation(sender: XMPPStream!) {
        NSLog("Did start negotiation")
    }

    func xmppStreamWasToldToDisconnect(sender: XMPPStream!) {
        NSLog("Stream was told to disconnect")
    }

    func xmppStreamDidSendClosingStreamStanza(sender: XMPPStream!) {
        NSLog("Did send closing stanza")
    }

    func xmppStream(sender: XMPPStream!, didFailToSendPresence presence: XMPPPresence!, error: NSError!) {
        NSLog("Did fail to send presence: \(error)")
    }

    func xmppStream(sender: XMPPStream!, didFailToSendIQ iq: XMPPIQ!, error: NSError!) {
        NSLog("Did fail to send IQ: \(error)")
    }

// MARK: XMPPReconnectDelegate

    func xmppReconnect(sender: XMPPReconnect!, didDetectAccidentalDisconnect connectionFlags: SCNetworkConnectionFlags) {
        NSLog("did detect accidental disconnect")
    }

    func xmppReconnect(sender: XMPPReconnect!, shouldAttemptAutoReconnect connectionFlags: SCNetworkConnectionFlags) -> Bool {
        NSLog("Should attempt auto reconnect")
        return true
    }

}

