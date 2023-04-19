//
//  TaskTemplate.swift
//  COMPASSMOBILE
//
//  Created by Andrew Harper on 26/01/2016.
//  Copyright © 2016 HYDOP E.C.S. All rights reserved.
//

import AEXML

class TaskTemplate: NSObject {
    
    // MARK: - Properties
    
    var RowId: String = String()
    var CreatedBy: String = String()
    var CreatedOn: Date = Date()
    var LastUpdatedBy: String? = nil
    var LastUpdatedOn: Date? = nil
    var Deleted: Date? = nil
    var OrganisationId: String = String()
    var AssetType: String = String()
    var TaskName: String = String()
    var Priority: Int = Int()
    var EstimatedDuration: Int = Int()
    var CanCreateFromDevice: Bool = true
    
    // MARK: - Contructors
    
    convenience
    init(rowId:String, createdBy: String, createdOn: Date, lastUpdatedBy: String?, lastUpdatedOn: Date?, deleted: Date?, organisationId: String, assetType: String, taskName: String, priority: Int, estimatedDuration: Int, canCreateFromDevice: Bool) {
        self.init()
        self.RowId = rowId
        self.CreatedBy = createdBy
        self.CreatedOn = createdOn
        self.LastUpdatedBy = lastUpdatedBy
        self.LastUpdatedOn = lastUpdatedOn
        self.Deleted = deleted
        self.OrganisationId = organisationId
        self.AssetType = assetType
        self.TaskName = taskName
        self.Priority = priority
        self.EstimatedDuration = estimatedDuration
        self.CanCreateFromDevice = canCreateFromDevice
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
        self.OrganisationId = XMLElement.attributes["OrganisationId"]!
        self.AssetType = XMLElement.attributes["AssetType"]!
        self.TaskName = XMLElement.attributes["TaskName"]!
        self.Priority = Int(XMLElement.attributes["Priority"]!)!
        self.EstimatedDuration = Int(XMLElement.attributes["EstimatedDuration"]!)!
        self.CanCreateFromDevice = (XMLElement.attributes["CanCreateFromDevice"]! == "true") //should test to make sure boolean
    }
}
