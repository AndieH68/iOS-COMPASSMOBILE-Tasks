//
//  TaskTemplateParameter.swift
//  COMPASSMOBILE
//
//  Created by Andrew Harper on 26/01/2016.
//  Copyright © 2016 HYDOP E.C.S. All rights reserved.
//

import Foundation

class TaskTemplateParameter: NSObject {
    
    // MARK: - Properties
    
    var RowId: String = String()
    var CreatedBy: String = String()
    var CreatedOn: NSDate = NSDate()
    var LastUpdatedBy: String? = nil
    var LastUpdatedOn: NSDate? = nil
    var Deleted: NSDate? = nil
    var TaskTemplateId: String = String()
    var ParameterName: String = String()
    var ParameterType: String = String()
    var ParameterDisplay: String = String()
    var Collect: Bool = Bool()
    var ReferenceDataType: String? = nil
    var ReferenceDataExtendedType: String? = nil
    var Ordinal: Int = Int()

    // MARK: - Contructors
    
    convenience
    init(rowId:String, createdBy: String, createdOn: NSDate, lastUpdatedBy: String?, lastUpdatedOn: NSDate?, deleted: NSDate?, taskTemplateId: String, parameterName: String, parameterType: String, parameterDisplay: String, collect: Bool, referenceDataType: String?, referenceDataExtendedType: String?, ordinal: Int) {
        self.init()
        self.RowId = rowId
        self.CreatedBy = createdBy
        self.CreatedOn = createdOn
        self.LastUpdatedBy = lastUpdatedBy
        self.LastUpdatedOn = lastUpdatedOn
        self.Deleted = deleted
        self.TaskTemplateId = taskTemplateId
        self.ParameterName = parameterName
        self.ParameterType = parameterType
        self.ParameterDisplay = parameterDisplay
        self.Collect = collect
        self.ReferenceDataType = referenceDataType
        self.ReferenceDataExtendedType = referenceDataExtendedType
        self.Ordinal = ordinal
    }
    
    convenience
    init(XMLElement: AEXMLElement) {
        self.init()
        self.RowId = XMLElement.attributes["RowId"]!
        self.CreatedBy = XMLElement.attributes["CreatedBy"]!
        self.CreatedOn = NSDate(dateString: XMLElement.attributes["CreatedOn"]!)
        if XMLElement.attributes.keys.contains("LastUpdatedBy") {
            if XMLElement.attributes["LastUpdatedBy"] != ""
            {
                self.LastUpdatedBy = XMLElement.attributes["LastUpdatedBy"]!
            }
        }
        if XMLElement.attributes.keys.contains("LastUpdatedOn") {
            if XMLElement.attributes["LastUpdatedOn"] != ""
            {
                self.LastUpdatedOn = NSDate(dateString: XMLElement.attributes["LastUpdatedOn"]!)
            }
        }
        if XMLElement.attributes.keys.contains("Deleted") {
            if XMLElement.attributes["Deleted"] != ""
            {
                self.Deleted = NSDate(dateString: XMLElement.attributes["Deleted"]!)
            }
        }
        self.TaskTemplateId = XMLElement.attributes["TaskTemplateId"]!
        self.ParameterName = XMLElement.attributes["ParameterName"]!
        self.ParameterType = XMLElement.attributes["ParameterType"]!
        self.ParameterDisplay = XMLElement.attributes["ParameterDisplay"]!
        self.Collect = Bool(XMLElement.attributes["Collect"]! == "1")
        if XMLElement.attributes.keys.contains("ReferenceDataType") {
            if XMLElement.attributes["ReferenceDataType"] != "" {
                self.ReferenceDataType = XMLElement.attributes["ReferenceDataType"]!
            }
        }
        if XMLElement.attributes.keys.contains("ReferenceDataExtendedType") {
            if XMLElement.attributes["ReferenceDataExtendedType"] != "" {
                self.ReferenceDataExtendedType = XMLElement.attributes["ReferenceDataExtendedType"]!
            }
        }
        self.Ordinal = Int(XMLElement.attributes["Ordinal"]!)!

    }
}
