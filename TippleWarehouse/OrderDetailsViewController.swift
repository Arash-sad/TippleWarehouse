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
        
        cell.productIdLabel.text = "ProductId:" + String(self.order.products[indexPath.row].productId)
        
        return cell
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }

}
