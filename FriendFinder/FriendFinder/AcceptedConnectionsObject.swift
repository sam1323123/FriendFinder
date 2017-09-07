//
//  AcceptedConnectionsObject.swift
//  FriendFinder
//
//  Created by Samuel Lee on 9/4/17.
//  Copyright © 2017 Samuel Lee and Avishek Ganguli. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class AcceptedConnectionsObject: NSObject {
    static let sharedInstance: AcceptedConnectionsObject = {
        return AcceptedConnectionsObject()
    }()
    
    private var ref: DatabaseReference!
    private var acceptedConnections: [String:[String:String]] = (UserDefaults.standard.dictionary(forKey: "connections")  ?? [:]) as! [String:[String:String]]
    private var observerID: UInt?
    private var username: String?
    
    private override init() {
        super.init()
    }
    
    
    deinit {
        if let id = observerID {
            ref.removeObserver(withHandle: id)
        }
    }
    
    
    /*! @brief Call this to start listening to objects */
    func start(username: String) {
        self.username = username
        let path = FirebasePaths.connections(username: username)
        ref = Database.database().reference().child(path)
        //attache an event observer
        observerID = ref.observe(.childAdded, with: {(snapshot) in
            //set data field then alert all observers
            let newValues = [snapshot.key: (snapshot.exists()) ? snapshot.value! as! [String:String] : [:]]
            self.newConnectionHandler(newChildren: newValues)
        }
            , withCancel: {(err) in
                print(err)
                self.acceptedConnections = [:]
                //possibliy bring up warning
        })
        return
    }
    
    //return number of pending requests to commect
    func numberOfAcceptedConnections() -> Int {
        return acceptedConnections.keys.count
    }
    
    

    func getAllAcceptedConnections() -> [String:[String:String]] {
        return acceptedConnections
    }
    
    func newConnectionHandler(newChildren: [String:[String:String]]) {
        let users = newChildren.keys
        for user in users {
            if(newChildren[user]!["accepted"] == "true") {
                //add to accepted and bring up alert if is a new Connection
                if(!acceptedConnections.contains(where: {(key, val) in return key == user})) {
                    //if is a new connection
                    acceptedConnections[user] = newChildren[user]
                    UserDefaults.standard.setValue(acceptedConnections, forKey: "connections")
                    //save persistent data locally
                    DispatchQueue.main.async {
                        guard let presentedVC = Utils.getVisibleViewController() else {
                            return //might want to do something if app is in background
                        }
                        Utils.displayAlert(with: presentedVC, title: "Connection Request Accepted", message: "\(user) Accepted your request to connect", text: "OK")
                    }
                }
                else {
                    acceptedConnections[user] = newChildren[user] //just in case it is an update
                }
                
                
            }
            else {
                //don't add to acceptedConnections, raise alert and remove from DB
                ref.child(FirebasePaths.connections(username: username!)).child(user).removeValue(completionBlock: {(err, dbRef) in
                    if let err = err {
                        print(err)
                        return
                    }
                    else {
                        //no error so data is deleted
                        DispatchQueue.main.async {
                            guard let presentedVC = Utils.getVisibleViewController() else {
                                return //might want to do something if app is in background
                            }
                            Utils.displayAlert(with: presentedVC, title: "Connection Request Denied", message: "\(user) denied your request to connect", text: "OK")
                        }
                    }
                })
            }
        }
        
        
    }
    
    
    
    //remove a pending request
    func removeConnection(username: String) {
    }
    
    //function to try to refresh connection to firebase using the observe method. Useful for network disconnects?
    func reconnect() {
        if let lastObserver = observerID {
            //has an observer attached to firebase so remove it
            ref.removeObserver(withHandle: lastObserver)
        }
        
        //retry connection to firebase
        let path = FirebasePaths.connections(username: self.username!) //username must have been set
        ref = Database.database().reference().child(path)
        //attach an event observer
        observerID = ref.observe(.childAdded, with: {(snapshot) in
            //set data field then alert all observers
            let newValues = (snapshot.exists()) ? snapshot.value as! [String: [String:String]] : [:]
            self.newConnectionHandler(newChildren: newValues)
        }
            , withCancel: {(err) in
                print(err)
                self.acceptedConnections = [:]
                //possibliy bring up warning
        })
    }

}
