//
//  Paths.swift
//  FriendFinder
//
//  Created by Avi on 8/21/17.
//  Copyright © 2017 Samuel Lee and Avishek Ganguli. All rights reserved.
//

struct FirebasePaths {
    static func uidProfile(uid: String) -> String {
        return "users/\(uid)"
    }
    static func uidProfileUsername(uid: String) -> String {
        return "users/\(uid)/username"
    }
    static func uidProfilePreferredName(uid: String) -> String {
        return "users/\(uid)/name"
    }
    static func usernameProfile(username: String) -> String {
        return "usernames/\(username)"
    }
    static func usernameProfileUid(username: String) -> String {
        return "usernames/\(username)/user_id"
    }
    static func usernameProfileName(username: String) -> String {
        return "usernames/\(username)/name"
    }
    static func connectionRequests(uid: String) -> String {
        return "users/\(uid)/connectionRequests"
    }
    static func userIcons(username: String) -> String {
        return "users/icons/\(username)"
    }
}

