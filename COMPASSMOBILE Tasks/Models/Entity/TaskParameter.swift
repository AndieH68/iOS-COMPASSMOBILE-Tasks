//
//  TaskParameter.swift
//  COMPASSMOBILE
//
//  Created by Andrew Harper on 26/01/2016.
//  Copyright © 2016 HYDOP E.C.S. All rights reserved.
//

import AEXML

class TaskParameter: NSObject {
    
    // MARK: - Properties
    
    var RowId: String = String()
    var CreatedBy: String = String()
    var CreatedOn: Date = Date()
    var LastUpdatedBy: String? = nil
    var LastUpdatedOn: Date? = nil
    var Deleted: Date? = nil
    var TaskTemplateParameterId: String? = nil
    var TaskId: String = String()
    var ParameterName: String = String()
    var ParameterType: String = String()
    var ParameterDisplay: String = String()
    var Collect: Bool = Bool()
    var ParameterValue: String = String()
    
    // MARK: - Contructors
    
    convenience
    init(rowId:String, createdBy: String, createdOn: Date, lastUpdatedBy: String?, lastUpdatedOn: Date?, deleted: Date?, taskTemplateParameterId: String?, taskId: String, parameterName: String, parameterType: String, parameterDisplay: String, collect: Bool, parameterValue: String) {
        self.init()
        self.RowId = rowId
        self.CreatedBy = createdBy
        self.CreatedOn = createdOn
        self.LastUpdatedBy = lastUpdatedBy
        self.LastUpdatedOn = lastUpdatedOn
        self.Deleted = deleted
        self.TaskTemplateParameterId = taskTemplateParameterId
        self.TaskId = taskId
        self.ParameterName = parameterName
        self.ParameterType = parameterType
        self.ParameterDisplay = parameterDisplay
        self.Collect = collect
        self.ParameterValue = parameterValue
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
        if XMLElement.attributes.keys.contains("TaskTemplateParameterId") {
            if XMLElement.attributes["TaskTemplateParameterId"] != "" {
                self.TaskTemplateParameterId = XMLElement.attributes["TaskTemplateParameterId"]!
            }
        }
        self.TaskId = XMLElement.attributes["TaskId"]!
        self.ParameterName = XMLElement.attributes["ParameterName"]!
        self.ParameterType = XMLElement.attributes["ParameterType"]!
        self.ParameterDisplay = XMLElement.attributes["ParameterDisplay"]!
        self.Collect = Bool(XMLElement.attributes["Collect"]! == "true")
        if XMLElement.attributes.keys.contains("ParameterValue") {
            if XMLElement.attributes["ParameterValue"] != "" {
                self.ParameterValue = XMLElement.attributes["ParameterValue"]!
            }
        }

    }
}
