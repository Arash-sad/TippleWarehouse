//
//  OrderDetailsViewController.swift
//  TippleWarehouse
//
//  Created by Arash Sadeghieh E on 18/10/2016.
//  Copyright © 2016 Treepi. All rights reserved.
//

import UIKit

class OrderDetailsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    var order:Order!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Add Scan bar Button Item to Navigation Controller
        let rightBarButton = UIBarButtonItem(title: "Scan", style: .plain, target: self, action: #selector(OrderDetailsViewController.scannerCameraView))
        self.navigationItem.setRightBarButton(rightBarButton, animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Helper Function - Navigate to Scanner
    func scannerCameraView() {
        performSegue(withIdentifier: "ScannerSegue", sender: nil)
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ScannerSegue" {
            let scannerVC = segue.destination as? ScannerViewController
            
            scannerVC?.products = self.order.products
            scannerVC?.delegate = self
        }
    }

    // MARK: - UITableViewDataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.order.products.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "OrderDetailsCell") as! OrderDetailsTableViewCell
        
        if self.order.isCollected == false {
            cell.accessoryType = UITableViewCellAccessoryType.none
        } else {
            cell.accessoryType = UITableViewCellAccessoryType.checkmark
        }
        
        cell.productNameLabel.text = self.order.products[indexPath.row].productName
        cell.productQuantityLabel.text = String(self.order.products[indexPath.row].quantity)
        
        return cell
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}

// MARK: - Protocol function implementation
extension OrderDetailsViewController: updateCompletedOrder {
    func updateOrder() {
        for product in self.order.products {
            product.isScanned = true
        }
        self.order.isCollected = true
        self.tableView.reloadData()
    }
}
