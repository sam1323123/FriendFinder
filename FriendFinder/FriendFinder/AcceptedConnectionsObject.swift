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
    private var acceptedConnections: [String:[String:String]] = [:]
    /*(UserDefaults.standard.dictionary(forKey: "connections")  ?? [:]) as! [String:[String:String]]*/
    private var observerID: UInt?
    private var username: String?
    private var currentVc: UIViewController?
    private var unhandledRequests: [String:[String:String]] = [:]
    private var didHandleBeforeObserving = false //used only on startup. See observing function
    
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
        let path = FirebasePaths.connectionRequestReply(username: username)
        ref = Database.database().reference()
        //attache an event observer
        ref.child(path).observeSingleEvent(of: .value, with: {(snapshot) in
            
            if(snapshot.exists()) {
                var allReplies = snapshot.value as! [String: [String:String]]
                var accepted: [String] = [] //currently not used
                for reply in allReplies.keys {
                    if allReplies[reply]?["accepted"] == "true" {
                        accepted.append(reply)
                    }
                    self.cleanupHandledRequest(entryID: reply) //cleanup from db
                }
                self.didHandleBeforeObserving = accepted.count > 0
            }
            
            self.observationFunction() //begin observation

        }, withCancel: {(err) in
            print("Err reading on acceptedNotif start: \(err)")
            })
        
        
        return
    }
    
    
    //function used for observing firebase in this object
    func observationFunction() {
        
        observerID = ref.child(FirebasePaths.connectionRequestReply(username: username!)).observe(.childAdded, with: {(snapshot) in
            //set data field then alert all observers
            print("New Value added")
            let newValues = (snapshot.exists()) ? snapshot.value as! [String:String] : [:]
            self.newConnectionHandler(user: snapshot.key, response: newValues)
        }
            , withCancel: {(err) in
                print(err)
                self.acceptedConnections = [:]
                //possibliy bring up warning
        })
        
    }
    
    //return number of pending requests to commect
    func numberOfAcceptedConnections() -> Int {
        return acceptedConnections.keys.count
    }
    
    

    func getAllAcceptedConnections() -> [String:[String:String]] {
        return acceptedConnections
    }
    
    func newConnectionHandler(user: String, response: [String:String]) {
        UserDefaults.standard.removeObject(forKey: "connections")
        if(response["accepted"] == "true") {
            //add to accepted and bring up alert if is a new Connection
            
            //if is a new connection
            acceptedConnections[user] = response
            //UserDefaults.standard.setValue(acceptedConnections, forKey: "connections")
            
            //save persistent data locally
            DispatchQueue.main.async {
                guard let presentedVC =  self.currentVc else {
                    return //might want to do something if app is in background
                }
                print("to display alert")
                self.unhandledRequests[user] = response //add as unhandled first
                var insertionText: String
                if self.didHandleBeforeObserving {
                    insertionText = "Multiple Users"
                    //multiple users added on start but did not notify user of all of them
                    self.didHandleBeforeObserving = false
                }
                else {
                    insertionText = "\(user)"
                }
                Utils.displayAlert(with: presentedVC, title: "Connection Request Accepted", message: "\(insertionText) Accepted your request to connect", text: "OK",callback: {() in
                    //cleanup db and unhandledArray
                    self.unhandledRequests.removeValue(forKey: user)
                    self.cleanupHandledRequest(entryID: user)
                })
            
            }
        
            
        }
        else {
            //raise alert and remove from DB
            ref.child(FirebasePaths.connectionRequestReply(username: username!)).child(user).removeValue(completionBlock: {(err, dbRef) in
                if let err = err {
                    print(err)
                    return
                }
                else {
                    //no error so data is deleted
                    DispatchQueue.main.async {
                        guard let presentedVC =  self.currentVc else {
                            return //might want to do something if app is in background
                        }
                        print("to display alert")
                        //only do cleanup, no need to alert
                        self.cleanupHandledRequest(entryID: user)

                    }
                }
            })
        }
        
        
    }
    
    
    
    //cleanup entries from database if handled
    func cleanupHandledRequest(entryID:String) {
        print("To CLEANUP \(entryID)")
        
        ref.child(FirebasePaths.connectionRequestReply(username: username!)).child(entryID).removeValue(completionBlock: {(err, dbref) in
            if let err = err {
                print("Couldn't remove from requuesReply due to: \(err)")
                return
            }
            else {
                //remove from connectionRequested
                self.ref.child(FirebasePaths.connectionRequested(uid: Auth.auth().currentUser!.uid)).child(entryID).removeValue(completionBlock: {
                    (err2, dbref2) in
                        if let err2 = err2 {
                            print("Couldn't remove from connrequested due to: \(err2)")
                            return
                        }
                    })
            }
        })
    }
    
    
    
    
    //function to try to refresh connection to firebase using the observe method. Useful for network disconnects?
    func reconnect() {
        if let lastObserver = observerID {
            //has an observer attached to firebase so remove it
            ref.removeObserver(withHandle: lastObserver)
        }
        
        //retry connection to firebase
        let path = FirebasePaths.connectionRequestReply(username: self.username!) //username must have been set
        ref = Database.database().reference().child(path)
        //attach an event observer
        observerID = ref.observe(.childAdded, with: {(snapshot) in
            //set data field then alert all observers
            let newValues = (snapshot.exists()) ? snapshot.value as! [String:String] : [:]
            self.newConnectionHandler(user: snapshot.key, response: newValues)
        }
            , withCancel: {(err) in
                print(err)
                self.acceptedConnections = [:]
                //possibliy bring up warning
        })
    }
    
    
    //registers an object to handle changes to number of Pending notifications
    func registerObserver(observer: UIViewController) {
        currentVc = observer
    }
    
    //remove an observer
    func removeObserver(observer: UIViewController) {
        currentVc = nil
    }

}

