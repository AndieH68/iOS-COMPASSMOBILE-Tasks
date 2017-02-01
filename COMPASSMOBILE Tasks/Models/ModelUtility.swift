//
//  ModelUtility.swift
//  COMPASSMOBILE
//
//  Created by Andrew Harper on 18/02/2016.
//  Copyright © 2016 HYDOP E.C.S. All rights reserved.
//

import UIKit

let sharedModelUtility = ModelUtility()

class ModelUtility: NSObject {

    let DELIMITER: Character = "\u{254}"
    
    class func getInstance() -> ModelUtility{
        return sharedModelUtility
    }
    
    // MARK: Control/Cache population
    
    func PopulateListControl(_ listControl: NSObject, referenceDateType: String, extendedReferenceDataType: String) -> Bool{
        return true
    }
    
    // MARK: Reference Data
    
    fileprivate func makeKey(_ type: String, parentType: String?, parentValue: String?) -> String{
        var key: String = type
        key.append(DELIMITER)
        if (parentType != nil) { key += parentType! }
        key.append(DELIMITER)
        if (parentValue != nil) { key += parentValue! }
        return key
    }
    
    func AssetNumber(_ asset: Asset) -> String {
        return (asset.ScanCode != nil ? "(" + asset.ScanCode! + ") " : "") + (asset.ClientName != nil ? asset.ClientName! : (asset.HydropName != nil ? asset.HydropName! : "UNKNOWN"))
    }
  
    func GetPropertyName(_ PropertyId: String) -> String {
        if let currentProperty: Property = GetPropertyDetails(PropertyId)
        {
            return currentProperty.Name
        }
        else
        {
            return "Property not found"
        }
    }
    
    func GetPropertyDetails(_ PropertyId: String) -> Property? {
        
        if(Session.PropertyList.keys.contains(PropertyId))
        {
            return Session.PropertyList[PropertyId]
        }
        else
        {
            let currentProperty: Property? = ModelManager.getInstance().getProperty(PropertyId)
            if (currentProperty != nil)
            {
                Session.PropertyList[PropertyId] = currentProperty
                return currentProperty
            }
            else
            {
                return nil
            }
        }
    }
    
    func ReferenceDataValueFromDisplay(_ type: String, value: String)-> String {
        return ReferenceDataValueFromDisplay(type, value: value, parentType: nil, parentValue: nil)
    }
    
    func ReferenceDataValueFromDisplay(_ type: String, value: String, parentType: String?, parentValue: String?) -> String {
        guard let key = GetReverseReferenceDataList(type, parentType: parentType, parentValue: parentValue)[value] else {return ""}
        return key
    }
    
    func ReferenceDataDisplayFromValue(_ type: String, key: String) -> String {
        return ReferenceDataDisplayFromValue(type, key: key, parentType: nil, parentValue: nil)
    }
    
    func ReferenceDataDisplayFromValue(_ type: String, key: String, parentType: String?, parentValue: String?) -> String {
        guard let value = GetReferenceDataList(type, parentType: parentType, parentValue: parentValue)[key] else {return ""}
        return value
    }
    
    func GetReferenceDataList(_ type: String, parentType: String?, parentValue: String?) -> Dictionary<String, String> {
        
        let key: String = makeKey(type, parentType: parentType,parentValue: parentValue)
        
        //Check to see if we have already got ths list for this entity
        if (Session.ReferenceLists[key] == nil)
        {
            _ = PopulateReferenceListCache(type, parentType: parentType, parentValue: parentValue)
        }
        
        return Session.ReferenceLists[key]!  //we've already checked if it exists to unwrapping if ok
    }

    func GetReverseReferenceDataList(_ type: String, parentType: String?, parentValue: String?) -> Dictionary<String, String> {
        
        let key: String = makeKey(type, parentType: parentType,parentValue: parentValue)
        
        //Check to see if we have already got ths list for this entity
        if (Session.ReverseReferenceLists[key] == nil)
        {
            _ = PopulateReferenceListCache(type, parentType: parentType, parentValue: parentValue)
        }
        
        return Session.ReverseReferenceLists[key]!  //we've already checked if it exists to unwrapping if ok
    }
    
