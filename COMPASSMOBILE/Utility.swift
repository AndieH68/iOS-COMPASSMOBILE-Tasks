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
    
    class func copyFile(viewController: UIViewController, fileName: NSString) {
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
                dispatch_async(dispatch_get_main_queue(), {
                    self.invokeAlertMethod(viewController, title: "Error Occured", message: (error?.localizedDescription)!, delegate: nil)
                })

            }
        }
    }
    
    class func invokeAlertMethod(viewController: UIViewController, title: String, message: String, delegate: AnyObject?) {
//        let alert: UIAlertView = UIAlertView()
//        alert.message = strBody as String
//        alert.title = strTitle as String
//        alert.delegate = delegate
//        alert.addButtonWithTitle("Ok")
//        alert.show()
//        
        let userPrompt: UIAlertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        
        //the default action
        let addAction = UIAlertAction( title: "Ok", style: UIAlertActionStyle.Default) {UIAlertAction in delegate}
        userPrompt.addAction(addAction)
        
        dispatch_async(dispatch_get_main_queue(),{viewController.presentViewController(userPrompt, animated: true, completion: nil)})
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
    class func importData(packageData: AEXMLElement, entityType: EntityType) -> (String, NSDate) {
        return importData(packageData, entityType: entityType, progressBar: nil)
    }
    
    class func importData(packageData: AEXMLElement, entityType: EntityType, progressBar: MBProgressHUD?) -> (String, NSDate) {
        
        var lastDateInPackage: NSDate = BaseDate
        var lastRowId: String = EmptyGuid
        
        var current: Int = 0
        var total: Int = 0
        
        switch entityType {
        
        case .Asset:
            
            //get the data nodes
            let dataNode: AEXMLElement = packageData["Asset"]
            
            total = dataNode.children.count
            
            for childNode in dataNode.children
            {
                autoreleasepool{
                current += 1
                
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
                    //is the current record deleted
                    if (asset.Deleted == nil)
                    {
                        //no insert it
                        ModelManager.getInstance().addAsset(asset)
                    }
                }
                else
                {
                    //yes
                    
                    //is the current record deleted
                    if (asset.Deleted != nil)
                    {
                        //yes  - delete the asset
                        ModelManager.getInstance().deleteAsset(asset)
                    }
                    else
                    {
                        //no  - update the asset
                        ModelManager.getInstance().updateAsset(asset)
                    }
                    
                }
                
                if (progressBar != nil)
                {
                    dispatch_async(dispatch_get_main_queue(),{progressBar!.labelText = "Asset"; progressBar!.progress = (Float(current) / Float(total))})
                }
                }
            }
            
        case .Location:
            
            //get the data nodes
            let dataNode: AEXMLElement = packageData["Location"]

            total = dataNode.children.count
            
            for childNode in dataNode.children
            {
                autoreleasepool{
                current += 1
                
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
                    //is the current record deleted
                    if (location.Deleted == nil)
                    {
                        //no insert it
                        ModelManager.getInstance().addLocation(location)
                    }
                }
                else
                {
                    //yes
                    
                    //is the current record deleted
                    if (location.Deleted != nil)
                    {
                        //yes  - delete the Location
                        ModelManager.getInstance().deleteLocation(location)
                    }
                    else
                    {
                        //no  - update the Location
                        ModelManager.getInstance().updateLocation(location)
                    }
                    
                }
                
                if (progressBar != nil)
                {
                    dispatch_async(dispatch_get_main_queue(),{progressBar!.labelText = "Location"; progressBar!.progress = (Float(current) / Float(total))})
                }
                }
            }

        case .LocationGroup:
            
            //get the data nodes
            let dataNode: AEXMLElement = packageData["LocationGroup"]
            
            total = dataNode.children.count
            
            for childNode in dataNode.children
            {
                autoreleasepool{
                current += 1
                
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
                    //is the current record deleted
                    if (locationGroup.Deleted == nil)
                    {
                        //no insert it
                        ModelManager.getInstance().addLocationGroup(locationGroup)
                    }
                }
                else
                {
                    //yes
                    
                    //is the current record deleted
                    if (locationGroup.Deleted != nil)
                    {
                        //yes  - delete the LocationGroup
                        ModelManager.getInstance().deleteLocationGroup(locationGroup)
                    }
                    else
                    {
                        //no  - update the LocationGroup
                        ModelManager.getInstance().updateLocationGroup(locationGroup)
                    }
                    
                }
                
                if (progressBar != nil)
                {
                    dispatch_async(dispatch_get_main_queue(),{progressBar!.labelText = "Area"; progressBar!.progress = (Float(current) / Float(total))})
                }
                }
            }

        case .LocationGroupMembership:
            
            //get the data nodes
            let dataNode: AEXMLElement = packageData["LocationGroupMembership"]
            
            total = dataNode.children.count
            
            for childNode in dataNode.children
            {
                autoreleasepool{
                current += 1
                
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
                    //is the current record deleted
                    if (locationGroupMembership.Deleted == nil)
                    {
                        //no insert it
                        ModelManager.getInstance().addLocationGroupMembership(locationGroupMembership)
                    }
                }
                else
                {
                    //yes
                    
                    //is the current record deleted
                    if (locationGroupMembership.Deleted != nil)
                    {
                        //yes  - delete the LocationGroupMembership
                        ModelManager.getInstance().deleteLocationGroupMembership(locationGroupMembership)
                    }
                    else
                    {
                        //no  - update the LocationGroupMembership
                        ModelManager.getInstance().updateLocationGroupMembership(locationGroupMembership)
                    }
                    
                }
                
                if (progressBar != nil)
                {
                    dispatch_async(dispatch_get_main_queue(),{progressBar!.labelText = "Area Link"; progressBar!.progress = (Float(current) / Float(total))})
                }
                }
            }
            
        case .Operative:
            
            //get the data nodes
            let dataNode: AEXMLElement = packageData["Operative"]
            
            total = dataNode.children.count
            
            for childNode in dataNode.children
            {
                autoreleasepool{
                current += 1
                
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
                    //is the current record deleted
                    if (operative.Deleted == nil)
                    {
                        //no insert it
                        ModelManager.getInstance().addOperative(operative)
                    }
                }
                else
                {
                    //yes
                    
                    //is the current record deleted
                    if (operative.Deleted != nil)
                    {
                        //yes  - delete the Operative
                        ModelManager.getInstance().deleteOperative(operative)
                    }
                    else
                    {
                        //no  - update the Operative
                        ModelManager.getInstance().updateOperative(operative)
                    }
                    
                }
                
                if (progressBar != nil)
                {
                    dispatch_async(dispatch_get_main_queue(),{progressBar!.labelText = "Operative"; progressBar!.progress = (Float(current) / Float(total))})
                }
                }
            }
            
        case .Organisation:
            
            //get the data nodes
            let dataNode: AEXMLElement = packageData["Organisation"]
            
            total = dataNode.children.count
            
            for childNode in dataNode.children
            {
                autoreleasepool{
                current += 1
                
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
                    //is the current record deleted
                    if (organisation.Deleted == nil)
                    {
                        //no insert it
                        ModelManager.getInstance().addOrganisation(organisation)
                    }
                }
                else
                {
                    //yes
                    
                    //is the current record deleted
                    if (organisation.Deleted != nil)
                    {
                        //yes  - delete the Organisation
                        ModelManager.getInstance().deleteOrganisation(organisation)
                    }
                    else
                    {
                        //no  - update the Organisation
                        ModelManager.getInstance().updateOrganisation(organisation)
                    }
                    
                }
                
                if (progressBar != nil)
                {
                    dispatch_async(dispatch_get_main_queue(),{progressBar!.labelText = "Organisation"; progressBar!.progress = (Float(current) / Float(total))})
                }
                }
            }

        case .Site:
            
            //get the data nodes
            let dataNode: AEXMLElement = packageData["Site"]
            
            total = dataNode.children.count
            
            for childNode in dataNode.children
            {
                autoreleasepool{
                current += 1
                
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
                    //is the current record deleted
                    if (site.Deleted == nil)
                    {
                        //no insert it
                        ModelManager.getInstance().addSite(site)
                    }
                }
                else
                {
                    //yes
                    
                    //is the current record deleted
                    if (site.Deleted != nil)
                    {
                        //yes  - delete the Site
                        ModelManager.getInstance().deleteSite(site)
                    }
                    else
                    {
                        //no  - update the Site
                        ModelManager.getInstance().updateSite(site)
                    }
                    
                }
                
                if (progressBar != nil)
                {
                    dispatch_async(dispatch_get_main_queue(),{progressBar!.labelText = "Site"; progressBar!.progress = (Float(current) / Float(total))})
                }
                }
            }
            
        case .Property:
            
            //get the data nodes
            let dataNode: AEXMLElement = packageData["Property"]
            
            total = dataNode.children.count
            
            for childNode in dataNode.children
            {
                autoreleasepool{
                current += 1
                
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
                    //is the current record deleted
                    if (property.Deleted == nil)
                    {
                        //no insert it
                        ModelManager.getInstance().addProperty(property)
                    }
                }
                else
                {
                    //yes
                    
                    //is the current record deleted
                    if (property.Deleted != nil)
                    {
                        //yes  - delete the Property
                        ModelManager.getInstance().deleteProperty(property)
                    }
                    else
                    {
                        //no  - update the Property
                        ModelManager.getInstance().updateProperty(property)
                    }
                    
                }
                
                if (progressBar != nil)
                {
                    dispatch_async(dispatch_get_main_queue(),{progressBar!.labelText = "Property"; progressBar!.progress = (Float(current) / Float(total))})
                }
                }
            }

        case .ReferenceData:
            
            //get the data nodes
            let dataNode: AEXMLElement = packageData["ReferenceData"]
            
            total = dataNode.children.count
            
            for childNode in dataNode.children
            {
                autoreleasepool{
                current += 1
                
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
                    //is the current record deleted
                    if (referenceData.Deleted == nil)
                    {
                        //no insert it
                        ModelManager.getInstance().addReferenceData(referenceData)
                    }
                }
                else
                {
                    //yes
                    
                    //is the current record deleted
                    if (referenceData.Deleted != nil)
                    {
                        //yes  - delete the ReferenceData
                        ModelManager.getInstance().deleteReferenceData(referenceData)
                    }
                    else
                    {
                        //no  - update the ReferenceData
                        ModelManager.getInstance().updateReferenceData(referenceData)
                    }
                }
                
                if (progressBar != nil)
                {
                    dispatch_async(dispatch_get_main_queue(),{progressBar!.labelText = "Reference"; progressBar!.progress = (Float(current) / Float(total))})
                }
                }
            }
            
        case .Task:
            
            //get the data nodes
            let dataNode: AEXMLElement = packageData["Task"]
            
            total = dataNode.children.count
            
            for childNode in dataNode.children
            {
                autoreleasepool{
                current += 1
                
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
                    //is the current record deleted
                    if (task.Deleted == nil)
                    {
                        //no insert it
                        ModelManager.getInstance().addTask(task)
                    }
                }
                else
                {
                    //yes
                    
                    //is the current record deleted
                    if (task.Deleted != nil)
                    {
                        //yes  - delete the Task
                        ModelManager.getInstance().deleteTask(task)
                    }
                    else
                    {
                        //no  - update the Task
                        ModelManager.getInstance().updateTask(task)
                    }
                    
                }
                
                if (progressBar != nil)
                {
                    dispatch_async(dispatch_get_main_queue(),{progressBar!.labelText = "Task"; progressBar!.progress = (Float(current) / Float(total))})
                }
                }
            }

        case .TaskParameter:
            
            //get the data nodes
            let dataNode: AEXMLElement = packageData["TaskParameter"]
            
            total = dataNode.children.count
            
            for childNode in dataNode.children
            {
                autoreleasepool{
                current += 1
                
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
                    //is the current record deleted
                    if (taskParameter.Deleted == nil)
                    {
                        //no insert it
                        ModelManager.getInstance().addTaskParameter(taskParameter)
                    }
                }
                else
                {
                    //yes
                    
                    //is the current record deleted
                    if (taskParameter.Deleted != nil)
                    {
                        //yes  - delete the TaskParameter
                        ModelManager.getInstance().deleteTaskParameter(taskParameter)
                    }
                    else
                    {
                        //no  - update the TaskParameter
                        ModelManager.getInstance().updateTaskParameter(taskParameter)
                    }
                    
                }
                
                if (progressBar != nil)
                {
                    dispatch_async(dispatch_get_main_queue(),{progressBar!.labelText = "Task Parameters"; progressBar!.progress = (Float(current) / Float(total))})
                }
                }
            }

        case .TaskTemplate:
            
            //get the data nodes
            let dataNode: AEXMLElement = packageData["TaskTemplate"]
            
            total = dataNode.children.count
            
            for childNode in dataNode.children
            {
                autoreleasepool{
                current += 1
                
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
                    //is the current record deleted
                    if (taskTemplate.Deleted == nil)
                    {
                        //no insert it
                        ModelManager.getInstance().addTaskTemplate(taskTemplate)
                    }
                }
                else
                {
                    //yes
                    
                    //is the current record deleted
                    if (taskTemplate.Deleted != nil)
                    {
                        //yes  - delete the TaskTemplate
                        ModelManager.getInstance().deleteTaskTemplate(taskTemplate)
                    }
                    else
                    {
                        //no  - update the TaskTemplate
                        ModelManager.getInstance().updateTaskTemplate(taskTemplate)
                    }
                    
                }
                
                if (progressBar != nil)
                {
                    dispatch_async(dispatch_get_main_queue(),{progressBar!.labelText = "Templates"; progressBar!.progress = (Float(current) / Float(total))})
                }
                }
            }

        case .TaskTemplateParameter:
            
            //get the data nodes
            let dataNode: AEXMLElement = packageData["TaskTemplateParameter"]
            
            total = dataNode.children.count
            
            for childNode in dataNode.children
            {
                autoreleasepool{
                current += 1
                
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
                    //is the current record deleted
                    if (taskTemplateParameter.Deleted == nil)
                    {
                        //no insert it
                        ModelManager.getInstance().addTaskTemplateParameter(taskTemplateParameter)
                    }
                }
                else
                {
                    //yes
                    
                    //is the current record deleted
                    if (taskTemplateParameter.Deleted != nil)
                    {
                        //yes  - delete the TaskTemplateParameter
                        ModelManager.getInstance().deleteTaskTemplateParameter(taskTemplateParameter)
                    }
                    else
                    {
                        //no  - update the TaskTemplateParameter
                        ModelManager.getInstance().updateTaskTemplateParameter(taskTemplateParameter)
                    }
                    
                }
                
                if (progressBar != nil)
                {
                    dispatch_async(dispatch_get_main_queue(), {progressBar!.labelText = "Template Parameters"; progressBar!.progress = (Float(current) / Float(total))})
                }
                }
            }

        //default:
            //response = nil
            //print ("invalid EntityType")
        }
        
        return (lastRowId, lastDateInPackage)
    }
    
    class func SynchroniseAllData(viewController: UIViewController, stage: Int32, progressBar: MBProgressHUD?) -> Bool {
        var SQLStatement: String
        var SQLParameterValues: [NSObject]
        var synchronisationDateToUse: NSDate = BaseDate
        var synchronisationType: String = Session.OrganisationId! + ":Receive:"
        synchronisationType.appendContentsOf(String(stage))
        
        SQLStatement = "SELECT [LastSynchronisationDate] FROM [Synchronisation] WHERE [Type] = '" + synchronisationType + "'"
        
        if let lastSynchronisationDate = ModelManager.getInstance().executeSingleDateReader(SQLStatement, SQLParameterValues: nil) {
            synchronisationDateToUse = lastSynchronisationDate
        }
        
        var state: Bool
        //var lastDate: NSDate?
        
        switch stage{
        
        case 1:
            (state, _) = refactoredGetAndImport(viewController, synchronisationDate: synchronisationDateToUse, stage: 1, entityType: EntityType.ReferenceData, progressBar: progressBar)
            if (!state){ return false }
            
        case 2:
            (state, _) = refactoredGetAndImport(viewController, synchronisationDate: synchronisationDateToUse, stage: 2, entityType: EntityType.Organisation, progressBar: progressBar)
            if (!state){ return false }
            
        case 3:
            (state, _) = refactoredGetAndImport(viewController, synchronisationDate: synchronisationDateToUse, stage: 3, entityType: EntityType.Site, progressBar: progressBar)
            if (!state){ return false }
            
        case 4:
            (state, _) = refactoredGetAndImport(viewController, synchronisationDate: synchronisationDateToUse, stage: 4, entityType: EntityType.Property, progressBar: progressBar)
            if (!state){ return false }
        
        case 5:
            (state, _) = refactoredGetAndImport(viewController, synchronisationDate: synchronisationDateToUse, stage: 5, entityType: EntityType.Location, progressBar: progressBar)
            if (!state){ return false }
            
        case 6:
            (state, _) = refactoredGetAndImport(viewController, synchronisationDate: synchronisationDateToUse, stage: 6, entityType: EntityType.LocationGroup, progressBar: progressBar)
            if (!state){ return false }
            
        case 7:
            (state, _) = refactoredGetAndImport(viewController, synchronisationDate: synchronisationDateToUse, stage: 7, entityType: EntityType.LocationGroupMembership, progressBar: progressBar)
            if (!state){ return false }
            
        case 8:
            (state, _) = refactoredGetAndImport(viewController, synchronisationDate: synchronisationDateToUse, stage: 8, entityType: EntityType.Asset, progressBar: progressBar)
            if (!state){ return false }
            
        case 9:
            (state, _) = refactoredGetAndImport(viewController, synchronisationDate: synchronisationDateToUse, stage: 9, entityType: EntityType.Operative, progressBar: progressBar)
            if (!state){ return false }
            
        case 10:
            (state, _) = refactoredGetAndImport(viewController, synchronisationDate: synchronisationDateToUse, stage: 10, entityType: EntityType.TaskTemplate, progressBar: progressBar)
            if (!state) {return false }
            
        case 11:
            (state, _) = refactoredGetAndImport(viewController, synchronisationDate: synchronisationDateToUse, stage: 11, entityType: EntityType.TaskTemplateParameter, progressBar: progressBar)
            if (!state){ return false }
            
        case 12:
            (state, _) = refactoredGetAndImport(viewController, synchronisationDate: synchronisationDateToUse, stage: 12, entityType: EntityType.Task, progressBar: progressBar)
            if (!state){ return false }

        case 13:
            (state, _) = refactoredGetAndImport(viewController, synchronisationDate: synchronisationDateToUse, stage: 13, entityType: EntityType.TaskParameter, progressBar: progressBar)
            if (!state){ return false }

        default:
            //response = nil
            print ("Invalid Stage")
        }

        
        SQLStatement = "DELETE FROM [Synchronisation] WHERE [Type] = ?"
        SQLParameterValues = [NSObject]()
        SQLParameterValues.append(synchronisationType)
        ModelManager.getInstance().executeDirect(SQLStatement, SQLParameterValues: SQLParameterValues)

        //update the synchronisation history
        let newSynchronisationDate = NSDate()
    
        SQLStatement = "INSERT INTO [Synchronisation] ([LastSynchronisationDate], [Type]) VALUES (?,?)"
        SQLParameterValues = [NSObject]()
        SQLParameterValues.append(newSynchronisationDate)
        SQLParameterValues.append(synchronisationType)
        ModelManager.getInstance().executeDirect(SQLStatement, SQLParameterValues: SQLParameterValues)
        
        SQLStatement = "INSERT INTO [SynchronisationHistory] ([SynchronisationDate], [CreatedBy], [CreatedOn], [Outcome]) VALUES (?, ?, ?, ?)"
        SQLParameterValues = [NSObject]()
        SQLParameterValues.append(newSynchronisationDate)
        SQLParameterValues.append(Session.OperativeId!)
        SQLParameterValues.append(newSynchronisationDate)
        SQLParameterValues.append("Success")
        ModelManager.getInstance().executeDirect(SQLStatement, SQLParameterValues: SQLParameterValues)

        return true
    }
  
    class func refactoredGetAndImport(viewController: UIViewController, synchronisationDate: NSDate, stage: Int32, entityType: EntityType, progressBar: MBProgressHUD?) -> (Bool, NSDate?) {
        
        var lastDate: NSDate = NSDate()
        var lastRowId: String = EmptyGuid
        var count: Int32 = 0
        
        while (lastRowId != EmptyGuid || count == 0) {
            count += 1
            if (progressBar != nil)
            {
                progressBar!.progress = (Float(count) / Float(count + 1));
            }
            
            let data: NSData? = WebService.getSynchronisationPackageSync(Session.OperativeId!, synchronisationDate: synchronisationDate, lastRowId: lastRowId, stage: stage)
            
            if data == nil{
                invokeAlertMethod(viewController, title: "Error", message: "error with web service", delegate: nil)
                return (false, nil)
            }
            
            let response: AEXMLElement = Utility.openSoapEnvelope(data)!
            
            if response.name == "soap:Fault"
            {
                //fault code here
                return (false, nil)
            }
            
            let SynchronisationPackageData: NSData = (response["GetSynchronisationPackageResult"].value! as NSString).dataUsingEncoding(NSUTF8StringEncoding)!
            
            var SynchronisationPackageDocument: AEXMLDocument?
            do {
                SynchronisationPackageDocument = try AEXMLDocument(xmlData: SynchronisationPackageData)
            }
            catch {
                SynchronisationPackageDocument = nil
            }
            
            if (SynchronisationPackageDocument != nil)
            {
                (lastRowId,lastDate) = Utility.importData(SynchronisationPackageDocument!.children[0], entityType: entityType, progressBar: progressBar)
            }

            print(String(entityType) + " " + lastRowId + " " + String(count))
            SynchronisationPackageDocument = nil
        }
        print(String(entityType) + " Data Done")
        return (true, lastDate)
    }
    

    class func CheckSynchronisation(viewController: UIViewController, HUD: MBProgressHUD?)
    {
        self.SendTasks(viewController, HUD: HUD)
        
        self.DownloadAll(viewController, HUD: HUD)
    }
    
    class func SendTasks(viewController: UIViewController, HUD: MBProgressHUD?)
    {
        var success: Bool = false
        var taskCount: Int32 = 0
        
        var message: String = "Send Tasks failed"
        
        (success,taskCount) = Utility.SendTaskDetails(viewController, HUD: HUD)
        
        if (success)
        {
            if (taskCount > 0)
            {
                message = String(taskCount) + " Task(s) sent to COMPASS"            }
            else
            {
                message = "No data sent to COMPASS"
            }
        }
        
        dispatch_async(dispatch_get_main_queue(),{invokeAlertMethod(viewController, title: "Tasks Sent", message: message, delegate: nil)})
    
    }
    
    class func SendTaskDetails(viewController: UIViewController, HUD: MBProgressHUD?) -> (Bool, Int32) {
        
        let isRemoteAvailable = Reachability().connectedToNetwork()
        var taskCounter: Int32 = 0;
        
        if isRemoteAvailable {
            var SQLStatement: String
            var SQLParameterValues: [NSObject]
            var synchronisationDateToUse: NSDate = BaseDate
            let synchronisationType: String = Session.OrganisationId! + ":Send"
            
            SQLStatement = "SELECT [LastSynchronisationDate] FROM [Synchronisation] WHERE [Type] = '" + synchronisationType + "'"
            
            if let lastSynchronisationDate = ModelManager.getInstance().executeSingleDateReader(SQLStatement, SQLParameterValues: nil) {
                synchronisationDateToUse = lastSynchronisationDate
            }
            
            var lastRowId: String = String("00000000-0000-0000-0000-000000000000")
            
            let taskQuery: String = "SELECT RowId, '<Task Id=\"' + CAST(RowId AS VARCHAR(40)) + '\">' + COALESCE('<CreatedBy>' + CAST(CreatedBy AS VARCHAR(40)) + '</CreatedBy>','<CreatedBy />') + COALESCE('<CreatedOn>' + CAST(CreatedOn AS VARCHAR(20)) + '</CreatedOn>','<CreatedOn />') + COALESCE('<LastUpdatedBy>' + CAST(LastUpdatedBy AS VARCHAR(40)) + '</LastUpdatedBy>','<LastUpdatedBy />') + COALESCE('<LastUpdatedOn>' + CAST(LastUpdatedOn AS VARCHAR(20)) + '</LastUpdatedOn>','<LastUpdatedOn />') + COALESCE('<Deleted>' + CAST(Deleted AS VARCHAR(20)) + '</Deleted>','<Deleted />') + COALESCE('<OrganisationId>' + CAST(OrganisationId AS VARCHAR(40)) + '</OrganisationId>','<OrganisationId />') + COALESCE('<SiteId>' + CAST(SiteId AS VARCHAR(40)) + '</SiteId>','<SiteId />') + COALESCE('<PropertyId>' + CAST(PropertyId AS VARCHAR(40)) + '</PropertyId>','<PropertyId />') + COALESCE('<LocationId>' + CAST(LocationId AS VARCHAR(40)) + '</LocationId>','<LocationId />') + COALESCE('<TaskTemplateId>' + CAST(TaskTemplateId AS VARCHAR(40)) + '</TaskTemplateId>','<TaskTemplateId />') + COALESCE('<TaskRef>' + TaskRef + '</TaskRef>','<TaskRef />') + COALESCE('<PPMGroup>' + PPMGroup + '</PPMGroup>','<PPMGroup />') + COALESCE('<AssetType>' + AssetType + '</AssetType>','<AssetType />') + COALESCE('<TaskName>' + TaskName + '</TaskName>','<TaskName />') + COALESCE('<Frequency>' + Frequency + '</Frequency>','<Frequency />') + COALESCE('<AssetId>' + CAST(AssetId AS VARCHAR(40)) + '</AssetId>','<AssetId />') + COALESCE('<ScheduledDate>' + CAST(ScheduledDate AS VARCHAR(20)) + '</ScheduledDate>','<ScheduledDate />') + COALESCE('<CompletedDate>' + CAST(CompletedDate AS VARCHAR(20)) + '</CompletedDate>','<CompletedDate />') + COALESCE('<Status>' + Status + '</Status>','<Status />') + COALESCE('<Status>Docking</Status>','<Status />') + COALESCE('<Priority>' + CAST(Priority AS VARCHAR(20)) + '</Priority>','<Priority />') + COALESCE('<EstimatedDuration>' + CAST(EstimatedDuration AS VARCHAR(20)) + '</EstimatedDuration>','<EstimatedDuration />') + COALESCE('<OperativeId>' + CAST(OperativeId AS VARCHAR(40)) + '</OperativeId>','<OperativeId />') + COALESCE('<ActualDuration>' + CAST(ActualDuration AS VARCHAR(20)) + '</ActualDuration>','<ActualDuration />') + COALESCE('<TravelDuration>' + CAST(TravelDuration AS VARCHAR(20)) + '</TravelDuration>','<TravelDuration />') + '<Docked>False</Docked>' + COALESCE('<Comments>' + Comments + '</Comments>','<Comments />') + '</Task>' FROM Task WHERE (Status = 'Complete' OR Status = 'Outstanding') AND COALESCE(LastUpdatedOn, CreatedOn) >= ? AND RowId > ? ORDER BY RowId "

            let taskParameterQuery: String = "SELECT '<TaskParameter Id=\"' + CAST(TaskParameter.RowId AS VARCHAR(40)) + '\">' + COALESCE('<CreatedBy>' + CAST(TaskParameter.CreatedBy AS VARCHAR(40)) + '</CreatedBy>','<CreatedBy />') + COALESCE('<CreatedOn>' + CAST(TaskParameter.CreatedOn AS VARCHAR(20)) + '</CreatedOn>','<CreatedOn />') + COALESCE('<LastUpdatedBy>' + CAST(TaskParameter.LastUpdatedBy AS VARCHAR(40)) + '</LastUpdatedBy>','<LastUpdatedBy />') + COALESCE('<LastUpdatedOn>' + CAST(TaskParameter.LastUpdatedOn AS VARCHAR(20)) + '</LastUpdatedOn>','<LastUpdatedOn />') + COALESCE('<Deleted>' + CAST(TaskParameter.Deleted AS VARCHAR(20)) + '</Deleted>','<Deleted />') + COALESCE('<TaskTemplateParameterId>' + CAST(TaskParameter.TaskTemplateParameterId AS VARCHAR(40)) + '</TaskTemplateParameterId>','<TaskTemplateParameterId />') + COALESCE('<TaskId>' + CAST(TaskParameter.TaskId AS VARCHAR(40)) + '</TaskId>','<TaskId />') + COALESCE('<ParameterName>' + TaskParameter.ParameterName + '</ParameterName>','<ParameterName />') + COALESCE('<ParameterType>' + TaskParameter.ParameterType + '</ParameterType>','<ParameterType />') + COALESCE('<ParameterDisplay>' + TaskParameter.ParameterDisplay + '</ParameterDisplay>','<ParameterDisplay />') + COALESCE('<Collect>' + CASE WHEN TaskParameter.Collect = 1 THEN 'True' ELSE 'False' END + '</Collect>','<Collect />') + COALESCE('<ParameterValue>' + TaskParameter.ParameterValue + '</ParameterValue>','<ParameterValue />') + '</TaskParameter>' FROM TaskParameter WHERE TaskParameter.TaskId = ? "
            
            var noMore: Bool = false
            
            while (!noMore)
            {
                var taskList: [String] = [String]()
            
                var taskQueryParameters: [AnyObject] = [AnyObject]()
                taskQueryParameters.append(synchronisationDateToUse)
                taskQueryParameters.append(lastRowId)
                
                var taskData: String = "<Tasks>"
  
                let resultSet: FMResultSet! = sharedModelManager.database!.executeQuery(taskQuery, withArgumentsInArray: taskQueryParameters)
                if (resultSet != nil)
                {
                    while resultSet.next()
                    {
                        let rowId = resultSet.stringForColumnIndex(0)
                        let taskRecord = resultSet.stringForColumnIndex(1)
                        
                        taskCounter += 1
                        taskList.append(rowId)
                        taskData += taskRecord
                    }
                }
                taskData += "</Tasks>"
            
                if (taskData == "<Tasks></Tasks>")
                {
                    taskData = "<Tasks />"
                    noMore = true;
                }
                
                
                var taskParameterData: String = "<TaskParameters>"
                        
                for taskId in taskList
                {
                    lastRowId = taskId;
                    
                    var taskParameterQueryParameters: [AnyObject] = [AnyObject]()
                    taskParameterQueryParameters.append(lastRowId)
                    
                    let resultSet: FMResultSet! = sharedModelManager.database!.executeQuery(taskParameterQuery, withArgumentsInArray: taskParameterQueryParameters)
                    if (resultSet != nil)
                    {
                        while resultSet.next()
                        {
                            let taskParameterRecord = resultSet.stringForColumnIndex(0)
                            taskParameterData += taskParameterRecord
                        }
                    }
                }
                taskParameterData += "</TaskParameters>"
                
                if (taskParameterData == "<TaskParameters></TaskParameters>")
                {
                    taskParameterData = "<TaskParameters />"
                }
                    
                var PDASynchronisationPackage: String = "<PDASynchronisation>" + taskData + taskParameterData + "</PDASynchronisation>"
                //let PDASynchronisationPackage: String = "&lt;PDASynchronisation&gt;&lt;Tasks /&gt;&lt;TaskParameters /&gt;&lt;/PDASynchronisation&gt;"
                
                PDASynchronisationPackage = PDASynchronisationPackage.xmlSimpleEscape()
                
                let data: NSData? = WebService.sendSyncronisationPackageSync(Session.OperativeId!, sysnchronisationPackage: PDASynchronisationPackage)
                
                if data == nil{
                    invokeAlertMethod(viewController, title: "Error", message: "error with web service", delegate: nil)
                    return (false, 0)
                }
                
                let response: AEXMLElement = Utility.openSoapEnvelope(data)!
                
                if response.name == "soap:Fault"
                {
                    //fault code here
                    return (false, 0)
                }
                
                let updateStatement = "UPDATE Task SET LastUpdatedBy = ?,LastUpdatedOn = ?, Status = 'Docked' WHERE RowId = ?";
                
                //set the status of all the tsks to docked
                for taskId in taskList
                {
                    var taskUpdateParameters: [AnyObject] = [AnyObject]()
                    taskUpdateParameters.append(Session.OperativeId!)
                    taskUpdateParameters.append(NSDate())
                    taskUpdateParameters.append(taskId)
                    
                    sharedModelManager.database!.executeUpdate(updateStatement, withArgumentsInArray: taskUpdateParameters)
                }
                
                SQLStatement = "DELETE FROM [Synchronisation] WHERE [Type] = ?"
                SQLParameterValues = [NSObject]()
                SQLParameterValues.append(synchronisationType)
                ModelManager.getInstance().executeDirect(SQLStatement, SQLParameterValues: SQLParameterValues)
                
                //update the synchronisation history
                let newSynchronisationDate = NSDate()
                
                SQLStatement = "INSERT INTO [Synchronisation] ([LastSynchronisationDate], [Type]) VALUES (?,?)"
                SQLParameterValues = [NSObject]()
                SQLParameterValues.append(newSynchronisationDate)
                SQLParameterValues.append(synchronisationType)
                ModelManager.getInstance().executeDirect(SQLStatement, SQLParameterValues: SQLParameterValues)
                
                SQLStatement = "INSERT INTO [SynchronisationHistory] ([SynchronisationDate], [CreatedBy], [CreatedOn], [Outcome]) VALUES (?, ?, ?, ?)"
                SQLParameterValues = [NSObject]()
                SQLParameterValues.append(newSynchronisationDate)
                SQLParameterValues.append(Session.OperativeId!)
                SQLParameterValues.append(newSynchronisationDate)
                SQLParameterValues.append("Success")
                ModelManager.getInstance().executeDirect(SQLStatement, SQLParameterValues: SQLParameterValues)
                
            }
        }
        return (isRemoteAvailable, taskCounter)
    }
 
    class func DownloadAll(viewController: UIViewController, HUD: MBProgressHUD?)
    {
        self.DownloadAllDetails(viewController, HUD: HUD)
        
        dispatch_async(dispatch_get_main_queue(),{invokeAlertMethod(viewController, title: "Synchronise", message: "Download complete", delegate: nil)})
        
    }
    
    class func DownloadAllDetails(viewController: UIViewController,HUD: MBProgressHUD?)
    {
        
        // Show the HUD while the provide method  executes in a new thread
        Utility.SynchroniseAllData(viewController, stage: 1, progressBar: HUD)
        Utility.SynchroniseAllData(viewController, stage: 10, progressBar: HUD)
        Utility.SynchroniseAllData(viewController, stage: 11, progressBar: HUD)
        Utility.SynchroniseAllData(viewController, stage: 9, progressBar: HUD)
        Utility.SynchroniseAllData(viewController, stage: 2, progressBar: HUD)
        Utility.SynchroniseAllData(viewController, stage: 3, progressBar: HUD)
        Utility.SynchroniseAllData(viewController, stage: 4, progressBar: HUD)
        Utility.SynchroniseAllData(viewController, stage: 6, progressBar: HUD)
        Utility.SynchroniseAllData(viewController, stage: 5, progressBar: HUD)
        Utility.SynchroniseAllData(viewController, stage: 7, progressBar: HUD)
        Utility.SynchroniseAllData(viewController, stage: 8, progressBar: HUD)
        
        Utility.SynchroniseAllData(viewController, stage: 12, progressBar: HUD)
        Utility.SynchroniseAllData(viewController, stage: 13, progressBar: HUD)
        
        var SQLStatement: String
        var SQLParameterValues: [NSObject]
        
        SQLStatement = "DELETE FROM [Task] WHERE [OrganisationId] = ? AND [Status] IN ('Complete','Incomplete','Rescheduled')"
        SQLParameterValues = [NSObject]()
        SQLParameterValues.append(Session.OrganisationId!)
        ModelManager.getInstance().executeDirect(SQLStatement, SQLParameterValues: SQLParameterValues)
        
    }
   
    class func ResetSynchronisationDates(viewController: UIViewController, HUD: MBProgressHUD?)
    {
        self.ResetSynchronisationDatesDetails(HUD)
        
        dispatch_async(dispatch_get_main_queue(),{invokeAlertMethod(viewController, title: "Synchronise", message: "Synchronisation complete", delegate: nil)})
    }
    
    class func ResetSynchronisationDatesDetails(HUD: MBProgressHUD?)
    {
        var SQLStatement: String
        var SQLParameterValues: [NSObject]
        let synchronisationType: String = Session.OrganisationId! + ":Receive%"

        SQLStatement = "DELETE FROM [Synchronisation] WHERE [Type] LIKE ?"
        SQLParameterValues = [NSObject]()
        SQLParameterValues.append(synchronisationType)
        ModelManager.getInstance().executeDirect(SQLStatement, SQLParameterValues: SQLParameterValues)
    }
    
    class func ResetTasks(viewController: UIViewController, HUD: MBProgressHUD?)
    {
        self.ResetTasksDetails(HUD)
        
        dispatch_async(dispatch_get_main_queue(),{invokeAlertMethod(viewController, title: "Synchronise", message: "Synchronisation complete", delegate: nil)})

    }
    
    class func ResetTasksDetails(HUD: MBProgressHUD?)
    {
        var SQLStatement: String
        var SQLParameterValues: [NSObject]
        
        var synchronisationType: String = Session.OrganisationId! + ":Receive:12"
        SQLStatement = "DELETE FROM [Synchronisation] WHERE [Type] LIKE ?"
        SQLParameterValues = [NSObject]()
        SQLParameterValues.append(synchronisationType)
        ModelManager.getInstance().executeDirect(SQLStatement, SQLParameterValues: SQLParameterValues)
    
        synchronisationType = Session.OrganisationId! + ":Receive:13"
        SQLStatement = "DELETE FROM [Synchronisation] WHERE [Type] LIKE ?"
        SQLParameterValues = [NSObject]()
        SQLParameterValues.append(synchronisationType)
        ModelManager.getInstance().executeDirect(SQLStatement, SQLParameterValues: SQLParameterValues)
        
        SQLStatement = "DELETE FROM [Task] WHERE [OrganisationId] = ?"
        SQLParameterValues = [NSObject]()
        SQLParameterValues.append(Session.OrganisationId!)
        ModelManager.getInstance().executeDirect(SQLStatement, SQLParameterValues: SQLParameterValues)
        
    
    }
    
    class func ResetAllData(viewController: UIViewController, HUD: MBProgressHUD?)
    {
        self.ResetAllDataDetails(HUD)
        
        dispatch_async(dispatch_get_main_queue(),{invokeAlertMethod(viewController, title: "Synchronise", message: "Synchronisation complete", delegate: nil)})
    }
    
    class func ResetAllDataDetails(HUD: MBProgressHUD?)
    {
        var SQLStatement: String
        var SQLParameterValues: [NSObject]  = [NSObject]()

        ModelManager.getInstance().executeDirect("DELETE FROM [ReferenceData]", SQLParameterValues: SQLParameterValues)
        ModelManager.getInstance().executeDirect("DELETE FROM [TaskTemplate]", SQLParameterValues: SQLParameterValues)
        ModelManager.getInstance().executeDirect("DELETE FROM [TaskTemplateParameter]", SQLParameterValues: SQLParameterValues)
        ModelManager.getInstance().executeDirect("DELETE FROM [Operative]", SQLParameterValues: SQLParameterValues)
        ModelManager.getInstance().executeDirect("DELETE FROM [Organisation]", SQLParameterValues: SQLParameterValues)
        ModelManager.getInstance().executeDirect("DELETE FROM [Site]", SQLParameterValues: SQLParameterValues)
        ModelManager.getInstance().executeDirect("DELETE FROM [Property]", SQLParameterValues: SQLParameterValues)
        ModelManager.getInstance().executeDirect("DELETE FROM [LocationGroup]", SQLParameterValues: SQLParameterValues)
        ModelManager.getInstance().executeDirect("DELETE FROM [LocationGroupMembership]", SQLParameterValues: SQLParameterValues)
        ModelManager.getInstance().executeDirect("DELETE FROM [Location]", SQLParameterValues: SQLParameterValues)
        ModelManager.getInstance().executeDirect("DELETE FROM [Asset]", SQLParameterValues: SQLParameterValues)
        ModelManager.getInstance().executeDirect("DELETE FROM [Task]", SQLParameterValues: SQLParameterValues)
        ModelManager.getInstance().executeDirect("DELETE FROM [TaskParameter]", SQLParameterValues: SQLParameterValues)

        var synchronisationType: String = Session.OrganisationId! + ":Receive%"
        SQLStatement = "DELETE FROM [Synchronisation] WHERE [Type] LIKE ?"
        SQLParameterValues = [NSObject]()
        SQLParameterValues.append(synchronisationType)
        ModelManager.getInstance().executeDirect(SQLStatement, SQLParameterValues: SQLParameterValues)
        
        synchronisationType = Session.OrganisationId! + ":Send%"
        
        SQLStatement = "DELETE FROM [Synchronisation] WHERE [Type] LIKE ?"
        SQLParameterValues = [NSObject]()
        SQLParameterValues.append(synchronisationType)
        ModelManager.getInstance().executeDirect(SQLStatement, SQLParameterValues: SQLParameterValues)
    }

    
    func findKeyForValue(value: String, dictionary: [String: [String]]) ->String?
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
    
    func startOfDay() -> NSDate {
        let dateStringFormatter = NSDateFormatter()
        dateStringFormatter.dateFormat = DateFormatStartOfDay
        dateStringFormatter.timeZone = NSTimeZone(abbreviation: "UTC")
        let startOfDay: NSDate =  NSDate(dateString: dateStringFormatter.stringFromDate(self))
        return startOfDay
    }
 
    func endOfDay() -> NSDate {
        let startOfDay: NSDate = self.startOfDay()
        let calendar = NSCalendar.currentCalendar()
        let startOfTomorrow = calendar.dateByAddingUnit(.Day, value: 1, toDate: startOfDay, options: NSCalendarOptions(rawValue: 0))!
        let endOfDay = calendar.dateByAddingUnit(.Second, value: -1, toDate: startOfTomorrow, options: NSCalendarOptions(rawValue: 0))!
        return endOfDay
    }
    
    func startOfWeek() -> NSDate {
        let calendar = NSCalendar.currentCalendar()
        calendar.firstWeekday = 2
        var startOfWeek : NSDate?
        calendar.rangeOfUnit(.WeekOfYear, startDate: &startOfWeek, interval: nil, forDate: self)
        return startOfWeek!
    }
   
    func endOfWeek() -> NSDate {
        let calendar = NSCalendar.currentCalendar()
        calendar.firstWeekday = 2
        var startOfWeek : NSDate?
        calendar.rangeOfUnit(.WeekOfYear, startDate: &startOfWeek, interval: nil, forDate: self)
        let startOfNextWeek = calendar.dateByAddingUnit(.Day, value: 7, toDate: startOfWeek!, options: NSCalendarOptions(rawValue: 0))!
        let endOfWeek = calendar.dateByAddingUnit(.Second, value: -1, toDate: startOfNextWeek, options: NSCalendarOptions(rawValue: 0))!
        return endOfWeek
    }
    
    func startOfMonth() -> NSDate {
        let dateStringFormatter = NSDateFormatter()
        dateStringFormatter.dateFormat = DateFormatStartOfMonth
        dateStringFormatter.timeZone = NSTimeZone(abbreviation: "UTC")
        return NSDate(dateString: dateStringFormatter.stringFromDate(self))
    }
 
    func endOfMonth() -> NSDate {
        let dateStringFormatter = NSDateFormatter()
        dateStringFormatter.dateFormat = DateFormatStartOfMonth
        dateStringFormatter.timeZone = NSTimeZone(abbreviation: "UTC")
        var startOfMonth : NSDate?
        startOfMonth =  NSDate(dateString: dateStringFormatter.stringFromDate(self))

        let calendar = NSCalendar.currentCalendar()
 
        let startOfNextMonth = calendar.dateByAddingUnit(.Month, value: 1, toDate: startOfMonth!, options: NSCalendarOptions(rawValue: 0))!
        let endOfMonth = calendar.dateByAddingUnit(.Second, value: -1, toDate: startOfNextMonth, options: NSCalendarOptions(rawValue: 0))!
        return endOfMonth
    }
    
    func startOfNextMonth() -> NSDate {
        let dateStringFormatter = NSDateFormatter()
        dateStringFormatter.dateFormat = DateFormatStartOfMonth
        dateStringFormatter.timeZone = NSTimeZone(abbreviation: "UTC")
        var startOfMonth : NSDate?
        startOfMonth =  NSDate(dateString: dateStringFormatter.stringFromDate(self))
        
        let calendar = NSCalendar.currentCalendar()
        let startOfNextMonth = calendar.dateByAddingUnit(.Month, value: 1, toDate: startOfMonth!, options: NSCalendarOptions(rawValue: 0))!
        return startOfNextMonth
    }
    
    func endOfNextMonth() -> NSDate {
        let dateStringFormatter = NSDateFormatter()
        dateStringFormatter.dateFormat = DateFormatStartOfMonth
        dateStringFormatter.timeZone = NSTimeZone(abbreviation: "UTC")
        var startOfMonth : NSDate?
        startOfMonth =  NSDate(dateString: dateStringFormatter.stringFromDate(self))
        
        let calendar = NSCalendar.currentCalendar()
        
        let startOfOverMonth = calendar.dateByAddingUnit(.Month, value: 2, toDate: startOfMonth!, options: NSCalendarOptions(rawValue: 0))!
        let endOfNextMonth = calendar.dateByAddingUnit(.Second, value: -1, toDate: startOfOverMonth, options: NSCalendarOptions(rawValue: 0))!
        return endOfNextMonth
    }
    
}

extension String
{
    typealias SimpleToFromReplaceList = [(fromSubString:String,toSubString:String)]

    func simpleReplace( mapList:SimpleToFromReplaceList ) -> String
    {
        var string = self

        for (fromStr, toStr) in mapList
        {
            let separatedList = string.componentsSeparatedByString(fromStr)
            if separatedList.count > 1
            {
                string = separatedList.joinWithSeparator(toStr)
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