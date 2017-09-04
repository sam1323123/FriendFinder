//
//  PendingNotificationObserver.swift
//  FriendFinder
//
//  Created by Samuel Lee on 8/16/17.
//  Copyright © 2017 Samuel Lee and Avishek Ganguli. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class PendingNotificationObject: NSObject {
    
    static let sharedInstance: PendingNotificationObject = {
     return PendingNotificationObject()
    }()
    
    private var ref: DatabaseReference!
    private var data: [String:String] = [:] //can implement a didset here
    
    private let notificationIdentifier: Notification.Name = Notification.Name("connectionRequest")
    private var observerID: UInt?
    
    private override init() {
        super.init()
        let path = FirebasePaths.connectionRequests(uid: Auth.auth().currentUser!.uid)
        ref = Database.database().reference().child(path)
        //attache an event observer
        observerID = ref.observe(.value, with: {(snapshot) in
            //set data field then alert all observers
            self.data = (snapshot.exists()) ? snapshot.value as! [String: String] : [:]
            NotificationCenter.default.post(name: self.notificationIdentifier, object: nil, userInfo: nil)
        }
            , withCancel: {(err) in
                print(err)
                self.data = [:]
                //possibliy bring up warning
        })
    }
    
    
    deinit {
        if let id = observerID {
            ref.removeObserver(withHandle: id)
        }
    }
    
    
    //return number of pending requests to commect
    func numberOfPendingRequests() -> Int {
        return data.keys.count
    }
    
    
    func getAllPendingRequests() -> [String:String] {
        return data
    }
    
    //registers an object to handle changes to number of Pending notifications
    func registerObserver(observer: Any, action: Selector) {
        NotificationCenter.default.addObserver(observer, selector: action, name: notificationIdentifier, object: nil)
    }
    
    //remove an observer
    func removeObserver(observer: Any) {
        NotificationCenter.default.removeObserver(observer, name: notificationIdentifier, object: nil)
    }
    
    //remove a pending request
    func removeRequest(username: String) {
        ref.child(username).removeValue(completionBlock: {
            (err, dbRef) in
            print(err ?? "No Error")
        })
    }
    
    //function to try to refresh connection to firebase using the observe method. Useful for network disconnects?
    func reconnect() {
        if let lastObserver = observerID {
            //has an observer attached to firebase so remove it
            ref.removeObserver(withHandle: lastObserver)
        }
        
        //retry connection to firebase
        let path = FirebasePaths.connectionRequests(uid: Auth.auth().currentUser!.uid)
        ref = Database.database().reference().child(path)
        //attache an event observer
        observerID = ref.observe(.value, with: {(snapshot) in
            //set data field then alert all observers
            self.data = (snapshot.exists()) ? snapshot.value as! [String: String] : [:]
            NotificationCenter.default.post(name: self.notificationIdentifier, object: nil, userInfo: nil)
        }
            , withCancel: {(err) in
                print(err)
                self.data = [:]
                //possibliy bring up warning
        })
    }
}
