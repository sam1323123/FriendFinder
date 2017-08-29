//
//  TextMessageViewController.swift
//  FriendFinder
//
//  Created by Avi on 8/23/17.
//  Copyright © 2017 Samuel Lee and Avishek Ganguli. All rights reserved.
//

import UIKit
import MessageUI
import ContactsUI

class TextMessageViewController: UIViewController, MFMessageComposeViewControllerDelegate, CNContactPickerDelegate {
    
    var recipients: [String]?
    var body: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presentContacts()
        Utils.getVisibleViewController()?.dismiss(animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    func presentContacts(callback completion: (() -> ())? = nil) {
        let contactsPicker = CNContactPickerViewController()
        contactsPicker.delegate = self
        contactsPicker.predicateForEnablingContact = NSPredicate(format:"phoneNumbers.@count > 0")
        contactsPicker.predicateForSelectionOfContact = NSPredicate(format: "phoneNumbers.@count == 1")
        contactsPicker.displayedPropertyKeys = [CNContactPhoneNumbersKey]
        present(contactsPicker, animated: true, completion: completion)
    }
    
    
    func contactPickerDidCancel(_ picker: CNContactPickerViewController) {
        picker.dismiss(animated: true, completion: nil)
        dismiss(animated: true, completion: nil)
        print("Cancelled contact picker")
    }
    
    // wrapper for additional functionality
    func canSend() -> Bool {
        return MFMessageComposeViewController.canSendText()
    }
    
    
    func contactPicker(_ picker: CNContactPickerViewController, didSelect contacts: [CNContact]) {
        recipients = []
        contacts.forEach { (contact) in
            contact.phoneNumbers.forEach({ (phone) in
                recipients!.append(phone.value.stringValue)
           })
        }
        picker.dismiss(animated: true, completion: {
            [weak self] in
            if (self!.canSend()) {
                self!.composeMessageView(containing: "Hi! FriendFinder has helped making plans way easier! Why don't you join?")
            }
            else {
                DispatchQueue.main.async {
                    Utils.displayAlert(with: MapViewController.currentController!, title: "Sorry!", message: "Your device does not support text messages.", text: "OK", callback: { [weak self] in
                        self?.dismiss(animated: true)
                    })
                }
            }
        })
    }
    
    // returns message view with params
    func composeMessageView(for receivers : [String]? = nil, containing body: String) {
        let receivers = receivers ?? recipients
        let messageVC = MFMessageComposeViewController()
        messageVC.messageComposeDelegate = self
        messageVC.recipients = receivers
        messageVC.body = body
        present(messageVC, animated: true) {
            [weak self] in
            self?.dismiss(animated: true, completion: nil)
        }
    }

    // callback after finish
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        controller.dismiss(animated: true, completion: nil)
    }

}

