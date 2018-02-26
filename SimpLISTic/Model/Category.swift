//
//  Category.swift
//  SimpLISTic
//
//  Created by Cameron Laury on 2/26/18.
//  Copyright © 2018 Cameron Laury. All rights reserved.
//

import Foundation
import RealmSwift

class Category: Object {
    
    @objc dynamic var name: String = ""
    @objc dynamic var color: String = ""
    
    let items = List<Item>()
}
