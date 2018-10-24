//
//  PreviewASController.swift
//  AOS
//
//  Created by SSIT on 12.10.18.
//  Copyright © 2018 SSIT. All rights reserved.
//

import Foundation
import UIKit
import MessageUI
import Alamofire

class PreviewASController: UIViewController , MFMailComposeViewControllerDelegate{
    
    @IBOutlet weak var webPreview: UIWebView!
    
    var invoiceInfo: [String: AnyObject]!

    var invoiceComposer: CreateASPDF!

    var HTMLContent: String!


    var URL_GET_AS = "http://aos.ssit.at/php/v1/getAS.php?asid="
    var URL_GET_ASArticle = "http://aos.ssit.at/php/v1/getOffeneASArticle.php?asid="
    var _as = [String]()
    var article = [String]()
    var asid = -1
    
    
    override func viewDidLoad() {
        self.webPreview.frame = self.view.bounds
        self.webPreview.scalesPageToFit = true
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }


    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        createInvoiceAsHTML()
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */

    // MARK: IBAction Methods


    
    @IBAction func exportToPDF(_ sender: Any) {
        invoiceComposer.exportHTMLContentToPDF(HTMLContent: HTMLContent)
        showOptionsAlert()
    }
    

    // MARK: Custom Methods

    func createInvoiceAsHTML() {
        invoiceComposer = CreateASPDF()
        asid = 13
        URL_GET_AS += String(asid)
        // Details des AS holen und laden
        Alamofire.request(URL_GET_AS, method: .get).responseJSON{
            response in
            if let result = response.result.value{
                let jsonData = result as! NSDictionary
                
                if(!(jsonData.value(forKey: "error") as! Bool)){
                    let As = jsonData.value(forKey: "AS") as! NSArray
                    let AsDescr = jsonData.value(forKey: "ASDescr") as! NSArray
                    let TTDescr = jsonData.value(forKey: "ASTTDescr") as! NSArray
                    let TKDescr = jsonData.value(forKey: "ASTKDescr") as! NSArray
                    let adescr = AsDescr.value(forKey: "description") as! NSArray
                    let cname = As.value(forKey: "companyname") as! NSArray
                    let tdescr = TTDescr.value(forKey: "description") as! NSArray
                    let tkdescr = TKDescr.value(forKey: "description") as! NSArray
                    let dfrom = As.value(forKey: "dateFrom") as! NSArray
                    let dto   = As.value(forKey: "dateTo") as! NSArray
                    let tfrom = As.value(forKey: "timeFrom") as! NSArray
                    let tto = As.value(forKey: "timeTo") as! NSArray
                    let kzeit = As.value(forKey: "kulanzzeit") as! NSArray
                    let kgrund = As.value(forKey: "kulanzgrund") as! NSArray
                    let AS = As.mutableCopy() as! NSMutableArray
                    
                    for i in 0..<AS.count{
                        var a = adescr[i] as! String + ";" //Beschreibung
                        a += (cname[i] as! String) + ";" //Kunde
                        a += (tdescr[i] as! String) + ";" //Termintyp
                        a += (tkdescr[i] as! String) + ";" //Taetigkeitsart
                        a += dfrom[i] as! String + ";" //Datum von
                        
                        if(dto[i] is NSNull){ //Datum bis
                            a += "0000-00-00;"
                        }else{
                            a += dto[i] as! String + ";"
                        }
                        
                        a += tfrom[i] as! String + ";" //Uhrzeit von
                        
                        if(tto[i] is NSNull){ //Uhrzeit bis
                            a += "00:00:00;"
                        }else{
                            a += tto[i] as! String + ";"
                        }
                        
                        if(kzeit[i] is NSNull){
                            a += "0;"
                        }else{
                            a += kzeit[i] as! String + ";" //Kulanzzeit
                        }
                        
                        if(kgrund[i] is NSNull){
                            a += "Keine Kulanzzeit;"
                        }else{
                           a += kgrund[i] as! String + ";" //Kulanzgrung
                        }
                        
                        self._as.append(a)
                        self.URL_GET_ASArticle += String(self.asid)
                        Alamofire.request(self.URL_GET_ASArticle, method: .get).responseJSON{
                            response in
                            if let result = response.result.value{
                                let jsonData = result as! NSDictionary
                                
                                if(!(jsonData.value(forKey: "error") as! Bool)){
                                    let oasArticle = jsonData.value(forKey: "Articles") as! NSArray
                                    let artid = oasArticle.value(forKey: "artID") as! NSArray
                                    let name = oasArticle.value(forKey: "articlename") as! NSArray
                                    let count = oasArticle.value(forKey: "count") as! NSArray
                                    let unit = oasArticle.value(forKey: "unit") as! NSArray
                                    
                                    for i in 0..<oasArticle.count{
                                        var a = (artid[i] as! String) + ";"
                                        a += (name[i] as! String) + ";"
                                        a += (count[i] as! String) + ";"
                                        a += (unit[i] as! String)
                                        self.article.append(a)
                                    }
                                }
                            }
                            let invoiceHTML = self.invoiceComposer.renderInvoice(invoiceNumber: "3", invoiceDate: "2018-09-10", recipientInfo:"Servet", as_: self._as, article: self.article)
                            self.webPreview.loadHTMLString(invoiceHTML!, baseURL: NSURL(string: self.invoiceComposer.pathToInvoiceHTMLTemplate!)! as URL)
                            self.HTMLContent = invoiceHTML
                        }
                    }
                }
            }
        }
    }



