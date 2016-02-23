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
            if (error != nil) {
                let alert: UIAlertView = UIAlertView()
                alert.title = "Error Occured"
                alert.message = error?.localizedDescription
                alert.delegate = nil
                alert.addButtonWithTitle("Ok")
                alert.show()
            }
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
    
    class func openSoapEnvelope(data: NSData?) -> AEXMLElement?{
        if data == nil{
            return nil
        }
        
        var result: AEXMLDocument?
        do {
            result = try AEXMLDocument(xmlData: data!)
        }
        catch {
            result = nil
        }
        
        if result == nil
        {
            return nil
        }
        let response: AEXMLElement = result!["soap:Envelope"]["soap:Body"].children[0]
        return response
    }
    
    // MARK: - Global
    
    class func importData(packageData: AEXMLElement, entityType: EntityType) -> String {
        
        var lastDateInPackage: NSDate = BaseDate
        var lastRowId: String = EmptyGuid
        
        switch entityType {
        
        case .Asset:
            
            //get the data nodes
            let dataNode: AEXMLElement = packageData["Asset"]
            
            for childNode in dataNode.children
            {
                //get the first child
                let asset: Asset = Asset(XMLElement: childNode)
                
                var currentSynchDate: NSDate
                if asset.LastUpdatedOn == nil {
                    currentSynchDate = asset.CreatedOn
                }
                else {
                    currentSynchDate = asset.LastUpdatedOn!
                }
                
                lastDateInPackage = lastDateInPackage.laterDate(currentSynchDate)
                lastRowId = asset.RowId
                
                //does the record exists
                let currentAsset: Asset? = ModelManager.getInstance().getAsset(asset.RowId)
                if currentAsset == nil
                {
                    //yes update it
                    ModelManager.getInstance().addAsset(asset)
                }
                else
                {
                    //no insert it
                    ModelManager.getInstance().updateAsset(asset)
                }
            }
            
        case .Location:
            
            //get the data nodes
            let dataNode: AEXMLElement = packageData["Location"]
            
            for childNode in dataNode.children
            {
                //get the first child
                let location: Location = Location(XMLElement: childNode)
                
                var currentSynchDate: NSDate
                if location.LastUpdatedOn == nil {
                    currentSynchDate = location.CreatedOn
                }
                else {
                    currentSynchDate = location.LastUpdatedOn!
                }
                
                lastDateInPackage = lastDateInPackage.laterDate(currentSynchDate)
                lastRowId = location.RowId
                
                //does the record exists
                let currentLocation: Location? = ModelManager.getInstance().getLocation(location.RowId)
                if currentLocation == nil
                {
                    //yes update it
                    ModelManager.getInstance().addLocation(location)
                }
                else
                {
                    //no insert it
                    ModelManager.getInstance().updateLocation(location)
                }
            }

        case .LocationGroup:
            
            //get the data nodes
            let dataNode: AEXMLElement = packageData["LocationGroup"]
            
            for childNode in dataNode.children
            {
                //get the first child
                let locationGroup: LocationGroup = LocationGroup(XMLElement: childNode)
                
                var currentSynchDate: NSDate
                if locationGroup.LastUpdatedOn == nil {
                    currentSynchDate = locationGroup.CreatedOn
                }
                else {
                    currentSynchDate = locationGroup.LastUpdatedOn!
                }
                
                lastDateInPackage = lastDateInPackage.laterDate(currentSynchDate)
                lastRowId = locationGroup.RowId
                
                //does the record exists
                let currentLocationGroup: LocationGroup? = ModelManager.getInstance().getLocationGroup(locationGroup.RowId)
                if currentLocationGroup == nil
                {
                    //yes update it
                    ModelManager.getInstance().addLocationGroup(locationGroup)
                }
                else
                {
                    //no insert it
                    ModelManager.getInstance().updateLocationGroup(locationGroup)
                }
            }

        case .LocationGroupMembership:
            
            //get the data nodes
            let dataNode: AEXMLElement = packageData["LocationGroupMembership"]
            
            for childNode in dataNode.children
            {
                //get the first child
                let locationGroupMembership: LocationGroupMembership = LocationGroupMembership(XMLElement: childNode)
                
                var currentSynchDate: NSDate
                if locationGroupMembership.LastUpdatedOn == nil {
                    currentSynchDate = locationGroupMembership.CreatedOn
                }
                else {
                    currentSynchDate = locationGroupMembership.LastUpdatedOn!
                }
                
                lastDateInPackage = lastDateInPackage.laterDate(currentSynchDate)
                lastRowId = locationGroupMembership.RowId
                
                //does the record exists
                let currentLocationGroupMembership: LocationGroupMembership? = ModelManager.getInstance().getLocationGroupMembership(locationGroupMembership.RowId)
                if currentLocationGroupMembership == nil
                {
                    //yes update it
                    ModelManager.getInstance().addLocationGroupMembership(locationGroupMembership)
                }
                else
                {
                    //no insert it
                    ModelManager.getInstance().updateLocationGroupMembership(locationGroupMembership)
                }
            }
            
        case .Operative:
            
            //get the data nodes
            let dataNode: AEXMLElement = packageData["Operative"]
            
            for childNode in dataNode.children
            {
                //get the first child
                let operative: Operative = Operative(XMLElement: childNode)
                
                var currentSynchDate: NSDate
                if operative.LastUpdatedOn == nil {
                    currentSynchDate = operative.CreatedOn
                }
                else {
                    currentSynchDate = operative.LastUpdatedOn!
                }
                
                lastDateInPackage = lastDateInPackage.laterDate(currentSynchDate)
                lastRowId = operative.RowId
                
                //does the record exists
                let currentOperative: Operative? = ModelManager.getInstance().getOperative(operative.RowId)
                if currentOperative == nil
                {
                    //yes update it
                    ModelManager.getInstance().addOperative(operative)
                }
                else
                {
                    //no insert it
                    ModelManager.getInstance().updateOperative(operative)
                }
            }
            
        case .Organisation:
            
            //get the data nodes
            let dataNode: AEXMLElement = packageData["Organisation"]
            
            for childNode in dataNode.children
            {
                //get the first child
                let organisation: Organisation = Organisation(XMLElement: childNode)
                
                var currentSynchDate: NSDate
                if organisation.LastUpdatedOn == nil {
                    currentSynchDate = organisation.CreatedOn
                }
                else {
                    currentSynchDate = organisation.LastUpdatedOn!
                }
                
                lastDateInPackage = lastDateInPackage.laterDate(currentSynchDate)
                lastRowId = organisation.RowId
                
                //does the record exists
                let currentOrganisation: Organisation? = ModelManager.getInstance().getOrganisation(organisation.RowId)
                if currentOrganisation == nil
                {
                    //yes update it
                    ModelManager.getInstance().addOrganisation(organisation)
                }
                else
                {
                    //no insert it
                    ModelManager.getInstance().updateOrganisation(organisation)
                }
            }

        case .Site:
            
            //get the data nodes
            let dataNode: AEXMLElement = packageData["Site"]
            
            for childNode in dataNode.children
            {
                //get the first child
                let site: Site = Site(XMLElement: childNode)
                
                var currentSynchDate: NSDate
                if site.LastUpdatedOn == nil {
                    currentSynchDate = site.CreatedOn
                }
                else {
                    currentSynchDate = site.LastUpdatedOn!
                }
                
                lastDateInPackage = lastDateInPackage.laterDate(currentSynchDate)
                lastRowId = site.RowId
                
                //does the record exists
                let currentSite: Site? = ModelManager.getInstance().getSite(site.RowId)
                if currentSite == nil
                {
                    //yes update it
                    ModelManager.getInstance().addSite(site)
                }
                else
                {
                    //no insert it
                    ModelManager.getInstance().updateSite(site)
                }
            }
            
        case .Property:
            
            //get the data nodes
            let dataNode: AEXMLElement = packageData["Property"]
            
            for childNode in dataNode.children
            {
                //get the first child
                let property: Property = Property(XMLElement: childNode)
                
                var currentSynchDate: NSDate
                if property.LastUpdatedOn == nil {
                    currentSynchDate = property.CreatedOn
                }
                else {
                    currentSynchDate = property.LastUpdatedOn!
                }
                
                lastDateInPackage = lastDateInPackage.laterDate(currentSynchDate)
                lastRowId = property.RowId
                
                //does the record exists
                let currentProperty: Property? = ModelManager.getInstance().getProperty(property.RowId)
                if currentProperty == nil
                {
                    //yes update it
                    ModelManager.getInstance().addProperty(property)
                }
                else
                {
                    //no insert it
                    ModelManager.getInstance().updateProperty(property)
                }
            }

        case .ReferenceData:
            
            //get the data nodes
            let dataNode: AEXMLElement = packageData["ReferenceData"]
            
            for childNode in dataNode.children
            {
                //get the first child
                let referenceData: ReferenceData = ReferenceData(XMLElement: childNode)
                
                var currentSynchDate: NSDate
                if referenceData.LastUpdatedOn == nil {
                    currentSynchDate = referenceData.CreatedOn
                }
                else {
                    currentSynchDate = referenceData.LastUpdatedOn!
                }
                
                lastDateInPackage = lastDateInPackage.laterDate(currentSynchDate)
                lastRowId = referenceData.RowId
                
                //does the record exists
                let currentReferenceData: ReferenceData? = ModelManager.getInstance().getReferenceData(referenceData.RowId)
                if currentReferenceData == nil
                {
                    //yes update it
                    ModelManager.getInstance().addReferenceData(referenceData)
                }
                else
                {
                    //no insert it
                    ModelManager.getInstance().updateReferenceData(referenceData)
                }
            }
            
        case .Task:
            
            //get the data nodes
            let dataNode: AEXMLElement = packageData["Task"]
            
            for childNode in dataNode.children
            {
                //get the first child
                let task: Task = Task(XMLElement: childNode)
                
                var currentSynchDate: NSDate
                if task.LastUpdatedOn == nil {
                    currentSynchDate = task.CreatedOn
                }
                else {
                    currentSynchDate = task.LastUpdatedOn!
                }
                
                lastDateInPackage = lastDateInPackage.laterDate(currentSynchDate)
                lastRowId = task.RowId
                
                //does the record exists
                let currentTask: Task? = ModelManager.getInstance().getTask(task.RowId)
                if currentTask == nil
                {
                    //yes update it
                    ModelManager.getInstance().addTask(task)
                }
                else
                {
                    //no insert it
                    ModelManager.getInstance().updateTask(task)
                }
            }

        case .TaskParameter:
            
            //get the data nodes
            let dataNode: AEXMLElement = packageData["TaskParameter"]
            
            for childNode in dataNode.children
            {
                //get the first child
                let taskParameter: TaskParameter = TaskParameter(XMLElement: childNode)
                
                var currentSynchDate: NSDate
                if taskParameter.LastUpdatedOn == nil {
                    currentSynchDate = taskParameter.CreatedOn
                }
                else {
                    currentSynchDate = taskParameter.LastUpdatedOn!
                }
                
                lastDateInPackage = lastDateInPackage.laterDate(currentSynchDate)
                lastRowId = taskParameter.RowId
                
                //does the record exists
                let currentTaskParameter: TaskParameter? = ModelManager.getInstance().getTaskParameter(taskParameter.RowId)
                if currentTaskParameter == nil
                {
                    //yes update it
                    ModelManager.getInstance().addTaskParameter(taskParameter)
                }
                else
                {
                    //no insert it
                    ModelManager.getInstance().updateTaskParameter(taskParameter)
                }
            }

        case .TaskTemplate:
            
            //get the data nodes
            let dataNode: AEXMLElement = packageData["TaskTemplate"]
            
            for childNode in dataNode.children
            {
                //get the first child
                let taskTemplate: TaskTemplate = TaskTemplate(XMLElement: childNode)
                
                var currentSynchDate: NSDate
                if taskTemplate.LastUpdatedOn == nil {
                    currentSynchDate = taskTemplate.CreatedOn
                }
                else {
                    currentSynchDate = taskTemplate.LastUpdatedOn!
                }
                
                lastDateInPackage = lastDateInPackage.laterDate(currentSynchDate)
                lastRowId = taskTemplate.RowId
                
                //does the record exists
                let currentTaskTemplate: TaskTemplate? = ModelManager.getInstance().getTaskTemplate(taskTemplate.RowId)
                if currentTaskTemplate == nil
                {
                    //yes update it
                    ModelManager.getInstance().addTaskTemplate(taskTemplate)
                }
                else
                {
                    //no insert it
                    ModelManager.getInstance().updateTaskTemplate(taskTemplate)
                }
            }

        case .TaskTemplateParameter:
            
            //get the data nodes
            let dataNode: AEXMLElement = packageData["TaskTemplateParameter"]
            
            for childNode in dataNode.children
            {
                //get the first child
                let taskTemplateParameter: TaskTemplateParameter = TaskTemplateParameter(XMLElement: childNode)
                
                var currentSynchDate: NSDate
                if taskTemplateParameter.LastUpdatedOn == nil {
                    currentSynchDate = taskTemplateParameter.CreatedOn
                }
                else {
                    currentSynchDate = taskTemplateParameter.LastUpdatedOn!
                }
                
                lastDateInPackage = lastDateInPackage.laterDate(currentSynchDate)
                lastRowId = taskTemplateParameter.RowId
                
                //does the record exists
                let currentTaskTemplateParameter: TaskTemplateParameter? = ModelManager.getInstance().getTaskTemplateParameter(taskTemplateParameter.RowId)
                if currentTaskTemplateParameter == nil
                {
                    //yes update it
                    ModelManager.getInstance().addTaskTemplateParameter(taskTemplateParameter)
                }
                else
                {
                    //no insert it
                    ModelManager.getInstance().updateTaskTemplateParameter(taskTemplateParameter)
                }
            }

        //default:
            //response = nil
            //print ("invalid EntityType")
        }
        
        return lastRowId
    }
    
    class func SynchroniseData(synchronisationDate: NSDate) -> Bool {
        var SQLStatement: String
        var SQLParameterValues: [NSObject]
        var synchronisationDateToUse: NSDate
        SQLStatement = "SELECT LastSynchronisationDate FROM Synchronisation WHERE Type = 'Receive'"
        if let lastSynchronisationDate = ModelManager.getInstance().executeSingleDateReader(SQLStatement, SQLParameterValues: nil) {
            synchronisationDateToUse = lastSynchronisationDate
        }
        else {
          synchronisationDateToUse = synchronisationDate
        }
        
        if !refactoredGetAndImport(synchronisationDateToUse, stage: 1, entityType: EntityType.ReferenceData){ return false }
        if !refactoredGetAndImport(synchronisationDateToUse, stage: 2, entityType: EntityType.Organisation){ return false }
        if !refactoredGetAndImport(synchronisationDateToUse, stage: 3, entityType: EntityType.Site){ return false }
        if !refactoredGetAndImport(synchronisationDateToUse, stage: 4, entityType: EntityType.Property){ return false }
        if !refactoredGetAndImport(synchronisationDateToUse, stage: 5, entityType: EntityType.Location){ return false }
        if !refactoredGetAndImport(synchronisationDateToUse, stage: 6, entityType: EntityType.LocationGroup){ return false }
        if !refactoredGetAndImport(synchronisationDateToUse, stage: 7, entityType: EntityType.LocationGroupMembership){ return false }
        if !refactoredGetAndImport(synchronisationDateToUse, stage: 8, entityType: EntityType.Asset){ return false }
        if !refactoredGetAndImport(synchronisationDateToUse, stage: 10, entityType: EntityType.TaskTemplate){ return false }
        if !refactoredGetAndImport(synchronisationDateToUse, stage: 11, entityType: EntityType.TaskTemplateParameter){ return false }
        if !refactoredGetAndImport(synchronisationDateToUse, stage: 12, entityType: EntityType.Task){ return false }

        //delete tasks that are not pending or outstanding
        ModelManager.getInstance().executeDirect("DELETE FROM [Task] WHERE [Status] != 'Pending' AND [Status] != 'Outstanding'", SQLParameterValues: nil)
        
        //update the synchronisation history
        let newSynchronisationDate = NSDate()
        
        SQLStatement = "INSERT INTO [Synchronisation] (LastSynchronisationDate, Type) VALUES (?,?)"
        SQLParameterValues = [NSObject]()
        SQLParameterValues.append(newSynchronisationDate)
        SQLParameterValues.append("Receive")
        ModelManager.getInstance().executeDirect(SQLStatement, SQLParameterValues: SQLParameterValues)
        
        SQLStatement = "INSERT INTO [SynchronisationHistory] (SynchronisationDate, CreatedBy, CreatedOn ,Outcome) VALUES (?, ?, ?, ?)"
        SQLParameterValues = [NSObject]()
        SQLParameterValues.append(newSynchronisationDate)
        SQLParameterValues.append(Session.OperativeId!)
        SQLParameterValues.append(newSynchronisationDate)
        SQLParameterValues.append("Success")
        ModelManager.getInstance().executeDirect(SQLStatement, SQLParameterValues: SQLParameterValues)

        return true
    }
  
    class func refactoredGetAndImport(synchronisationDate: NSDate, stage: Int32, entityType: EntityType) ->Bool {
            
        var lastRowId: String = EmptyGuid
        var count: Int32 = 0
        
        while (lastRowId != EmptyGuid || count == 0) {
            count += 1
            let data: NSData? = WebService.getSynchronisationPackage(Session.OperativeId!, synchronisationDate: synchronisationDate, lastRowId: lastRowId, stage: stage)
            
            if data == nil{
                invokeAlertMethod("Error", strBody: "error with web service", delegate: nil)
                return false
            }
            
            let response: AEXMLElement = Utility.openSoapEnvelope(data)!
            
            if response.name == "soap:Fault"
            {
                //fault code here
                return false
            }
            
            let SynchronisationPackageData: NSData = (response["GetSynchronisationPackageResult"].value! as NSString).dataUsingEncoding(NSUTF8StringEncoding)!
            
            var SynchronisationPackageDocument: AEXMLDocument?
            do {
                SynchronisationPackageDocument = try AEXMLDocument(xmlData: SynchronisationPackageData)
            }
            catch {
                SynchronisationPackageDocument = nil
            }
            
            lastRowId = Utility.importData(SynchronisationPackageDocument!.children[0], entityType: entityType)
            if entityType == EntityType.Task
            {
              Utility.importData(SynchronisationPackageDocument!.children[0], entityType: .TaskParameter)
            }
            print(String(entityType) + " " + lastRowId + " " + String(count))
        }
        print(String(entityType) + " Data Done")
        return true
    }
}

