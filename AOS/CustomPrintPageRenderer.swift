//
//  CustomPrintPageRenderer.swift
//  AOS
//
//  Created by SSIT on 11.10.18.
//  Copyright © 2018 SSIT. All rights reserved.
//


import UIKit

class CustomPrintPageRenderer: UIPrintPageRenderer {
    
    let A4PageWidth: CGFloat = 595.2
    
    let A4PageHeight: CGFloat = 841.8
    
    
    override init() {
        super.init()
        
        // Specify the frame of the A4 page.
        let pageFrame = CGRect(x: 0.0, y: 0.0, width: A4PageWidth, height: A4PageHeight)
        
        // Set the page frame.
        self.setValue(NSValue(cgRect: pageFrame), forKey: "paperRect")
        
        // Set the horizontal and vertical insets (that's optional).
        // self.setValue(NSValue(CGRect: pageFrame), forKey: "printableRect")
        self.setValue(NSValue(cgRect: pageFrame.insetBy(dx: 10.0, dy: 10.0)), forKey: "printableRect")
        
        
        self.headerHeight = 50.0
        self.footerHeight = 50.0
        
        let headerText: NSString = "/Users/ssit/Documents/5CHIF/AOS/AOS/as_logo.png"
        headerText.draw(at: CGPoint(x: 0, y: 40))
        
    }
    
    func getTextSize(text: String, font: UIFont!, textAttributes: [NSAttributedStringKey: Any]! = nil) -> CGSize {
        let testLabel = UILabel(frame: CGRect(x: 0.0, y: 0.0, width: self.paperRect.size.width, height: footerHeight))
        if let attributes = textAttributes {
            testLabel.attributedText = NSAttributedString(string: text, attributes: attributes)
        }
        else {
            testLabel.text = text
            testLabel.font = font!
        }
        
        testLabel.sizeToFit()
        
        return testLabel.frame.size
    }
    
}
