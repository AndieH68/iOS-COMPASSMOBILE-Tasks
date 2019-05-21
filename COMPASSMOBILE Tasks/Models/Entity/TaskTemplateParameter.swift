//
//  TaskTemplateParameter.swift
//  COMPASSMOBILE
//
//  Created by Andrew Harper on 26/01/2016.
//  Copyright © 2016 HYDOP E.C.S. All rights reserved.
//

import AEXML

class TaskTemplateParameter: NSObject {
    
    // MARK: - Properties
    
    var RowId: String = String()
    var CreatedBy: String = String()
    var CreatedOn: Date = Date()
    var LastUpdatedBy: String? = nil
    var LastUpdatedOn: Date? = nil
    var Deleted: Date? = nil
    var TaskTemplateId: String = String()
    var ParameterName: String = String()
    var ParameterType: String = String()
    var ParameterDisplay: String = String()
    var Collect: Bool = Bool()
    var ReferenceDataType: String? = nil
    var ReferenceDataExtendedType: String? = nil
    var Ordinal: Int = Int()
    var Predecessor: String? = nil
    var PredecessorTrueValue: String? = nil

    // MARK: - Contructors
    
    convenience
    init(rowId:String, createdBy: String, createdOn: Date, lastUpdatedBy: String?, lastUpdatedOn: Date?, deleted: Date?, taskTemplateId: String, parameterName: String, parameterType: String, parameterDisplay: String, collect: Bool, referenceDataType: String?, referenceDataExtendedType: String?, ordinal: Int, predecessor: String?, predecessorTrueValue: String?) {
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
        self.Predecessor = predecessor
        self.PredecessorTrueValue = predecessorTrueValue
    }
    
    convenience
    init(XMLElement: AEXMLElement) {
        self.init()
        self.RowId = XMLElement.attributes["RowId"]!
        self.CreatedBy = XMLElement.attributes["CreatedBy"]!
        self.CreatedOn = Date(dateString: XMLElement.attributes["CreatedOn"]!)
        if XMLElement.attributes.keys.contains("LastUpdatedBy") {
            if XMLElement.attributes["LastUpdatedBy"] != ""
            {
                self.LastUpdatedBy = XMLElement.attributes["LastUpdatedBy"]!
            }
        }
        if XMLElement.attributes.keys.contains("LastUpdatedOn") {
            if XMLElement.attributes["LastUpdatedOn"] != ""
            {
                self.LastUpdatedOn = Date(dateString: XMLElement.attributes["LastUpdatedOn"]!)
            }
        }
        if XMLElement.attributes.keys.contains("Deleted") {
            if XMLElement.attributes["Deleted"] != ""
            {
                self.Deleted = Date(dateString: XMLElement.attributes["Deleted"]!)
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
        if XMLElement.attributes.keys.contains("Predecessor") {
            if XMLElement.attributes["Predecessor"] != "" {
                self.Predecessor = XMLElement.attributes["Predecessor"]!
            }
        }
        if XMLElement.attributes.keys.contains("PredecessorTrueValue") {
            if XMLElement.attributes["PredecessorTrueValue"] != "" {
                self.PredecessorTrueValue = XMLElement.attributes["PredecessorTrueValue"]!
            }
        }


    }
}