    func GetLookupList(_ ReferenceDataType: String, ExtendedReferenceDataType: String?) -> [String]
    {
        var returnArray: [String] = [String]()
        
        if (!Session.LookupLists.keys.contains(ReferenceDataType))
        {
            var lookupList: [String] = [String]()
            
            var criteria: Dictionary<String, AnyObject> = Dictionary<String, AnyObject>()
            criteria["Type"] = ReferenceDataType as AnyObject?
            
            //get the list of reference data from the databse
            let (referenceDataListData, _) = ModelManager.getInstance().findReferenceDataList(criteria, pageSize: nil, pageNumber: nil, sortOrder: ReferenceDataSortOrder.ordinal)
            
            for referenceDataItem in referenceDataListData {
                lookupList.append(referenceDataItem.Display)
            }
            Session.LookupLists[ReferenceDataType] = lookupList as AnyObject?
        }
        
        returnArray = Session.LookupLists[ReferenceDataType] as! [String]
 
        if (ExtendedReferenceDataType != nil)
        {
            if (!Session.LookupLists.keys.contains(ExtendedReferenceDataType!))
            {
                var lookupList: [String] = [String]()
                
                var criteria: Dictionary<String, AnyObject> = Dictionary<String, AnyObject>()
                criteria["Type"] = ExtendedReferenceDataType! as AnyObject?
                
                //get the list of reference data from the databse
                let (referenceDataListData, _) = ModelManager.getInstance().findReferenceDataList(criteria, pageSize: nil, pageNumber: nil, sortOrder: ReferenceDataSortOrder.ordinal)
                
                for referenceDataItem in referenceDataListData {
                    lookupList.append(referenceDataItem.Display)
                }
                Session.LookupLists[ExtendedReferenceDataType!] = lookupList as AnyObject?
            }
            
            returnArray.append(contentsOf: Session.LookupLists[ExtendedReferenceDataType!] as! [String])
        }
        
        return returnArray
    }
    
    func PopulateReferenceListCache(_ type: String, parentType: String?, parentValue: String?) -> Bool {
        
        //get a the reference data unique key
        let key: String = makeKey(type, parentType: parentType, parentValue: parentValue)
        
        //check to see if the unique key exists in the list of lists
        if (Session.ReferenceLists[key] == nil)
        {
            //doesn't exist so we need to populate it from the database and then cache it
            var referenceDataList: Dictionary<String, String> = Dictionary<String, String>()
            var reverseReferenceDataList: Dictionary<String, String> = Dictionary<String, String>()
            
            //build the criteria
            var criteria: Dictionary<String, AnyObject> = Dictionary<String, AnyObject>()
            criteria["Type"] = type as AnyObject?
            if (parentType != nil && parentValue != nil)
            {
                criteria["ParentType"] = parentType! as String as AnyObject?
                criteria["ParentValue"] = parentValue! as String as AnyObject?
            }
            
            //get the list of reference data from the databse
            let referenceDataListData: [ReferenceData] = ModelManager.getInstance().findReferenceDataList(criteria)
            
            for referenceDataItem in referenceDataListData {
                
                //belt and braces: check the keys are no already present
                if (referenceDataList[referenceDataItem.Value] == nil && reverseReferenceDataList[referenceDataItem.Display] == nil)
                {
                    referenceDataList[referenceDataItem.Value] = referenceDataItem.Display
                    reverseReferenceDataList[referenceDataItem.Display] = referenceDataItem.Value
                }
            }
            
            Session.ReferenceLists[key] = referenceDataList
            Session.ReverseReferenceLists[key] = reverseReferenceDataList
        }
        
        return true
    }
    
    //MARK: Filter functions
    func GetFilterSiteList(_ OrganisationId: String) -> [String]
    {
        var Sites: [String] = [String]()
        
        var Query: String = "SELECT DISTINCT [Site].[RowId] FROM [Task] INNER JOIN [Site] ON [Task].[SiteId] = [Site].[RowId] WHERE [Task].[Deleted] IS NULL AND [Site].[Deleted] IS NULL AND [Task].[OrganisationId] = '" + OrganisationId + "'"

        Query +=  " ORDER BY [Site].[Name]"
        sharedModelManager.database!.open()
        let resultSet: FMResultSet! = sharedModelManager.database!.executeQuery(Query, withArgumentsIn: nil)
        if (resultSet != nil) {
            while resultSet.next()
            {
                Sites.append(resultSet.string(forColumn: "RowId"))
            }
        }
        return Sites
    }
    
