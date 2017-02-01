//
//  Location.swift
//  COMPASSMOBILE
//
//  Created by Andrew Harper on 26/01/2016.
//  Copyright © 2016 HYDOP E.C.S. All rights reserved.
//

import UIKit

class Location: NSObject {
    
    // MARK: - Properties
    
    var RowId: String = String()
    var CreatedBy: String = String()
    var CreatedOn: Date = Date()
    var LastUpdatedBy: String? = nil
    var LastUpdatedOn: Date? = nil
    var Deleted: Date? = nil
    var PropertyId: String = String()
    var Name: String = String()
    var Description: String? = nil
    var Level: String? = nil
    var Number: String? = nil
    var SubNumber: String? = nil
    var Use: String? = nil
    var ClientLocationName: String? = nil
    
    // MARK: - Contructors
    
    convenience
    init(rowId:String, createdBy: String, createdOn: Date, lastUpdatedBy: String?, lastUpdatedOn: Date?, deleted: Date?, propertyId: String, name: String, description: String?, level: String?, number: String?, subNumber: String?, use: String?, clientLocationName: String?) {
        self.init()
        self.RowId = rowId
        self.CreatedBy = createdBy
        self.CreatedOn = createdOn
        self.LastUpdatedBy = lastUpdatedBy
        self.LastUpdatedOn = lastUpdatedOn
        self.Deleted = deleted
        self.PropertyId = propertyId
        self.Name = name
        self.Description = description
        self.Level = level
        self.Number = number
        self.SubNumber = subNumber
        self.Use = use
        self.ClientLocationName = clientLocationName
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
        self.Name = XMLElement.attributes["Name"]!
        if XMLElement.attributes.keys.contains("Description") {
            if XMLElement.attributes["Description"] != ""
            {
                self.Description = XMLElement.attributes["Description"]!
            }
        }
        if XMLElement.attributes.keys.contains("Level") {
            if XMLElement.attributes["Level"] != ""
            {
                self.Level = XMLElement.attributes["Level"]!
            }
        }
        if XMLElement.attributes.keys.contains("Number") {
            if XMLElement.attributes["Number"] != ""
            {
                self.Number = XMLElement.attributes["Number"]!
            }
        }
        if XMLElement.attributes.keys.contains("SubNumber") {
            if XMLElement.attributes["SubNumber"] != ""
            {
                self.SubNumber = XMLElement.attributes["SubNumber"]!
            }
        }
        if XMLElement.attributes.keys.contains("Use") {
            if XMLElement.attributes["Use"] != ""
            {
                self.Use = XMLElement.attributes["Use"]!
            }
        }
        if XMLElement.attributes.keys.contains("ClientLocationName") {
            if XMLElement.attributes["ClientLocationName"] != ""
            {
                self.ClientLocationName = XMLElement.attributes["ClientLocationName"]!
            }
        }
    }
}
