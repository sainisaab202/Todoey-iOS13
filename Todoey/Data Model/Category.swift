//
//  Category.swift
//  Todoey
//
//  Created by GurPreet SaiNi on 2024-04-03.
//  Copyright © 2024 App Brewery. All rights reserved.
//

import Foundation
import RealmSwift

class Category: Object{
    //marking dynamic as we want to monitor this property by realm
    @objc dynamic var name: String = ""
    @objc dynamic var colorCode: String = ""
    
    //relationship 1:M
    let items = List<Item>()
}
