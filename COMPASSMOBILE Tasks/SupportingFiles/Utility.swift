//
//  Utility.swift
//  COMPASSMOBILE
//
//  Created by Andrew Harper on 20/01/2016.
//  Copyright © 2016 HYDOP E.C.S. All rights reserved.
//

import UIKit
import AEXML
import FMDB
import MBProgressHUD

class Utility: NSObject {
    
    static func lockOrientation(_ orientation: UIInterfaceOrientationMask) {
        
        if let delegate = UIApplication.shared.delegate as? AppDelegate {
            delegate.orientationLock = orientation
        }
    }
    
    /// OPTIONAL Added method to adjust lock and rotate to the desired orientation
    static func lockOrientation(_ orientation: UIInterfaceOrientationMask, andRotateTo rotateOrientation:UIInterfaceOrientation) {
        
        self.lockOrientation(orientation)
        
        UIDevice.current.setValue(rotateOrientation.rawValue, forKey: "orientation")
    }
    
    class func getPath(_ fileName: String) -> String {
        
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileURL = documentsURL.appendingPathComponent(fileName)
        
        return fileURL.path
    }
    
    class func copyFile(_ fileName: NSString) -> (Bool, String){
        let dbPath: String = getPath(fileName as String)
        let fileManager = FileManager.default
        if !fileManager.fileExists(atPath: dbPath) {
            
            let documentsURL = Bundle.main.resourceURL
            let fromPath = documentsURL!.appendingPathComponent(fileName as String)
            
            var error : NSError?
            do {
                try fileManager.copyItem(atPath: fromPath.path, toPath: dbPath)
            } catch let error1 as NSError {
                error = error1
            }
            if (error != nil) {
                return(false, (error?.localizedDescription)!)
            }
            
            if !fileManager.fileExists(atPath: dbPath) {
                return(false, "Missing Database file")
            }
        }

        return (true, String())
    }
    
    class func backupDatabase(_ fileName: NSString) -> (Bool, String){
        var returnValue: Bool = true
        var message: String = ""
        let dbPath: String = getPath(fileName as String)
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: dbPath) {
        
            let documentsURL = try! FileManager.default.url(for: .documentDirectory,in: .userDomainMask,appropriateFor: nil, create: true)
            let documentPath = documentsURL.appendingPathComponent("Backup " + (fileName as String))
         
            if fileManager.fileExists(atPath: documentPath.path) {
                var error : NSError?
                do {
                    try fileManager.removeItem(atPath: documentPath.path)
                } catch let error1 as NSError {
                    error = error1
                }
                if (error != nil) {
                    message = error!.localizedDescription
                    returnValue = false
                }
            }
            else
            {
                var error : NSError?
                do {
                    try fileManager.copyItem(atPath: dbPath, toPath: documentPath.path)
                } catch let error1 as NSError {
                    error = error1
                }
                if (error != nil) {
                    message = error!.localizedDescription
                    returnValue = false
                }
                
                if !fileManager.fileExists(atPath: documentPath.path) {
                    message = "Missing Backup file"
                    returnValue = false
                }
            }
        }
        
