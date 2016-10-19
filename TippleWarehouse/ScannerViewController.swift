//
//  ScannerViewController.swift
//  TippleWarehouse
//
//  Created by Arash Sadeghieh E on 18/10/2016.
//  Copyright © 2016 Treepi. All rights reserved.
//

import UIKit
import AVFoundation

class ScannerViewController: UIViewController,AVCaptureMetadataOutputObjectsDelegate {

    var captureSession = AVCaptureSession()
    var previewLayer : AVCaptureVideoPreviewLayer?
    var identifiedBorder : DiscoveredBarCodeView?
    var timer : Timer?
    
    var products:[Product]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("$$$$$$$$$$$$$$$")
        print(self.products)
        print("$$$$$$$$$$$$$")
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
        print("@@@\(captureMetaDataOutput.availableMetadataObjectTypes)")
        // Create a new queue and set delegate for metadata objects scanned.
        
        captureMetaDataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        
        captureSession.startRunning()
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
        previewLayer?.bounds = self.view.bounds
        previewLayer?.bounds.size.height = self.view.bounds.height/2
        previewLayer?.position = CGPoint(x:self.view.bounds.midX,y:self.view.bounds.midY)
        
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
                self.startTimer()
                
            }
            
            // ..check if it is a suported barcode
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
//                        self.barcodeLabel.text = capturedBarcode
                        print("@@@@@@@@@@@@@@@")
                        print(capturedBarcode)
                        print("@@@@@@@@@@@@@@@")
                        self.alertWithTextField(productName: capturedBarcode)
                    })
                    return
                }
            }
            
        }
    }
    
    func alertWithTextField(productName: String) {
        let alert = UIAlertController(title: "Please Enter the Quantity:", message: productName, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler:nil))
        alert.addTextField { (textField) in
            textField.placeholder = "Quantity"
        }
        alert.addAction(UIAlertAction(title: "Enter", style: .default, handler: { (UIAlertAction) in
            if let quantity = alert.textFields?[0].text {
                print("$$$$$$$$$$")
                print(quantity)
            }
        }))
        
        self.present(alert, animated: true, completion: nil)
    }

}
