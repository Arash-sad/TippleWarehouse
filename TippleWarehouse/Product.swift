//
//  Product.swift
//  TippleWarehouse
//
//  Created by Arash Sadeghieh E on 17/10/2016.
//  Copyright © 2016 Treepi. All rights reserved.
//

import Foundation

struct Product {
    let productId: Int
    let productName: String
    let quantity: Int
    
    init(productId: Int, productName: String, quantity: Int) {
        self.productId = productId
        self.productName = productName
        self.quantity = quantity
    }
}
