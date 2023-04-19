//
//  Task.swift
//  COMPASSMOBILE
//
//  Created by Andrew Harper on 26/01/2016.
//  Copyright © 2016 HYDOP E.C.S. All rights reserved.
//

import AEXML

class Task: NSObject {

    // MARK: - Properties
    
    var RowId: String = String()
    var CreatedBy: String = String()
    var CreatedOn: Date = Date()
    var LastUpdatedBy: String? = nil
    var LastUpdatedOn: Date? = nil
    var Deleted: Date? = nil
    var OrganisationId: String = String()
    var SiteId: String = String()
    var PropertyId: String = String()
    var LocationId: String = String()
    var LocationGroupName: String = String()
    var LocationName: String = String()
    var Room: String? = nil
    var TaskTemplateId: String? = nil
    var TaskRef: String = String()
    var PPMGroup: String? = nil
    var AssetType: String? = nil
    var TaskName: String = String()
    var Frequency: String = String()
    var AssetId: String? = nil
    var AssetNumber: String? = nil
    var ScheduledDate: Date = Date()
    var CompletedDate: Date? = nil
    var Status: String = String()
    var Priority: Int = Int()
    var EstimatedDuration: Int? = nil
    var OperativeId: String? = nil
    var ActualDuration: Int? = nil
    var TravelDuration: Int? = nil
    var Comments: String? = nil
    var AlternateAssetCode: String? = nil
    var Level: String? = nil

    // MARK: - Contructors
    
    convenience
    init(rowId: String, createdBy: String, createdOn: Date, lastUpdatedBy: String?, lastUpdatedOn: Date?, deleted: Date?, organisationId: String, siteId: String, propertyId: String, locationId: String, locationGroupName: String, locationName: String, room: String?, taskTemplateId: String?, taskRef: String, PPMGroup: String?, assetType: String?, taskName: String, frequency: String, assetId: String?, assetNumber: String?, scheduledDate: Date, completedDate: Date?, status: String, priority: Int, estimatedDuration: Int?, operativeId: String?, actualDuration: Int?, travelDuration: Int?, comments: String?, alternateAssetCode: String?, level: String?) {
        self.init()
        self.RowId = rowId
        self.CreatedBy = createdBy
        self.CreatedOn = createdOn
        self.LastUpdatedBy = lastUpdatedBy
        self.LastUpdatedOn = lastUpdatedOn
        self.Deleted = deleted
        self.OrganisationId = organisationId
        self.SiteId = siteId
        self.PropertyId = propertyId
        self.LocationId = locationId
        self.LocationGroupName = locationGroupName
        self.LocationName = locationName
        self.Room = room
        self.TaskTemplateId = taskTemplateId
        self.TaskRef = taskRef
        self.PPMGroup = PPMGroup
        self.AssetType = assetType
        self.TaskName = taskName
        self.Frequency = frequency
        self.AssetId = assetId
        self.AssetNumber = assetNumber
        self.ScheduledDate = scheduledDate
        self.CompletedDate = completedDate
        self.Status = status
        self.Priority = priority
        self.EstimatedDuration = estimatedDuration
        self.OperativeId = operativeId
        self.ActualDuration = actualDuration
        self.TravelDuration = travelDuration
        self.Comments = comments
        self.AlternateAssetCode = alternateAssetCode
        self.Level = level
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
        self.SiteId = XMLElement.attributes["SiteId"]!
        self.PropertyId = XMLElement.attributes["PropertyId"]!
        self.LocationId = XMLElement.attributes["LocationId"]!
        self.LocationGroupName = XMLElement.attributes["LocationGroupName"]!
        self.LocationName = XMLElement.attributes["LocationName"]!
        if XMLElement.attributes.keys.contains("Room") {
            if XMLElement.attributes["Room"] != "" {
                self.Room = XMLElement.attributes["Room"]!
            }
        }
        if XMLElement.attributes.keys.contains("TaskTemplateId") {
            if XMLElement.attributes["TaskTemplateId"] != "" {
                self.TaskTemplateId = XMLElement.attributes["TaskTemplateId"]!
            }
        }
        self.TaskRef = XMLElement.attributes["TaskRef"]!
        if XMLElement.attributes.keys.contains("PPMGroup") {
            if XMLElement.attributes["PPMGroup"] != "" {
                self.PPMGroup = XMLElement.attributes["PPMGroup"]!}}
        if XMLElement.attributes.keys.contains("AssetType") {
            if XMLElement.attributes["AssetType"] != "" {
                self.AssetType = XMLElement.attributes["AssetType"]!}}
        self.TaskName = XMLElement.attributes["TaskName"]!
        self.Frequency = XMLElement.attributes["Frequency"]!
        if XMLElement.attributes.keys.contains("AssetId") {
            if XMLElement.attributes["AssetId"] != "" {
                self.AssetId = XMLElement.attributes["AssetId"]!}}
        if XMLElement.attributes.keys.contains("AssetNumber") {
            if XMLElement.attributes["AssetNumber"] != "" {
                self.AssetNumber = XMLElement.attributes["AssetNumber"]!}}
        self.ScheduledDate = Date(dateString: XMLElement.attributes["ScheduledDate"]!)
        if XMLElement.attributes.keys.contains("CompletedDate") {
            if XMLElement.attributes["CompletedDate"] != "" {
                self.CompletedDate = Date(dateString: XMLElement.attributes["CompletedDate"]!)
            }
        }
        self.Status = XMLElement.attributes["Status"]!
        self.Priority = Int(XMLElement.attributes["Priority"]!)!
        if XMLElement.attributes.keys.contains("EstimatedDuration") {
            if XMLElement.attributes["EstimatedDuration"] != "" {
                self.EstimatedDuration = Int(XMLElement.attributes["EstimatedDuration"]!)!
            }
        }
        if XMLElement.attributes.keys.contains("OperativeId") {
            if XMLElement.attributes["OperativeId"] != "" {
                self.OperativeId = XMLElement.attributes["OperativeId"]!
            }
        }
        if XMLElement.attributes.keys.contains("ActualDuration") {
            if XMLElement.attributes["ActualDuration"] != "" {
                self.ActualDuration = Int(XMLElement.attributes["ActualDuration"]!)!
            }
        }
        if XMLElement.attributes.keys.contains("TravelDuration") {
            if XMLElement.attributes["TravelDuration"] != "" {
                self.TravelDuration = Int(XMLElement.attributes["TravelDuration"]!)!
            }
        }
        if XMLElement.attributes.keys.contains("Comments") {
            if XMLElement.attributes["Comments"] != "" {
                self.Comments = XMLElement.attributes["Comments"]!
            }
        }
        if XMLElement.attributes.keys.contains("AlternateAssetCode") {
            if XMLElement.attributes["AlternateAssetCode"] != "" {
                self.AlternateAssetCode = XMLElement.attributes["AlternateAssetCode"]!
            }
        }
        if XMLElement.attributes.keys.contains("Level") {
            if XMLElement.attributes["Level"] != "" {
                self.Level = XMLElement.attributes["Level"]!
            }
        }
    }
}
