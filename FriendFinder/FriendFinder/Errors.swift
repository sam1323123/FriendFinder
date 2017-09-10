//
//  FirebaseErrors.swift
//  FriendFinder
//
//  Created by Samuel Lee on 7/1/17.
//  Copyright © 2017 Samuel Lee and Avishek Ganguli. All rights reserved.
//

import Foundation
import FirebaseAuth
import GooglePlaces


public class Errors {
    
    public static let firebaseErrors : [AuthErrorCode:(String, String)] =
        [
        .networkError: (title: "No network!", message: "Please try again after connecting to the network."),
        .userNotFound: (title: "User account not found!", message: "There is no account with this email. Your account could have been deleted."),
        .userTokenExpired: (title: "You have been logged out.", message: "Please login again."),
        .tooManyRequests: (title: "Login error!", message: "Please try again later."),
        .invalidEmail: (title: "Invalid email address!", message: "Please enter a valid email address."),
        .emailAlreadyInUse: (title: "Email is already in use!", message: "Please use another email address."),
        .userDisabled: (title: "Account has been disabled!", message: "Please check email for instructions."),
        .wrongPassword: (title: "Wrong Password entered!", message: "Please try again."),
        .invalidUserToken: (tile: "Session has expired!", message: "Please login again."),
        .operationNotAllowed: (title: "Email sign in not enabled!", message: "Shouldn't happen!"),
        .keychainError: (title: "Error occurred while accessing keychain.", message: "Please try again later.")
    ]
    
    public static let placeErrors : [GMSPlacesErrorCode:(String, String)] =
        [
            .networkError: (title: "No network!", message: "Please try again after connecting to the network."),
            .serverError: (title: "Server Error!", message: "Our server reported a problem."),
            .internalError: (title: "Error!", message: "Please try again later."),
            .keyInvalid: (title: "Error!", message: "Please try again later."),
            .keyExpired: (title: "Error!", message: "Please try again later."),
            .usageLimitExceeded: (title: "Error!", message: "Please try again later."),
            .rateLimitExceeded: (title: "Error!", message: "Please try again later."),
            .deviceRateLimitExceeded: (title: "Too Many Requests!", message: "Please try again later."),
            .accessNotConfigured: (title: "Error!", message: "Please try again later."),
            .incorrectBundleIdentifier: (title: "Error!", message: "Please try again later."),
            .locationError: (title: "Location Error!", message: "We could not find your location."),

            
        ]
    
    

}
