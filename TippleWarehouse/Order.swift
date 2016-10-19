//
//  Order.swift
//  TippleWarehouse
//
//  Created by Arash Sadeghieh E on 17/10/2016.
//  Copyright © 2016 Treepi. All rights reserved.
//

import Foundation

struct Order {
    
    let orderId: Int
    let firstName: String
    let lastName: String
    let address: String
    let suburb: String
    let postCode: Int
    let state: String
    let country: String
    let products: [Product]
    let isCollected: Bool
    
    init(orderId: Int, firstName: String, lastName: String, address: String, suburb: String, postCode: Int, state: String, country: String, products: [Product], isCollected: Bool) {
        self.orderId = orderId
        self.firstName = firstName
        self.lastName = lastName
        self.address = address
        self.suburb = suburb
        self.postCode = postCode
        self.state = state
        self.country = country
        self.products = products
        self.isCollected = isCollected
    }
    
}
