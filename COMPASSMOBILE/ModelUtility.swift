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
    
    func SystemKey(type: String, value: String)-> String {
        return SystemKey(type, value: value, parentType: nil, parentValue: nil)
    }
    
    func SystemKey(type: String, value: String, parentType: String?, parentValue: String?) -> String {
        guard let key = GetReverseReferenceDataList(type, parentType: parentType, parentValue: parentValue)[value] else {return ""}
        return key
    }
    
    func SystemValue(type: String, key: String) -> String {
        return SystemValue(type, key: key, parentType: nil, parentValue: nil)
    }
    
    func SystemValue(type: String, key: String, parentType: String?, parentValue: String?) -> String {
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
            var criteria: Dictionary<String,AnyObject> = Dictionary<String,AnyObject>()
            criteria["Type"] = type
            if (parentType != nil && parentValue != nil)
            {
                criteria["ParentType"] = parentType!
                criteria["ParentValue"] = parentValue!
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
    
    //MARK: Task functions
    func GetFilteredTaskList(pageNumber: Int32, sortOrder: TaskSortOrder) -> [Task]
    {
        
        
        return [Task]()
    }
}

