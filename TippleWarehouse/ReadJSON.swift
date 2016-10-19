//
//  ReadJSON.swift
//  TippleWarehouse
//
//  Created by Arash Sadeghieh E on 17/10/2016.
//  Copyright © 2016 Treepi. All rights reserved.
//

import Foundation

func loadJson(fileName: String) -> [Order]  {
    var orders:[Order] = []
    if let path = Bundle.main.path(forResource: fileName, ofType: "json") {
        if let data = NSData(contentsOfFile: path) {
            do {
                let json = try JSONSerialization.jsonObject(with: data as Data, options: .allowFragments)
                if let ordersArray = json as? [AnyObject] {
                    for order in ordersArray {
                        if let nestedArray = order["products"] as? [AnyObject] {
                            var orderProducts = [Product]()
                            for products in nestedArray {
                                if let productDictionary = products as? [String:Any] {
                                    let product = Product(productId: productDictionary["product_id"] as! Int, productName: productDictionary["product_name"] as! String, quantity: productDictionary["quantity"] as! Int)
                                    orderProducts.append(product)
                                }
                            }
                            let orderObject = Order(orderId: order["order_id"] as! Int, firstName: order["firstname"] as! String, lastName: order["lastname"] as! String, address: order["address"] as! String, suburb: order["suburb"] as! String, postCode: order["postcode"] as! Int, state: order["state"] as! String, country: order["country"] as! String, products: orderProducts, isCollected: false)
                            
                            orders.append(orderObject)
                        }
                    }
                }
            } catch {
                print("Error!! Unable to parse  \(fileName).json")
            }
        }
    }
    return orders
}
