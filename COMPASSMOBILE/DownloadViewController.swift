//
//  DownloadViewController.swift
//  COMPASSMOBILE
//
//  Created by Andrew Harper on 25/02/2016.
//  Copyright © 2016 HYDOP E.C.S. All rights reserved.
//

import UIKit

class DownloadViewController: UIViewController {
    
    @IBOutlet weak var ReferenceDataFeedback: UILabel!
    @IBOutlet weak var TaskTemplateFeedback: UILabel!
    @IBOutlet weak var OperativeFeedback: UILabel!
    @IBOutlet weak var OrganisationFeedback: UILabel!
    @IBOutlet weak var SiteFeedback: UILabel!
    @IBOutlet weak var PropertyFeedback: UILabel!
    @IBOutlet weak var AreaFeedback: UILabel!
    @IBOutlet weak var LocationFeedback: UILabel!
    @IBOutlet weak var AssetFeedback: UILabel!
    @IBOutlet weak var TaskFeedback: UILabel!
    
    @IBOutlet weak var ReferenceDataButton: UIButton!
    @IBOutlet weak var TaskTemplateButton: UIButton!
    @IBOutlet weak var OperativeButton: UIButton!
    @IBOutlet weak var OrganisationButton: UIButton!
    @IBOutlet weak var SiteButton: UIButton!
    @IBOutlet weak var PropertyButton: UIButton!
    @IBOutlet weak var AreaButton: UIButton!
    @IBOutlet weak var LocationButton: UIButton!
    @IBOutlet weak var AssetButton: UIButton!
    @IBOutlet weak var TaskButton: UIButton!
    
    @IBOutlet weak var ReferenceDataProgress: UIProgressView!
    @IBOutlet weak var TaskTemplateProgress: UIProgressView!
    @IBOutlet weak var OperativeProgress: UIProgressView!
    @IBOutlet weak var OrganisationProgress: UIProgressView!
    @IBOutlet weak var SiteProgress: UIProgressView!
    @IBOutlet weak var PropertyProgress: UIProgressView!
    @IBOutlet weak var AreaProgress: UIProgressView!
    @IBOutlet weak var LocationProgress: UIProgressView!
    @IBOutlet weak var AssetProgress: UIProgressView!
    @IBOutlet weak var TaskProgress: UIProgressView!
    
    @IBAction func downloadReferenceData(sender: UIButton) {
        self.doEnableButtons(false)
        ReferenceDataProgress.setProgress(0, animated: true)
        self.ReferenceDataFeedback.text = ""
        
//        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND,0), {
//            Utility.SynchroniseAllData(1, progressBar: self.ReferenceDataProgress);
//            dispatch_async(dispatch_get_main_queue(),{self.ReferenceDataProgress.setProgress(1, animated: true);
//                self.doEnableButtons(true);
//                self.ReferenceDataFeedback.text = "Done"})
//            })
    }
    
    @IBAction func downloadTaskTemplate(sender: UIButton) {
        self.doEnableButtons(false)
        TaskTemplateProgress.setProgress(0, animated: true)
        self.TaskTemplateFeedback.text = ""
        
//        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND,0), {
//            Utility.SynchroniseAllData(10, progressBar: self.TaskTemplateProgress);
//            Utility.SynchroniseAllData(11, progressBar: self.TaskTemplateProgress);
//            dispatch_async(dispatch_get_main_queue(),{self.TaskTemplateProgress.setProgress(1, animated: true);
//                self.doEnableButtons(true);
//                self.TaskTemplateFeedback.text = "Done"})
//        })
    }
    
    @IBAction func downloadOperative(sender: UIButton) {
        self.doEnableButtons(false)
        OperativeProgress.setProgress(0, animated: true)
        self.OperativeFeedback.text = ""
//        
//        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND,0), {
//            Utility.SynchroniseAllData(9, progressBar: self.OperativeProgress);
//            dispatch_async(dispatch_get_main_queue(),{self.OperativeProgress.setProgress(1, animated: true);
//                self.doEnableButtons(true);
//                self.OperativeFeedback.text = "Done"})
//        })
    }
    
    @IBAction func downloadOrganisation(sender: UIButton) {
        self.doEnableButtons(false)
        OrganisationProgress.setProgress(0, animated: true)
        self.OrganisationFeedback.text = ""
        
//        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND,0), {
//            Utility.SynchroniseAllData(2, progressBar: self.OrganisationProgress);
//            dispatch_async(dispatch_get_main_queue(),{self.OrganisationProgress.setProgress(1, animated: true);
//                self.doEnableButtons(true);
//                self.OrganisationFeedback.text = "Done"})
//        })
    }
    
    @IBAction func downloadSite(sender: UIButton) {
        self.doEnableButtons(false)
        SiteProgress.setProgress(0, animated: true)
        self.SiteFeedback.text = ""
        
//        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND,0), {
//            Utility.SynchroniseAllData(3, progressBar: self.SiteProgress);
//            dispatch_async(dispatch_get_main_queue(),{self.SiteProgress.setProgress(1, animated: true);
//                self.doEnableButtons(true);
//                self.SiteFeedback.text = "Done"})
//        })
    }
    