    func showOptionsAlert() {
        let alertController = UIAlertController(title: "Yeah!", message: "Your invoice has been successfully printed to a PDF file.\n\nWhat do you want to do now?", preferredStyle: UIAlertControllerStyle.alert)
        
        let actionPreview = UIAlertAction(title: "Preview it", style: UIAlertActionStyle.default) { (action) in
            if let filename = self.invoiceComposer.pdfFilename, let url = URL(string: filename) {
                let request = URLRequest(url: url)
                self.webPreview.loadRequest(request)
            }
        }
        
        let actionEmail = UIAlertAction(title: "Send by Email", style: UIAlertActionStyle.default) { (action) in
            DispatchQueue.main.async {
                let mailComposeViewController = self.configuredMailComposeViewController()
                if MFMailComposeViewController.canSendMail() {
                    self.present(mailComposeViewController, animated: true, completion: nil)
                } else {
                    self.showSendMailErrorAlert()
                }
            }
        }
        
        let actionNothing = UIAlertAction(title: "Nothing", style: UIAlertActionStyle.default) { (action) in
            
        }
        
        alertController.addAction(actionPreview)
        alertController.addAction(actionEmail)
        alertController.addAction(actionNothing)
        
        present(alertController, animated: true, completion: nil)
    }

    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        
        // Dismiss the mail compose view controller.
        controller.dismiss(animated: true, completion: nil)
    }

    func configuredMailComposeViewController() -> MFMailComposeViewController {
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self // Extremely important to set the --mailComposeDelegate-- property, NOT the --delegate-- property
        
        mailComposerVC.setSubject("Arbeitsschein")
        mailComposerVC.setToRecipients(["s.simsek@ssit.at"])
        mailComposerVC.addAttachmentData(NSData(contentsOfFile: invoiceComposer.pdfFilename)! as Data, mimeType: "application/pdf", fileName: "Arbeitsschein.pdf")
        
        return mailComposerVC
    }
    
    func showSendMailErrorAlert() {
        let sendMailErrorAlert = UIAlertView(title: "Could Not Send Email", message: "Your device could not send e-mail.  Please check e-mail configuration and try again.", delegate: self, cancelButtonTitle: "OK")
        sendMailErrorAlert.show()
    }
    
    // MARK: MFMailComposeViewControllerDelegate Method
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
        let mvc = self.storyboard?.instantiateViewController(withIdentifier: "MenuViewController") as! MenuViewController
        self.navigationController?.pushViewController(mvc, animated: true)
    }
}
