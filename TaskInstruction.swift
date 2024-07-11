//
//  TaskInstruction.swift
//  COMPASSMOBILE
//
//  Created by Andrew Harper on 26/01/2016.
//  Copyright © 2016 HYDOP E.C.S. All rights reserved.
//

import AEXML

class TaskInstruction: NSObject {

    // MARK: - Properties
    
    var RowId: String = String()
    var CreatedBy: String = String()
    var CreatedOn: Date = Date()
    var LastUpdatedBy: String? = nil
    var LastUpdatedOn: Date? = nil
    var Deleted: Date? = nil
    var TaskId: String = String()
    var EntityType: String = String()
    var EntityId: String = String()
    var OutletId: String? = nil
    var FlushType: String? = nil
    
    // MARK: - Contructors
    
    convenience
    init(rowId: String, createdBy: String, createdOn: Date, lastUpdatedBy: String?, lastUpdatedOn: Date?, deleted: Date?, taskId: String, entityType: String, entityId: String, outletId: String?, flushType: String?) {
        self.init()
        self.RowId = rowId
        self.CreatedBy = createdBy
        self.CreatedOn = createdOn
        self.LastUpdatedBy = lastUpdatedBy
        self.LastUpdatedOn = lastUpdatedOn
        self.Deleted = deleted
        self.TaskId = taskId
        self.EntityType = entityType
        self.EntityId = entityId
        self.OutletId = outletId
        self.FlushType = flushType
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
        self.TaskId = XMLElement.attributes["TaskId"]!
        self.EntityType = XMLElement.attributes["EntityType"]!
        self.EntityId = XMLElement.attributes["EntityId"]!
        if XMLElement.attributes.keys.contains("OutletId") {
            if XMLElement.attributes["OutletId"] != "" {
                self.OutletId = XMLElement.attributes["OutletId"]!
            }
        } 
        if XMLElement.attributes.keys.contains("FlushType") {
            if XMLElement.attributes["FlushType"] != "" {
                self.FlushType = XMLElement.attributes["FlushType"]!
            }
        }
    }
}

