//
//  ViewController.swift
//  RealmException
//
//  Created by Craig Siemens on 2017-04-04.
//  Copyright © 2017 Craig Siemens. All rights reserved.
//

import RealmSwift
import UIKit

class ViewController: UIViewController {
    
    let realm = try! Realm()
    var tokens: [NotificationToken] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        try! realm.write {
            realm.deleteAll()
        }
        
        let token = realm.objects(Model.self).addNotificationBlock { (change) in
            guard case let .update(objects, _, insertions, _) = change else { return }
            
            for i in insertions {
                // Exception thrown from here which is bubbled up to the second write
                let token = objects[i].addNotificationBlock { (_) in }
                self.tokens.append(token)
            }
        }
        tokens.append(token)
    }
    
    @IBAction func crashButtonPressed(_ sender: Any) {
        // Add an object so that a update change notification needs to be sent
        try! realm.write {
            realm.add(Model())
        }
        
        // Uncommenting this line will fix the issue
//        realm.refresh()
        
        // This is where the crash occurs
        // RealmException[72730:7223932] *** Terminating app due to uncaught exception 'RLMException', reason: 'Wrong transactional state (no active transaction, wrong type of transaction, or transaction already in progress)'
        try! realm.write {
            realm.add(Model())
        }
    }
}

