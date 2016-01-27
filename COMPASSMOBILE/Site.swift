//
//  Site.swift
//  COMPASSMOBILE
//
//  Created by Andrew Harper on 26/01/2016.
//  Copyright © 2016 HYDOP E.C.S. All rights reserved.
//

import Foundation

class Site: NSObject {
    
    // MARK: - Properties
    
    var RowId: String = String()
    var CreatedBy: String = String()
    var CreatedOn: NSDate = NSDate()
    var LastUpdatedBy: String? = nil
    var LastUpdatedOn: NSDate? = nil
    var Deleted: NSDate? = nil
    var OrganisationId: String = String()
    var Name: String = String()
    var Type: String? = nil
    
    // MARK: - Contructors
    
    convenience
    init(rowId:String, createdBy: String, createdOn: NSDate, lastUpdatedBy: String?, lastUpdatedOn: NSDate?, deleted: NSDate?, organisationId: String, name: String, type: String?) {
        self.init()
        self.RowId = rowId
        self.CreatedBy = createdBy
        self.CreatedOn = createdOn
        self.LastUpdatedBy = lastUpdatedBy
        self.LastUpdatedOn = lastUpdatedOn
        self.Deleted = deleted
        self.OrganisationId = organisationId
        self.Name = name
        self.Type = type
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
        self.OrganisationId = XMLElement.attributes["OrganisationId"]!
        self.Name = XMLElement.attributes["Name"]!
        if XMLElement.attributes.keys.contains("Type") {
            if XMLElement.attributes["Type"] != ""
            {
                self.LastUpdatedBy = XMLElement.attributes["Type"]!
            }
        }
    }
}