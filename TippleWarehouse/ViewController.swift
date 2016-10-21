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
    var completedOrders:[Order] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "Orders"
        
        //Read from JSON file
        self.orders = loadJson(fileName: "orders")
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        for i:Int in 0...(orders.count - 1) {
            if orders[i].isCollected == true {
                self.completedOrders.append(orders[i])
                self.orders.remove(at: i)
                break
            }
        }
        self.tableView.reloadData()
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "OrderDetailSegue" {
            let orderDetailVC = segue.destination as? OrderDetailsViewController
            let indexPath = self.tableView.indexPathForSelectedRow
            
            if self.orders.count == 0 {
                orderDetailVC?.order = self.completedOrders[indexPath!.row]
            } else if self.completedOrders.count == 0 {
                orderDetailVC?.order = self.orders[indexPath!.row]
            } else {
                if indexPath?.section == 0 {
                    orderDetailVC?.order = self.orders[indexPath!.row]
                } else {
                    orderDetailVC?.order = self.completedOrders[indexPath!.row]
                }
            }
        }
    }

    // MARK: - UITableViewDataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if (self.orders.count == 0 || self.completedOrders.count == 0) {
            return 1
        } else {
            return 2
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if self.orders.count == 0 {
            return "Completed"
        } else if self.completedOrders.count == 0 {
            return "New"
        } else {
            if section == 0 {
                return "New"
            } else {
                return "Completed"
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.orders.count == 0 {
            return self.completedOrders.count
        } else if self.completedOrders.count == 0 {
            return self.orders.count
        } else {
            if section == 0 {
                return self.orders.count
            } else {
                return self.completedOrders.count
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "OrderCell") as! OrderTableViewCell
        
        if self.orders.count == 0 {
            cell.accessoryType = UITableViewCellAccessoryType.checkmark
            
            cell.orderIdLabel.text = String(self.completedOrders[indexPath.row].orderId)
            cell.nameLabel.text = self.completedOrders[indexPath.row].firstName + " " + self.completedOrders[indexPath.row].lastName
            cell.addressLabel.text = self.completedOrders[indexPath.row].address + " " + self.completedOrders[indexPath.row].suburb + " " + self.completedOrders[indexPath.row].state + " " + String(self.completedOrders[indexPath.row].postCode) + " " + self.completedOrders[indexPath.row].country
        } else if self.completedOrders.count == 0 {
            cell.accessoryType = UITableViewCellAccessoryType.none
            
            cell.orderIdLabel.text = String(self.orders[indexPath.row].orderId)
            cell.nameLabel.text = self.orders[indexPath.row].firstName + " " + self.orders[indexPath.row].lastName
            cell.addressLabel.text = self.orders[indexPath.row].address + " " + self.orders[indexPath.row].suburb + " " + self.orders[indexPath.row].state + " " + String(self.orders[indexPath.row].postCode) + " " + self.orders[indexPath.row].country
        } else {
            if indexPath.section == 0 {
                cell.accessoryType = UITableViewCellAccessoryType.none
                
                cell.orderIdLabel.text = String(self.orders[indexPath.row].orderId)
                cell.nameLabel.text = self.orders[indexPath.row].firstName + " " + self.orders[indexPath.row].lastName
                cell.addressLabel.text = self.orders[indexPath.row].address + " " + self.orders[indexPath.row].suburb + " " + self.orders[indexPath.row].state + " " + String(self.orders[indexPath.row].postCode) + " " + self.orders[indexPath.row].country
            } else {
                cell.accessoryType = UITableViewCellAccessoryType.checkmark
                
                cell.orderIdLabel.text = String(self.completedOrders[indexPath.row].orderId)
                cell.nameLabel.text = self.completedOrders[indexPath.row].firstName + " " + self.completedOrders[indexPath.row].lastName
                cell.addressLabel.text = self.completedOrders[indexPath.row].address + " " + self.completedOrders[indexPath.row].suburb + " " + self.completedOrders[indexPath.row].state + " " + String(self.completedOrders[indexPath.row].postCode) + " " + self.completedOrders[indexPath.row].country
            }
        }
        
        return cell
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "OrderDetailSegue", sender: nil)
    }

}