        return (returnValue, message)
    }
    
    //class func invokeAlertMethod(_ viewController: UIViewController, title: String, message: String, delegate: AnyObject?) {
    class func invokeAlertMethod(_ viewController: UIViewController, title: String, message: String) {

        let userPrompt: UIAlertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        
        //the default action
        let addAction = UIAlertAction( title: "Ok", style: UIAlertAction.Style.default)
        userPrompt.addAction(addAction)
        
        DispatchQueue.main.async(execute: {viewController.present(userPrompt, animated: true, completion: nil)})
    }

    class func invokeAlertMethodDirect(_ viewController: UIViewController, title: String, message: String) {

        let userPrompt: UIAlertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        
        //the default action
        let addAction = UIAlertAction( title: "Ok", style: UIAlertAction.Style.default)
        userPrompt.addAction(addAction)
        
        viewController.present(userPrompt, animated: true, completion: nil)
    }
    
    class func openSoapEnvelope(_ data: Data?) -> AEXMLElement?{
        if data == nil{
            return nil
        }
        
        var result: AEXMLDocument?
        do {
            result = try AEXMLDocument(xml: data!)
        }
        catch {
            result = nil
        }
        
        if result == nil
        {
            return AEXMLElement(name: "soap:Fault", value: "invalid URL")
        }
        
        var response: AEXMLElement?
        let SOAPEnvelope: AEXMLElement = result!["soap:Envelope"]
        
        if !(SOAPEnvelope.value == "element <soap:Envelope> not found" || SOAPEnvelope.children.count == 0)
        {
            let SOAPBody: AEXMLElement = SOAPEnvelope["soap:Body"]
        
            response = SOAPBody.children[0]
        }
        else{
            response = AEXMLElement(name: "soap:Fault", value: "invalid URL")
        }
      
        return response
    }
    
    // MARK: - Global
    class func importData(_ packageData: AEXMLElement, entityType: EntityType) -> (String, Date, Int32, Int32) {
        let count: Int32 = 0
        let maxCount: Int32 = 0
        return importData(packageData, entityType: entityType, progressBar: nil, count: count, maxCount: maxCount)
    }
    
    class func importData(_ packageData: AEXMLElement, entityType: EntityType, progressBar: MBProgressHUD?, count: Int32, maxCount: Int32) -> (String, Date, Int32, Int32) {
        
        var lastDateInPackage: Date = BaseDate as Date
        var lastRowId: String = EmptyGuid
        
        var current: Int32 = 0
        var total: Int32 = 0
        
        if (maxCount <= 0)
        {
            var countNode: AEXMLElement = packageData["Process"]
            countNode = countNode["Relevant"]
            if (countNode.attributes["Count"] != nil)
            {
                
                total = Int32(countNode.attributes["Count"]!)!
                current = 0
            }
        }
        else
        {
            total = maxCount
            current = count
        }
        
        if (maxCount > 0 || total > 0)
        {
            switch entityType {
            
            case .asset:
                
                //get the data nodes
                let dataNode: AEXMLElement = packageData["Asset"]
                
                for childNode in dataNode.children
                {

                    
                    autoreleasepool{
                        current += 1
                        
                        //get the first child
                        let asset: Asset = Asset(XMLElement: childNode)
                        
                        var currentSynchDate: Date
                        if asset.LastUpdatedOn == nil {
                            currentSynchDate = asset.CreatedOn as Date
                        }
                        else {
                            currentSynchDate = asset.LastUpdatedOn! as Date
                        }
                        
                        lastDateInPackage = (lastDateInPackage as NSDate).laterDate(currentSynchDate)
                        lastRowId = asset.RowId
                        
                        //does the record exists
                        let currentAsset: Asset? = ModelManager.getInstance().getAsset(asset.RowId)
                        if currentAsset == nil
                        {
                            //is the current record deleted
                            if (asset.Deleted == nil)
                            {
                                //no insert it
                                _ = ModelManager.getInstance().addAsset(asset)
                            }
                        }
                        else
                        {
                            //yes
                            
                            //is the current record deleted
                            if (asset.Deleted != nil)
                            {
                                //yes  - delete the asset
                                _ = ModelManager.getInstance().deleteAsset(asset)
                            }
                            else
                            {
                                //no  - update the asset
                                _ = ModelManager.getInstance().updateAsset(asset)
                            }
                            
                        }
                        
                        
                        if (progressBar != nil)
                        {
                            DispatchQueue.main.async(execute: {progressBar!.label.text = "Asset"; progressBar!.progress = (Float(current) / Float(total))})
                        }
                    }
                }
                
            case .location:
                
                //get the data nodes
                let dataNode: AEXMLElement = packageData["Location"]

                //total = dataNode.children.count
                
                for childNode in dataNode.children
                {
                    autoreleasepool{
                    current += 1
                    
                    //get the first child
                    let location: Location = Location(XMLElement: childNode)
                    
                    var currentSynchDate: Date
                    if location.LastUpdatedOn == nil {
                        currentSynchDate = location.CreatedOn as Date
                    }
                    else {
                        currentSynchDate = location.LastUpdatedOn! as Date
                    }
                    
                    lastDateInPackage = (lastDateInPackage as NSDate).laterDate(currentSynchDate)
                    lastRowId = location.RowId
                    
                    //does the record exists
                    let currentLocation: Location? = ModelManager.getInstance().getLocation(location.RowId)
                    if currentLocation == nil
                    {
                        //is the current record deleted
                        if (location.Deleted == nil)
                        {
                            //no insert it
                            _ = ModelManager.getInstance().addLocation(location)
                        }
                    }
                    else
                    {
                        //yes
                        
                        //is the current record deleted
                        if (location.Deleted != nil)
                        {
                            //yes  - delete the Location
                            _ = ModelManager.getInstance().deleteLocation(location)
                        }
                        else
                        {
                            //no  - update the Location
                            _ = ModelManager.getInstance().updateLocation(location)
                        }
                        
                    }
                    
                    if (progressBar != nil)
                    {
                        DispatchQueue.main.async(execute: {progressBar!.label.text = "Location"; progressBar!.progress = (Float(current) / Float(total))})
                    }
                    }
                }

            case .locationGroup:
                
                //get the data nodes
                let dataNode: AEXMLElement = packageData["LocationGroup"]
                
                //total = dataNode.children.count
                
                for childNode in dataNode.children
                {
                    autoreleasepool{
                    current += 1
                    
                    //get the first child
                    let locationGroup: LocationGroup = LocationGroup(XMLElement: childNode)
                    
                    var currentSynchDate: Date
                    if locationGroup.LastUpdatedOn == nil {
                        currentSynchDate = locationGroup.CreatedOn as Date
                    }
                    else {
                        currentSynchDate = locationGroup.LastUpdatedOn! as Date
                    }
                    
                    lastDateInPackage = (lastDateInPackage as NSDate).laterDate(currentSynchDate)
                    lastRowId = locationGroup.RowId
                    
                    //does the record exists
                    let currentLocationGroup: LocationGroup? = ModelManager.getInstance().getLocationGroup(locationGroup.RowId)
                    if currentLocationGroup == nil
                    {
                        //is the current record deleted
                        if (locationGroup.Deleted == nil)
                        {
                            //no insert it
                            _ = ModelManager.getInstance().addLocationGroup(locationGroup)
                        }
                    }
                    else
                    {
                        //yes
                        
                        //is the current record deleted
                        if (locationGroup.Deleted != nil)
                        {
                            //yes  - delete the LocationGroup
                            _ = ModelManager.getInstance().deleteLocationGroup(locationGroup)
                        }
                        else
                        {
                            //no  - update the LocationGroup
                            _ = ModelManager.getInstance().updateLocationGroup(locationGroup)
                        }
                        
                    }
                    
                    if (progressBar != nil)
                    {
                        DispatchQueue.main.async(execute: {progressBar!.label.text = "Area"; progressBar!.progress = (Float(current) / Float(total))})
                    }
                    }
                }

            case .locationGroupMembership:
                
                //get the data nodes
                let dataNode: AEXMLElement = packageData["LocationGroupMembership"]
                
                //total = dataNode.children.count
                
                for childNode in dataNode.children
                {
                    autoreleasepool{
                    current += 1
                    
                    //get the first child
                    let locationGroupMembership: LocationGroupMembership = LocationGroupMembership(XMLElement: childNode)
                    
                    var currentSynchDate: Date
                    if locationGroupMembership.LastUpdatedOn == nil {
                        currentSynchDate = locationGroupMembership.CreatedOn as Date
                    }
                    else {
                        currentSynchDate = locationGroupMembership.LastUpdatedOn! as Date
                    }
                    
                    lastDateInPackage = (lastDateInPackage as NSDate).laterDate(currentSynchDate)
                    lastRowId = locationGroupMembership.RowId
                    
                    //does the record exists
                    let currentLocationGroupMembership: LocationGroupMembership? = ModelManager.getInstance().getLocationGroupMembership(locationGroupMembership.RowId)
                    if currentLocationGroupMembership == nil
                    {
                        //is the current record deleted
                        if (locationGroupMembership.Deleted == nil)
                        {
                            //no insert it
                            _ = ModelManager.getInstance().addLocationGroupMembership(locationGroupMembership)
                        }
                    }
                    else
                    {
                        //yes
                        
                        //is the current record deleted
                        if (locationGroupMembership.Deleted != nil)
                        {
                            //yes  - delete the LocationGroupMembership
                            _ = ModelManager.getInstance().deleteLocationGroupMembership(locationGroupMembership)
                        }
                        else
                        {
                            //no  - update the LocationGroupMembership
                            _ = ModelManager.getInstance().updateLocationGroupMembership(locationGroupMembership)
                        }
                        
                    }
                    
                    if (progressBar != nil)
                    {
                        DispatchQueue.main.async(execute: {progressBar!.label.text = "Area Link"; progressBar!.progress = (Float(current) / Float(total))})
                    }
                    }
                }
                
            case .operative:
                
                //get the data nodes
                let dataNode: AEXMLElement = packageData["Operative"]
                
                //total = dataNode.children.count
                
                for childNode in dataNode.children
                {
                    //autoreleasepool{
                    current += 1
                    
                    //get the first child
                    let operative: Operative = Operative(XMLElement: childNode)
                    
                    var currentSynchDate: Date
                    if operative.LastUpdatedOn == nil {
                        currentSynchDate = operative.CreatedOn as Date
                    }
                    else {
                        currentSynchDate = operative.LastUpdatedOn! as Date
                    }
                    
                    lastDateInPackage = (lastDateInPackage as NSDate).laterDate(currentSynchDate)
                    lastRowId = operative.RowId
                    
                    //does the record exists
                    let currentOperative: Operative? = ModelManager.getInstance().getOperative(operative.RowId)
                    if currentOperative == nil
                    {
                        //is the current record deleted
                        if (operative.Deleted == nil)
                        {
                            //no insert it
                            _ = ModelManager.getInstance().addOperative(operative)
                        }
                    }
                    else
                    {
                        //yes
                        
                        //is the current record deleted
                        if (operative.Deleted != nil)
                        {
                            //yes  - delete the Operative
                            _ = ModelManager.getInstance().deleteOperative(operative)
                        }
                        else
                        {
                            //no  - update the Operative
                            _ = ModelManager.getInstance().updateOperative(operative)
                        }
                        
                    }
                    
                    if (progressBar != nil)
                    {
                        DispatchQueue.main.async(execute: {progressBar!.label.text = "Operative"; progressBar!.progress = (Float(current) / Float(total))})
                    }
                    //}
                }
                
            case .operativeGroup:
                
                //get the data nodes
                let dataNode: AEXMLElement = packageData["OperativeGroup"]
                
                //total = dataNode.children.count
                
                for childNode in dataNode.children
                {
                    autoreleasepool{
                        current += 1
                        
                        //get the first child
                        let operativeGroup: OperativeGroup = OperativeGroup(XMLElement: childNode)
                        
                        var currentSynchDate: Date
                        if operativeGroup.LastUpdatedOn == nil {
                            currentSynchDate = operativeGroup.CreatedOn as Date
                        }
                        else {
                            currentSynchDate = operativeGroup.LastUpdatedOn! as Date
                        }
                        
                        lastDateInPackage = (lastDateInPackage as NSDate).laterDate(currentSynchDate)
                        lastRowId = operativeGroup.RowId
                        
                        //does the record exists
                        let currentOperativeGroup: OperativeGroup? = ModelManager.getInstance().getOperativeGroup(operativeGroup.RowId)
                        if currentOperativeGroup == nil
                        {
                            //is the current record deleted
                            if (operativeGroup.Deleted == nil)
                            {
                                //no insert it
                                _ = ModelManager.getInstance().addOperativeGroup(operativeGroup)
                            }
                        }
                        else
                        {
                            //yes
                            
                            //is the current record deleted
                            if (operativeGroup.Deleted != nil)
                            {
                                //yes  - delete the OperativeGroup
                                _ = ModelManager.getInstance().deleteOperativeGroup(operativeGroup)
                            }
                            else
                            {
                                //no  - update the OperativeGroup
                                _ = ModelManager.getInstance().updateOperativeGroup(operativeGroup)
                            }
                            
                        }
                        
                        if (progressBar != nil)
                        {
                            DispatchQueue.main.async(execute: {progressBar!.label.text = "Operative Group"; progressBar!.progress = (Float(current) / Float(total))})
                        }
                    }
                }
                
            case .operativeGroupMembership:
                
                //get the data nodes
                let dataNode: AEXMLElement = packageData["OperativeGroupMembership"]
                
                //total = dataNode.children.count
                
                for childNode in dataNode.children
                {
                    autoreleasepool{
                        current += 1
                        
                        //get the first child
                        let operativeGroupMembership: OperativeGroupMembership = OperativeGroupMembership(XMLElement: childNode)
                        
                        var currentSynchDate: Date
                        if operativeGroupMembership.LastUpdatedOn == nil {
                            currentSynchDate = operativeGroupMembership.CreatedOn as Date
                        }
                        else {
                            currentSynchDate = operativeGroupMembership.LastUpdatedOn! as Date
                        }
                        
                        lastDateInPackage = (lastDateInPackage as NSDate).laterDate(currentSynchDate)
                        lastRowId = operativeGroupMembership.RowId
                        
                        //does the record exists
                        let currentOperativeGroupMembership: OperativeGroupMembership? = ModelManager.getInstance().getOperativeGroupMembership(operativeGroupMembership.RowId)
                        if currentOperativeGroupMembership == nil
                        {
                            //is the current record deleted
                            if (operativeGroupMembership.Deleted == nil)
                            {
                                //no insert it
                                _ = ModelManager.getInstance().addOperativeGroupMembership(operativeGroupMembership)
                            }
                        }
                        else
                        {
                            //yes
                            
                            //is the current record deleted
                            if (operativeGroupMembership.Deleted != nil)
                            {
                                //yes  - delete the OperativeGroupMembership
                                _ = ModelManager.getInstance().deleteOperativeGroupMembership(operativeGroupMembership)
                            }
                            else
                            {
                                //no  - update the OperativeGroupMembership
                                _ = ModelManager.getInstance().updateOperativeGroupMembership(operativeGroupMembership)
                            }
                            
                        }
                        
                        if (progressBar != nil)
                        {
                            DispatchQueue.main.async(execute: {progressBar!.label.text = "OperativeGroup Link"; progressBar!.progress = (Float(current) / Float(total))})
                        }
                    }
                }
                
            case .operativeGroupTaskTemplateMembership:
                
                //get the data nodes
                let dataNode: AEXMLElement = packageData["OperativeGroupTaskTemplateMembership"]
                
                //total = dataNode.children.count
                
                for childNode in dataNode.children
                {
                    autoreleasepool{
                        current += 1
                        
                        //get the first child
                        let operativeGroupTaskTemplateMembership: OperativeGroupTaskTemplateMembership = OperativeGroupTaskTemplateMembership(XMLElement: childNode)
                        
                        var currentSynchDate: Date
                        if operativeGroupTaskTemplateMembership.LastUpdatedOn == nil {
                            currentSynchDate = operativeGroupTaskTemplateMembership.CreatedOn as Date
                        }
                        else {
                            currentSynchDate = operativeGroupTaskTemplateMembership.LastUpdatedOn! as Date
                        }
                        
                        lastDateInPackage = (lastDateInPackage as NSDate).laterDate(currentSynchDate)
                        lastRowId = operativeGroupTaskTemplateMembership.RowId
                        
                        //does the record exists
                        let currentOperativeGroupTaskTemplateMembership: OperativeGroupTaskTemplateMembership? = ModelManager.getInstance().getOperativeGroupTaskTemplateMembership(operativeGroupTaskTemplateMembership.RowId)
                        if currentOperativeGroupTaskTemplateMembership == nil
                        {
                            //is the current record deleted
                            if (operativeGroupTaskTemplateMembership.Deleted == nil)
                            {
                                //no insert it
                                _ = ModelManager.getInstance().addOperativeGroupTaskTemplateMembership(operativeGroupTaskTemplateMembership)
                            }
                        }
                        else
                        {
                            //yes
                            
                            //is the current record deleted
                            if (operativeGroupTaskTemplateMembership.Deleted != nil)
                            {
                                //yes  - delete the OperativeGroupTaskTemplateMembership
                                _ = ModelManager.getInstance().deleteOperativeGroupTaskTemplateMembership(operativeGroupTaskTemplateMembership)
                            }
                            else
                            {
                                //no  - update the OperativeGroupTaskTemplateMembership
                                _ = ModelManager.getInstance().updateOperativeGroupTaskTemplateMembership(operativeGroupTaskTemplateMembership)
                            }
                            
                        }
                        
                        if (progressBar != nil)
                        {
                            DispatchQueue.main.async(execute: {progressBar!.label.text = "OperativeGroup Task Link"; progressBar!.progress = (Float(current) / Float(total))})
                        }
                    }
                }
            
            case .organisation:
                
                //get the data nodes
                let dataNode: AEXMLElement = packageData["Organisation"]
                
                //total = dataNode.children.count
                
                for childNode in dataNode.children
                {
                    autoreleasepool{
                    current += 1
                    
                    //get the first child
                    let organisation: Organisation = Organisation(XMLElement: childNode)
                    
                    var currentSynchDate: Date
                    if organisation.LastUpdatedOn == nil {
                        currentSynchDate = organisation.CreatedOn as Date
                    }
                    else {
                        currentSynchDate = organisation.LastUpdatedOn! as Date
                    }
                    
                    lastDateInPackage = (lastDateInPackage as NSDate).laterDate(currentSynchDate)
                    lastRowId = organisation.RowId
                    
                    //does the record exists
                    let currentOrganisation: Organisation? = ModelManager.getInstance().getOrganisation(organisation.RowId)
                    if currentOrganisation == nil
                    {
                        //is the current record deleted
                        if (organisation.Deleted == nil)
                        {
                            //no insert it
                            _ = ModelManager.getInstance().addOrganisation(organisation)
                        }
                    }
                    else
                    {
                        //yes
                        
                        //is the current record deleted
                        if (organisation.Deleted != nil)
                        {
                            //yes  - delete the Organisation
                            _ = ModelManager.getInstance().deleteOrganisation(organisation)
                        }
                        else
                        {
                            //no  - update the Organisation
                            _ = ModelManager.getInstance().updateOrganisation(organisation)
                        }
                        
                    }
                    
                    if (progressBar != nil)
                    {
                        DispatchQueue.main.async(execute: {progressBar!.label.text = "Organisation"; progressBar!.progress = (Float(current) / Float(total))})
                    }
                    }
                }

            case .site:
                
                //get the data nodes
                let dataNode: AEXMLElement = packageData["Site"]
                
                //total = dataNode.children.count
                
                for childNode in dataNode.children
                {
                    autoreleasepool{
                    current += 1
                    
                    //get the first child
                    let site: Site = Site(XMLElement: childNode)
                    
                    var currentSynchDate: Date
                    if site.LastUpdatedOn == nil {
                        currentSynchDate = site.CreatedOn as Date
                    }
                    else {
                        currentSynchDate = site.LastUpdatedOn! as Date
                    }
                    
                    lastDateInPackage = (lastDateInPackage as NSDate).laterDate(currentSynchDate)
                    lastRowId = site.RowId
                    
                    //does the record exists
                    let currentSite: Site? = ModelManager.getInstance().getSite(site.RowId)
                    if currentSite == nil
                    {
                        //is the current record deleted
                        if (site.Deleted == nil)
                        {
                            //no insert it
                            _ = ModelManager.getInstance().addSite(site)
                        }
                    }
                    else
                    {
                        //yes
                        
                        //is the current record deleted
                        if (site.Deleted != nil)
                        {
                            //yes  - delete the Site
                            _ = ModelManager.getInstance().deleteSite(site)
                        }
                        else
                        {
                            //no  - update the Site
                            _ = ModelManager.getInstance().updateSite(site)
                        }
                        
                    }
                    
                    if (progressBar != nil)
                    {
                        DispatchQueue.main.async(execute: {progressBar!.label.text = "Site"; progressBar!.progress = (Float(current) / Float(total))})
                    }
                    }
                }
                
            case .property:
                
                //get the data nodes
                let dataNode: AEXMLElement = packageData["Property"]
                
                //total = dataNode.children.count
                
                for childNode in dataNode.children
                {
                    autoreleasepool{
                    current += 1
                    
                    //get the first child
                    let property: Property = Property(XMLElement: childNode)
                    
                    var currentSynchDate: Date
                    if property.LastUpdatedOn == nil {
                        currentSynchDate = property.CreatedOn as Date
                    }
                    else {
                        currentSynchDate = property.LastUpdatedOn! as Date
                    }
                    
                    lastDateInPackage = (lastDateInPackage as NSDate).laterDate(currentSynchDate)
                    lastRowId = property.RowId
                    
                    //does the record exists
                    let currentProperty: Property? = ModelManager.getInstance().getProperty(property.RowId)
                    if currentProperty == nil
                    {
                        //is the current record deleted
                        if (property.Deleted == nil)
                        {
                            //no insert it
                            _ = ModelManager.getInstance().addProperty(property)
                        }
                    }
                    else
                    {
                        //yes
                        
                        //is the current record deleted
                        if (property.Deleted != nil)
                        {
                            //yes  - delete the Property
                            _ = ModelManager.getInstance().deleteProperty(property)
                        }
                        else
                        {
                            //no  - update the Property
                            _ = ModelManager.getInstance().updateProperty(property)
                        }
                        
                    }
                    
                    if (progressBar != nil)
                    {
                        DispatchQueue.main.async(execute: {progressBar!.label.text = "Property"; progressBar!.progress = (Float(current) / Float(total))})
                    }
                    }
                }

            case .referenceData:
                
                //get the data nodes
                let dataNode: AEXMLElement = packageData["ReferenceData"]
                
                //total = dataNode.children.count
                
                for childNode in dataNode.children
                {
                    autoreleasepool{
                    current += 1
                    
                    //get the first child
                    let referenceData: ReferenceData = ReferenceData(XMLElement: childNode)
                    
                    var currentSynchDate: Date
                    if referenceData.LastUpdatedOn == nil {
                        currentSynchDate = referenceData.CreatedOn as Date
                    }
                    else {
                        currentSynchDate = referenceData.LastUpdatedOn! as Date
                    }
                    
                    lastDateInPackage = (lastDateInPackage as NSDate).laterDate(currentSynchDate)
                    lastRowId = referenceData.RowId
                    
                    //does the record exists
                    let currentReferenceData: ReferenceData? = ModelManager.getInstance().getReferenceData(referenceData.RowId)
                    if currentReferenceData == nil
                    {
                        //is the current record deleted
                        if (referenceData.Deleted == nil)
                        {
                            //no insert it
                            _ = ModelManager.getInstance().addReferenceData(referenceData)
                        }
                    }
                    else
                    {
                        //yes
                        
                        //is the current record deleted
                        if (referenceData.Deleted != nil)
                        {
                            //yes  - delete the ReferenceData
                            _ = ModelManager.getInstance().deleteReferenceData(referenceData)
                        }
                        else
                        {
                            //no  - update the ReferenceData
                            _ = ModelManager.getInstance().updateReferenceData(referenceData)
                        }
                    }
                    
                    if (progressBar != nil)
                    {
                        DispatchQueue.main.async(execute: {progressBar!.label.text = "Reference"; progressBar!.progress = (Float(current) / Float(total))})
                    }
                    }
                }
                
            case .task:
                
                //get the data nodes
                let dataNode: AEXMLElement = packageData["Task"]
                
                //total = dataNode.children.count
                
                for childNode in dataNode.children
                {
                    autoreleasepool{
                    current += 1
                    
                    //get the first child
                    let task: Task = Task(XMLElement: childNode)
                    
                    var currentSynchDate: Date
                    if task.LastUpdatedOn == nil {
                        currentSynchDate = task.CreatedOn as Date
                    }
                    else {
                        currentSynchDate = task.LastUpdatedOn! as Date
                    }
                    
                    lastDateInPackage = (lastDateInPackage as NSDate).laterDate(currentSynchDate)
                    lastRowId = task.RowId
                    
                    //does the record exists
                    let currentTask: Task? = ModelManager.getInstance().getTask(task.RowId)
                    if currentTask == nil
                    {
                        //is the current record deleted
                        if (task.Deleted == nil)
                        {
                            //no insert it
                            _ = ModelManager.getInstance().addTask(task)
                        }
                    }
                    else
                    {
                        //yes
                        
                        //is the current record deleted
                        if (task.Deleted != nil)
                        {
                            //yes  - delete the Task
                            _ = ModelManager.getInstance().deleteTask(task)
                        }
                        else
                        {
                            //no  - update the Task
                            if (task.Status != "Outstanding" || (task.Status == "Outstanding" && task.OperativeId != Session.OperativeId))
                            {
                                _ = ModelManager.getInstance().updateTask(task)
                            }
                            else
                            {
                                task.LastUpdatedOn = currentTask?.LastUpdatedOn
                                 _ = ModelManager.getInstance().updateTask(task)
                            }
                        }
                    }
                    
                    if (progressBar != nil)
                    {
                        DispatchQueue.main.async(execute: {progressBar!.label.text = "Task"; progressBar!.progress = (Float(current) / Float(total))})
                    }
                    }
                }

            case .taskParameter:
                
                //get the data nodes
                let dataNode: AEXMLElement = packageData["TaskParameter"]
                
                //total = dataNode.children.count
                
                for childNode in dataNode.children
                {
                    autoreleasepool{
                    current += 1
                    
                    //get the first child
                    let taskParameter: TaskParameter = TaskParameter(XMLElement: childNode)
                    
                    var currentSynchDate: Date
                    if taskParameter.LastUpdatedOn == nil {
                        currentSynchDate = taskParameter.CreatedOn as Date
                    }
                    else {
                        currentSynchDate = taskParameter.LastUpdatedOn! as Date
                    }
                    
                    lastDateInPackage = (lastDateInPackage as NSDate).laterDate(currentSynchDate)
                    lastRowId = taskParameter.RowId
                    
                    //does the record exists
                    let currentTaskParameter: TaskParameter? = ModelManager.getInstance().getTaskParameter(taskParameter.RowId)
                    if currentTaskParameter == nil
                    {
                        //is the current record deleted
                        if (taskParameter.Deleted == nil)
                        {
                            //no insert it
                            _ = ModelManager.getInstance().addTaskParameter(taskParameter)
                        }
                    }
                    else
                    {
                        //yes
                        
                        //is the current record deleted
                        if (taskParameter.Deleted != nil)
                        {
                            //yes  - delete the TaskParameter
                            _ = ModelManager.getInstance().deleteTaskParameter(taskParameter)
                        }
                        else
                        {
                            //no  - update the TaskParameter
                            _ = ModelManager.getInstance().updateTaskParameter(taskParameter)
                        }
                        
                    }
                    
                    if (progressBar != nil)
                    {
                        DispatchQueue.main.async(execute: {progressBar!.label.text = "Task Parameters"; progressBar!.progress = (Float(current) / Float(total))})
                    }
                    }
                }

            case .taskTemplate:
                
                //get the data nodes
                let dataNode: AEXMLElement = packageData["TaskTemplate"]
                
                //total = dataNode.children.count
                
                for childNode in dataNode.children
                {
                    autoreleasepool{
                    current += 1
                    
                    //get the first child
                    let taskTemplate: TaskTemplate = TaskTemplate(XMLElement: childNode)
                    
                    var currentSynchDate: Date
                    if taskTemplate.LastUpdatedOn == nil {
                        currentSynchDate = taskTemplate.CreatedOn as Date
                    }
                    else {
                        currentSynchDate = taskTemplate.LastUpdatedOn! as Date
                    }
                    
                    lastDateInPackage = (lastDateInPackage as NSDate).laterDate(currentSynchDate)
                    lastRowId = taskTemplate.RowId
                    
                    //does the record exists
                    let currentTaskTemplate: TaskTemplate? = ModelManager.getInstance().getTaskTemplate(taskTemplate.RowId)
                    if currentTaskTemplate == nil
                    {
                        //is the current record deleted
                        if (taskTemplate.Deleted == nil)
                        {
                            //no insert it
                            _ = ModelManager.getInstance().addTaskTemplate(taskTemplate)
                        }
                    }
                    else
                    {
                        //yes
                        
                        //is the current record deleted
                        if (taskTemplate.Deleted != nil)
                        {
                            //yes  - delete the TaskTemplate
                            _ = ModelManager.getInstance().deleteTaskTemplate(taskTemplate)
                        }
                        else
                        {
                            //no  - update the TaskTemplate
                            _ = ModelManager.getInstance().updateTaskTemplate(taskTemplate)
                        }
                        
                    }
                    
                    if (progressBar != nil)
                    {
                        DispatchQueue.main.async(execute: {progressBar!.label.text = "Templates"; progressBar!.progress = (Float(current) / Float(total))})
                    }
                    }
                }

            case .taskTemplateParameter:
                
                //get the data nodes
                let dataNode: AEXMLElement = packageData["TaskTemplateParameter"]
                
                //total = dataNode.children.count
                
                for childNode in dataNode.children
                {
                    autoreleasepool{
                    current += 1
                    
                    //get the first child
                    let taskTemplateParameter: TaskTemplateParameter = TaskTemplateParameter(XMLElement: childNode)
                    
                    var currentSynchDate: Date
                    if taskTemplateParameter.LastUpdatedOn == nil {
                        currentSynchDate = taskTemplateParameter.CreatedOn as Date
                    }
                    else {
                        currentSynchDate = taskTemplateParameter.LastUpdatedOn! as Date
                    }
                    
                    lastDateInPackage = (lastDateInPackage as NSDate).laterDate(currentSynchDate)
                    lastRowId = taskTemplateParameter.RowId
                    
                    //does the record exists
                    let currentTaskTemplateParameter: TaskTemplateParameter? = ModelManager.getInstance().getTaskTemplateParameter(taskTemplateParameter.RowId)
                    if currentTaskTemplateParameter == nil
                    {
                        //is the current record deleted
                        if (taskTemplateParameter.Deleted == nil)
                        {
                            //no insert it
                            _ = ModelManager.getInstance().addTaskTemplateParameter(taskTemplateParameter)
                        }
                    }
                    else
                    {
                        //yes
                        
                        //is the current record deleted
                        if (taskTemplateParameter.Deleted != nil)
                        {
                            //yes  - delete the TaskTemplateParameter
                            _ = ModelManager.getInstance().deleteTaskTemplateParameter(taskTemplateParameter)
                        }
                        else
                        {
                            //no  - update the TaskTemplateParameter
                            _ = ModelManager.getInstance().updateTaskTemplateParameter(taskTemplateParameter)
                        }
                        
                    }
                    
                    if (progressBar != nil)
                    {
                        DispatchQueue.main.async(execute: {progressBar!.label.text = "Template Parameters"; progressBar!.progress = (Float(current) / Float(total))})
                    }
                    }
                }

            }
        }
        else
        {
            current = 1
            lastDateInPackage = Date()
        }
        
        return (lastRowId, lastDateInPackage, current, total)
    }
    
    class func SynchroniseAllData(_ viewController: UIViewController, stage: Int32, progressBar: MBProgressHUD?) -> Bool
    {
        var SQLStatement: String
        var SQLParameterValues: [NSObject]
        var synchronisationDateToUse: Date = BaseDate as Date
        var synchronisationType: String = Session.OrganisationId! + ":Receive:"
        synchronisationType.append(String(stage))
        
        SQLStatement = "SELECT [LastSynchronisationDate] FROM [Synchronisation] WHERE [Type] = '" + synchronisationType + "'"
        
        if let lastSynchronisationDate = ModelManager.getInstance().executeSingleDateReader(SQLStatement, SQLParameterValues: []) {
            synchronisationDateToUse = lastSynchronisationDate
        }
        
        var state: Bool
        //var lastDate: NSDate?
        
        switch stage{
        
        case 1:
            (state, _) = refactoredGetAndImport(viewController, synchronisationDate: synchronisationDateToUse, stage: 1, entityType: EntityType.referenceData, progressBar: progressBar)
            if (!state){ return false }
            
        case 2:
            (state, _) = refactoredGetAndImport(viewController, synchronisationDate: synchronisationDateToUse, stage: 2, entityType: EntityType.organisation, progressBar: progressBar)
            if (!state){ return false }
            
        case 3:
            (state, _) = refactoredGetAndImport(viewController, synchronisationDate: synchronisationDateToUse, stage: 3, entityType: EntityType.site, progressBar: progressBar)
            if (!state){ return false }
            
        case 4:
            (state, _) = refactoredGetAndImport(viewController, synchronisationDate: synchronisationDateToUse, stage: 4, entityType: EntityType.property, progressBar: progressBar)
            if (!state){ return false }
        
        case 5:
            (state, _) = refactoredGetAndImport(viewController, synchronisationDate: synchronisationDateToUse, stage: 5, entityType: EntityType.location, progressBar: progressBar)
            if (!state){ return false }
            
        case 6:
            (state, _) = refactoredGetAndImport(viewController, synchronisationDate: synchronisationDateToUse, stage: 6, entityType: EntityType.locationGroup, progressBar: progressBar)
            if (!state){ return false }
            
        case 7:
            (state, _) = refactoredGetAndImport(viewController, synchronisationDate: synchronisationDateToUse, stage: 7, entityType: EntityType.locationGroupMembership, progressBar: progressBar)
            if (!state){ return false }
            
        case 8:
            (state, _) = refactoredGetAndImport(viewController, synchronisationDate: synchronisationDateToUse, stage: 8, entityType: EntityType.asset, progressBar: progressBar)
            if (!state){ return false }
            
        case 9:
            (state, _) = refactoredGetAndImport(viewController, synchronisationDate: synchronisationDateToUse, stage: 9, entityType: EntityType.operative, progressBar: progressBar)
            if (!state){ return false }
            
        case 10:
            (state, _) = refactoredGetAndImport(viewController, synchronisationDate: synchronisationDateToUse, stage: 10, entityType: EntityType.taskTemplate, progressBar: progressBar)
            if (!state) {return false }
            
        case 11:
            (state, _) = refactoredGetAndImport(viewController, synchronisationDate: synchronisationDateToUse, stage: 11, entityType: EntityType.taskTemplateParameter, progressBar: progressBar)
            if (!state){ return false }
            
        case 12:
            (state, _) = refactoredGetAndImport(viewController, synchronisationDate: synchronisationDateToUse, stage: 12, entityType: EntityType.task, progressBar: progressBar)
            if (!state){ return false }

        case 13:
            (state, _) = refactoredGetAndImport(viewController, synchronisationDate: synchronisationDateToUse, stage: 13, entityType: EntityType.taskParameter, progressBar: progressBar)
            if (!state){ return false }

        case 14:
            (state, _) = refactoredGetAndImport(viewController, synchronisationDate: synchronisationDateToUse, stage: 14, entityType: EntityType.operativeGroup, progressBar: progressBar)
            if (!state){ return false }
            
        case 15:
            (state, _) = refactoredGetAndImport(viewController, synchronisationDate: synchronisationDateToUse, stage: 15, entityType: EntityType.operativeGroupMembership, progressBar: progressBar)
            if (!state){ return false }
            
        case 16:
            (state, _) = refactoredGetAndImport(viewController, synchronisationDate: synchronisationDateToUse, stage: 16, entityType: EntityType.operativeGroupTaskTemplateMembership, progressBar: progressBar)
            if (!state){ return false }

        default:
            //response = nil
            print ("Invalid Stage")
        }

        
        SQLStatement = "DELETE FROM [Synchronisation] WHERE [Type] = ?"
        SQLParameterValues = [NSObject]()
        SQLParameterValues.append(synchronisationType as NSObject)
        _ = ModelManager.getInstance().executeDirect(SQLStatement, SQLParameterValues: SQLParameterValues)

        //update the synchronisation history
        let newSynchronisationDate = Date()
    
        SQLStatement = "INSERT INTO [Synchronisation] ([LastSynchronisationDate], [Type]) VALUES (?,?)"
        SQLParameterValues = [NSObject]()
        SQLParameterValues.append(newSynchronisationDate as NSObject)
        SQLParameterValues.append(synchronisationType as NSObject)
        _ = ModelManager.getInstance().executeDirect(SQLStatement, SQLParameterValues: SQLParameterValues)
        
        SQLStatement = "INSERT INTO [SynchronisationHistory] ([SynchronisationDate], [CreatedBy], [CreatedOn], [Outcome]) VALUES (?, ?, ?, ?)"
        SQLParameterValues = [NSObject]()
        SQLParameterValues.append(newSynchronisationDate as NSObject)
        SQLParameterValues.append(Session.OperativeId! as NSObject)
        SQLParameterValues.append(newSynchronisationDate as NSObject)
        SQLParameterValues.append("Success" as NSObject)
        _ = ModelManager.getInstance().executeDirect(SQLStatement, SQLParameterValues: SQLParameterValues)

        return true
    }
  
    class func refactoredGetAndImport(_ viewController: UIViewController, synchronisationDate: Date, stage: Int32, entityType: EntityType, progressBar: MBProgressHUD?) -> (Bool, Date?) {
        
        var lastDate: Date = Date()
        var lastRowId: String = EmptyGuid
        var count: Int32 = 0
        var maxCount: Int32 = 0
        var failed: Bool = false
        
        while ((lastRowId != EmptyGuid || count == 0) && !failed) {
            autoreleasepool{
                count += 1
//                if (progressBar != nil)
//                {
//                    progressBar!.progress = (Float(count) / Float(count + 1));
//                }
                
                let data: Data? = WebService.getSynchronisationPackageSync(Session.OperativeId!, synchronisationDate: synchronisationDate, lastRowId: lastRowId, stage: stage)
                
                if data == nil{
                    NSLog("data  is nil")
                    Session.AlertTitle = "Error"
                    Session.AlertMessage =  "Error with web service - no data"
                    failed = true
                }
                
                if (!failed)
                {
                    let response: AEXMLElement = Utility.openSoapEnvelope(data)!
                    
                    if response.name == "soap:Fault"
                    {
                        NSLog("Soap fault")
                        Session.AlertTitle = "Error"
                        Session.AlertMessage =  response.children[1].value //"Error with web service - invalid data"
                        failed = true
                    }

                    if (!failed)
                    {
                        let SynchronisationPackageData: Data = (response["GetSynchronisationPackageResult"].value! as NSString).data(using: String.Encoding.utf8.rawValue)!
                        
                        var SynchronisationPackageDocument: AEXMLDocument?
                        do {
                            SynchronisationPackageDocument = try AEXMLDocument(xml: SynchronisationPackageData)
                        }
                        catch {
                            SynchronisationPackageDocument = nil
                        }
                        
                        if (SynchronisationPackageDocument != nil)
                        {
                            (lastRowId, lastDate, count, maxCount) = Utility.importData(SynchronisationPackageDocument!.children[0], entityType: entityType, progressBar: progressBar, count: count, maxCount: maxCount)
                        }
                        else{
                            NSLog("Empty packet")
                        }

                        SynchronisationPackageDocument = nil
                    }
                }
            }
        }
        if (!failed)
        {
            return (true, lastDate)
        }
        else
        {
            return (false, nil)
        }
    }
    

    class func CheckSynchronisation(_ viewController: UIViewController, HUD: MBProgressHUD?)
    {
        NSLog("CheckSynchronisation - started")
        self.SendTasks(viewController, HUD: HUD)
        
        self.DownloadAllDetails(viewController, HUD: HUD)
        NSLog("CheckSynchronisation - ended")
    }
    
    class func SendTasks(_ viewController: UIViewController, HUD: MBProgressHUD?)
    {
        var success: Bool = false
        var taskCount: Int32 = 0
        
        var message: String = "Send Tasks failed"
        
        (success,taskCount) = Utility.SendTaskDetails(viewController, HUD: HUD)
        
        if (success)
        {
            if (taskCount > 0)
            {
                message = String(taskCount) + " Task(s) sent to COMPASS"
            }
            else
            {
                return
            }
        }
        else
        {
            message += " : " + Session.AlertMessage!
        }
        
        DispatchQueue.main.async(execute: {invokeAlertMethod(viewController, title: "Send Tasks", message: message)})
    
    }
    
    class func SendTaskDetails(_ viewController: UIViewController, HUD: MBProgressHUD?) -> (Bool, Int32) {
        NSLog("SendTaskDetails - started")
        let isRemoteAvailable = Reachability().connectedToNetwork()
        var taskCounter: Int32 = 0;
        
        if isRemoteAvailable {
            var SQLStatement: String
            var SQLParameterValues: [NSObject]
            var synchronisationDateToUse: Date = BaseDate as Date
            let synchronisationType: String = Session.OrganisationId! + ":Send"
            
            SQLStatement = "SELECT [LastSynchronisationDate] FROM [Synchronisation] WHERE [Type] = '" + synchronisationType + "'"
            
            if let lastSynchronisationDate = ModelManager.getInstance().executeSingleDateReader(SQLStatement, SQLParameterValues: []) {
                synchronisationDateToUse = lastSynchronisationDate
            }
            
            var lastRowId: String = String("00000000-0000-0000-0000-000000000000")
            
            let taskQuery: String = "SELECT RowId, '<Task Id=\"' || CAST(RowId AS VARCHAR(40)) || '\">' || COALESCE('<CreatedBy>' || CAST(CreatedBy AS VARCHAR(40)) || '</CreatedBy>','<CreatedBy />') || COALESCE('<CreatedOn>' || DATETIME(CreatedOn,'unixepoch') || '</CreatedOn>','<CreatedOn />') || COALESCE('<LastUpdatedBy>' || CAST(LastUpdatedBy AS VARCHAR(40)) || '</LastUpdatedBy>','<LastUpdatedBy />') || COALESCE('<LastUpdatedOn>' || DATETIME(LastUpdatedOn,'unixepoch') || '</LastUpdatedOn>','<LastUpdatedOn />') || COALESCE('<Deleted>' || CAST(Deleted AS VARCHAR(20)) || '</Deleted>','<Deleted />') || COALESCE('<OrganisationId>' || CAST(OrganisationId AS VARCHAR(40)) || '</OrganisationId>','<OrganisationId />') || COALESCE('<SiteId>' || CAST(SiteId AS VARCHAR(40)) || '</SiteId>','<SiteId />') || COALESCE('<PropertyId>' || CAST(PropertyId AS VARCHAR(40)) || '</PropertyId>','<PropertyId />') || COALESCE('<LocationId>' || CAST(LocationId AS VARCHAR(40)) || '</LocationId>','<LocationId />') || COALESCE('<TaskTemplateId>' || CAST(TaskTemplateId AS VARCHAR(40)) || '</TaskTemplateId>','<TaskTemplateId />') || COALESCE('<TaskRef>' || TaskRef || '</TaskRef>','<TaskRef />') || COALESCE('<PPMGroup>' || PPMGroup || '</PPMGroup>','<PPMGroup />') || COALESCE('<AssetType>' || AssetType || '</AssetType>','<AssetType />') || COALESCE('<TaskName>' || TaskName || '</TaskName>','<TaskName />') || COALESCE('<Frequency>' || Frequency || '</Frequency>','<Frequency />') || COALESCE('<AssetId>' || CAST(AssetId AS VARCHAR(40)) || '</AssetId>','<AssetId />') || COALESCE('<ScheduledDate>' || DATETIME(ScheduledDate,'unixepoch') || '</ScheduledDate>','<ScheduledDate />') || COALESCE('<CompletedDate>' || DATETIME(CompletedDate,'unixepoch') || '</CompletedDate>','<CompletedDate />') || COALESCE('<Status>' || Status || '</Status>','<Status />') || COALESCE('<Priority>' || CAST(Priority AS VARCHAR(20)) || '</Priority>','<Priority />') || COALESCE('<EstimatedDuration>' || CAST(EstimatedDuration AS VARCHAR(20)) || '</EstimatedDuration>','<EstimatedDuration />') || COALESCE('<OperativeId>' || CAST(OperativeId AS VARCHAR(40)) || '</OperativeId>','<OperativeId />') || COALESCE('<ActualDuration>' || CAST(ActualDuration AS VARCHAR(20)) || '</ActualDuration>','<ActualDuration />') || COALESCE('<TravelDuration>' || CAST(TravelDuration AS VARCHAR(20)) || '</TravelDuration>','<TravelDuration />') || '<Docked>False</Docked>' || COALESCE('<Comments>' || Comments || '</Comments>','<Comments />') || '</Task>' FROM Task WHERE (Status = 'Dockable' OR (Status = 'Outstanding' AND OperativeId = '" + Session.OperativeId! + "')) AND COALESCE(LastUpdatedOn, CreatedOn) >= ? AND RowId > ? ORDER BY RowId "

            let taskParameterQuery: String = "SELECT '<TaskParameter Id=\"' || CAST(TaskParameter.RowId AS VARCHAR(40)) || '\">' || COALESCE('<CreatedBy>' || CAST(TaskParameter.CreatedBy AS VARCHAR(40)) || '</CreatedBy>','<CreatedBy />') || COALESCE('<CreatedOn>' || DATETIME(TaskParameter.CreatedOn,'unixepoch') || '</CreatedOn>','<CreatedOn />') || COALESCE('<LastUpdatedBy>' || CAST(TaskParameter.LastUpdatedBy AS VARCHAR(40)) || '</LastUpdatedBy>','<LastUpdatedBy />') || COALESCE('<LastUpdatedOn>' || DATETIME(TaskParameter.LastUpdatedOn,'unixepoch') || '</LastUpdatedOn>','<LastUpdatedOn />') || COALESCE('<Deleted>' || CAST(TaskParameter.Deleted AS VARCHAR(20)) || '</Deleted>','<Deleted />') || COALESCE('<TaskTemplateParameterId>' || CAST(TaskParameter.TaskTemplateParameterId AS VARCHAR(40)) || '</TaskTemplateParameterId>','<TaskTemplateParameterId />') || COALESCE('<TaskId>' || CAST(TaskParameter.TaskId AS VARCHAR(40)) || '</TaskId>','<TaskId />') || COALESCE('<ParameterName>' || TaskParameter.ParameterName || '</ParameterName>','<ParameterName />') || COALESCE('<ParameterType>' || TaskParameter.ParameterType || '</ParameterType>','<ParameterType />') || COALESCE('<ParameterDisplay>' || TaskParameter.ParameterDisplay || '</ParameterDisplay>','<ParameterDisplay />') || COALESCE('<Collect>' || CASE WHEN TaskParameter.Collect = 1 THEN 'True' ELSE 'False' END || '</Collect>','<Collect />') || COALESCE('<ParameterValue>' || TaskParameter.ParameterValue || '</ParameterValue>','<ParameterValue />') || '</TaskParameter>' FROM TaskParameter WHERE TaskParameter.TaskId = ? "
            
            NSLog("SendTaskDetails - get tasks")
            var noMore: Bool = false
            
            while (!noMore)
            {
                var taskList: [String] = [String]()
            
                var taskQueryParameters: [AnyObject] = [AnyObject]()
                taskQueryParameters.append(synchronisationDateToUse as AnyObject)
                taskQueryParameters.append(lastRowId as AnyObject)
                
                var taskData: String = "<Tasks>"
  
                let resultSet: FMResultSet! = sharedModelManager.database!.executeQuery(taskQuery, withArgumentsIn: taskQueryParameters)
                if (resultSet != nil)
                {
                    while resultSet.next()
                    {
                        let rowId = resultSet.string(forColumnIndex: 0)!
                        let taskRecord = resultSet.string(forColumnIndex: 1)!.replacingOccurrences(of: "<Status>Dockable</Status>", with: "<Status>Complete</Status>")
                        
                        taskCounter += 1
                        taskList.append(rowId)
                        taskData += taskRecord
                    } //while resultSet.next()
                } //if (resultSet != nil)
                
                taskData += "</Tasks>"
            
                if (taskData == "<Tasks></Tasks>")
                {
                    taskData = "<Tasks />"
                    noMore = true;
                }
                
                NSLog("SendTaskDetails - get parameters")
                var taskParameterData: String = "<TaskParameters>"
                        
                for taskId in taskList
                {
                    lastRowId = taskId;
                    
                    var taskParameterQueryParameters: [AnyObject] = [AnyObject]()
                    taskParameterQueryParameters.append(lastRowId as AnyObject)
                    
                    let resultSet: FMResultSet! = sharedModelManager.database!.executeQuery(taskParameterQuery, withArgumentsIn: taskParameterQueryParameters)
                    if (resultSet != nil)
                    {
                        while resultSet.next()
                        {
                            let taskParameterRecord = resultSet.string(forColumnIndex: 0)
                            taskParameterData += taskParameterRecord!
                        } //while resultSet.next()
                    } //if (resultSet != nil)
                } //for taskId in taskList
                
                taskParameterData += "</TaskParameters>"
                
                if (taskParameterData == "<TaskParameters></TaskParameters>")
                {
                    taskParameterData = "<TaskParameters />"
                }
                
                NSLog("SendTaskDetails - send package")
                var PDASynchronisationPackage: String = "<PDASynchronisation>" + taskData + taskParameterData + "</PDASynchronisation>"
                
                PDASynchronisationPackage = PDASynchronisationPackage.xmlSimpleEscape()
                
                let data: Data? = WebService.sendSyncronisationPackageSync(Session.OperativeId!, sysnchronisationPackage: PDASynchronisationPackage)
                
                NSLog("SendTaskDetails - process response")
                if data == nil{
                    Session.AlertTitle = "Error"
                    Session.AlertMessage =  "Error with web service - no data"
                    return (false, 0)
                }
                
                let response: AEXMLElement = Utility.openSoapEnvelope(data)!
                
                if response.name == "soap:Fault"
                {
                    Session.AlertTitle = "Error"
                    Session.AlertMessage =  "Error with web service - soap fault"
                    return (false, 0)
                }
                
                NSLog("SendTaskDetails - update tasks")
                let updateStatement = "UPDATE Task SET LastUpdatedBy = ?,LastUpdatedOn = ?, Status = 'Docked' WHERE RowId = ?";
                
                //set the status of all the tasks sent to Docked
                for taskId in taskList
                {
                    var taskUpdateParameters: [AnyObject] = [AnyObject]()
                    taskUpdateParameters.append(Session.OperativeId! as AnyObject)
                    taskUpdateParameters.append(Date() as AnyObject)
                    taskUpdateParameters.append(taskId as AnyObject)
                    
                    sharedModelManager.database!.executeUpdate(updateStatement, withArgumentsIn: taskUpdateParameters)
                } //for taskId in taskList
                
                NSLog("SendTaskDetails - update synchronisation status")
                SQLStatement = "DELETE FROM [Synchronisation] WHERE [Type] = ?"
                SQLParameterValues = [NSObject]()
                SQLParameterValues.append(synchronisationType as NSObject)
                _ = ModelManager.getInstance().executeDirect(SQLStatement, SQLParameterValues: SQLParameterValues)
                
                //update the synchronisation history
                let newSynchronisationDate = Date()
                
                SQLStatement = "INSERT INTO [Synchronisation] ([LastSynchronisationDate], [Type]) VALUES (?,?)"
                SQLParameterValues = [NSObject]()
                SQLParameterValues.append(newSynchronisationDate as NSObject)
                SQLParameterValues.append(synchronisationType as NSObject)
                _ = ModelManager.getInstance().executeDirect(SQLStatement, SQLParameterValues: SQLParameterValues)
                
                SQLStatement = "INSERT INTO [SynchronisationHistory] ([SynchronisationDate], [CreatedBy], [CreatedOn], [Outcome]) VALUES (?, ?, ?, ?)"
                SQLParameterValues = [NSObject]()
                SQLParameterValues.append(newSynchronisationDate as NSObject)
                SQLParameterValues.append(Session.OperativeId! as NSObject)
                SQLParameterValues.append(newSynchronisationDate as NSObject)
                SQLParameterValues.append("Success" as NSObject)
                _ = ModelManager.getInstance().executeDirect(SQLStatement, SQLParameterValues: SQLParameterValues)
                
            } //while (!noMore)
        }
        else
        {
            Session.AlertMessage = NoNetwork;
        }
        NSLog("SendTaskDetails - ended")
        return (isRemoteAvailable, taskCounter)
    }
 
    class func DownloadAll(_ viewController: UIViewController, HUD: MBProgressHUD?)
    {
        self.DownloadAllDetails(viewController, HUD: HUD)
        
        DispatchQueue.main.async(execute: {invokeAlertMethod(viewController, title: "Synchronise", message: "Download complete")})
        
    }
    
    class func DownloadAllDetails(_ viewController: UIViewController, HUD: MBProgressHUD?)
    {
        var success: Bool = false
        
        // Show the HUD while the provide method  executes in a new thread
        success = Utility.SynchroniseAllData(viewController, stage: 1, progressBar: HUD)
        if(!success)
        {
            Utility.invokeAlertMethodDirect(viewController, title: "Failed to synchronise Reference Data", message: Session.AlertMessage!)
        }
            
        success = Utility.SynchroniseAllData(viewController, stage: 10, progressBar: HUD)
        if(!success)
        {
            Utility.invokeAlertMethodDirect(viewController, title: "Failed to synchronise Task Templates", message: Session.AlertMessage!)
        }
        
        success = Utility.SynchroniseAllData(viewController, stage: 11, progressBar: HUD)
        if(!success)
        {
            Utility.invokeAlertMethodDirect(viewController, title: "Failed to synchronise Task Template Parameters", message: Session.AlertMessage!)
        }
        
        success = Utility.SynchroniseAllData(viewController, stage: 9, progressBar: HUD)
        if(!success)
        {
            Utility.invokeAlertMethodDirect(viewController, title: "Failed to synchronise Operatives", message: Session.AlertMessage!)
        }
        
        success = Utility.SynchroniseAllData(viewController, stage: 14, progressBar: HUD)
        if(!success)
        {
            Utility.invokeAlertMethodDirect(viewController, title: "Failed to synchronise OperativeGroups", message: Session.AlertMessage!)
        }

        success = Utility.SynchroniseAllData(viewController, stage: 15, progressBar: HUD)
        if(!success)
        {
            Utility.invokeAlertMethodDirect(viewController, title: "Failed to synchronise OperativeGroupMemberships", message: Session.AlertMessage!)
        }

        success = Utility.SynchroniseAllData(viewController, stage: 16, progressBar: HUD)
        if(!success)
        {
            Utility.invokeAlertMethodDirect(viewController, title: "Failed to synchronise OperativeGroupTaskTemplateMemberships", message: Session.AlertMessage!)
        }
        
        success = Utility.SynchroniseAllData(viewController, stage: 2, progressBar: HUD)
        if(!success)
        {
            Utility.invokeAlertMethodDirect(viewController, title: "Failed to synchronise Organisations", message: Session.AlertMessage!)
        }
        
        success = Utility.SynchroniseAllData(viewController, stage: 3, progressBar: HUD)
        if(!success)
        {
            Utility.invokeAlertMethodDirect(viewController, title: "Failed to synchronise Sites", message: Session.AlertMessage!)
        }
        
        success = Utility.SynchroniseAllData(viewController, stage: 4, progressBar: HUD)
        if(!success)
        {
            Utility.invokeAlertMethodDirect(viewController, title: "Failed to synchronise Properties", message: Session.AlertMessage!)
        }
        
        success = Utility.SynchroniseAllData(viewController, stage: 6, progressBar: HUD)
        if(!success)
        {
            Utility.invokeAlertMethodDirect(viewController, title: "Failed to synchronise Areas", message: Session.AlertMessage!)
        }
        
        success = Utility.SynchroniseAllData(viewController, stage: 5, progressBar: HUD)
        if(!success)
        {
            Utility.invokeAlertMethodDirect(viewController, title: "Failed to synchronise Locations", message: Session.AlertMessage!)
        }
        
        success = Utility.SynchroniseAllData(viewController, stage: 7, progressBar: HUD)
        if(!success)
        {
            Utility.invokeAlertMethodDirect(viewController, title: "Failed to synchronise Area Links", message: Session.AlertMessage!)
        }
        
        success = Utility.SynchroniseAllData(viewController, stage: 8, progressBar: HUD)
        if(!success)
        {
            Utility.invokeAlertMethodDirect(viewController, title: "Failed to synchronise Assets", message: Session.AlertMessage!)
        }
        
        success = Utility.SynchroniseAllData(viewController, stage: 12, progressBar: HUD)
        if(!success)
        {
            Utility.invokeAlertMethodDirect(viewController, title: "Failed to synchronise Tasks", message: Session.AlertMessage!)
        }
        else
        {
            var SQLStatement: String
            var SQLParameterValues: [NSObject]
            
            SQLStatement = "DELETE FROM [Task] WHERE [OrganisationId] = ? AND [Status] IN ('Complete','Incomplete','Rescheduled') OR [Deleted] IS NOT NULL"
            SQLParameterValues = [NSObject]()
            SQLParameterValues.append(Session.OrganisationId! as NSObject)
            _ = ModelManager.getInstance().executeDirect(SQLStatement, SQLParameterValues: SQLParameterValues)
        }

        success = Utility.SynchroniseAllData(viewController, stage: 13, progressBar: HUD)
        if(!success)
        {
            Utility.invokeAlertMethodDirect(viewController, title: "Failed to synchronise Task Parameters", message: Session.AlertMessage!)
        }
        else
        {
            var SQLStatement: String
            var SQLParameterValues: [NSObject]
            
            SQLStatement = "DELETE FROM [TaskParameter] WHERE [TaskId] NOT IN (SELECT [RowId] FROM [Task])"
            SQLParameterValues = [NSObject]()
            _ = ModelManager.getInstance().executeDirect(SQLStatement, SQLParameterValues: SQLParameterValues)
        }
    }
    
    class func ResetSynchronisationDates(_ viewController: UIViewController, HUD: MBProgressHUD?)
    {
        self.ResetSynchronisationDatesDetails(HUD)
        
        DispatchQueue.main.async(execute: {invokeAlertMethod(viewController, title: "Synchronise", message: "Synchronisation complete")})
    }
    
    class func ResetSynchronisationDatesDetails(_ HUD: MBProgressHUD?)
    {
        var SQLStatement: String
        var SQLParameterValues: [NSObject]
        let synchronisationType: String = Session.OrganisationId! + ":Receive%"

        SQLStatement = "DELETE FROM [Synchronisation] WHERE [Type] LIKE ?"
        SQLParameterValues = [NSObject]()
        SQLParameterValues.append(synchronisationType as NSObject)
        _ = ModelManager.getInstance().executeDirect(SQLStatement, SQLParameterValues: SQLParameterValues)
    }
    
    class func ResetTasks(_ viewController: UIViewController, HUD: MBProgressHUD?)
    {
        self.ResetTasksDetails(HUD)
        
        DispatchQueue.main.async(execute: {invokeAlertMethod(viewController, title: "Synchronise", message: "Synchronisation complete")})

    }
    
    class func ResetTasksDetails(_ HUD: MBProgressHUD?)
    {
        var SQLStatement: String
        var SQLParameterValues: [NSObject]
        
        var synchronisationType: String = Session.OrganisationId! + ":Receive:12"
        SQLStatement = "DELETE FROM [Synchronisation] WHERE [Type] LIKE ?"
        SQLParameterValues = [NSObject]()
        SQLParameterValues.append(synchronisationType as NSObject)
        _ = ModelManager.getInstance().executeDirect(SQLStatement, SQLParameterValues: SQLParameterValues)
    
        synchronisationType = Session.OrganisationId! + ":Receive:13"
        SQLStatement = "DELETE FROM [Synchronisation] WHERE [Type] LIKE ?"
        SQLParameterValues = [NSObject]()
        SQLParameterValues.append(synchronisationType as NSObject)
        _ = ModelManager.getInstance().executeDirect(SQLStatement, SQLParameterValues: SQLParameterValues)
        
        SQLStatement = "DELETE FROM [Task] WHERE [OrganisationId] = ?"
        SQLParameterValues = [NSObject]()
        SQLParameterValues.append(Session.OrganisationId! as NSObject)
        _ = ModelManager.getInstance().executeDirect(SQLStatement, SQLParameterValues: SQLParameterValues)
        
    
    }
    
    class func ResetAllData(_ viewController: UIViewController, HUD: MBProgressHUD?)
    {
        self.ResetAllDataDetails(HUD)
        
        DispatchQueue.main.async(execute: {invokeAlertMethod(viewController, title: "Synchronise", message: "Synchronisation complete")})
    }
    
    class func ResetAllDataDetails(_ HUD: MBProgressHUD?)
    {
        var SQLStatement: String
        var SQLParameterValues: [NSObject]  = [NSObject]()

        _ = ModelManager.getInstance().executeDirectNoParameters("DELETE FROM [ReferenceData]")
        _ = ModelManager.getInstance().executeDirectNoParameters("DELETE FROM [TaskTemplate]")
        _ = ModelManager.getInstance().executeDirectNoParameters("DELETE FROM [TaskTemplateParameter]")
        _ = ModelManager.getInstance().executeDirectNoParameters("DELETE FROM [Operative]")
        _ = ModelManager.getInstance().executeDirectNoParameters("DELETE FROM [Organisation]")
        _ = ModelManager.getInstance().executeDirectNoParameters("DELETE FROM [Site]")
        _ = ModelManager.getInstance().executeDirectNoParameters("DELETE FROM [Property]")
        _ = ModelManager.getInstance().executeDirectNoParameters("DELETE FROM [LocationGroup]")
        _ = ModelManager.getInstance().executeDirectNoParameters("DELETE FROM [LocationGroupMembership]")
        _ = ModelManager.getInstance().executeDirectNoParameters("DELETE FROM [Location]")
        _ = ModelManager.getInstance().executeDirectNoParameters("DELETE FROM [Asset]")
        _ = ModelManager.getInstance().executeDirectNoParameters("DELETE FROM [Task]")
        _ = ModelManager.getInstance().executeDirectNoParameters("DELETE FROM [TaskParameter]")

        var synchronisationType: String = Session.OrganisationId! + ":Receive%"
        SQLStatement = "DELETE FROM [Synchronisation] WHERE [Type] LIKE ?"
        SQLParameterValues = [NSObject]()
        SQLParameterValues.append(synchronisationType as NSObject)
        _ = ModelManager.getInstance().executeDirect(SQLStatement, SQLParameterValues: SQLParameterValues)
        
        synchronisationType = Session.OrganisationId! + ":Send%"
        
        SQLStatement = "DELETE FROM [Synchronisation] WHERE [Type] LIKE ?"
        SQLParameterValues = [NSObject]()
        SQLParameterValues.append(synchronisationType as NSObject)
        _ = ModelManager.getInstance().executeDirect(SQLStatement, SQLParameterValues: SQLParameterValues)
    }

    class func DateToStringForXML(_ dateToFormat: Date) -> String {
        //this doesn't work in 12 hour locale
        let dateStringFormatter = DateFormatter()
        dateStringFormatter.locale = Locale.init(identifier: "en_US_POSIX")
        dateStringFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"
        dateStringFormatter.timeZone = TimeZone(abbreviation: "UTC")
        return dateStringFormatter.string(from: dateToFormat)
    }
    
    class func DateToStringForView(_ dateToFormat: Date) -> String {
        let dateStringFormatter = DateFormatter()
        dateStringFormatter.locale = Locale.init(identifier: "en_US_POSIX")
        dateStringFormatter.dateFormat = "dd/MM/yyyy"
        dateStringFormatter.timeZone = TimeZone(abbreviation: "UTC")
        return dateStringFormatter.string(from: dateToFormat)
    }
    
    class func DateToStringForTaskRef(_ dateToFormat: Date) -> String {
        let dateStringFormatter = DateFormatter()
        dateStringFormatter.locale = Locale.init(identifier: "en_US_POSIX")
        dateStringFormatter.dateFormat = "yyMMddHHmm"
        dateStringFormatter.timeZone = TimeZone(abbreviation: "UTC")
        return dateStringFormatter.string(from: dateToFormat)
    }
    
    func findKeyForValue(_ value: String, dictionary: [String: [String]]) ->String?
    {
        for (key, array) in dictionary
        {
            if (array.contains(value))
            {
                return key
            }
        }
        
        return nil
    }
}

