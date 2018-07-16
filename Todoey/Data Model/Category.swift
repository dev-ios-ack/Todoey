//
//  Category.swift
//  Todoey
//
//  Created by dev.ios.ack on 2018/07/14.
//  Copyright © 2018年 Akihito Haga. All rights reserved.
//

import Foundation
import RealmSwift

class Category: Object{
    @objc dynamic var name: String = ""
    let items = List<Item>()
    
}
