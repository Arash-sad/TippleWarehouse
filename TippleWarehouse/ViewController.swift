//
//  ViewController.swift
//  TippleWarehouse
//
//  Created by Arash Sadeghieh E on 16/10/2016.
//  Copyright © 2016 Treepi. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    var orders:[Order] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Read from JSON file
        self.orders = loadJson(fileName: "orders")
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "OrderDetailSegue" {
            let orderDetailVC = segue.destination as? OrderDetailsViewController
            let indexPath = self.tableView.indexPathForSelectedRow
            orderDetailVC?.order = self.orders[indexPath!.row]
        }
    }

    // MARK: - UITableViewDataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
//    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//        if section == 0 {
//            return "Waiting for Packing"
//        } else {
//            return "Collected"
//        }
//    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.orders.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "OrderCell") as! OrderTableViewCell
        
        cell.orderIdLabel.text = "OrderId:" + String(self.orders[indexPath.row].orderId)
        
        return cell
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "OrderDetailSegue", sender: nil)
    }
    
    

}