extension Date
{
    
    init(dateString:String) {
        let dateStringFormatter = DateFormatter()
        dateStringFormatter.timeZone = TimeZone(abbreviation: "UTC")
        dateStringFormatter.dateFormat = hasAMPM ? DateFormat12 : DateFormat24
        if let d = dateStringFormatter.date(from: dateString)
        {
            self = Date(timeInterval: 0, since: d)
            return
        }
        
        dateStringFormatter.dateFormat = hasAMPM ? DateFormat12NoNano : DateFormat24NoNano
        if let d = dateStringFormatter.date(from: dateString)
        {
            self = Date(timeInterval: 0, since: d)
            return
        }
        
        dateStringFormatter.dateFormat = DateFormatNoTime
        if let d = dateStringFormatter.date(from: dateString)
        {
            self = Date(timeInterval: 0, since: d)
            return
        }
        
        dateStringFormatter.locale = Locale.init(identifier: "en_US_POSIX")
        dateStringFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"
        dateStringFormatter.timeZone = TimeZone(abbreviation: "UTC")
        if let d = dateStringFormatter.date(from: dateString)
        {
            self = Date(timeInterval: 0, since: d)
            return
        }

        dateStringFormatter.locale = Locale.init(identifier: "en_US_POSIX")
        dateStringFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        dateStringFormatter.timeZone = TimeZone(abbreviation: "UTC")
        if let d = dateStringFormatter.date(from: dateString)
        {
            self = Date(timeInterval: 0, since: d)
            return
        }
        
        let d = dateStringFormatter.date(from: dateString)
        self = Date(timeInterval: 0, since: d!)
    }
   
