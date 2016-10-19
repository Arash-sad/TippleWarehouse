//
//  Product.swift
//  TippleWarehouse
//
//  Created by Arash Sadeghieh E on 17/10/2016.
//  Copyright © 2016 Treepi. All rights reserved.
//

import Foundation

class Product {
    let productId: Int
    let productName: String
    let quantity: Int
    var isScanned: Bool
    
    init(productId: Int, productName: String, quantity: Int, isScanned: Bool) {
        self.productId = productId
        self.productName = productName
        self.quantity = quantity
        self.isScanned = isScanned
    }
}
