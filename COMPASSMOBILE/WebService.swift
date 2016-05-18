//
//  WebService.swift
//  COMPASSMOBILE
//
//  Created by Andrew Harper on 21/01/2016.
//  Copyright © 2016 HYDOP E.C.S. All rights reserved.
//

import UIKit

class WebService : NSObject {
    
    class func validateOperative (username: String, password: String) -> NSData? {
        
        let urlString = "http://" + Session.Server + "/services/servicepdautility2.asmx"
        let url = NSURL(string: urlString)
        
        let theSession = NSURLSession.sharedSession()
        let theRequest = NSMutableURLRequest(URL: url!)
        
        let soapHeader: String = "<?xml version=\"1.0\" encoding=\"utf-8\"?><soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">"
        let soapFooter: String = "</soap:Envelope>"
        
        let soapAction: String = "http://compass.hydrop.com/services/ValidateOperative"
        var soapBody: String = "<soap:Body>"
        soapBody += "<ValidateOperative xmlns=\"http://compass.hydrop.com/services/\">"
        soapBody += "<Username>\"" + username + "\"</Username>"
        soapBody += "<Password>\"" + password + "\"</Password>"
        soapBody += "</ValidateOperative>"
        soapBody += "</soap:Body>"
        
        let soapMessage: String = soapHeader + soapBody + soapFooter
        
        theRequest.HTTPMethod = "POST"
        theRequest.addValue(Session.Server, forHTTPHeaderField: "Host")
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

    class func getSynchronisationPackageSync (operativeId: String, synchronisationDate: NSDate, lastRowId: String, stage: Int32) -> NSData? {

        var data: NSData?
        
        //autoreleasepool{
            let urlString = "http://" + Session.Server + "/services/servicepdautility2.asmx"
            let url = NSURL(string: urlString)
        
            let theSession = NSURLSession.sharedSession()
            
            let theRequest = NSMutableURLRequest(URL: url!)
            
            let soapHeader: String = "<?xml version=\"1.0\" encoding=\"utf-8\"?><soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">"
            let soapFooter: String = "</soap:Envelope>"
            
            let soapAction: String = "http://compass.hydrop.com/services/GetSynchronisationPackage"
            var soapBody: String = "<soap:Body>"
            soapBody += "<GetSynchronisationPackage xmlns=\"http://compass.hydrop.com/services/\">"
            soapBody += "<OperativeId>" + operativeId + "</OperativeId>"
            soapBody += "<LastSynchonisationDateTime>" + synchronisationDate.toString() + "</LastSynchonisationDateTime>"
            soapBody += "<LastRowId>" + lastRowId + "</LastRowId>"
            soapBody += "<Stage>" + String(stage) + "</Stage>"
            soapBody += "</GetSynchronisationPackage>"
            soapBody += "</soap:Body>"
            
            let soapMessage: String = soapHeader + soapBody + soapFooter
            
            theRequest.HTTPMethod = "POST"
            theRequest.addValue(Session.Server, forHTTPHeaderField: "Host")
            theRequest.addValue("text/xml; charset=utf-8", forHTTPHeaderField: "Content-Type")
            theRequest.addValue(String(soapMessage.characters.count), forHTTPHeaderField: "Content-Length")
            theRequest.addValue(soapAction, forHTTPHeaderField: "SOAPAction")
            theRequest.HTTPBody = soapMessage.dataUsingEncoding(NSUTF8StringEncoding)
            
            let semaphore = dispatch_semaphore_create(0)
            
            theSession.dataTaskWithRequest(theRequest) { (responseData: NSData? , _ , _) -> Void in
                data = responseData
                dispatch_semaphore_signal(semaphore)
                }.resume()
            
            dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
        //}
        
        return data
    }

    class func sendSyncronisationPackageSync (operativeId: String, sysnchronisationPackage: String) -> NSData? {

        var data: NSData?
        
        //autoreleasepool{
            let urlString = "http://" + Session.Server + "/services/servicepdautility2.asmx"
            let url = NSURL(string: urlString)
            
            let theSession = NSURLSession.sharedSession()
            
            let theRequest = NSMutableURLRequest(URL: url!)
            
            let soapHeader: String = "<?xml version=\"1.0\" encoding=\"utf-8\"?><soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">"
            let soapFooter: String = "</soap:Envelope>"
            
            let soapAction: String = "http://compass.hydrop.com/services/SetSynchronisationPackage"
            var soapBody: String = "<soap:Body>"
            soapBody += "<SetSynchronisationPackage xmlns=\"http://compass.hydrop.com/services/\">"
            soapBody += "<OperativeId>" + operativeId + "</OperativeId>"
            soapBody += "<SynchonisationPackage>" + sysnchronisationPackage + "</SynchonisationPackage>"
            soapBody += "</SetSynchronisationPackage>"
            soapBody += "</soap:Body>"
            
            let soapMessage: String = soapHeader + soapBody + soapFooter
            
            theRequest.HTTPMethod = "POST"
            theRequest.addValue(Session.Server, forHTTPHeaderField: "Host")
            theRequest.addValue("text/xml; charset=utf-8", forHTTPHeaderField: "Content-Type")
            theRequest.addValue(String(soapMessage.characters.count), forHTTPHeaderField: "Content-Length")
            theRequest.addValue(soapAction, forHTTPHeaderField: "SOAPAction")
            theRequest.HTTPBody = soapMessage.dataUsingEncoding(NSUTF8StringEncoding)
            
            let semaphore = dispatch_semaphore_create(0)
            
            theSession.dataTaskWithRequest(theRequest) { (responseData: NSData? , _ , _) -> Void in
                data = responseData
                dispatch_semaphore_signal(semaphore)
                }.resume()
            
            dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
        //}
        
        return data
    }
}