    func startOfDay() -> Date {
        let dateStringFormatter = DateFormatter()
        dateStringFormatter.dateFormat = hasAMPM ? DateFormat12StartOfDay : DateFormat24StartOfDay
        dateStringFormatter.timeZone = TimeZone(abbreviation: "UTC")
        let startOfDay: Date =  Date(dateString: dateStringFormatter.string(from: self))
        return startOfDay
    }
 
    func endOfDay() -> Date {
        let startOfDay: Date = self.startOfDay()
        let calendar = Calendar.current
        let startOfTomorrow = (calendar as NSCalendar).date(byAdding: .day, value: 1, to: startOfDay, options: NSCalendar.Options(rawValue: 0))!
        let endOfDay = (calendar as NSCalendar).date(byAdding: .second, value: -1, to: startOfTomorrow, options: NSCalendar.Options(rawValue: 0))!
        return endOfDay
    }
    
    func startOfWeek() -> Date {
        var calendar = Calendar.current
        calendar.firstWeekday = 2
        var startOfWeek : NSDate?
        (calendar as NSCalendar).range(of: .weekOfYear, start: &startOfWeek, interval: nil, for: self)
        return startOfWeek! as Date
    }
   
    func endOfWeek() -> Date {
        var calendar = Calendar.current
        calendar.firstWeekday = 2
        var startOfWeek : NSDate?
        (calendar as NSCalendar).range(of: .weekOfYear, start: &startOfWeek, interval: nil, for: self)
        let startOfNextWeek = (calendar as NSCalendar).date(byAdding: .day, value: 7, to: startOfWeek! as Date, options: NSCalendar.Options(rawValue: 0))!
        let endOfWeek = (calendar as NSCalendar).date(byAdding: .second, value: -1, to: startOfNextWeek, options: NSCalendar.Options(rawValue: 0))!
        return endOfWeek as Date
    }
    
