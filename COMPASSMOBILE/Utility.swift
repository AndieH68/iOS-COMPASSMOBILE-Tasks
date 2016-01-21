//
//  Utility.swift
//  COMPASSMOBILE
//
//  Created by Andrew Harper on 20/01/2016.
//  Copyright © 2016 HYDOP E.C.S. All rights reserved.
//

import UIKit

class Utility: NSObject {
    
    class func getPath(fileName: String) -> String {
        
        let documentsURL = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0]
        let fileURL = documentsURL.URLByAppendingPathComponent(fileName)
        
        return fileURL.path!
    }
    
    class func copyFile(fileName: NSString) {
        let dbPath: String = getPath(fileName as String)
        let fileManager = NSFileManager.defaultManager()
        if !fileManager.fileExistsAtPath(dbPath) {
            
            let documentsURL = NSBundle.mainBundle().resourceURL
            let fromPath = documentsURL!.URLByAppendingPathComponent(fileName as String)
            
            var error : NSError?
            do {
                try fileManager.copyItemAtPath(fromPath.path!, toPath: dbPath)
            } catch let error1 as NSError {
                error = error1
            }
            let alert: UIAlertView = UIAlertView()
            if (error != nil) {
                alert.title = "Error Occured"
                alert.message = error?.localizedDescription
            } else {
                alert.title = "Successfully Copy"
                alert.message = "Your database copy successfully"
            }
            alert.delegate = nil
            alert.addButtonWithTitle("Ok")
            alert.show()
        }
    }
    
    class func invokeAlertMethod(strTitle: NSString, strBody: NSString, delegate: AnyObject?) {
        let alert: UIAlertView = UIAlertView()
        alert.message = strBody as String
        alert.title = strTitle as String
        alert.delegate = delegate
        alert.addButtonWithTitle("Ok")
        alert.show()
    }
    
    class func getSynchronisationPackage (operativeId: String, synchronisationDate: NSDate, lastRowId: String, stage: String) -> NSData? {
        
        let urlString = "http://compass2.hydrop.com/services/servicepdautility2.asmx"
        let url = NSURL(string: urlString)
        
        var soapAction: String = ""
        var soapMessage: String = ""
        var soapBody: String = ""
        let theSession = NSURLSession.sharedSession()
        let theRequest = NSMutableURLRequest(URL: url!)
        
        let soapHeader: String = "<?xml version=\"1.0\" encoding=\"utf-8\"?><soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">"
        let soapFooter: String = "</soap:Envelope>"

        let lastRowId: String = "00000000-0000-0000-0000-000000000000"
        let stage: String = "9"
        
        soapAction = "http://compass.hydrop.com/services/GeySynchronisationPackage"
        soapBody = "<soap:Body><GetSynchronisationPackage xmlns=\"http://compass.hydrop.com/services/\"><OperativeId>\"" + operativeId + "\"</OperativeId><LastSynchonisationDateTime>\"" + synchronisationDate.toString() + "\"</LastSynchonisationDateTime><LastRowId>\"" + lastRowId + "\"</LastRowId><Stage>\"" + stage + "\"</Stage></GetSynchronisationPackage></soap:Body>"
        
        soapMessage = soapHeader + soapBody + soapFooter
        
        theRequest.HTTPMethod = "POST"
        theRequest.addValue("compass2.hydrop.com", forHTTPHeaderField: "Host")
        theRequest.addValue("text/xml; charset=utf-8", forHTTPHeaderField: "Content-Type")
        theRequest.addValue(String(soapMessage.characters.count), forHTTPHeaderField: "Content-Length")
        theRequest.addValue(soapAction, forHTTPHeaderField: "SOAPAction")
        theRequest.HTTPBody = soapMessage.dataUsingEncoding(NSUTF8StringEncoding)
        
        var data: NSData? = nil
        let semaphore = dispatch_semaphore_create(0)
        
        theSession.dataTaskWithRequest(theRequest) { (responseData: NSData? , _, _) -> Void in
            data = responseData
            dispatch_semaphore_signal(semaphore)
            }.resume()
        
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
        
        return data
    }
}

extension NSDate
{
    convenience
    init(dateString:String) {
        let dateStringFormatter = NSDateFormatter()
        dateStringFormatter.dateFormat = "yyyy-MMM-dd hh:mm:ss"
        let d = dateStringFormatter.dateFromString(dateString)!
        self.init(timeInterval:0, sinceDate:d)
    }
    
    func toString() -> String {
        let dateStringFormatter = NSDateFormatter()
        dateStringFormatter.dateFormat = "yyyy-MMM-dd hh:mm:ss"
        return dateStringFormatter.stringFromDate(self)
    }
}