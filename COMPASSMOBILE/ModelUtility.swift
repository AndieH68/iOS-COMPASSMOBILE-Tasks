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
    
    func PopulateListControl(listControl: NSObject, referenceDateType: String, extendedReferenceDataType: String) -> Bool{
        return true
    }
    
    // MARK: Reference Data
    
    private func makeKey(type: String, parentType: String?, parentValue: String?) -> String{
        var key: String = type
        key.append(DELIMITER)
        if (parentType != nil) { key += parentType! }
        key.append(DELIMITER)
        if (parentValue != nil) { key += parentValue! }
        return key
    }
    
    func ReferenceDataValueFromDisplay(type: String, value: String)-> String {
        return ReferenceDataValueFromDisplay(type, value: value, parentType: nil, parentValue: nil)
    }
    
    func ReferenceDataValueFromDisplay(type: String, value: String, parentType: String?, parentValue: String?) -> String {
        guard let key = GetReverseReferenceDataList(type, parentType: parentType, parentValue: parentValue)[value] else {return ""}
        return key
    }
    
    func ReferenceDataDisplayFromValue(type: String, key: String) -> String {
        return ReferenceDataDisplayFromValue(type, key: key, parentType: nil, parentValue: nil)
    }
    
    func ReferenceDataDisplayFromValue(type: String, key: String, parentType: String?, parentValue: String?) -> String {
        guard let value = GetReferenceDataList(type, parentType: parentType, parentValue: parentValue)[key] else {return ""}
        return value
    }
    
    func GetReferenceDataList(type: String, parentType: String?, parentValue: String?) -> Dictionary<String, String> {
        
        let key: String = makeKey(type, parentType: parentType,parentValue: parentValue)
        
        //Check to see if we have already got ths list for this entity
        if (Session.ReferenceLists[key] == nil)
        {
            PopulateReferenceListCache(type, parentType: parentType, parentValue: parentValue)
        }
        
        return Session.ReferenceLists[key]!  //we've already checked if it exists to unwrapping if ok
    }

    func GetReverseReferenceDataList(type: String, parentType: String?, parentValue: String?) -> Dictionary<String, String> {
        
        let key: String = makeKey(type, parentType: parentType,parentValue: parentValue)
        
        //Check to see if we have already got ths list for this entity
        if (Session.ReverseReferenceLists[key] == nil)
        {
            PopulateReferenceListCache(type, parentType: parentType, parentValue: parentValue)
        }
        
        return Session.ReverseReferenceLists[key]!  //we've already checked if it exists to unwrapping if ok
    }
    
    func PopulateReferenceListCache(type: String, parentType: String?, parentValue: String?) -> Bool {
        
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
            criteria["Type"] = type
            if (parentType != nil && parentValue != nil)
            {
                criteria["ParentType"] = parentType! as String
                criteria["ParentValue"] = parentValue! as String
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

    func GetFilterAssetGroupList(PropertyId: String, LocationGroupName: String?, Location: String?) -> [String]
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
        let resultSet: FMResultSet! = sharedModelManager.database!.executeQuery(Query, withArgumentsInArray: nil)
        if (resultSet != nil) {
            while resultSet.next()
            {
                AssetGroups.append(resultSet.stringForColumn("PPMGroup"))
            }
        }
        return AssetGroups
    }
    
    func GetFilterTaskNameList(PropertyId: String, AssetGroup: String, AssetType: String?, LocationGroupName: String?, Location: String?) -> [String]
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
        let resultSet: FMResultSet! = sharedModelManager.database!.executeQuery(Query, withArgumentsInArray: nil)
        if (resultSet != nil) {
            while resultSet.next()
            {
                TaskNames.append(resultSet.stringForColumn("TaskName"))
            }
        }
        return TaskNames
    }
    
    func GetFilterAssetTypeList(PropertyId: String, AssetGroup: String, TaskName: String?, LocationGroupName: String?, Location: String?) -> [String]
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
        let resultSet: FMResultSet! = sharedModelManager.database!.executeQuery(Query, withArgumentsInArray: nil)
        if (resultSet != nil) {
            while resultSet.next()
            {
                AssetTypes.append(resultSet.stringForColumn("AssetType"))
            }
        }
        return AssetTypes
    }
    
    func GetFilterLocationGroupList(PropertyId: String, AssetGroup: String?, TaskName: String?, AssetType: String?) -> [String]
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
        let resultSet: FMResultSet! = sharedModelManager.database!.executeQuery(Query, withArgumentsInArray: nil)
        if (resultSet != nil) {
            while resultSet.next()
            {
                LocationGroups.append(resultSet.stringForColumn("LocationGroupName"))
            }
        }
        return LocationGroups
    }
    
    func GetFilterLocationList(PropertyId: String, AssetGroup: String?, TaskName: String?, AssetType: String?, LocationGroupName: String) -> [String]
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
        let resultSet: FMResultSet! = sharedModelManager.database!.executeQuery(Query, withArgumentsInArray: nil)
        if (resultSet != nil) {
            while resultSet.next()
            {
                Locations.append(resultSet.stringForColumn("LocationName"))
            }
        }
        return Locations
    }

    func GetFilterAssetNumberList(PropertyId: String, AssetGroup: String?, TaskName: String?, AssetType: String?, LocationGroupName: String?, Location: String?) -> [String]
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
        let resultSet: FMResultSet! = sharedModelManager.database!.executeQuery(Query, withArgumentsInArray: nil)
        if (resultSet != nil) {
            while resultSet.next()
            {
                AssetNumbers.append(resultSet.stringForColumn("AssetNumber"))
            }
        }
        return AssetNumbers
    }
    

}

