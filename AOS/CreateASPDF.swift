//
//  InvoiceComposer.swift
//  AOS
//
//  Created by SSIT on 11.10.18.
//  Copyright © 2018 SSIT. All rights reserved.
//

import UIKit
import Alamofire

class CreateASPDF: NSObject {
    
    let pathToInvoiceHTMLTemplate = Bundle.main.path(forResource: "invoice", ofType: "html")
    
    let logoImageURL = "http://aos.ssit.at/assets/img/rz_logo.jpg"
    
    var invoiceNumber: String!
    
    var pdfFilename: String!
    
    var URL_GET_AS = "http://aos.ssit.at/php/v1/getAS.php?asid="
    var URL_GET_ASArticle = "http://aos.ssit.at/php/v1/getOffeneASArticle.php?asid="
    var _as = [String]()
    var article = [String]()
    var asid = -1
    
    override init() {
        super.init()
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
    
    func renderInvoice(invoiceNumber: String, invoiceDate: String, recipientInfo: String, as_: [String], article: [String]) -> String! {
        // Store the invoice number for future use.
        self.invoiceNumber = invoiceNumber
        print(as_)
        print(article)
        do {
            // Load the invoice HTML template code into a String variable.
            var HTMLContent = try String(contentsOfFile: pathToInvoiceHTMLTemplate!)
            
            // Replace all the placeholders with real values except for the items.
            // The logo image.
            HTMLContent = HTMLContent.replacingOccurrences(of: "#LOGO_IMAGE#", with: logoImageURL)
            
            // Invoice number.
            HTMLContent = HTMLContent.replacingOccurrences(of: "#AS_NUMBER#", with: "35")
            
            // Invoice date.
            HTMLContent = HTMLContent.replacingOccurrences(of: "#INVOICE_DATE#", with: invoiceDate)
            
            // Recipient info.
            HTMLContent = HTMLContent.replacingOccurrences(of: "#RECIPIENT_INFO#", with: recipientInfo.replacingOccurrences(of: "\n", with: "<br>"))
            
            // The invoice items will be added by using a loop.
            var allItems = ""
            
            // For all the items except for the last one we'll use the "single_item.html" template.
            // For the last one we'll use the "last_item.html" template.
            // Set the items.
            HTMLContent = HTMLContent.replacingOccurrences(of: "#ITEMS#", with: allItems)
            
            // The HTML code is ready.
            return HTMLContent
            
        }
        catch {
            print("Unable to open and use HTML template files.")
        }
        
        return nil
    }
    
    
    func exportHTMLContentToPDF(HTMLContent: String) {
        let printPageRenderer = CustomPrintPageRenderer()
        
        let printFormatter = UIMarkupTextPrintFormatter(markupText: HTMLContent)
        printPageRenderer.addPrintFormatter(printFormatter, startingAtPageAt: 0)
        
        let pdfData = drawPDFUsingPrintPageRenderer(printPageRenderer: printPageRenderer)
        
        if(getDocumentsDirectory().relativePath != nil && invoiceNumber != nil){
            if(getDocumentsDirectory().relativePath.last == "/"){
                pdfFilename = getDocumentsDirectory().relativePath + "Invoice" + String(invoiceNumber) + ".pdf"
            }else{
                pdfFilename = getDocumentsDirectory().relativePath + "/Invoice" + String(invoiceNumber) + ".pdf"
            }
            pdfData?.write(toFile: pdfFilename, atomically: true)
        }
    }
    
    
    func drawPDFUsingPrintPageRenderer(printPageRenderer: UIPrintPageRenderer) -> NSData! {
        let data = NSMutableData()
        
        UIGraphicsBeginPDFContextToData(data, CGRect.zero, nil)
        for i in 0..<printPageRenderer.numberOfPages {
            UIGraphicsBeginPDFPage()
            printPageRenderer.drawPage(at: i, in: UIGraphicsGetPDFContextBounds())
        }
        
        UIGraphicsEndPDFContext()
        
        return data
    }
    
}
