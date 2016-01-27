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
    var CreatedOn: NSDate = NSDate()
    var LastUpdatedBy: String? = nil
    var LastUpdatedOn: NSDate? = nil
    var Deleted: NSDate? = nil
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
    init(rowId:String, createdBy: String, createdOn: NSDate, lastUpdatedBy: String?, lastUpdatedOn: NSDate?, deleted: NSDate?, assetType: String, propertyId: String, locationId: String, hydropName: String?, clientName: String?, scanCode: String?, hotType: String?, coldType: String?) {
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
        self.AssetType = XMLElement.attributes["AssetType"]!
        self.PropertyId = XMLElement.attributes["PropertyId"]!
        self.LocationId = XMLElement.attributes["LocationId"]!
        if XMLElement.attributes.keys.contains("HydropName") {
            if XMLElement.attributes["HydropName"] != ""
            {
                self.LastUpdatedBy = XMLElement.attributes["HydropName"]!
            }
        }
        if XMLElement.attributes.keys.contains("ClientName") {
            if XMLElement.attributes["ClientName"] != ""
            {
                self.LastUpdatedBy = XMLElement.attributes["ClientName"]!
            }
        }
        if XMLElement.attributes.keys.contains("ScanCode") {
            if XMLElement.attributes["ScanCode"] != ""
            {
                self.LastUpdatedBy = XMLElement.attributes["ScanCode"]!
            }
        }
        if XMLElement.attributes.keys.contains("HotType") {
            if XMLElement.attributes["HotType"] != ""
            {
                self.LastUpdatedBy = XMLElement.attributes["HotType"]!
            }
        }
        if XMLElement.attributes.keys.contains("ColdType") {
            if XMLElement.attributes["ColdType"] != ""
            {
                self.LastUpdatedBy = XMLElement.attributes["ColdType"]!
            }
        }
    }
}