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

class PendingNotificationObserver: NSObject {
    
    static let sharedInstance: PendingNotificationObserver = {
     return PendingNotificationObserver()
    }()
    
    private var ref: DatabaseReference!
    private var data: [String:String] = [:] //can implement a didset here
    
    private var path: String = ""
    private var observerID: UInt?
    
    override init() {
        super.init()
        path = "users/\(Auth.auth().currentUser!.uid)/connectionRequests"
        ref = Database.database().reference().child(path)
        //attache an event observer
        observerID = ref.observe(.value, with: {(snapshot) in
            self.data = (snapshot.exists()) ? snapshot.value as! [String: String] : [:] }
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
    
    
    
    
}
