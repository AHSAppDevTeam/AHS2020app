//
//  alpha:developer.swift
//  AHS20
//
//  Created by Richard Wei on 8/21/20.
//  Copyright © 2020 AHS. All rights reserved.
//

import Foundation
import UIKit
import FirebaseDatabase
import Firebase

func setUpDevConfigs(){
    print("set up testing notif")
    Messaging.messaging().subscribe(toTopic: "testing");
}

func resetAllSettingsDefaults() {
    let defaults = UserDefaults.standard
    let dictionary = defaults.dictionaryRepresentation()
    dictionary.keys.forEach { key in
        defaults.removeObject(forKey: key)
    }
}