    func GetFilterPropertyList(_ SiteId: String) -> [String]
    {
        var Properties: [String] = [String]()
        
        var Query: String = "SELECT DISTINCT [Property].[RowId] FROM [Task] INNER JOIN [Property] ON [Task].[PropertyId] = [Property].[RowId] WHERE [Task].[Deleted] IS NULL AND [Property].[Deleted] IS NULL AND [Task].[SiteId] = '" + SiteId + "'"
        Query +=  " ORDER BY [Property].[Name]"
    
        sharedModelManager.database!.open()
        let resultSet: FMResultSet! = sharedModelManager.database!.executeQuery(Query, withArgumentsIn: nil)
        if (resultSet != nil) {
            while resultSet.next()
            {
                Properties.append(resultSet.string(forColumn: "RowId"))
            }
        }
        return Properties
    }
    
    func GetFilterAssetGroupList(_ PropertyId: String, LocationGroupName: String?, Location: String?) -> [String]
    {
        var AssetGroups: [String] = [String]()

        var Query: String = "SELECT DISTINCT [PPMGroup] FROM [Task] WHERE [Deleted] IS NULL AND [PropertyId] = '" + PropertyId + "'"
        if (LocationGroupName != nil)
        {
            Query += " AND [LocationGroupName] = '" + LocationGroupName! + "'"
        }
        
        if (Location != nil)
        {
            Query += " AND [LocationName] = '" + Location! + "'"
        }
        Query +=  " ORDER BY [PPMGroup]"
        sharedModelManager.database!.open()
        let resultSet: FMResultSet! = sharedModelManager.database!.executeQuery(Query, withArgumentsIn: nil)
        if (resultSet != nil) {
            while resultSet.next()
            {
                if (resultSet.string(forColumn: "PPMGroup") != nil)
                {
                    AssetGroups.append(resultSet.string(forColumn: "PPMGroup"))
                }
            }
        }
        return AssetGroups
    }
    
    func GetFilterTaskNameList(_ PropertyId: String, AssetGroup: String, AssetType: String?, LocationGroupName: String?, Location: String?) -> [String]
    {
        var TaskNames: [String] = [String]()
        var Query: String = "SELECT DISTINCT [TaskName] FROM [Task] WHERE [Deleted] IS NULL AND [PropertyId] = '" + PropertyId + "' AND [PPMGroup] = '" + AssetGroup + "' "
        if (AssetType != nil)
        {
            Query += " AND [AssetType] = '" + AssetType! + "'"
        }
        if (LocationGroupName != nil)
        {
            Query += " AND [LocationGroupName] = '" + LocationGroupName! + "'"
        }
        if (Location != nil)
        {
            Query += " AND [LocationName] = '" + Location! + "'"
        }
        Query +=  " ORDER BY [TaskName]"
        sharedModelManager.database!.open()
        let resultSet: FMResultSet! = sharedModelManager.database!.executeQuery(Query, withArgumentsIn: nil)
        if (resultSet != nil) {
            while resultSet.next()
            {
                if (resultSet.string(forColumn: "TaskName") != nil)
                {
                    TaskNames.append(resultSet.string(forColumn: "TaskName"))
                }
            }
        }
        return TaskNames
    }
    
    func GetFilterAssetTypeList(_ PropertyId: String, AssetGroup: String, TaskName: String?, LocationGroupName: String?, Location: String?) -> [String]
    {
        var AssetTypes: [String] = [String]()
        var Query: String = "SELECT DISTINCT [AssetType] FROM [Task] WHERE [Deleted] IS NULL AND [PropertyId] = '" + PropertyId + "' AND [PPMGroup] = '" + AssetGroup + "' "
        if (TaskName != nil)
        {
            Query += " AND [TaskName] = '" + TaskName! + "'"
        }
        if (LocationGroupName != nil)
        {
            Query += " AND [LocationGroupName] = '" + LocationGroupName! + "'"
        }
        if (Location != nil)
        {
            Query += " AND [LocationName] = '" + Location! + "'"
        }
        Query += " ORDER BY [AssetType]"
        sharedModelManager.database!.open()
        let resultSet: FMResultSet! = sharedModelManager.database!.executeQuery(Query, withArgumentsIn: nil)
        if (resultSet != nil) {
            while resultSet.next()
            {
                if (resultSet.string(forColumn: "AssetType") != nil)
                {
                    AssetTypes.append(resultSet.string(forColumn: "AssetType"))
                }
            }
        }
        return AssetTypes
    }
    
