//
//  Item.swift
//  SimpLISTic
//
//  Created by Cameron Laury on 2/26/18.
//  Copyright © 2018 Cameron Laury. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift

class Item: Object {
    
    @objc dynamic var title: String = ""
    @objc dynamic var done: Bool = false
    @objc dynamic var dateCreated: Date?
    
    var parentCategory = LinkingObjects(fromType: Category.self, property: "items")
}
