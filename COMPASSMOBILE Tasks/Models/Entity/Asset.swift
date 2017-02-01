//
//  Asset.swift
//  COMPASSMOBILE
//
//  Created by Andrew Harper on 26/01/2016.
//  Copyright © 2016 HYDOP E.C.S. All rights reserved.
//

import UIKit

class Asset: NSObject {

    // MARK: - Properties
    
    var RowId: String = String()
    var CreatedBy: String = String()
    var CreatedOn: Date = Date()
    var LastUpdatedBy: String? = nil
    var LastUpdatedOn: Date? = nil
    var Deleted: Date? = nil
    var AssetType: String = String()
    var PropertyId: String = String()
    var LocationId: String = String()
    var HydropName: String? = nil
    var ClientName: String? = nil
    var ScanCode: String? = nil
    var HotType: String? = nil
    var ColdType: String? = nil
    
    // MARK: - Contructors
    
    convenience
    init(rowId:String, createdBy: String, createdOn: Date, lastUpdatedBy: String?, lastUpdatedOn: Date?, deleted: Date?, assetType: String, propertyId: String, locationId: String, hydropName: String?, clientName: String?, scanCode: String?, hotType: String?, coldType: String?) {
        self.init()
        self.RowId = rowId
        self.CreatedBy = createdBy
        self.CreatedOn = createdOn
        self.LastUpdatedBy = lastUpdatedBy
        self.LastUpdatedOn = lastUpdatedOn
        self.Deleted = deleted
        self.AssetType = assetType
        self.PropertyId = propertyId
        self.LocationId = locationId
        self.HydropName = hydropName
        self.ClientName = clientName
        self.ScanCode = scanCode
        self.HotType = hotType
        self.ColdType = coldType
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
        self.AssetType = XMLElement.attributes["AssetType"]!
        self.PropertyId = XMLElement.attributes["PropertyId"]!
        self.LocationId = XMLElement.attributes["LocationId"]!
        if XMLElement.attributes.keys.contains("HydropName") {
            if XMLElement.attributes["HydropName"] != ""
            {
                self.HydropName = XMLElement.attributes["HydropName"]!
            }
        }
        if XMLElement.attributes.keys.contains("ClientName") {
            if XMLElement.attributes["ClientName"] != ""
            {
                self.ClientName = XMLElement.attributes["ClientName"]!
            }
        }
        if XMLElement.attributes.keys.contains("ScanCode") {
            if XMLElement.attributes["ScanCode"] != ""
            {
                self.ScanCode = XMLElement.attributes["ScanCode"]!
            }
        }
        if XMLElement.attributes.keys.contains("HotType") {
            if XMLElement.attributes["HotType"] != ""
            {
                self.HotType = XMLElement.attributes["HotType"]!
            }
        }
        if XMLElement.attributes.keys.contains("ColdType") {
            if XMLElement.attributes["ColdType"] != ""
            {
                self.ColdType = XMLElement.attributes["ColdType"]!
            }
        }
    }
}