extension NSDate
{
    convenience
    init(dateString:String) {
        let dateStringFormatter = NSDateFormatter()
        dateStringFormatter.timeZone = NSTimeZone(abbreviation: "UTC")
        dateStringFormatter.dateFormat = DateFormat
        if let d = dateStringFormatter.dateFromString(dateString)
        {
            self.init(timeInterval:0, sinceDate:d)
            return
        }
        dateStringFormatter.dateFormat = DateFormatNoNano
        if let d = dateStringFormatter.dateFromString(dateString)
        {
            self.init(timeInterval:0, sinceDate:d)
            return
        }
        dateStringFormatter.dateFormat = DateFormatNoTime
        if let d = dateStringFormatter.dateFromString(dateString)
        {
            self.init(timeInterval:0, sinceDate:d)
            return
        }
        let d = dateStringFormatter.dateFromString(dateString)
        self.init(timeInterval:0, sinceDate:d!)
    }
    
    func toString() -> String {
        let dateStringFormatter = NSDateFormatter()
        dateStringFormatter.dateFormat = DateFormat
        dateStringFormatter.timeZone = NSTimeZone(abbreviation: "UTC")
        return dateStringFormatter.stringFromDate(self)
    }
    
    func toStringForView() -> String {
        let dateStringFormatter = NSDateFormatter()
        dateStringFormatter.dateFormat = "dd/MM/yyyy"
        dateStringFormatter.timeZone = NSTimeZone(abbreviation: "UTC")
        return dateStringFormatter.stringFromDate(self)
    }
}