    func GetFilterLocationGroupList(_ PropertyId: String, AssetGroup: String?, TaskName: String?, AssetType: String?) -> [String]
    {
        var LocationGroups: [String] = [String]()
        var Query: String = "SELECT DISTINCT [LocationGroupName] FROM [Task] WHERE [Deleted] IS NULL AND [PropertyId] = '" + PropertyId + "'"
        if (AssetGroup != nil)
        {
            Query += " AND [PPMGroup] = '" + AssetGroup! + "'"
        }
        if (TaskName != nil)
        {
            Query += " AND [TaskName] = '" + TaskName! + "'"
        }
        if (AssetType != nil)
        {
            Query += " AND [AssetType] = '" + AssetType! + "'"
        }
        Query += " ORDER BY [LocationGroupName]"
        sharedModelManager.database!.open()
        let resultSet: FMResultSet! = sharedModelManager.database!.executeQuery(Query, withArgumentsIn: nil)
        if (resultSet != nil) {
            while resultSet.next()
            {
                if (resultSet.string(forColumn: "LocationGroupName") != nil)
                {
                    LocationGroups.append(resultSet.string(forColumn: "LocationGroupName"))
                }
            }
        }
        return LocationGroups
    }
    
    func GetFilterLocationList(_ PropertyId: String, AssetGroup: String?, TaskName: String?, AssetType: String?, LocationGroupName: String) -> [String]
    {
        var Locations: [String] = [String]()
        var Query: String = "SELECT DISTINCT [LocationName] FROM [Task] WHERE [Deleted] IS NULL AND [PropertyId] = '" + PropertyId + "'"
        if (AssetGroup != nil)
        {
            Query += " AND [PPMGroup] = '" + AssetGroup! + "'"
        }
        
        if (TaskName != nil)
        {
            Query += " AND [TaskName] = '" + TaskName! + "'"
        }
        
        if (AssetType != nil)
        {
            Query += " AND [AssetType] = '" + AssetType! + "'"
        }
        Query += " AND [LocationGroupName] = '" + LocationGroupName + "'"
        Query += " ORDER BY [LocationName]"
        sharedModelManager.database!.open()
        let resultSet: FMResultSet! = sharedModelManager.database!.executeQuery(Query, withArgumentsIn: nil)
        if (resultSet != nil) {
            while resultSet.next()
            {
                if (resultSet.string(forColumn: "LocationName") != nil)
                {
                    Locations.append(resultSet.string(forColumn: "LocationName"))
                }
            }
        }
        return Locations
    }

    func GetFilterAssetNumberList(_ PropertyId: String, AssetGroup: String?, TaskName: String?, AssetType: String?, LocationGroupName: String?, Location: String?) -> [String]
    {
        var AssetNumbers: [String] = [String]()
        var Query: String = "SELECT DISTINCT [AssetNumber] FROM [Task] WHERE [Deleted] IS NULL AND [PropertyId] = '" + PropertyId + "'"
        if (AssetGroup != nil)
        {
            Query += " AND [PPMGroup] = '" + AssetGroup! + "'"
        }

        if (TaskName != nil)
        {
            Query += " AND [TaskName] = '" + TaskName! + "'"
        }
        
        if (AssetType != nil)
        {
            Query += " AND [AssetType] = '" + AssetType! + "'"
        }
        
        if (LocationGroupName != nil)
        {
            Query += " AND [LocationGroupName] = '" + LocationGroupName! + "'"
        }
        
        if (Location != nil)
        {
            Query += " AND [LocationName] = '" + Location! + "'"
        }
        Query += " ORDER BY [AssetNumber]"
        sharedModelManager.database!.open()
        let resultSet: FMResultSet! = sharedModelManager.database!.executeQuery(Query, withArgumentsIn: nil)
        if (resultSet != nil) {
            while resultSet.next()
            {
                if (resultSet.string(forColumn: "AssetNumber") != nil)
                {
                    AssetNumbers.append(resultSet.string(forColumn: "AssetNumber"))
                }
            }
        }
        return AssetNumbers
    }
    
    func GetCompletedTaskCount() -> Int32
    {
        var count: Int32 = 0
        let Query: String = "SELECT COUNT(RowId) FROM [Task] WHERE [Status] = 'Complete' AND [OrganisationId] = '" + Session.OrganisationId! + "'"
        sharedModelManager.database!.open()
        let resultSet: FMResultSet! = sharedModelManager.database!.executeQuery(Query, withArgumentsIn: nil)
        if (resultSet != nil) {
            while resultSet.next()
            {
                count = resultSet.int(forColumnIndex: 0)
            }
        }
        return count
    }
    

}

