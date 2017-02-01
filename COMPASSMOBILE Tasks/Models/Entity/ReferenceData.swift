//
//  ReferenceData.swift
//  COMPASSMOBILE
//
//  Created by Andrew Harper on 19/01/2016.
//  Copyright © 2016 HYDOP E.C.S. All rights reserved.
//

import UIKit

class ReferenceData: NSObject{
    
    // MARK: - Properties
    
    var RowId: String = String()
    var CreatedBy: String = String()
    var CreatedOn: Date = Date()
    var LastUpdatedBy: String? = nil
    var LastUpdatedOn: Date? = nil
    var Deleted: Date? = nil
    var StartDate: Date = Date()
    var EndDate: Date? = nil
    var ReferenceType: String = String()
    var Value: String = String()
    var Ordinal: Int = Int()
    var Display: String = String()
    var System: Bool = Bool()
    var ParentType: String? = nil
    var ParentValue: String? = nil
    
    // MARK: - Contructors
    
    convenience
    init(rowId:String, createdBy: String, createdOn: Date, lastUpdatedBy: String?, lastUpdatedOn: Date?, deleted: Date?, startDate: Date, endDate: Date?, referenceType: String, value: String, ordinal: Int, display: String, system: Bool, parentType: String?, parentValue: String?) {
        self.init()
        self.RowId = rowId
        self.CreatedBy = createdBy
        self.CreatedOn = createdOn
        self.LastUpdatedBy = lastUpdatedBy
        self.LastUpdatedOn = lastUpdatedOn
        self.Deleted = deleted
        self.StartDate = startDate
        self.EndDate = endDate
        self.ReferenceType = referenceType
        self.Value = value
        self.Ordinal = ordinal
        self.Display = display
        self.System = system
        self.ParentType = parentType
        self.ParentValue = parentValue
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
        self.CreatedOn = Date(dateString: XMLElement.attributes["StartDate"]!)
        if XMLElement.attributes.keys.contains("EndDate") {
            if XMLElement.attributes["EndDate"] != ""
            {
                self.Deleted = Date(dateString: XMLElement.attributes["EndDate"]!)
            }
        }
        self.ReferenceType = XMLElement.attributes["Type"]!
        self.Value = XMLElement.attributes["Value"]!
        self.Ordinal = Int(XMLElement.attributes["Ordinal"]!)! //should test for numeric here
        self.Display = XMLElement.attributes["Display"]!
        self.System = (XMLElement.attributes["System"]! == "true") //should test to make sure boolean
        if XMLElement.attributes.keys.contains("ParentType") {
            if XMLElement.attributes["ParentType"] != ""
            {
                self.ParentType = XMLElement.attributes["ParentType"]!
            }
        }
        if XMLElement.attributes.keys.contains("ParentValue") {
            if XMLElement.attributes["ParentValue"] != ""
            {
                self.ParentValue = XMLElement.attributes["ParentValue"]!
            }
        }
    }
}
