//
//  LocationGroup.swift
//  COMPASSMOBILE
//
//  Created by Andrew Harper on 26/01/2016.
//  Copyright © 2016 HYDOP E.C.S. All rights reserved.
//

import UIKit

class LocationGroup: NSObject {
    
    // MARK: - Properties
    
    var RowId: String = String()
    var CreatedBy: String = String()
    var CreatedOn: NSDate = NSDate()
    var LastUpdatedBy: String? = nil
    var LastUpdatedOn: NSDate? = nil
    var Deleted: NSDate? = nil
    var PropertyId: String = String()
    var Type: String? = nil
    var Name: String? = nil
    var Description: String? = nil
    var OccupantRiskFactor: String? = nil

    // MARK: - Contructors
    
    convenience
    init(rowId:String, createdBy: String, createdOn: NSDate, lastUpdatedBy: String?, lastUpdatedOn: NSDate?, deleted: NSDate?, propertyId: String, type: String?, name: String, description: String?, occupantRiskFactor: String?) {
        self.init()
        self.RowId = rowId
        self.CreatedBy = createdBy
        self.CreatedOn = createdOn
        self.LastUpdatedBy = lastUpdatedBy
        self.LastUpdatedOn = lastUpdatedOn
        self.Deleted = deleted
        self.PropertyId = propertyId
        self.Type = type
        self.Name = name
        self.Description = description
        self.OccupantRiskFactor = occupantRiskFactor
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
        self.PropertyId = XMLElement.attributes["PropertyId"]!
        if XMLElement.attributes.keys.contains("Type") {
            if XMLElement.attributes["Type"] != ""
            {
                self.Type = XMLElement.attributes["Type"]!
            }
        }
        if XMLElement.attributes.keys.contains("Name") {
            if XMLElement.attributes["Name"] != ""
            {
                self.Name = XMLElement.attributes["Name"]!
            }
        }
        if XMLElement.attributes.keys.contains("Description") {
            if XMLElement.attributes["Description"] != ""
            {
                self.Description = XMLElement.attributes["Description"]!
            }
        }
        if XMLElement.attributes.keys.contains("OccupantRiskFactor") {
            if XMLElement.attributes["OccupantRiskFactor"] != ""
            {
                self.OccupantRiskFactor = XMLElement.attributes["OccupantRiskFactor"]!
            }
        }
    }
}
