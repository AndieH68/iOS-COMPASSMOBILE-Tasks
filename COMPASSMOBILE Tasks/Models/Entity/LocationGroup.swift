//
//  LocationGroup.swift
//  COMPASSMOBILE
//
//  Created by Andrew Harper on 26/01/2016.
//  Copyright © 2016 HYDOP E.C.S. All rights reserved.
//

import AEXML

class LocationGroup: NSObject {
    
    // MARK: - Properties
    
    var RowId: String = String()
    var CreatedBy: String = String()
    var CreatedOn: Date = Date()
    var LastUpdatedBy: String? = nil
    var LastUpdatedOn: Date? = nil
    var Deleted: Date? = nil
    var PropertyId: String = String()
    var LocationGroupType: String? = nil
    var Name: String? = nil
    var Description: String? = nil
    var OccupantRiskFactor: String? = nil

    // MARK: - Contructors
    
    convenience
    init(rowId:String, createdBy: String, createdOn: Date, lastUpdatedBy: String?, lastUpdatedOn: Date?, deleted: Date?, propertyId: String, locationGroupType: String?, name: String, description: String?, occupantRiskFactor: String?) {
        self.init()
        self.RowId = rowId
        self.CreatedBy = createdBy
        self.CreatedOn = createdOn
        self.LastUpdatedBy = lastUpdatedBy
        self.LastUpdatedOn = lastUpdatedOn
        self.Deleted = deleted
        self.PropertyId = propertyId
        self.LocationGroupType = locationGroupType
        self.Name = name
        self.Description = description
        self.OccupantRiskFactor = occupantRiskFactor
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
        self.PropertyId = XMLElement.attributes["PropertyId"]!
        if XMLElement.attributes.keys.contains("Type") {
            if XMLElement.attributes["Type"] != ""
            {
                self.LocationGroupType = XMLElement.attributes["Type"]!
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
