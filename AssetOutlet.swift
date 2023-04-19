//
//  AssetOutlet.swift
//  COMPASSMOBILE
//
//  Created by Andrew Harper on 17/03/2023.
//  Copyright © 2016 HYRDOP E.C.S. All rights reserved.
//

import AEXML

class AssetOutlet: NSObject {

    // MARK: - Properties
    
    var RowId: String = String()
    var CreatedBy: String = String()
    var CreatedOn: Date = Date()
    var LastUpdatedBy: String? = nil
    var LastUpdatedOn: Date? = nil
    var Deleted: Date? = nil
    var OutletType: String = String()
    var FacilityId: String = String()
    var HydropName: String? = nil
    var ClientName: String? = nil
    var ScanCode: String? = nil
    var Integral: Bool = Bool()
    
    // MARK: - Contructors
    
    convenience
    init(rowId:String, createdBy: String, createdOn: Date, lastUpdatedBy: String?, lastUpdatedOn: Date?, deleted: Date?, outletType: String, facilityId: String, hydropName: String?, clientName: String?, scanCode: String?, integral: Bool) {
        self.init()
        self.RowId = rowId
        self.CreatedBy = createdBy
        self.CreatedOn = createdOn
        self.LastUpdatedBy = lastUpdatedBy
        self.LastUpdatedOn = lastUpdatedOn
        self.Deleted = deleted
        self.OutletType = outletType
        self.FacilityId = facilityId
        self.HydropName = hydropName
        self.ClientName = clientName
        self.ScanCode = scanCode
        self.Integral = integral
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
        self.OutletType = XMLElement.attributes["OutletType"]!
        self.FacilityId = XMLElement.attributes["FacilityId"]!
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
        self.Integral = (XMLElement.attributes["Integral"]! == "true") //should test to make sure boolean
    }
}
