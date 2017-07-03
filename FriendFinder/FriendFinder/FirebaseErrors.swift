//
//  FirebaseErrors.swift
//  FriendFinder
//
//  Created by Samuel Lee on 7/1/17.
//  Copyright © 2017 Samuel Lee and Avishek Ganguli. All rights reserved.
//

import Foundation
import FirebaseAuth


public class FirebaseErrors {
    
    public static let errors : [AuthErrorCode:(String, String)] =
        [
        .networkError: (title: "No network!", message: "Please try again after connecting to the network."),
        .userNotFound: (title: "User account not found!", message: "It appears your account has been deleted."),
        .userTokenExpired: (title: "You have been logged out.", message: "Please login again."),
        .tooManyRequests: (title: "Login error!", message: "Please try again later."),
        .invalidEmail: (title: "Invalid email address!", message: "Please enter a valid email address."),
        .emailAlreadyInUse: (title: "Email is already in use!", message: "Please use another email address."),
        .userDisabled: (title: "Account has been disabled!", message: "Please check email for instructions."),
        .wrongPassword: (title: "Wrong Password entered!", message: "Please try again."),
        .invalidUserToken: (tile: "Session has expired!", message: "Please login again."),
        .operationNotAllowed: (title: "Email sign in not enabled!", message: "Check Firebase Config.")
    ]

}
