//
//  ScannerViewController.swift
//  TippleWarehouse
//
//  Created by Arash Sadeghieh E on 18/10/2016.
//  Copyright © 2016 Treepi. All rights reserved.
//

import UIKit
import AVFoundation

protocol updateCompletedOrder {
    func updateOrder()
}

class ScannerViewController: UIViewController,AVCaptureMetadataOutputObjectsDelegate, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var navigationBar: UINavigationBar!
    
    var captureSession = AVCaptureSession()
    var previewLayer : AVCaptureVideoPreviewLayer?
    var identifiedBorder : DiscoveredBarCodeView?
    var timer : Timer?
    
    var products:[Product]!
    var producIds = [Int]()
    
    var delegate: updateCompletedOrder?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        for product in products {
            self.producIds.append(product.productId)
        }
        self.navigationBar.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 80)
        
        // Start Capture
        do {
            let captureDevice = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
            let input = try AVCaptureDeviceInput(device: captureDevice)
            
            self.captureSession.addInput(input)
        } catch let error as NSError {
            print(error)
        }
        addPreviewLayer()
        
        identifiedBorder = DiscoveredBarCodeView(frame: self.view.bounds)
        identifiedBorder?.backgroundColor = UIColor.clear
        identifiedBorder?.isHidden = true;
        self.view.addSubview(identifiedBorder!)
        
        //Check for meta-data
        let captureMetaDataOutput = AVCaptureMetadataOutput()
        self.captureSession.addOutput(captureMetaDataOutput)
        
        captureMetaDataOutput.metadataObjectTypes = captureMetaDataOutput.availableMetadataObjectTypes
        // Create a new queue and set delegate for metadata objects scanned.
        
        captureMetaDataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        
        // Start scan items if order has not been packed
        if self.products[0].isScanned == false {
            captureSession.startRunning()
        } else {
            alertForCompletedOrders(title: "Packed Already!", message: "This order is completed!")
        }
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.captureSession.stopRunning()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Add Preview Layer
    func addPreviewLayer() {
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
        previewLayer?.frame = CGRect(x: 0, y: self.view.bounds.height/2, width: self.view.bounds.width, height: self.view.bounds.height/2)
//        previewLayer?.position = CGPoint(x:self.view.bounds.midX,y:self.view.bounds.midY)
        self.view.layer.addSublayer(previewLayer!)
    }
    
    // Helper Functions
    
    func translatePoints(points : [AnyObject], fromView : UIView, toView: UIView) -> [CGPoint] {
        var translatedPoints : [CGPoint] = []
        for point in points {
            let dict = point as! NSDictionary
            let x = CGFloat((dict.object(forKey: "X") as! NSNumber).floatValue)
            let y = CGFloat((dict.object(forKey: "Y") as! NSNumber).floatValue)
            let curr = CGPoint(x:x,y:y)
            let currFinal = fromView.convert(curr, to: toView)
            translatedPoints.append(currFinal)
        }
        return translatedPoints
    }
    
    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [Any]!, from connection: AVCaptureConnection!) {
        
        var capturedBarcode: String
        // Speify the barcodes you want to read
        let supportedBarcodeTypes = [AVMetadataObjectTypeUPCECode, AVMetadataObjectTypeCode39Code, AVMetadataObjectTypeCode39Mod43Code,
                                     AVMetadataObjectTypeEAN13Code, AVMetadataObjectTypeEAN8Code, AVMetadataObjectTypeCode93Code, AVMetadataObjectTypeCode128Code,
                                     AVMetadataObjectTypePDF417Code, AVMetadataObjectTypeQRCode, AVMetadataObjectTypeAztecCode]
        
        for data in metadataObjects {
            let metaData = data as! AVMetadataObject
            let transformed = previewLayer?.transformedMetadataObject(for: metaData) as? AVMetadataMachineReadableCodeObject
            if let unwraped = transformed {
                identifiedBorder?.frame = unwraped.bounds
                identifiedBorder?.isHidden = false
                let identifiedCorners = self.translatePoints(points: unwraped.corners as [AnyObject], fromView: self.view, toView: self.identifiedBorder!)
                identifiedBorder?.drawBorder(points: identifiedCorners)
                self.identifiedBorder?.isHidden = false
//                self.startTimer()
                
            }
            
            // Check if it is a suported barcode
            for supportedBarcode in supportedBarcodeTypes {
                
                if supportedBarcode == (data as AnyObject).type {
                    // This is a supported barcode
                    // Note barcodeMetadata is of type AVMetadataObject
                    // AND barcodeObject is of type AVMetadataMachineReadableCodeObject
                    let barcodeObject = self.previewLayer!.transformedMetadataObject(for: data as! AVMetadataObject)
                    capturedBarcode = (barcodeObject as! AVMetadataMachineReadableCodeObject).stringValue
                    // Got the barcode. Set the text in the UI and break out of the loop.
                    
                    DispatchQueue.main.async(execute: { () -> Void in
                        self.captureSession.stopRunning()
                        let productId = self.barcodeToProductId(barcode: capturedBarcode)
                        if (productId == 0  || !self.producIds.contains(productId)) {
                            self.alert(title: "Wrong Product!", message: "You have scanned the wrong item. Do not take it!")
                        } else {
                            for var product in self.products {
                                if (product.productId == productId && product.isScanned == false) {
                                    product.isScanned = true
                                    self.tableView.reloadData()
                                    self.alertForCorrectItem(productName: product.productName,quantity: String(product.quantity))
                                } else if (product.productId == productId && product.isScanned == true) {
                                    self.alert(title: "Scanned Already!", message: "You have scanned this item before, please double check your bag!")
                                }
                            }
                        }
                        
                    })
                    return
                }
            }
            
        }
    }
    
    func startTimer() {
        if timer?.isValid != true {
            timer = Timer.scheduledTimer(timeInterval: 0.2, target: self, selector: #selector(ScannerViewController.removeBorder), userInfo: nil, repeats: false)
        } else {
            timer?.invalidate()
        }
    }
    
    func removeBorder() {
        // Remove the identified border
        self.identifiedBorder?.isHidden = true
        captureSession.startRunning()
    }
    
    func alertForCorrectItem(productName: String, quantity: String) {
        let alert = UIAlertController(title: "Quantity:\(quantity)", message: productName, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (UIAlertAction) in
            
            var scanned = [Bool]()
            for product in self.products {
                scanned.append(product.isScanned)
            }
            if !scanned.contains(false) {
                self.alertForCompletedOrders(title: "Great Job!", message: "You have finished this order!")
                self.delegate?.updateOrder()
            } else {
                self.removeBorder()
            }
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func alertForCompletedOrders(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (UIAlertAction) in
            self.dismiss(animated: true, completion: nil)
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func alert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (UIAlertAction) in
            self.removeBorder()
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func barcodeToProductId(barcode: String) -> Int {
        switch barcode {
        case "93258081":
            return 1
        case "9343529000160":
            return 2
        case "9345663000792":
            return 3
        default:
            return 0
        }
    }

    @IBAction func cancelBarButtonItem(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - UITableViewDataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.products.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ScannerCell") as! ScannerTableViewCell
        
        if self.products[indexPath.row].isScanned == false {
            cell.accessoryType = UITableViewCellAccessoryType.none
        } else {
            cell.accessoryType = UITableViewCellAccessoryType.checkmark
        }
        
        cell.productLabel.text = self.products[indexPath.row].productName + " X " + String(self.products[indexPath.row].quantity)
        
        return cell
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}
