//
//  Item.swift
//  Todoey
//
//  Created by dev.ios.ack on 2018/07/14.
//  Copyright © 2018年 Akihito Haga. All rights reserved.
//

import Foundation
import RealmSwift

class Item: Object{
    @objc dynamic var title: String = ""
    @objc dynamic var done: Bool = false
    @objc dynamic var dateCreated: Date?

    var parentCategory = LinkingObjects(fromType: Category.self, property: "items")
}
