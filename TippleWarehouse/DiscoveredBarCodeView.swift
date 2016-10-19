//
//  DiscoveredBarCodeView.swift
//  TippleWarehouse
//
//  Created by Arash Sadeghieh E on 18/10/2016.
//  Copyright © 2016 Treepi. All rights reserved.
//

import Foundation
import UIKit

class DiscoveredBarCodeView: UIView {
    
    var borderLayer : CAShapeLayer?
    var corners : [CGPoint]?
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setMyView()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
    func drawBorder(points : [CGPoint]) {
        self.corners = points
        let path = UIBezierPath()
        
        print(points)
        path.move(to: points.first!)
        for i in 1..<points.count {
            path.addLine(to: points[i])
        }
        path.addLine(to: points.first!)
        borderLayer?.path = path.cgPath
    }
    
    func setMyView() {
        borderLayer = CAShapeLayer()
        borderLayer?.strokeColor = UIColor.red.cgColor
        borderLayer?.lineWidth = 2.0
        borderLayer?.fillColor = UIColor.clear.cgColor
        self.layer.addSublayer(borderLayer!)
    }
    
}
