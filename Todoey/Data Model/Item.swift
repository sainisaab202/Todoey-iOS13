//
//  Item.swift
//  Todoey
//
//  Created by GurPreet SaiNi on 2024-04-03.
//  Copyright © 2024 App Brewery. All rights reserved.
//

import Foundation
import RealmSwift

class Item: Object{
    @objc dynamic var title: String = ""
    @objc dynamic var done: Bool = false
    @objc dynamic var dateCreated: Date?
    
    //relationship
    var parentCategory = LinkingObjects(fromType: Category.self, property: "items")
}