    func startOfMonth() -> Date {
        let dateStringFormatter = DateFormatter()
        dateStringFormatter.dateFormat = hasAMPM ? DateFormat12StartOfMonth : DateFormat24StartOfMonth
        dateStringFormatter.timeZone = TimeZone(abbreviation: "UTC")
        return Date(dateString: dateStringFormatter.string(from: self))
    }
 
    func endOfMonth() -> Date {
        let dateStringFormatter = DateFormatter()
        dateStringFormatter.dateFormat = hasAMPM ? DateFormat12StartOfMonth : DateFormat24StartOfMonth
        dateStringFormatter.timeZone = TimeZone(abbreviation: "UTC")
        var startOfMonth : Date?
        startOfMonth =  Date(dateString: dateStringFormatter.string(from: self))

        let calendar = Calendar.current
 
        let startOfNextMonth = (calendar as NSCalendar).date(byAdding: .month, value: 1, to: startOfMonth!, options: NSCalendar.Options(rawValue: 0))!
        let endOfMonth = (calendar as NSCalendar).date(byAdding: .second, value: -1, to: startOfNextMonth, options: NSCalendar.Options(rawValue: 0))!
        return endOfMonth
    }
    
    func startOfNextMonth() -> Date {
        let dateStringFormatter = DateFormatter()
        dateStringFormatter.dateFormat = hasAMPM ? DateFormat12StartOfMonth : DateFormat24StartOfMonth
        dateStringFormatter.timeZone = TimeZone(abbreviation: "UTC")
        var startOfMonth : Date?
        startOfMonth =  Date(dateString: dateStringFormatter.string(from: self))
        
        let calendar = Calendar.current
        let startOfNextMonth = (calendar as NSCalendar).date(byAdding: .month, value: 1, to: startOfMonth!, options: NSCalendar.Options(rawValue: 0))!
        return startOfNextMonth
    }
    
