//
//  Item.swift
//  SimpLISTic
//
//  Created by Cameron Laury on 2/22/18.
//  Copyright © 2018 Cameron Laury. All rights reserved.
//

import Foundation

class Item: Codable {
    var title: String = ""
    var done: Bool = false
    var dateCreated: Date?
}