    @IBAction func downloadProperty(sender: UIButton) {
        self.doEnableButtons(false)
        PropertyProgress.setProgress(0, animated: true)
        self.PropertyFeedback.text = ""
        
//        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND,0), {
//            Utility.SynchroniseAllData(4, progressBar: self.PropertyProgress);
//            dispatch_async(dispatch_get_main_queue(),{self.PropertyProgress.setProgress(1, animated: true);
//                self.doEnableButtons(true);
//                self.PropertyFeedback.text = "Done"})
//        })
    }
    
    @IBAction func downloadArea(sender: UIButton) {
        self.doEnableButtons(false)
        AreaProgress.setProgress(0, animated: true)
        self.AreaFeedback.text = ""
        
//        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND,0), {
//            Utility.SynchroniseAllData(6, progressBar: self.AreaProgress);
//            dispatch_async(dispatch_get_main_queue(),{self.AreaProgress.setProgress(1, animated: true);
//                self.doEnableButtons(true);
//                self.AreaFeedback.text = "Done"})
//        })
    }
    
    @IBAction func downloadLocation(sender: UIButton) {
        self.doEnableButtons(false)
        LocationProgress.setProgress(0, animated: true)
        self.LocationFeedback.text = ""
        
//        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND,0), {
//            Utility.SynchroniseAllData(5, progressBar: self.LocationProgress);
//            Utility.SynchroniseAllData(7, progressBar: self.LocationProgress);
//            dispatch_async(dispatch_get_main_queue(),{self.LocationProgress.setProgress(1, animated: true);
//                self.doEnableButtons(true);
//                self.LocationFeedback.text = "Done"})
//        })
    }

    @IBAction func downloadAsset(sender: UIButton) {
        self.doEnableButtons(false)
        AssetProgress.setProgress(0, animated: true)
        self.AssetFeedback.text = ""
        
//        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND,0), {
//            Utility.SynchroniseAllData(8, progressBar: self.AssetProgress);
//            dispatch_async(dispatch_get_main_queue(),{self.AssetProgress.setProgress(1, animated: true);
//                self.doEnableButtons(true);
//                self.AssetFeedback.text = "Done"})
//        })
    }

    @IBAction func downloadTask(sender: UIButton) {
        self.doEnableButtons(false)
       TaskProgress.setProgress(0, animated: true)
        self.TaskFeedback.text = ""
        
//        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND,0), {
//            Utility.SynchroniseAllData(12, progressBar: self.TaskProgress);
//            dispatch_async(dispatch_get_main_queue(),{self.TaskProgress.setProgress(1, animated: true);
//                self.doEnableButtons(true);
//                self.TaskFeedback.text = "Done"})
//        })
    }
    

    
    
//    func doDownload(stage: Int32, synchronisationDate: NSDate, lastRowId: String){
//        
//        let urlString = "http://compass2.hydrop.com/services/servicepdautility2.asmx"
//        let url = NSURL(string: urlString)
//        
//        //let theSession = NSURLSession.sharedSession()
//        let theRequest = NSMutableURLRequest(URL: url!)
//        
//        let soapHeader: String = "<?xml version=\"1.0\" encoding=\"utf-8\"?><soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">"
//        let soapFooter: String = "</soap:Envelope>"
//        
//        let soapAction: String = "http://compass.hydrop.com/services/GetSynchronisationPackage"
//        let operativeId: String = Session.OperativeId!
//        let soapBody: String = "<soap:Body><GetSynchronisationPackage xmlns=\"http://compass.hydrop.com/services/\"><OperativeId>" + operativeId + "</OperativeId><LastSynchonisationDateTime>" + synchronisationDate.toString() + "</LastSynchonisationDateTime><LastRowId>" + lastRowId + "</LastRowId><Stage>" + String(stage) + "</Stage></GetSynchronisationPackage></soap:Body>"
//        
//        let soapMessage: String = soapHeader + soapBody + soapFooter
//        
//        theRequest.HTTPMethod = "POST"
//        theRequest.addValue("compass2.hydrop.com", forHTTPHeaderField: "Host")
//        theRequest.addValue("text/xml; charset=utf-8", forHTTPHeaderField: "Content-Type")
//        theRequest.addValue(String(soapMessage.characters.count), forHTTPHeaderField: "Content-Length")
//        theRequest.addValue(soapAction, forHTTPHeaderField: "SOAPAction")
//        theRequest.HTTPBody = soapMessage.dataUsingEncoding(NSUTF8StringEncoding)
//        
//        let connection = NSURLConnection(request: theRequest, delegate: self, startImmediately: true)
//        connection!.start()
//        
//        if (connection == true) {
//            var mutableData : Void = NSMutableData.initialize()
//        }
//        
//        
//    }
//
//    func connection(connection: NSURLConnection!, didReceiveResponse response: NSURLResponse!) {
//        mutableData.length = 0;
//    }
//    
//    func connection(connection: NSURLConnection!, didReceiveData data: NSData!) {
//        mutableData.appendData(data)
//    }
//    
//    func connectionDidFinishLoading(connection: NSURLConnection!) {
//        
//        doEnableButtons(true)
//    }
    
    func doEnableButtons(toggle: Bool)
    {
        ReferenceDataButton.enabled = toggle
        TaskTemplateButton.enabled = toggle
        OperativeButton.enabled = toggle
        OrganisationButton.enabled = toggle
        SiteButton.enabled = toggle
        PropertyButton.enabled = toggle
        AreaButton.enabled = toggle
        LocationButton.enabled = toggle
        AssetButton.enabled = toggle
        TaskButton.enabled = toggle
    }
}