    func endOfNextMonth() -> Date {
        let dateStringFormatter = DateFormatter()
        dateStringFormatter.dateFormat = hasAMPM ? DateFormat12StartOfMonth : DateFormat24StartOfMonth
        dateStringFormatter.timeZone = TimeZone(abbreviation: "UTC")
        var startOfMonth : Date?
        startOfMonth =  Date(dateString: dateStringFormatter.string(from: self))
        
        let calendar = Calendar.current
        
        let startOfOverMonth = (calendar as NSCalendar).date(byAdding: .month, value: 2, to: startOfMonth!, options: NSCalendar.Options(rawValue: 0))!
        let endOfNextMonth = (calendar as NSCalendar).date(byAdding: .second, value: -1, to: startOfOverMonth, options: NSCalendar.Options(rawValue: 0))!
        return endOfNextMonth
    }
    
}

extension String
{
    typealias SimpleToFromReplaceList = [(fromSubString:String,toSubString:String)]

    func simpleReplace( _ mapList:SimpleToFromReplaceList ) -> String
    {
        var string = self

        for (fromStr, toStr) in mapList
        {
            let separatedList = string.components(separatedBy: fromStr)
            if separatedList.count > 1
            {
                string = separatedList.joined(separator: toStr)
            }
        }
    
        return string
    }

    func xmlSimpleUnescape() -> String
    {
        let mapList : SimpleToFromReplaceList = [
        ("&amp;",  "&"),
        ("&quot;", "\""),
        ("&#x27;", "'"),
        ("&#x39;", "'"),
        ("&#x92;", "'"),
        ("&#x96;", "'"),
        ("&gt;",   ">"),
        ("&lt;",   "<")]

        return self.simpleReplace(mapList)
    }

    func xmlSimpleEscape() -> String
    {
        let mapList : SimpleToFromReplaceList = [
        ("&",  "&amp;"),
        ("\"", "&quot;"),
        ("'",  "&#x27;"),
        (">",  "&gt;"),
        ("<",  "&lt;")]

        return self.simpleReplace(mapList)
    }
}

extension URL {
    func value(for parameter: String) -> String? {
        
        let queryItems = URLComponents(string: self.absoluteString)?.queryItems
        let queryItem = queryItems?.filter({$0.name == parameter}).first
        let value = queryItem?.value
        
        return value
    }
}
