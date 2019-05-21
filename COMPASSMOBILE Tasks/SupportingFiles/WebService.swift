//
//  WebService.swift
//  COMPASSMOBILE
//
//  Created by Andrew Harper on 21/01/2016.
//  Copyright © 2016 HYDOP E.C.S. All rights reserved.
//

import UIKit

class WebService : NSObject {
    
    class func validateOperative (_ username: String, password: String) -> Data? {
        
        var data: Data?
        NSLog("Validate Operative started")
        autoreleasepool{
            let urlString = Session.WebProtocol + Session.Server + "/services/servicepdautility2osx.asmx"
            let url = URL(string: urlString)
            
            let theSession = URLSession.shared
            let theRequest = NSMutableURLRequest(url: url!)
            
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
            
            theRequest.httpMethod = "POST"
            theRequest.addValue(Session.Server, forHTTPHeaderField: "Host")
            theRequest.addValue("text/xml; charset=utf-8", forHTTPHeaderField: "Content-Type")
            theRequest.addValue(String(soapMessage.count), forHTTPHeaderField: "Content-Length")
            theRequest.addValue(soapAction, forHTTPHeaderField: "SOAPAction")
            theRequest.httpBody = soapMessage.data(using: String.Encoding.utf8)
            
            let semaphore = DispatchSemaphore(value: 0)
            
            theSession.dataTask(with: theRequest as URLRequest, completionHandler: { (responseData: Data? , _, _) -> Void in
                data = responseData
                semaphore.signal()
                }) .resume()
            
            _ = semaphore.wait(timeout: DispatchTime.distantFuture)
        }
        NSLog("Validate Operative ended")
        return data
    }

    class func getSynchronisationPackageSync (_ operativeId: String, synchronisationDate: Date, lastRowId: String, stage: Int32) -> Data? {

        var data: Data?
        NSLog("Synch Package download started")
        autoreleasepool{
            let urlString = Session.WebProtocol + Session.Server + "/services/servicepdautility2osx.asmx"
            let url = URL(string: urlString)
        
            let theSession = URLSession.shared
            
            let theRequest = NSMutableURLRequest(url: url!)
            
            let soapHeader: String = "<?xml version=\"1.0\" encoding=\"utf-8\"?><soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">"
            let soapFooter: String = "</soap:Envelope>"
            
            let soapAction: String = "http://compass.hydrop.com/services/GetSynchronisationPackage"
            var soapBody: String = "<soap:Body>"
            soapBody += "<GetSynchronisationPackage xmlns=\"http://compass.hydrop.com/services/\">"
            soapBody += "<OperativeId>" + operativeId + "</OperativeId>"
            soapBody += "<LastSynchonisationDateTime>" + Utility.DateToStringForXML(synchronisationDate) + "</LastSynchonisationDateTime>"
            soapBody += "<LastRowId>" + lastRowId + "</LastRowId>"
            soapBody += "<Stage>" + String(stage) + "</Stage>"
            soapBody += "</GetSynchronisationPackage>"
            soapBody += "</soap:Body>"
            
            let soapMessage: String = soapHeader + soapBody + soapFooter
            
            theRequest.httpMethod = "POST"
            theRequest.addValue(Session.Server, forHTTPHeaderField: "Host")
            theRequest.addValue("text/xml; charset=utf-8", forHTTPHeaderField: "Content-Type")
            theRequest.addValue(String(soapMessage.count), forHTTPHeaderField: "Content-Length")
            theRequest.addValue(soapAction, forHTTPHeaderField: "SOAPAction")
            theRequest.httpBody = soapMessage.data(using: String.Encoding.utf8)
            
            let semaphore = DispatchSemaphore(value: 0)
            
            theSession.dataTask(with: theRequest as URLRequest, completionHandler: { (responseData: Data? , _ , _) -> Void in
                data = responseData
                semaphore.signal()
                }) .resume()
            
            _ = semaphore.wait(timeout: DispatchTime.distantFuture)
        }
        NSLog("Synch Package download ended")
        return data
    }

    class func sendSyncronisationPackageSync (_ operativeId: String, sysnchronisationPackage: String) -> Data? {

        var data: Data?
        NSLog("Synch Package upload started")
        autoreleasepool{
            let urlString = Session.WebProtocol + Session.Server + "/services/servicepdautility2osx.asmx"
            let url = URL(string: urlString)
            
            let theSession = URLSession.shared
            
            let theRequest = NSMutableURLRequest(url: url!)
            
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
            
            theRequest.httpMethod = "POST"
            theRequest.addValue(Session.Server, forHTTPHeaderField: "Host")
            theRequest.addValue("text/xml; charset=utf-8", forHTTPHeaderField: "Content-Type")
            theRequest.addValue(String(soapMessage.count), forHTTPHeaderField: "Content-Length")
            theRequest.addValue(soapAction, forHTTPHeaderField: "SOAPAction")
            theRequest.httpBody = soapMessage.data(using: String.Encoding.utf8)
            
            let semaphore = DispatchSemaphore(value: 0)
            
            theSession.dataTask(with: theRequest as URLRequest, completionHandler: { (responseData: Data? , _ , _) -> Void in
                data = responseData
                semaphore.signal()
                }) .resume()
            
            _ = semaphore.wait(timeout: DispatchTime.distantFuture)
        }
        NSLog("Synch Package upload ended")
        return data
    }
}
