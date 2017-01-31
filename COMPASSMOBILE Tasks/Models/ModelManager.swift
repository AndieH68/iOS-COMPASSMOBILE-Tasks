//
// ModelManager.swift
// COMPASSMOBILE
//
// Created by Andrew Harper on 20/01/2016.
// Copyright © 2016 HYDOP E.C.S. All rights reserved.
//

import UIKit

let sharedModelManager = ModelManager()

class ModelManager: NSObject {
    
    // MARK: - Instance
    
    var database: FMDatabase? = nil
    
    class func getInstance() -> ModelManager
    {
        if(sharedModelManager.database == nil)
        {
            sharedModelManager.database = FMDatabase(path: Utility.getPath("COMPASSDB.sqlite"))
        }
        return sharedModelManager
    }
    
    func executeDirectNoParameters(SQLStatement: String) -> Bool{
        sharedModelManager.database!.open()
        let isExecuted: Bool = sharedModelManager.database!.executeStatements(SQLStatement)
        sharedModelManager.database!.close()
        return isExecuted
    }
    
    func executeDirect(SQLStatement: String, SQLParameterValues: [NSObject]?) -> Bool{
        sharedModelManager.database!.open()
        let isExecuted: Bool = sharedModelManager.database!.executeUpdate(SQLStatement, withArgumentsInArray: SQLParameterValues)
        sharedModelManager.database!.close()
        return isExecuted
    }
    
    func executeSingleValueReader(SQLStatement: String, SQLParameterValues: [NSObject]?) -> NSObject?{
        var returnValue: NSObject = NSObject()
        sharedModelManager.database!.open()
        let resultSet = sharedModelManager.database!.executeQuery(SQLStatement, withArgumentsInArray: SQLParameterValues)
        if (resultSet != nil) {
            while resultSet.next() {
                returnValue = resultSet.objectForColumnIndex(0) as! NSObject
            }
        }
        sharedModelManager.database!.close()
        return returnValue
    }
    
    func executeSingleDateReader(SQLStatement: String, SQLParameterValues: [NSObject]?) -> NSDate?{
        sharedModelManager.database!.open()
        let resultSet = sharedModelManager.database!.executeQuery(SQLStatement, withArgumentsInArray: SQLParameterValues)
        if (resultSet != nil) {
            while resultSet.next() {
                return resultSet.dateForColumnIndex(0)
            }
        }
        sharedModelManager.database!.close()
        return nil
    }
    
    func buildWhereClause(criteria: Dictionary<String, AnyObject>) -> (whereClause: String, whereValues: [AnyObject]) {
        var whereClause: String = String()
        var loopCount: Int32 = 0
        var whereValues: [AnyObject] = [AnyObject]()
        for (itemKey, itemValue) in criteria
        {
            whereClause += (loopCount > 0 ? " AND " : " ")
            
            if (itemValue is String)
            {
                whereClause += (itemKey) + " LIKE ? "
            }
            else
            {
                whereClause += (itemKey) + " = ? "
            }
            
            whereValues.append(itemValue)
            
            loopCount += 1
        }
        return (whereClause, whereValues)
    }
    
    // MARK: - Asset
    
    func addAsset(asset: Asset) -> Bool {
        //build the sql statemnt
        var SQLStatement: String = String()
        var SQLParameterNames: String = String()
        var SQLParameterPlaceholders: String = String()
        var SQLParameterValues: [NSObject] = [NSObject]()
        
        SQLParameterNames = "[RowId], [CreatedBy], [CreatedOn]"
        SQLParameterPlaceholders = "?, ?, ?"
        SQLParameterValues.append(asset.RowId)
        SQLParameterValues.append(asset.CreatedBy)
        SQLParameterValues.append(asset.CreatedOn)
        
        if asset.LastUpdatedBy != nil {
            SQLParameterNames += ", [LastUpdatedBy]"
            SQLParameterPlaceholders += ", ?"
            SQLParameterValues.append(asset.LastUpdatedBy!)
        }
        
        if asset.LastUpdatedOn != nil {
            SQLParameterNames += ", [LastUpdatedOn]"
            SQLParameterPlaceholders += ", ?"
            SQLParameterValues.append(asset.LastUpdatedOn!)
        }
        
        if asset.Deleted != nil {
            SQLParameterNames += ", [Deleted]"
            SQLParameterPlaceholders += ", ?"
            SQLParameterValues.append(asset.Deleted!)
        }
        
        SQLParameterNames += ", [AssetType]"
        SQLParameterPlaceholders += ", ?"
        SQLParameterValues.append(asset.AssetType)
        SQLParameterNames += ", [PropertyId]"
        SQLParameterPlaceholders += ", ?"
        SQLParameterValues.append(asset.PropertyId)
        SQLParameterNames += ", [LocationId]"
        SQLParameterPlaceholders += ", ?"
        SQLParameterValues.append(asset.LocationId)
        if asset.HydropName != nil {
            SQLParameterNames += ", [HydropName]"
            SQLParameterPlaceholders += ", ?"
            SQLParameterValues.append(asset.HydropName!)
        }
        if asset.ClientName != nil {
            SQLParameterNames += ", [ClientName]"
            SQLParameterPlaceholders += ", ?"
            SQLParameterValues.append(asset.ClientName!)
        }
        if asset.ScanCode != nil {
            SQLParameterNames += ", [ScanCode]"
            SQLParameterPlaceholders += ", ?"
            SQLParameterValues.append(asset.ScanCode!)
        }
        if asset.HotType != nil {
            SQLParameterNames += ", [HotType]"
            SQLParameterPlaceholders += ", ?"
            SQLParameterValues.append(asset.HotType!)
        }
        if asset.ColdType != nil {
            SQLParameterNames += ", [ColdType]"
            SQLParameterPlaceholders += ", ?"
            SQLParameterValues.append(asset.ColdType!)
        }
        
        SQLStatement = "INSERT INTO [Asset] (" + SQLParameterNames + ") VALUES (" + SQLParameterPlaceholders + ")"
        
        sharedModelManager.database!.open()
        let isInserted = sharedModelManager.database!.executeUpdate(SQLStatement, withArgumentsInArray: SQLParameterValues)
        sharedModelManager.database!.close()
        return isInserted
    }
    
    func updateAsset(asset: Asset) -> Bool {
        //build the sql statemnt
        var SQLStatement: String = String()
        var SQLParameterNames: String = String()
        var SQLParameterValues: [NSObject] = [NSObject]()
        
        SQLParameterNames = "[CreatedBy]=?, [CreatedOn]=?"
        SQLParameterValues.append(asset.CreatedBy)
        SQLParameterValues.append(asset.CreatedOn)
        
        if asset.LastUpdatedBy != nil {
            SQLParameterNames += ", [LastUpdatedBy]=?"
            SQLParameterValues.append(asset.LastUpdatedBy!)
        }
        
        if asset.LastUpdatedOn != nil {
            SQLParameterNames += ", [LastUpdatedOn]=?"
            SQLParameterValues.append(asset.LastUpdatedOn!)
        }
        
        if asset.Deleted != nil {
            SQLParameterNames += ", [Deleted]=?"
            SQLParameterValues.append(asset.Deleted!)
        }
        
        SQLParameterNames += ", [AssetType]=?"
        SQLParameterValues.append(asset.AssetType)
        SQLParameterNames += ", [PropertyId]=?"
        SQLParameterValues.append(asset.PropertyId)
        SQLParameterNames += ", [LocationId]=?"
        SQLParameterValues.append(asset.LocationId)
        if asset.HydropName != nil {
            SQLParameterNames += ", [HydropName]=?"
            SQLParameterValues.append(asset.HydropName!)
        }
        if asset.ClientName != nil {
            SQLParameterNames += ", [ClientName]=?"
            SQLParameterValues.append(asset.ClientName!)
        }
        if asset.ScanCode != nil {
            SQLParameterNames += ", [ScanCode]=?"
            SQLParameterValues.append(asset.ScanCode!)
        }
        if asset.HotType != nil {
            SQLParameterNames += ", [HotType]=?"
            SQLParameterValues.append(asset.HotType!)
        }
        if asset.ColdType != nil {
            SQLParameterNames += ", [ColdType]=?"
            SQLParameterValues.append(asset.ColdType!)
        }
        
        SQLParameterValues.append(asset.RowId)
        
        SQLStatement = "UPDATE [Asset] SET " + SQLParameterNames + "WHERE [RowId]=?"
        
        sharedModelManager.database!.open()
        let isUpdated = sharedModelManager.database!.executeUpdate(SQLStatement, withArgumentsInArray: SQLParameterValues)
        sharedModelManager.database!.close()
        return isUpdated
    }
    
    func deleteAsset(asset: Asset) -> Bool {
        sharedModelManager.database!.open()
        let isDeleted = sharedModelManager.database!.executeUpdate("DELETE FROM [Asset] WHERE [RowId]=?", withArgumentsInArray: [asset.RowId])
        sharedModelManager.database!.close()
        return isDeleted
    }
    
    func getAsset(assetId: String) -> Asset? {
        sharedModelManager.database!.open()
        var asset: Asset? = nil
        
        let resultSet = sharedModelManager.database!.executeQuery("SELECT [RowId], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [Deleted], [AssetType], [PropertyId], [LocationId], [HydropName], [ClientName], [ScanCode], [HotType], [ColdType] FROM [Asset] WHERE [RowId]=?", withArgumentsInArray: [assetId])
        if (resultSet != nil) {
            while resultSet.next() {
                var resultAsset: Asset = Asset()
                resultAsset = Asset()
                resultAsset.RowId = resultSet.stringForColumn("RowId")
                resultAsset.CreatedBy = resultSet.stringForColumn("CreatedBy")
                resultAsset.CreatedOn = resultSet.dateForColumn("CreatedOn")
                if !resultSet.columnIsNull("LastUpdatedBy")
                {
                    resultAsset.LastUpdatedBy = resultSet.stringForColumn("LastUpdatedBy")
                }
                if !resultSet.columnIsNull("LastUpdatedOn")
                {
                    resultAsset.LastUpdatedOn = resultSet.dateForColumn("LastUpdatedOn")
                }
                if !resultSet.columnIsNull("Deleted")
                {
                    resultAsset.Deleted = resultSet.dateForColumn("Deleted")
                }
                resultAsset.AssetType = resultSet.stringForColumn("AssetType")
                resultAsset.PropertyId = resultSet.stringForColumn("PropertyId")
                resultAsset.LocationId = resultSet.stringForColumn("LocationId")
                if !resultSet.columnIsNull("HydropName") {
                    resultAsset.HydropName = resultSet.stringForColumn("HydropName")
                }
                if !resultSet.columnIsNull("ClientName") {
                    resultAsset.ClientName = resultSet.stringForColumn("ClientName")
                }
                if !resultSet.columnIsNull("ScanCode") {
                    resultAsset.ScanCode = resultSet.stringForColumn("ScanCode")
                }
                if !resultSet.columnIsNull("HotType") {
                    resultAsset.HotType = resultSet.stringForColumn("HotType")
                }
                if !resultSet.columnIsNull("ColdType") {
                    resultAsset.ColdType = resultSet.stringForColumn("ColdType")
                }
                
                asset = resultAsset
            }
        }
        sharedModelManager.database!.close()
        return asset
    }
    
    func getAllAsset() -> [Asset] {
        sharedModelManager.database!.open()
        let resultSet: FMResultSet! = sharedModelManager.database!.executeQuery("SELECT [RowId], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [Deleted], [AssetType], [PropertyId], [LocationId], [HydropName], [ClientName], [ScanCode], [HotType], [ColdType] FROM [Asset]", withArgumentsInArray: nil)
        var assetList: [Asset] = [Asset]()
        if (resultSet != nil) {
            while resultSet.next() {
                let asset : Asset = Asset()
                asset.RowId = resultSet.stringForColumn("RowId")
                asset.CreatedBy = resultSet.stringForColumn("CreatedBy")
                asset.CreatedOn = resultSet.dateForColumn("CreatedOn")
                if !resultSet.columnIsNull("LastUpdatedBy")
                {
                    asset.LastUpdatedBy = resultSet.stringForColumn("LastUpdatedBy")
                }
                if !resultSet.columnIsNull("LastUpdatedOn")
                {
                    asset.LastUpdatedOn = resultSet.dateForColumn("LastUpdatedOn")
                }
                if !resultSet.columnIsNull("Deleted")
                {
                    asset.Deleted = resultSet.dateForColumn("Deleted")
                }
                asset.AssetType = resultSet.stringForColumn("AssetType")
                asset.PropertyId = resultSet.stringForColumn("PropertyId")
                asset.LocationId = resultSet.stringForColumn("LocationId")
                if !resultSet.columnIsNull("HydropName") {
                    asset.HydropName = resultSet.stringForColumn("HydropName")
                }
                if !resultSet.columnIsNull("ClientName") {
                    asset.ClientName = resultSet.stringForColumn("ClientName")
                }
                if !resultSet.columnIsNull("ScanCode") {
                    asset.ScanCode = resultSet.stringForColumn("ScanCode")
                }
                if !resultSet.columnIsNull("HotType") {
                    asset.HotType = resultSet.stringForColumn("HotType")
                }
                if !resultSet.columnIsNull("ColdType") {
                    asset.ColdType = resultSet.stringForColumn("ColdType")
                }
                
                assetList.append(asset)
            }
        }
        sharedModelManager.database!.close()
        return assetList
    }
    
    func findAssetList(criteria: Dictionary<String, AnyObject>) -> [Asset] {
        var list: [Asset] = [Asset]()
        //var count: Int32 = 0
        (list, _) = findAssetList(criteria, pageSize: nil, pageNumber: nil)
        return list
    }

    func findAssetList(criteria: Dictionary<String, AnyObject>, pageSize: Int32?, pageNumber: Int32?) -> (List: [Asset], Count: Int32) {
        
        //return variables
        var count: Int32 = 0
        var assetList: [Asset] = [Asset]()
        
        //build the where clause
        var whereClause: String = String()
        var whereValues: [AnyObject] = [AnyObject]()
        
        (whereClause, whereValues) = buildWhereClause(criteria)
        
        if (whereClause != "")
        {
            whereClause = "WHERE " + whereClause
        }
   
        sharedModelManager.database!.open()
        let countSet: FMResultSet! = sharedModelManager.database!.executeQuery("SELECT COUNT([RowId]) FROM [Asset] " + whereClause, withArgumentsInArray: whereValues)
        if (countSet != nil) {
            while countSet.next() {
                count = countSet.intForColumnIndex(0)
            }
        }
        
        if (count > 0)
        {
            var pageClause: String = String()
            if (pageSize != nil && pageNumber != nil)
            {
                pageClause = " LIMIT " + String(pageSize!) + " OFFSET " + String((pageNumber! - 1) * pageSize!)
            }
            
            let resultSet: FMResultSet! = sharedModelManager.database!.executeQuery("SELECT [RowId], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [Deleted], [AssetType], [PropertyId], [LocationId], [HydropName], [ClientName], [ScanCode], [HotType], [ColdType] FROM [Asset] " + whereClause + pageClause, withArgumentsInArray: whereValues)
            if (resultSet != nil) {
                while resultSet.next() {
                    let asset : Asset = Asset()
                    asset.RowId = resultSet.stringForColumn("RowId")
                    asset.CreatedBy = resultSet.stringForColumn("CreatedBy")
                    asset.CreatedOn = resultSet.dateForColumn("CreatedOn")
                    if !resultSet.columnIsNull("LastUpdatedBy")
                    {
                        asset.LastUpdatedBy = resultSet.stringForColumn("LastUpdatedBy")
                    }
                    if !resultSet.columnIsNull("LastUpdatedOn")
                    {
                        asset.LastUpdatedOn = resultSet.dateForColumn("LastUpdatedOn")
                    }
                    if !resultSet.columnIsNull("Deleted")
                    {
                        asset.Deleted = resultSet.dateForColumn("Deleted")
                    }
                    asset.AssetType = resultSet.stringForColumn("AssetType")
                    asset.PropertyId = resultSet.stringForColumn("PropertyId")
                    asset.LocationId = resultSet.stringForColumn("LocationId")
                    if !resultSet.columnIsNull("HydropName") {
                        asset.HydropName = resultSet.stringForColumn("HydropName")
                    }
                    if !resultSet.columnIsNull("ClientName") {
                        asset.ClientName = resultSet.stringForColumn("ClientName")
                    }
                    if !resultSet.columnIsNull("ScanCode") {
                        asset.ScanCode = resultSet.stringForColumn("ScanCode")
                    }
                    if !resultSet.columnIsNull("HotType") {
                        asset.HotType = resultSet.stringForColumn("HotType")
                    }
                    if !resultSet.columnIsNull("ColdType") {
                        asset.ColdType = resultSet.stringForColumn("ColdType")
                    }
                    
                    assetList.append(asset)
                }
            }
        }
        
        sharedModelManager.database!.close()
        
        return (assetList, count)
    }
    
    // MARK: - Location
    
    func addLocation(location: Location) -> Bool {
        //build the sql statemnt
        var SQLStatement: String = String()
        var SQLParameterNames: String = String()
        var SQLParameterPlaceholders: String = String()
        var SQLParameterValues: [NSObject] = [NSObject]()
        
        SQLParameterNames = "[RowId], [CreatedBy], [CreatedOn]"
        SQLParameterPlaceholders = "?, ?, ?"
        SQLParameterValues.append(location.RowId)
        SQLParameterValues.append(location.CreatedBy)
        SQLParameterValues.append(location.CreatedOn)
        
        if location.LastUpdatedBy != nil {
            SQLParameterNames += ", [LastUpdatedBy]"
            SQLParameterPlaceholders += ", ?"
            SQLParameterValues.append(location.LastUpdatedBy!)
        }
        
        if location.LastUpdatedOn != nil {
            SQLParameterNames += ", [LastUpdatedOn]"
            SQLParameterPlaceholders += ", ?"
            SQLParameterValues.append(location.LastUpdatedOn!)
        }
        
        if location.Deleted != nil {
            SQLParameterNames += ", [Deleted]"
            SQLParameterPlaceholders += ", ?"
            SQLParameterValues.append(location.Deleted!)
        }
        
        SQLParameterNames += ", [PropertyId]"
        SQLParameterPlaceholders += ", ?"
        SQLParameterValues.append(location.PropertyId)
        SQLParameterNames += ", [Name]"
        SQLParameterPlaceholders += ", ?"
        SQLParameterValues.append(location.Name)
        if location.Description != nil {
            SQLParameterNames += ", [Description]"
            SQLParameterPlaceholders += ", ?"
            SQLParameterValues.append(location.Description!)
        }
        if location.Level != nil {
            SQLParameterNames += ", [Level]"
            SQLParameterPlaceholders += ", ?"
            SQLParameterValues.append(location.Level!)
        }
        if location.Number != nil {
            SQLParameterNames += ", [Number]"
            SQLParameterPlaceholders += ", ?"
            SQLParameterValues.append(location.Number!)
        }
        if location.SubNumber != nil {
            SQLParameterNames += ", [SubNumber]"
            SQLParameterPlaceholders += ", ?"
            SQLParameterValues.append(location.SubNumber!)
        }
        if location.Use != nil {
            SQLParameterNames += ", [Use]"
            SQLParameterPlaceholders += ", ?"
            SQLParameterValues.append(location.Use!)
        }
        if location.ClientLocationName != nil {
            SQLParameterNames += ", [ClientLocationName]"
            SQLParameterPlaceholders += ", ?"
            SQLParameterValues.append(location.ClientLocationName!)
        }
        
        
        SQLStatement = "INSERT INTO [Location] (" + SQLParameterNames + ") VALUES (" + SQLParameterPlaceholders + ")"
        
        sharedModelManager.database!.open()
        let isInserted = sharedModelManager.database!.executeUpdate(SQLStatement, withArgumentsInArray: SQLParameterValues)
        sharedModelManager.database!.close()
        return isInserted
    }
    
    func updateLocation(location: Location) -> Bool {
        //build the sql statemnt
        var SQLStatement: String = String()
        var SQLParameterNames: String = String()
        var SQLParameterValues: [NSObject] = [NSObject]()
        
        SQLParameterNames = "[CreatedBy]=?, [CreatedOn]=?"
        SQLParameterValues.append(location.CreatedBy)
        SQLParameterValues.append(location.CreatedOn)
        
        if location.LastUpdatedBy != nil {
            SQLParameterNames += ", [LastUpdatedBy]=?"
            SQLParameterValues.append(location.LastUpdatedBy!)
        }
        
        if location.LastUpdatedOn != nil {
            SQLParameterNames += ", [LastUpdatedOn]=?"
            SQLParameterValues.append(location.LastUpdatedOn!)
        }
        
        if location.Deleted != nil {
            SQLParameterNames += ", [Deleted]=?"
            SQLParameterValues.append(location.Deleted!)
        }
        
        SQLParameterNames += ", [PropertyId]=?"
        SQLParameterValues.append(location.PropertyId)
        SQLParameterNames += ", [Name]=?"
        SQLParameterValues.append(location.Name)
        if location.Description != nil {
            SQLParameterNames += ", [Description]=?"
            SQLParameterValues.append(location.Description!)
        }
        if location.Level != nil {
            SQLParameterNames += ", [Level]=?"
            SQLParameterValues.append(location.Level!)
        }
        if location.Number != nil {
            SQLParameterNames += ", [Number]=?"
            SQLParameterValues.append(location.Number!)
        }
        if location.SubNumber != nil {
            SQLParameterNames += ", [SubNumber]=?"
            SQLParameterValues.append(location.SubNumber!)
        }
        if location.Use != nil {
            SQLParameterNames += ", [Use]=?"
            SQLParameterValues.append(location.Use!)
        }
        if location.ClientLocationName != nil {
            SQLParameterNames += ", [ClientLocationName]=?"
            SQLParameterValues.append(location.ClientLocationName!)
        }
        
        
        SQLParameterValues.append(location.RowId)
        
        SQLStatement = "UPDATE [Location] SET " + SQLParameterNames + "WHERE [RowId]=?"
        
        sharedModelManager.database!.open()
        let isUpdated = sharedModelManager.database!.executeUpdate(SQLStatement, withArgumentsInArray: SQLParameterValues)
        sharedModelManager.database!.close()
        return isUpdated
    }
    
    func deleteLocation(location: Location) -> Bool {
        sharedModelManager.database!.open()
        let isDeleted = sharedModelManager.database!.executeUpdate("DELETE FROM [Location] WHERE [RowId]=?", withArgumentsInArray: [location.RowId])
        sharedModelManager.database!.close()
        return isDeleted
    }
    
    func getLocation(locationId: String) -> Location? {
        sharedModelManager.database!.open()
        var location: Location? = nil
        
        let resultSet = sharedModelManager.database!.executeQuery("SELECT [RowId], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [Deleted], [PropertyId], [Name], [Description], [Level], [Number], [SubNumber], [Use], [ClientLocationName] FROM [Location] WHERE [RowId]=?", withArgumentsInArray: [locationId])
        if (resultSet != nil) {
            while resultSet.next() {
                var resultLocation: Location = Location()
                resultLocation = Location()
                resultLocation.RowId = resultSet.stringForColumn("RowId")
                resultLocation.CreatedBy = resultSet.stringForColumn("CreatedBy")
                resultLocation.CreatedOn = resultSet.dateForColumn("CreatedOn")
                if !resultSet.columnIsNull("LastUpdatedBy")
                {
                    resultLocation.LastUpdatedBy = resultSet.stringForColumn("LastUpdatedBy")
                }
                if !resultSet.columnIsNull("LastUpdatedOn")
                {
                    resultLocation.LastUpdatedOn = resultSet.dateForColumn("LastUpdatedOn")
                }
                if !resultSet.columnIsNull("Deleted")
                {
                    resultLocation.Deleted = resultSet.dateForColumn("Deleted")
                }
                resultLocation.PropertyId = resultSet.stringForColumn("PropertyId")
                resultLocation.Name = resultSet.stringForColumn("Name")
                if !resultSet.columnIsNull("Description") {
                    resultLocation.Description = resultSet.stringForColumn("Description")
                }
                if !resultSet.columnIsNull("Level") {
                    resultLocation.Level = resultSet.stringForColumn("Level")
                }
                if !resultSet.columnIsNull("Number") {
                    resultLocation.Number = resultSet.stringForColumn("Number")
                }
                if !resultSet.columnIsNull("SubNumber") {
                    resultLocation.SubNumber = resultSet.stringForColumn("SubNumber")
                }
                if !resultSet.columnIsNull("Use") {
                    resultLocation.Use = resultSet.stringForColumn("Use")
                }
                if !resultSet.columnIsNull("ClientLocationName") {
                    resultLocation.ClientLocationName = resultSet.stringForColumn("ClientLocationName")
                }
                
                location = resultLocation
            }
        }
        sharedModelManager.database!.close()
        return location
    }
    
    func getAllLocation() -> [Location] {
        sharedModelManager.database!.open()
        let resultSet: FMResultSet! = sharedModelManager.database!.executeQuery("SELECT [RowId], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [Deleted], [PropertyId], [Name], [Description], [Level], [Number], [SubNumber], [Use], [ClientLocationName] FROM [Location]", withArgumentsInArray: nil)
        var locationList : [Location] = [Location]()
        if (resultSet != nil) {
            while resultSet.next() {
                let location : Location = Location()
                location.RowId = resultSet.stringForColumn("RowId")
                location.CreatedBy = resultSet.stringForColumn("CreatedBy")
                location.CreatedOn = resultSet.dateForColumn("CreatedOn")
                if !resultSet.columnIsNull("LastUpdatedBy")
                {
                    location.LastUpdatedBy = resultSet.stringForColumn("LastUpdatedBy")
                }
                if !resultSet.columnIsNull("LastUpdatedOn")
                {
                    location.LastUpdatedOn = resultSet.dateForColumn("LastUpdatedOn")
                }
                if !resultSet.columnIsNull("Deleted")
                {
                    location.Deleted = resultSet.dateForColumn("Deleted")
                }
                location.PropertyId = resultSet.stringForColumn("PropertyId")
                location.Name = resultSet.stringForColumn("Name")
                if !resultSet.columnIsNull("Description") {
                    location.Description = resultSet.stringForColumn("Description")
                }
                if !resultSet.columnIsNull("Level") {
                    location.Level = resultSet.stringForColumn("Level")
                }
                if !resultSet.columnIsNull("Number") {
                    location.Number = resultSet.stringForColumn("Number")
                }
                if !resultSet.columnIsNull("SubNumber") {
                    location.SubNumber = resultSet.stringForColumn("SubNumber")
                }
                if !resultSet.columnIsNull("Use") {
                    location.Use = resultSet.stringForColumn("Use")
                }
                if !resultSet.columnIsNull("ClientLocationName") {
                    location.ClientLocationName = resultSet.stringForColumn("ClientLocationName")
                }
                
                locationList.append(location)
            }
        }
        sharedModelManager.database!.close()
        return locationList
    }
    
    func findLocationList(criteria: Dictionary<String, AnyObject>) -> [Location] {
        var list: [Location] = [Location]()
        //var count: Int32 = 0
        (list, _) = findLocationList(criteria, pageSize: nil, pageNumber: nil)
        return list
    }

    func findLocationList(criteria: Dictionary<String, AnyObject>, pageSize: Int32?, pageNumber: Int32?) -> (List: [Location], Count: Int32) {
        //return variables
        var count: Int32 = 0
        var locationList: [Location] = [Location]()
        
        //build the order clause
        let orderByClause: String = " ORDER BY [Name]"
        
        //build the where clause
        var whereClause: String = String()
        var whereValues: [AnyObject] = [AnyObject]()
        
        (whereClause, whereValues) = buildWhereClause(criteria)
        
        if (whereClause != "")
        {
            whereClause = "WHERE " + whereClause
        }

        sharedModelManager.database!.open()
        let countSet: FMResultSet! = sharedModelManager.database!.executeQuery("SELECT COUNT([RowId]) FROM [Location] " + whereClause + orderByClause, withArgumentsInArray: whereValues)
        if (countSet != nil) {
            while countSet.next() {
                count = countSet.intForColumnIndex(0)
            }
        }
        
        if (count > 0)
        {
            var pageClause: String = String()
            if (pageSize != nil && pageNumber != nil)
            {
                pageClause = " LIMIT " + String(pageSize!) + " OFFSET " + String((pageNumber! - 1) * pageSize!)
            }
            
            let resultSet: FMResultSet! = sharedModelManager.database!.executeQuery("SELECT [RowId], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [Deleted], [PropertyId], [Name], [Description], [Level], [Number], [SubNumber], [Use], [ClientLocationName] FROM [Location] " + whereClause + orderByClause + pageClause, withArgumentsInArray: whereValues)
            
            if (resultSet != nil) {
                while resultSet.next() {
                    let location : Location = Location()
                    location.RowId = resultSet.stringForColumn("RowId")
                    location.CreatedBy = resultSet.stringForColumn("CreatedBy")
                    location.CreatedOn = resultSet.dateForColumn("CreatedOn")
                    if !resultSet.columnIsNull("LastUpdatedBy") {
                        location.LastUpdatedBy = resultSet.stringForColumn("LastUpdatedBy")
                    }
                    if !resultSet.columnIsNull("LastUpdatedOn")
                    {
                        location.LastUpdatedOn = resultSet.dateForColumn("LastUpdatedOn")
                    }
                    if !resultSet.columnIsNull("Deleted")
                    {
                        location.Deleted = resultSet.dateForColumn("Deleted")
                    }
                    location.PropertyId = resultSet.stringForColumn("PropertyId")
                    location.Name = resultSet.stringForColumn("Name")
                    if !resultSet.columnIsNull("Description") {
                        location.Description = resultSet.stringForColumn("Description")
                    }
                    if !resultSet.columnIsNull("Level") {
                        location.Level = resultSet.stringForColumn("Level")
                    }
                    if !resultSet.columnIsNull("Number") {
                        location.Number = resultSet.stringForColumn("Number")
                    }
                    if !resultSet.columnIsNull("SubNumber") {
                        location.SubNumber = resultSet.stringForColumn("SubNumber")
                    }
                    if !resultSet.columnIsNull("Use") {
                        location.Use = resultSet.stringForColumn("Use")
                    }
                    if !resultSet.columnIsNull("ClientLocationName") {
                        location.ClientLocationName = resultSet.stringForColumn("ClientLocationName")
                    }
                    
                    locationList.append(location)
                }
            }
        }
        
        sharedModelManager.database!.close()
        return (locationList, count)
    }

    func findLocationListByLocationGroup(LocationGroupId: String, criteria: Dictionary<String, AnyObject>, pageSize: Int32?, pageNumber: Int32?) -> (List: [Location], Count: Int32) {
        //return variables
        var count: Int32 = 0
        var locationList: [Location] = [Location]()
        
        //build the order clause
        let orderByClause: String = " ORDER BY [Name]"
        
        //build the where clause
        var whereClause: String = String()
        var whereValues: [AnyObject] = [AnyObject]()
        
        (whereClause, whereValues) = buildWhereClause(criteria)
        whereClause += (whereClause != "" ? " AND " : "") + " [LocationGroupMembership].[LocationGroupId] = ? "
        whereValues.append(LocationGroupId)
        
        if (whereClause != "")
        {
            whereClause = "WHERE " + whereClause
        }
        
        sharedModelManager.database!.open()
        let countSet: FMResultSet! = sharedModelManager.database!.executeQuery("SELECT COUNT([Location].[RowId]) FROM [Location] INNER JOIN [LocationGroupMembership] ON [Location].[RowId] = [LocationGroupMembership].[LocationId] " + whereClause + orderByClause, withArgumentsInArray: whereValues)
        if (countSet != nil) {
            while countSet.next() {
                count = countSet.intForColumnIndex(0)
            }
        }
        
        if (count > 0)
        {
            var pageClause: String = String()
            if (pageSize != nil && pageNumber != nil)
            {
                pageClause = " LIMIT " + String(pageSize!) + " OFFSET " + String((pageNumber! - 1) * pageSize!)
            }
            
            let resultSet: FMResultSet! = sharedModelManager.database!.executeQuery("SELECT [Location].[RowId], [Location].[CreatedBy], [Location].[CreatedOn], [Location].[LastUpdatedBy], [Location].[LastUpdatedOn], [Location].[Deleted], [Location].[PropertyId], [Location].[Name], [Location].[Description], [Location].[Level], [Location].[Number], [Location].[SubNumber], [Location].[Use], [Location].[ClientLocationName] FROM [Location] INNER JOIN [LocationGroupMembership] ON [Location].[RowId] = [LocationGroupMembership].[LocationId] " + whereClause + orderByClause + pageClause, withArgumentsInArray: whereValues)
            
            if (resultSet != nil) {
                while resultSet.next() {
                    let location : Location = Location()
                    location.RowId = resultSet.stringForColumn("RowId")
                    location.CreatedBy = resultSet.stringForColumn("CreatedBy")
                    location.CreatedOn = resultSet.dateForColumn("CreatedOn")
                    if !resultSet.columnIsNull("LastUpdatedBy") {
                        location.LastUpdatedBy = resultSet.stringForColumn("LastUpdatedBy")
                    }
                    if !resultSet.columnIsNull("LastUpdatedOn")
                    {
                        location.LastUpdatedOn = resultSet.dateForColumn("LastUpdatedOn")
                    }
                    if !resultSet.columnIsNull("Deleted")
                    {
                        location.Deleted = resultSet.dateForColumn("Deleted")
                    }
                    location.PropertyId = resultSet.stringForColumn("PropertyId")
                    location.Name = resultSet.stringForColumn("Name")
                    if !resultSet.columnIsNull("Description") {
                        location.Description = resultSet.stringForColumn("Description")
                    }
                    if !resultSet.columnIsNull("Level") {
                        location.Level = resultSet.stringForColumn("Level")
                    }
                    if !resultSet.columnIsNull("Number") {
                        location.Number = resultSet.stringForColumn("Number")
                    }
                    if !resultSet.columnIsNull("SubNumber") {
                        location.SubNumber = resultSet.stringForColumn("SubNumber")
                    }
                    if !resultSet.columnIsNull("Use") {
                        location.Use = resultSet.stringForColumn("Use")
                    }
                    if !resultSet.columnIsNull("ClientLocationName") {
                        location.ClientLocationName = resultSet.stringForColumn("ClientLocationName")
                    }
                    
                    locationList.append(location)
                }
            }
        }
        
        sharedModelManager.database!.close()
        return (locationList, count)
    }

    // MARK: - LocationGroup
    
    func addLocationGroup(locationGroup: LocationGroup) -> Bool {
        //build the sql statemnt
        var SQLStatement: String = String()
        var SQLParameterNames: String = String()
        var SQLParameterPlaceholders: String = String()
        var SQLParameterValues: [NSObject] = [NSObject]()
        
        SQLParameterNames = "[RowId], [CreatedBy], [CreatedOn]"
        SQLParameterPlaceholders = "?, ?, ?"
        SQLParameterValues.append(locationGroup.RowId)
        SQLParameterValues.append(locationGroup.CreatedBy)
        SQLParameterValues.append(locationGroup.CreatedOn)
        
        if locationGroup.LastUpdatedBy != nil {
            SQLParameterNames += ", [LastUpdatedBy]"
            SQLParameterPlaceholders += ", ?"
            SQLParameterValues.append(locationGroup.LastUpdatedBy!)
        }
        
        if locationGroup.LastUpdatedOn != nil {
            SQLParameterNames += ", [LastUpdatedOn]"
            SQLParameterPlaceholders += ", ?"
            SQLParameterValues.append(locationGroup.LastUpdatedOn!)
        }
        
        if locationGroup.Deleted != nil {
            SQLParameterNames += ", [Deleted]"
            SQLParameterPlaceholders += ", ?"
            SQLParameterValues.append(locationGroup.Deleted!)
        }
        SQLParameterNames += ", [PropertyId]"
        SQLParameterPlaceholders += ", ?"
        SQLParameterValues.append(locationGroup.PropertyId)
        if locationGroup.Type != nil {
            SQLParameterNames += ", [Type]"
            SQLParameterPlaceholders += ", ?"
            SQLParameterValues.append(locationGroup.Type!)
        }
        if locationGroup.Name != nil {
            SQLParameterNames += ", [Name]"
            SQLParameterPlaceholders += ", ?"
            SQLParameterValues.append(locationGroup.Name!)
        }
        if locationGroup.Description != nil {
            SQLParameterNames += ", [Description]"
            SQLParameterPlaceholders += ", ?"
            SQLParameterValues.append(locationGroup.Description!)
        }
        if locationGroup.OccupantRiskFactor != nil {
            SQLParameterNames += ", [OccupantRiskFactor]"
            SQLParameterPlaceholders += ", ?"
            SQLParameterValues.append(locationGroup.OccupantRiskFactor!)
        }
        
        SQLStatement = "INSERT INTO [LocationGroup] (" + SQLParameterNames + ") VALUES (" + SQLParameterPlaceholders + ")"
        
        sharedModelManager.database!.open()
        let isInserted = sharedModelManager.database!.executeUpdate(SQLStatement, withArgumentsInArray: SQLParameterValues)
        sharedModelManager.database!.close()
        return isInserted
    }
    
    func updateLocationGroup(locationGroup: LocationGroup) -> Bool {
        //build the sql statemnt
        var SQLStatement: String = String()
        var SQLParameterNames: String = String()
        var SQLParameterValues: [NSObject] = [NSObject]()
        
        SQLParameterNames = "[CreatedBy]=?, [CreatedOn]=?"
        SQLParameterValues.append(locationGroup.CreatedBy)
        SQLParameterValues.append(locationGroup.CreatedOn)
        
        if locationGroup.LastUpdatedBy != nil {
            SQLParameterNames += ", [LastUpdatedBy]=?"
            SQLParameterValues.append(locationGroup.LastUpdatedBy!)
        }
        
        if locationGroup.LastUpdatedOn != nil {
            SQLParameterNames += ", [LastUpdatedOn]=?"
            SQLParameterValues.append(locationGroup.LastUpdatedOn!)
        }
        
        if locationGroup.Deleted != nil {
            SQLParameterNames += ", [Deleted]=?"
            SQLParameterValues.append(locationGroup.Deleted!)
        }
        SQLParameterNames += ", [PropertyId]=?"
        SQLParameterValues.append(locationGroup.PropertyId)
        if locationGroup.Type != nil {
            SQLParameterNames += ", [Type]=?"
            SQLParameterValues.append(locationGroup.Type!)
        }
        if locationGroup.Name != nil {
            SQLParameterNames += ", [Name]=?"
            SQLParameterValues.append(locationGroup.Name!)
        }
        if locationGroup.Description != nil {
            SQLParameterNames += ", [Description]=?"
            SQLParameterValues.append(locationGroup.Description!)
        }
        if locationGroup.OccupantRiskFactor != nil {
            SQLParameterNames += ", [OccupantRiskFactor]=?"
            SQLParameterValues.append(locationGroup.OccupantRiskFactor!)
        }
        
        
        SQLParameterValues.append(locationGroup.RowId)
        
        SQLStatement = "UPDATE [LocationGroup] SET " + SQLParameterNames + "WHERE [RowId]=?"
        
        sharedModelManager.database!.open()
        let isUpdated = sharedModelManager.database!.executeUpdate(SQLStatement, withArgumentsInArray: SQLParameterValues)
        sharedModelManager.database!.close()
        return isUpdated
    }
    
    func deleteLocationGroup(locationGroup: LocationGroup) -> Bool {
        sharedModelManager.database!.open()
        let isDeleted = sharedModelManager.database!.executeUpdate("DELETE FROM [LocationGroup] WHERE [RowId]=?", withArgumentsInArray: [locationGroup.RowId])
        sharedModelManager.database!.close()
        return isDeleted
    }
    
    func getLocationGroup(locationGroupId: String) -> LocationGroup? {
        sharedModelManager.database!.open()
        var locationGroup: LocationGroup? = nil
        
        let resultSet = sharedModelManager.database!.executeQuery("SELECT [RowId], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [Deleted], [PropertyId], [Type], [Name], [Description], [OccupantRiskFactor] FROM [LocationGroup] WHERE [RowId]=?", withArgumentsInArray: [locationGroupId])
        if (resultSet != nil) {
            while resultSet.next() {
                var resultLocationGroup: LocationGroup = LocationGroup()
                resultLocationGroup = LocationGroup()
                resultLocationGroup.RowId = resultSet.stringForColumn("RowId")
                resultLocationGroup.CreatedBy = resultSet.stringForColumn("CreatedBy")
                resultLocationGroup.CreatedOn = resultSet.dateForColumn("CreatedOn")
                if !resultSet.columnIsNull("LastUpdatedBy")
                {
                    resultLocationGroup.LastUpdatedBy = resultSet.stringForColumn("LastUpdatedBy")
                }
                if !resultSet.columnIsNull("LastUpdatedOn")
                {
                    resultLocationGroup.LastUpdatedOn = resultSet.dateForColumn("LastUpdatedOn")
                }
                if !resultSet.columnIsNull("Deleted")
                {
                    resultLocationGroup.Deleted = resultSet.dateForColumn("Deleted")
                }
                resultLocationGroup.PropertyId = resultSet.stringForColumn("PropertyId")
                if !resultSet.columnIsNull("Type") {
                    resultLocationGroup.Type = resultSet.stringForColumn("Type")
                }
                if !resultSet.columnIsNull("Name") {
                    resultLocationGroup.Name = resultSet.stringForColumn("Name")
                }
                if !resultSet.columnIsNull("Description") {
                    resultLocationGroup.Description = resultSet.stringForColumn("Description")
                }
                if !resultSet.columnIsNull("OccupantRiskFactor") {
                    resultLocationGroup.OccupantRiskFactor = resultSet.stringForColumn("OccupantRiskFactor")
                }
                
                
                locationGroup = resultLocationGroup
            }
        }
        sharedModelManager.database!.close()
        return locationGroup
    }
    
    func getAllLocationGroup() -> [LocationGroup] {
        sharedModelManager.database!.open()
        let resultSet: FMResultSet! = sharedModelManager.database!.executeQuery("SELECT [RowId], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [Deleted], [PropertyId], [Type], [Name], [Description], [OccupantRiskFactor] FROM [LocationGroup]", withArgumentsInArray: nil)
        var locationGroupList : [LocationGroup] = [LocationGroup]()
        if (resultSet != nil) {
            while resultSet.next() {
                let locationGroup : LocationGroup = LocationGroup()
                locationGroup.RowId = resultSet.stringForColumn("RowId")
                locationGroup.CreatedBy = resultSet.stringForColumn("CreatedBy")
                locationGroup.CreatedOn = resultSet.dateForColumn("CreatedOn")
                if !resultSet.columnIsNull("LastUpdatedBy")
                {
                    locationGroup.LastUpdatedBy = resultSet.stringForColumn("LastUpdatedBy")
                }
                if !resultSet.columnIsNull("LastUpdatedOn")
                {
                    locationGroup.LastUpdatedOn = resultSet.dateForColumn("LastUpdatedOn")
                }
                if !resultSet.columnIsNull("Deleted")
                {
                    locationGroup.Deleted = resultSet.dateForColumn("Deleted")
                }
                locationGroup.PropertyId = resultSet.stringForColumn("PropertyId")
                if !resultSet.columnIsNull("Type") {
                    locationGroup.Type = resultSet.stringForColumn("Type")
                }
                if !resultSet.columnIsNull("Name") {
                    locationGroup.Name = resultSet.stringForColumn("Name")
                }
                if !resultSet.columnIsNull("Description") {
                    locationGroup.Description = resultSet.stringForColumn("Description")
                }
                if !resultSet.columnIsNull("OccupantRiskFactor") {
                    locationGroup.OccupantRiskFactor = resultSet.stringForColumn("OccupantRiskFactor")
                }
                
                
                locationGroupList.append(locationGroup)
            }
        }
        sharedModelManager.database!.close()
        return locationGroupList
    }
    
    func findLocationGroupList(criteria: Dictionary<String, AnyObject>) -> [LocationGroup] {
        var list: [LocationGroup] = [LocationGroup]()
        //var count: Int32 = 0
        (list, _) = findLocationGroupList(criteria, pageSize: nil, pageNumber: nil)
        return list
    }

    func findLocationGroupList(criteria: Dictionary<String, AnyObject>, pageSize: Int32?, pageNumber: Int32?) -> (List: [LocationGroup], Count: Int32) {
        //return variables
        var count: Int32 = 0
        var locationGroupList: [LocationGroup] = [LocationGroup]()
        
        //build the order clause
        let orderByClause: String = " ORDER BY [Name]"
        
        //build the where clause
        var whereClause: String = String()
        var whereValues: [AnyObject] = [AnyObject]()
        
        (whereClause, whereValues) = buildWhereClause(criteria)
        
        if (whereClause != "")
        {
            whereClause = "WHERE " + whereClause
        }

        sharedModelManager.database!.open()
        let countSet: FMResultSet! = sharedModelManager.database!.executeQuery("SELECT COUNT([RowId]) FROM [LocationGroup] " + whereClause + orderByClause, withArgumentsInArray: whereValues)
        if (countSet != nil) {
            while countSet.next() {
                count = countSet.intForColumnIndex(0)
            }
        }
        
        if (count > 0)
        {
            var pageClause: String = String()
            if (pageSize != nil && pageNumber != nil)
            {
                pageClause = " LIMIT " + String(pageSize!) + " OFFSET " + String((pageNumber! - 1) * pageSize!)
            }
            
            let resultSet: FMResultSet! = sharedModelManager.database!.executeQuery("SELECT [RowId], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [Deleted], [PropertyId], [Type], [Name], [Description], [OccupantRiskFactor] FROM [LocationGroup] " + whereClause + orderByClause + pageClause, withArgumentsInArray: whereValues)
            if (resultSet != nil) {
                while resultSet.next() {
                    let locationGroup : LocationGroup = LocationGroup()
                    locationGroup.RowId = resultSet.stringForColumn("RowId")
                    locationGroup.CreatedBy = resultSet.stringForColumn("CreatedBy")
                    locationGroup.CreatedOn = resultSet.dateForColumn("CreatedOn")
                    if !resultSet.columnIsNull("LastUpdatedBy")
                    {
                        locationGroup.LastUpdatedBy = resultSet.stringForColumn("LastUpdatedBy")
                    }
                    if !resultSet.columnIsNull("LastUpdatedOn")
                    {
                        locationGroup.LastUpdatedOn = resultSet.dateForColumn("LastUpdatedOn")
                    }
                    if !resultSet.columnIsNull("Deleted")
                    {
                        locationGroup.Deleted = resultSet.dateForColumn("Deleted")
                    }
                    locationGroup.PropertyId = resultSet.stringForColumn("PropertyId")
                    if !resultSet.columnIsNull("Type") {
                        locationGroup.Type = resultSet.stringForColumn("Type")
                    }
                    if !resultSet.columnIsNull("Name") {
                        locationGroup.Name = resultSet.stringForColumn("Name")
                    }
                    if !resultSet.columnIsNull("Description") {
                        locationGroup.Description = resultSet.stringForColumn("Description")
                    }
                    if !resultSet.columnIsNull("OccupantRiskFactor") {
                        locationGroup.OccupantRiskFactor = resultSet.stringForColumn("OccupantRiskFactor")
                    }
                    
                    
                    locationGroupList.append(locationGroup)
                }
            }
        }
        
        sharedModelManager.database!.close()
        return (locationGroupList, count)
    }
    
    // MARK: - LocationGroupMembership
    
    func addLocationGroupMembership(locationGroupMembership: LocationGroupMembership) -> Bool {
        //build the sql statemnt
        var SQLStatement: String = String()
        var SQLParameterNames: String = String()
        var SQLParameterPlaceholders: String = String()
        var SQLParameterValues: [NSObject] = [NSObject]()
        
        SQLParameterNames = "[RowId], [CreatedBy], [CreatedOn]"
        SQLParameterPlaceholders = "?, ?, ?"
        SQLParameterValues.append(locationGroupMembership.RowId)
        SQLParameterValues.append(locationGroupMembership.CreatedBy)
        SQLParameterValues.append(locationGroupMembership.CreatedOn)
        
        if locationGroupMembership.LastUpdatedBy != nil {
            SQLParameterNames += ", [LastUpdatedBy]"
            SQLParameterPlaceholders += ", ?"
            SQLParameterValues.append(locationGroupMembership.LastUpdatedBy!)
        }
        
        if locationGroupMembership.LastUpdatedOn != nil {
            SQLParameterNames += ", [LastUpdatedOn]"
            SQLParameterPlaceholders += ", ?"
            SQLParameterValues.append(locationGroupMembership.LastUpdatedOn!)
        }
        
        if locationGroupMembership.Deleted != nil {
            SQLParameterNames += ", [Deleted]"
            SQLParameterPlaceholders += ", ?"
            SQLParameterValues.append(locationGroupMembership.Deleted!)
        }
        SQLParameterNames += ", [LocationGroupId]"
        SQLParameterPlaceholders += ", ?"
        SQLParameterValues.append(locationGroupMembership.LocationGroupId)
        SQLParameterNames += ", [LocationId]"
        SQLParameterPlaceholders += ", ?"
        SQLParameterValues.append(locationGroupMembership.LocationId)
        
        SQLStatement = "INSERT INTO [LocationGroupMembership] (" + SQLParameterNames + ") VALUES (" + SQLParameterPlaceholders + ")"
        
        sharedModelManager.database!.open()
        let isInserted = sharedModelManager.database!.executeUpdate(SQLStatement, withArgumentsInArray: SQLParameterValues)
        sharedModelManager.database!.close()
        return isInserted
    }
    
    func updateLocationGroupMembership(locationGroupMembership: LocationGroupMembership) -> Bool {
        //build the sql statemnt
        var SQLStatement: String = String()
        var SQLParameterNames: String = String()
        var SQLParameterValues: [NSObject] = [NSObject]()
        
        SQLParameterNames = "[CreatedBy]=?, [CreatedOn]=?"
        SQLParameterValues.append(locationGroupMembership.CreatedBy)
        SQLParameterValues.append(locationGroupMembership.CreatedOn)
        
        if locationGroupMembership.LastUpdatedBy != nil {
            SQLParameterNames += ", [LastUpdatedBy]=?"
            SQLParameterValues.append(locationGroupMembership.LastUpdatedBy!)
        }
        
        if locationGroupMembership.LastUpdatedOn != nil {
            SQLParameterNames += ", [LastUpdatedOn]=?"
            SQLParameterValues.append(locationGroupMembership.LastUpdatedOn!)
        }
        
        if locationGroupMembership.Deleted != nil {
            SQLParameterNames += ", [Deleted]=?"
            SQLParameterValues.append(locationGroupMembership.Deleted!)
        }
        SQLParameterNames += ", [LocationGroupId]=?"
        SQLParameterValues.append(locationGroupMembership.LocationGroupId)
        SQLParameterNames += ", [LocationId]=?"
        SQLParameterValues.append(locationGroupMembership.LocationId)
        
        SQLParameterValues.append(locationGroupMembership.RowId)
        
        SQLStatement = "UPDATE [LocationGroupMembership] SET " + SQLParameterNames + "WHERE [RowId]=?"
        
        sharedModelManager.database!.open()
        let isUpdated = sharedModelManager.database!.executeUpdate(SQLStatement, withArgumentsInArray: SQLParameterValues)
        sharedModelManager.database!.close()
        return isUpdated
    }
    
    func deleteLocationGroupMembership(locationGroupMembership: LocationGroupMembership) -> Bool {
        sharedModelManager.database!.open()
        let isDeleted = sharedModelManager.database!.executeUpdate("DELETE FROM [LocationGroupMembership] WHERE [RowId]=?", withArgumentsInArray: [locationGroupMembership.RowId])
        sharedModelManager.database!.close()
        return isDeleted
    }
    
    func getLocationGroupMembership(locationGroupMembershipId: String) -> LocationGroupMembership? {
        sharedModelManager.database!.open()
        var locationGroupMembership: LocationGroupMembership? = nil
        
        let resultSet = sharedModelManager.database!.executeQuery("SELECT [RowId], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [Deleted], [LocationGroupId], [LocationId] FROM [LocationGroupMembership] WHERE [RowId]=?", withArgumentsInArray: [locationGroupMembershipId])
        if (resultSet != nil) {
            while resultSet.next() {
                var resultLocationGroupMembership: LocationGroupMembership = LocationGroupMembership()
                resultLocationGroupMembership = LocationGroupMembership()
                resultLocationGroupMembership.RowId = resultSet.stringForColumn("RowId")
                resultLocationGroupMembership.CreatedBy = resultSet.stringForColumn("CreatedBy")
                resultLocationGroupMembership.CreatedOn = resultSet.dateForColumn("CreatedOn")
                if !resultSet.columnIsNull("LastUpdatedBy")
                {
                    resultLocationGroupMembership.LastUpdatedBy = resultSet.stringForColumn("LastUpdatedBy")
                }
                if !resultSet.columnIsNull("LastUpdatedOn")
                {
                    resultLocationGroupMembership.LastUpdatedOn = resultSet.dateForColumn("LastUpdatedOn")
                }
                if !resultSet.columnIsNull("Deleted")
                {
                    resultLocationGroupMembership.Deleted = resultSet.dateForColumn("Deleted")
                }
                resultLocationGroupMembership.LocationGroupId = resultSet.stringForColumn("LocationGroupId")
                resultLocationGroupMembership.LocationId = resultSet.stringForColumn("LocationId")
                
                locationGroupMembership = resultLocationGroupMembership
            }
        }
        sharedModelManager.database!.close()
        return locationGroupMembership
    }
    
    func getAllLocationGroupMembership() -> [LocationGroupMembership] {
        sharedModelManager.database!.open()
        let resultSet: FMResultSet! = sharedModelManager.database!.executeQuery("SELECT [RowId], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [Deleted], [LocationGroupId], [LocationId] FROM [LocationGroupMembership]", withArgumentsInArray: nil)
        var locationGroupMembershipList : [LocationGroupMembership] = [LocationGroupMembership]()
        if (resultSet != nil) {
            while resultSet.next() {
                let locationGroupMembership : LocationGroupMembership = LocationGroupMembership()
                locationGroupMembership.RowId = resultSet.stringForColumn("RowId")
                locationGroupMembership.CreatedBy = resultSet.stringForColumn("CreatedBy")
                locationGroupMembership.CreatedOn = resultSet.dateForColumn("CreatedOn")
                if !resultSet.columnIsNull("LastUpdatedBy")
                {
                    locationGroupMembership.LastUpdatedBy = resultSet.stringForColumn("LastUpdatedBy")
                }
                if !resultSet.columnIsNull("LastUpdatedOn")
                {
                    locationGroupMembership.LastUpdatedOn = resultSet.dateForColumn("LastUpdatedOn")
                }
                if !resultSet.columnIsNull("Deleted")
                {
                    locationGroupMembership.Deleted = resultSet.dateForColumn("Deleted")
                }
                locationGroupMembership.LocationGroupId = resultSet.stringForColumn("LocationGroupId")
                locationGroupMembership.LocationId = resultSet.stringForColumn("LocationId")
                
                locationGroupMembershipList.append(locationGroupMembership)
            }
        }
        sharedModelManager.database!.close()
        return locationGroupMembershipList
    }
    
    func findLocationGroupMembershipList(criteria: Dictionary<String, AnyObject>) -> [LocationGroupMembership] {
        var list: [LocationGroupMembership] = [LocationGroupMembership]()
        //var count: Int32 = 0
        (list, _) = findLocationGroupMembershipList(criteria, pageSize: nil, pageNumber: nil)
        return list
    }

    func findLocationGroupMembershipList(criteria: Dictionary<String, AnyObject>, pageSize: Int32?, pageNumber: Int32?) -> (List: [LocationGroupMembership], Count: Int32) {
        //return variables
        var count: Int32 = 0
        var locationGroupMembershipList: [LocationGroupMembership] = [LocationGroupMembership]()
        
        //build the where clause
        var whereClause: String = String()
        var whereValues: [AnyObject] = [AnyObject]()
        
        (whereClause, whereValues) = buildWhereClause(criteria)
        
        if (whereClause != "")
        {
            whereClause = "WHERE " + whereClause
        }

        sharedModelManager.database!.open()
        let countSet: FMResultSet! = sharedModelManager.database!.executeQuery("SELECT COUNT([RowId]) FROM [LocationGroupMembership] " + whereClause, withArgumentsInArray: whereValues)
        if (countSet != nil) {
            while countSet.next() {
                count = countSet.intForColumnIndex(0)
            }
        }
        
        if (count > 0)
        {
            var pageClause: String = String()
            if (pageSize != nil && pageNumber != nil)
            {
                pageClause = " LIMIT " + String(pageSize!) + " OFFSET " + String((pageNumber! - 1) * pageSize!)
            }
            
            let resultSet: FMResultSet! = sharedModelManager.database!.executeQuery("SELECT [RowId], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [Deleted], [LocationGroupId], [LocationId] FROM [LocationGroupMembership] " + whereClause + pageClause, withArgumentsInArray: whereValues)
            if (resultSet != nil) {
                while resultSet.next() {
                    let locationGroupMembership : LocationGroupMembership = LocationGroupMembership()
                    locationGroupMembership.RowId = resultSet.stringForColumn("RowId")
                    locationGroupMembership.CreatedBy = resultSet.stringForColumn("CreatedBy")
                    locationGroupMembership.CreatedOn = resultSet.dateForColumn("CreatedOn")
                    if !resultSet.columnIsNull("LastUpdatedBy")
                    {
                        locationGroupMembership.LastUpdatedBy = resultSet.stringForColumn("LastUpdatedBy")
                    }
                    if !resultSet.columnIsNull("LastUpdatedOn")
                    {
                        locationGroupMembership.LastUpdatedOn = resultSet.dateForColumn("LastUpdatedOn")
                    }
                    if !resultSet.columnIsNull("Deleted")
                    {
                        locationGroupMembership.Deleted = resultSet.dateForColumn("Deleted")
                    }
                    locationGroupMembership.LocationGroupId = resultSet.stringForColumn("LocationGroupId")
                    locationGroupMembership.LocationId = resultSet.stringForColumn("LocationId")
                    
                    locationGroupMembershipList.append(locationGroupMembership)
                }
            }
        }
        sharedModelManager.database!.close()
        return (locationGroupMembershipList, count)
    }
    
    // MARK: - Operative
    
    func addOperative(operative: Operative) -> Bool {
        //build the sql statemnt
        var SQLStatement: String = String()
        var SQLParameterNames: String = String()
        var SQLParameterPlaceholders: String = String()
        var SQLParameterValues: [NSObject] = [NSObject]()
        
        SQLParameterNames = "[RowId], [CreatedBy], [CreatedOn]"
        SQLParameterPlaceholders = "?, ?, ?"
        SQLParameterValues.append(operative.RowId)
        SQLParameterValues.append(operative.CreatedBy)
        SQLParameterValues.append(operative.CreatedOn)
        
        if operative.LastUpdatedBy != nil {
            SQLParameterNames += ", [LastUpdatedBy]"
            SQLParameterPlaceholders += ", ?"
            SQLParameterValues.append(operative.LastUpdatedBy!)
        }
        
        if operative.LastUpdatedOn != nil {
            SQLParameterNames += ", [LastUpdatedOn]"
            SQLParameterPlaceholders += ", ?"
            SQLParameterValues.append(operative.LastUpdatedOn!)
        }
        
        if operative.Deleted != nil {
            SQLParameterNames += ", [Deleted]"
            SQLParameterPlaceholders += ", ?"
            SQLParameterValues.append(operative.Deleted!)
        }
        
        SQLParameterNames += ", [OrganisationId], [Username], [Password]"
        SQLParameterPlaceholders += ", ?, ?, ?"
        SQLParameterValues.append(operative.OrganisationId)
        SQLParameterValues.append(operative.Username)
        SQLParameterValues.append(operative.Password)
        
        SQLStatement = "INSERT INTO [OPERATIVE] (" + SQLParameterNames + ") VALUES (" + SQLParameterPlaceholders + ")"
        
        sharedModelManager.database!.open()
        let isInserted = sharedModelManager.database!.executeUpdate(SQLStatement, withArgumentsInArray: SQLParameterValues)
        sharedModelManager.database!.close()
        return isInserted
    }
    
    func updateOperative(operative: Operative) -> Bool {
        //build the sql statemnt
        var SQLStatement: String = String()
        var SQLParameterNames: String = String()
        var SQLParameterValues: [NSObject] = [NSObject]()
        
        SQLParameterNames = "[CreatedBy]=?, [CreatedOn]=?"
        SQLParameterValues.append(operative.CreatedBy)
        SQLParameterValues.append(operative.CreatedOn)
        
        if operative.LastUpdatedBy != nil {
            SQLParameterNames += ", [LastUpdatedBy]=?"
            SQLParameterValues.append(operative.LastUpdatedBy!)
        }
        
        if operative.LastUpdatedOn != nil {
            SQLParameterNames += ", [LastUpdatedOn]=?"
            SQLParameterValues.append(operative.LastUpdatedOn!)
        }
        
        if operative.Deleted != nil {
            SQLParameterNames += ", [Deleted]=?"
            SQLParameterValues.append(operative.Deleted!)
        }
        
        SQLParameterNames += ", [OrganisationId]=?, [Username]=?, [Password]=?"
        SQLParameterValues.append(operative.OrganisationId)
        SQLParameterValues.append(operative.Username)
        SQLParameterValues.append(operative.Password)
        
        SQLParameterValues.append(operative.RowId)
        
        SQLStatement = "UPDATE [OPERATIVE] SET " + SQLParameterNames + "WHERE [RowId]=?"
        
        sharedModelManager.database!.open()
        let isUpdated = sharedModelManager.database!.executeUpdate(SQLStatement, withArgumentsInArray: SQLParameterValues)
        sharedModelManager.database!.close()
        return isUpdated
    }
    
    func deleteOperative(operative: Operative) -> Bool {
        sharedModelManager.database!.open()
        let isDeleted = sharedModelManager.database!.executeUpdate("DELETE FROM [OPERATIVE] WHERE [RowId]=?", withArgumentsInArray: [operative.RowId])
        sharedModelManager.database!.close()
        return isDeleted
    }
    
    func getOperative(operativeId: String) -> Operative? {
        sharedModelManager.database!.open()
        var operative: Operative? = nil
        
        let resultSet = sharedModelManager.database!.executeQuery("SELECT [RowId], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [Deleted], [OrganisationId], [Username], [Password] FROM [Operative] WHERE [RowId]=?", withArgumentsInArray: [operativeId])
        if (resultSet != nil) {
            while resultSet.next() {
                var resultOperative: Operative = Operative()
                resultOperative = Operative()
                resultOperative.RowId = resultSet.stringForColumn("RowId")
                resultOperative.CreatedBy = resultSet.stringForColumn("CreatedBy")
                resultOperative.CreatedOn = resultSet.dateForColumn("CreatedOn")
                if !resultSet.columnIsNull("LastUpdatedBy")
                {
                    resultOperative.LastUpdatedBy = resultSet.stringForColumn("LastUpdatedBy")
                }
                if !resultSet.columnIsNull("LastUpdatedOn")
                {
                    resultOperative.LastUpdatedOn = resultSet.dateForColumn("LastUpdatedOn")
                }
                if !resultSet.columnIsNull("Deleted")
                {
                    resultOperative.Deleted = resultSet.dateForColumn("Deleted")
                }
                resultOperative.OrganisationId = resultSet.stringForColumn("OrganisationId")
                resultOperative.Username = resultSet.stringForColumn("Username")
                resultOperative.Password = resultSet.stringForColumn("Password")
                
                operative = resultOperative
            }
        }
        sharedModelManager.database!.close()
        return operative
    }
    
    func getAllOperative() -> [Operative] {
        sharedModelManager.database!.open()
        let resultSet: FMResultSet! = sharedModelManager.database!.executeQuery("SELECT [RowId], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [Deleted], [OrganisationId], [Username], [Password] FROM [Operative]", withArgumentsInArray: nil)
        var operativeList: [Operative] = [Operative]()
        if (resultSet != nil) {
            while resultSet.next() {
                let operative : Operative = Operative()
                operative.RowId = resultSet.stringForColumn("RowId")
                operative.CreatedBy = resultSet.stringForColumn("CreatedBy")
                operative.CreatedOn = resultSet.dateForColumn("CreatedOn")
                if !resultSet.columnIsNull("LastUpdatedBy")
                {
                    operative.LastUpdatedBy = resultSet.stringForColumn("LastUpdatedBy")
                }
                if !resultSet.columnIsNull("LastUpdatedOn")
                {
                    operative.LastUpdatedOn = resultSet.dateForColumn("LastUpdatedOn")
                }
                if !resultSet.columnIsNull("Deleted")
                {
                    operative.Deleted = resultSet.dateForColumn("Deleted")
                }
                operative.OrganisationId = resultSet.stringForColumn("OrganisationId")
                operative.Username = resultSet.stringForColumn("Username")
                operative.Password = resultSet.stringForColumn("Password")
                
                operativeList.append(operative)
            }
        }
        sharedModelManager.database!.close()
        return operativeList
    }
    
    func findOperativeList(criteria: Dictionary<String, AnyObject>) -> [Operative] {
        var list: [Operative] = [Operative]()
        //var count: Int32 = 0
        (list, _) = findOperativeList(criteria, pageSize: nil, pageNumber: nil)
        return list
    }

    func findOperativeList(criteria: Dictionary<String, AnyObject>, pageSize: Int32?, pageNumber: Int32?) -> (List: [Operative], Count: Int32) {
        //return variables
        var count: Int32 = 0
        var operativeList: [Operative] = [Operative]()
        
        //build the order clause
        let orderByClause: String = " ORDER BY [Username]"
        
        //build the where clause
        var whereClause: String = String()
        var whereValues: [AnyObject] = [AnyObject]()
        
        (whereClause, whereValues) = buildWhereClause(criteria)
        
        if (whereClause != "")
        {
            whereClause = "WHERE " + whereClause
        }

        sharedModelManager.database!.open()
        let countSet: FMResultSet! = sharedModelManager.database!.executeQuery("SELECT COUNT([RowId]) FROM [Operative] " + whereClause + orderByClause, withArgumentsInArray: whereValues)
        if (countSet != nil) {
            while countSet.next() {
                count = countSet.intForColumnIndex(0)
            }
        }
        
        if (count > 0)
        {
            var pageClause: String = String()
            if (pageSize != nil && pageNumber != nil)
            {
                pageClause = " LIMIT " + String(pageSize!) + " OFFSET " + String((pageNumber! - 1) * pageSize!)
            }
            
            let resultSet: FMResultSet! = sharedModelManager.database!.executeQuery("SELECT [RowId], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [Deleted], [OrganisationId], [Username], [Password] FROM [Operative] " + whereClause + orderByClause + pageClause, withArgumentsInArray: whereValues)
            if (resultSet != nil) {
                while resultSet.next() {
                    let operative : Operative = Operative()
                    operative.RowId = resultSet.stringForColumn("RowId")
                    operative.CreatedBy = resultSet.stringForColumn("CreatedBy")
                    operative.CreatedOn = resultSet.dateForColumn("CreatedOn")
                    if !resultSet.columnIsNull("LastUpdatedBy")
                    {
                        operative.LastUpdatedBy = resultSet.stringForColumn("LastUpdatedBy")
                    }
                    if !resultSet.columnIsNull("LastUpdatedOn")
                    {
                        operative.LastUpdatedOn = resultSet.dateForColumn("LastUpdatedOn")
                    }
                    if !resultSet.columnIsNull("Deleted")
                    {
                        operative.Deleted = resultSet.dateForColumn("Deleted")
                    }
                    operative.OrganisationId = resultSet.stringForColumn("OrganisationId")
                    operative.Username = resultSet.stringForColumn("Username")
                    operative.Password = resultSet.stringForColumn("Password")
                    
                    operativeList.append(operative)
                }
            }
        }
        
        sharedModelManager.database!.close()
        return (operativeList, count)
    }
    
    // MARK: - Organisation
    
    
    func addOrganisation(organisation: Organisation) -> Bool {
        //build the sql statemnt
        var SQLStatement: String = String()
        var SQLParameterNames: String = String()
        var SQLParameterPlaceholders: String = String()
        var SQLParameterValues: [NSObject] = [NSObject]()
        
        SQLParameterNames = "[RowId], [CreatedBy], [CreatedOn]"
        SQLParameterPlaceholders = "?, ?, ?"
        SQLParameterValues.append(organisation.RowId)
        SQLParameterValues.append(organisation.CreatedBy)
        SQLParameterValues.append(organisation.CreatedOn)
        
        if organisation.LastUpdatedBy != nil {
            SQLParameterNames += ", [LastUpdatedBy]"
            SQLParameterPlaceholders += ", ?"
            SQLParameterValues.append(organisation.LastUpdatedBy!)
        }
        
        if organisation.LastUpdatedOn != nil {
            SQLParameterNames += ", [LastUpdatedOn]"
            SQLParameterPlaceholders += ", ?"
            SQLParameterValues.append(organisation.LastUpdatedOn!)
        }
        
        if organisation.Deleted != nil {
            SQLParameterNames += ", [Deleted]"
            SQLParameterPlaceholders += ", ?"
            SQLParameterValues.append(organisation.Deleted!)
        }
        
        SQLParameterNames += ", [ParentOrganisationId]"
        SQLParameterPlaceholders += ", ?"
        SQLParameterValues.append(organisation.ParentOrganisationId)
        SQLParameterNames += ", [Name]"
        SQLParameterPlaceholders += ", ?"
        SQLParameterValues.append(organisation.Name)
        
        SQLStatement = "INSERT INTO [Organisation] (" + SQLParameterNames + ") VALUES (" + SQLParameterPlaceholders + ")"
        
        sharedModelManager.database!.open()
        let isInserted = sharedModelManager.database!.executeUpdate(SQLStatement, withArgumentsInArray: SQLParameterValues)
        sharedModelManager.database!.close()
        return isInserted
    }
    
    func updateOrganisation(organisation: Organisation) -> Bool {
        //build the sql statemnt
        var SQLStatement: String = String()
        var SQLParameterNames: String = String()
        var SQLParameterValues: [NSObject] = [NSObject]()
        
        SQLParameterNames = "[CreatedBy]=?, [CreatedOn]=?"
        SQLParameterValues.append(organisation.CreatedBy)
        SQLParameterValues.append(organisation.CreatedOn)
        
        if organisation.LastUpdatedBy != nil {
            SQLParameterNames += ", [LastUpdatedBy]=?"
            SQLParameterValues.append(organisation.LastUpdatedBy!)
        }
        
        if organisation.LastUpdatedOn != nil {
            SQLParameterNames += ", [LastUpdatedOn]=?"
            SQLParameterValues.append(organisation.LastUpdatedOn!)
        }
        
        if organisation.Deleted != nil {
            SQLParameterNames += ", [Deleted]=?"
            SQLParameterValues.append(organisation.Deleted!)
        }
        SQLParameterNames += ", [ParentOrganisationId]=?"
        SQLParameterValues.append(organisation.ParentOrganisationId)
        SQLParameterNames += ", [Name]=?"
        SQLParameterValues.append(organisation.Name)
        
        
        SQLParameterValues.append(organisation.RowId)
        
        SQLStatement = "UPDATE [Organisation] SET " + SQLParameterNames + "WHERE [RowId]=?"
        
        sharedModelManager.database!.open()
        let isUpdated = sharedModelManager.database!.executeUpdate(SQLStatement, withArgumentsInArray: SQLParameterValues)
        sharedModelManager.database!.close()
        return isUpdated
    }
    
    func deleteOrganisation(organisation: Organisation) -> Bool {
        sharedModelManager.database!.open()
        let isDeleted = sharedModelManager.database!.executeUpdate("DELETE FROM [Organisation] WHERE [RowId]=?", withArgumentsInArray: [organisation.RowId])
        sharedModelManager.database!.close()
        return isDeleted
    }
    
    func getOrganisation(organisationId: String) -> Organisation? {
        sharedModelManager.database!.open()
        var organisation: Organisation? = nil
        
        let resultSet = sharedModelManager.database!.executeQuery("SELECT [RowId], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [Deleted], [ParentOrganisationId], [Name] FROM [Organisation] WHERE [RowId]=?", withArgumentsInArray: [organisationId])
        if (resultSet != nil) {
            while resultSet.next() {
                var resultOrganisation: Organisation = Organisation()
                resultOrganisation = Organisation()
                resultOrganisation.RowId = resultSet.stringForColumn("RowId")
                resultOrganisation.CreatedBy = resultSet.stringForColumn("CreatedBy")
                resultOrganisation.CreatedOn = resultSet.dateForColumn("CreatedOn")
                if !resultSet.columnIsNull("LastUpdatedBy")
                {
                    resultOrganisation.LastUpdatedBy = resultSet.stringForColumn("LastUpdatedBy")
                }
                if !resultSet.columnIsNull("LastUpdatedOn")
                {
                    resultOrganisation.LastUpdatedOn = resultSet.dateForColumn("LastUpdatedOn")
                }
                if !resultSet.columnIsNull("Deleted")
                {
                    resultOrganisation.Deleted = resultSet.dateForColumn("Deleted")
                }
                resultOrganisation.ParentOrganisationId = resultSet.stringForColumn("ParentOrganisationId")
                resultOrganisation.Name = resultSet.stringForColumn("Name")
                
                organisation = resultOrganisation
            }
        }
        sharedModelManager.database!.close()
        return organisation
    }
    
    func getAllOrganisation() -> [Organisation] {
        sharedModelManager.database!.open()
        let resultSet: FMResultSet! = sharedModelManager.database!.executeQuery("SELECT [RowId], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [Deleted], [ParentOrganisationId], [Name] FROM [Organisation]", withArgumentsInArray: nil)
        var organisationList: [Organisation] = [Organisation]()
        if (resultSet != nil) {
            while resultSet.next() {
                let organisation : Organisation = Organisation()
                organisation.RowId = resultSet.stringForColumn("RowId")
                organisation.CreatedBy = resultSet.stringForColumn("CreatedBy")
                organisation.CreatedOn = resultSet.dateForColumn("CreatedOn")
                if !resultSet.columnIsNull("LastUpdatedBy")
                {
                    organisation.LastUpdatedBy = resultSet.stringForColumn("LastUpdatedBy")
                }
                if !resultSet.columnIsNull("LastUpdatedOn")
                {
                    organisation.LastUpdatedOn = resultSet.dateForColumn("LastUpdatedOn")
                }
                if !resultSet.columnIsNull("Deleted")
                {
                    organisation.Deleted = resultSet.dateForColumn("Deleted")
                }
                organisation.ParentOrganisationId = resultSet.stringForColumn("ParentOrganisationId")
                organisation.Name = resultSet.stringForColumn("Name")
                
                organisationList.append(organisation)
            }
        }
        sharedModelManager.database!.close()
        return organisationList
    }
    
    func findOrganisationList(criteria: Dictionary<String, AnyObject>) -> [Organisation] {
        var list: [Organisation] = [Organisation]()
        //var count: Int32 = 0
        (list, _) = findOrganisationList(criteria, pageSize: nil, pageNumber: nil)
        return list
    }

    func findOrganisationList(criteria: Dictionary<String, AnyObject>, pageSize: Int32?, pageNumber: Int32?) -> (List: [Organisation], Count: Int32) {
        //return variables
        var count: Int32 = 0
        var organisationList: [Organisation] = [Organisation]()
        
        //build the order clause
        let orderByClause: String = " ORDER BY [Name]"
        
        //build the where clause
        var whereClause: String = String()
        var whereValues: [AnyObject] = [AnyObject]()
        
        (whereClause, whereValues) = buildWhereClause(criteria)
        
        if (whereClause != "")
        {
            whereClause = "WHERE " + whereClause
        }

        sharedModelManager.database!.open()
        let countSet: FMResultSet! = sharedModelManager.database!.executeQuery("SELECT COUNT([RowId]) FROM [Organisation] " + whereClause + orderByClause, withArgumentsInArray: whereValues)
        if (countSet != nil) {
            while countSet.next() {
                count = countSet.intForColumnIndex(0)
            }
        }
        
        if (count > 0)
        {
            var pageClause: String = String()
            if (pageSize != nil && pageNumber != nil)
            {
                pageClause = " LIMIT " + String(pageSize!) + " OFFSET " + String((pageNumber! - 1) * pageSize!)
            }
            
            let resultSet: FMResultSet! = sharedModelManager.database!.executeQuery("SELECT [RowId], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [Deleted], [ParentOrganisationId], [Name] FROM [Organisation] " + whereClause + orderByClause + pageClause, withArgumentsInArray: whereValues)
            if (resultSet != nil) {
                while resultSet.next() {
                    let organisation : Organisation = Organisation()
                    organisation.RowId = resultSet.stringForColumn("RowId")
                    organisation.CreatedBy = resultSet.stringForColumn("CreatedBy")
                    organisation.CreatedOn = resultSet.dateForColumn("CreatedOn")
                    if !resultSet.columnIsNull("LastUpdatedBy")
                    {
                        organisation.LastUpdatedBy = resultSet.stringForColumn("LastUpdatedBy")
                    }
                    if !resultSet.columnIsNull("LastUpdatedOn")
                    {
                        organisation.LastUpdatedOn = resultSet.dateForColumn("LastUpdatedOn")
                    }
                    if !resultSet.columnIsNull("Deleted")
                    {
                        organisation.Deleted = resultSet.dateForColumn("Deleted")
                    }
                    organisation.ParentOrganisationId = resultSet.stringForColumn("ParentOrganisationId")
                    organisation.Name = resultSet.stringForColumn("Name")
                    
                    organisationList.append(organisation)
                }
            }
        }
        
        sharedModelManager.database!.close()
        return (organisationList, count)
    }
    
    // MARK: - Property
    
    func addProperty(property: Property) -> Bool {
        //build the sql statemnt
        var SQLStatement: String = String()
        var SQLParameterNames: String = String()
        var SQLParameterPlaceholders: String = String()
        var SQLParameterValues: [NSObject] = [NSObject]()
        
        SQLParameterNames = "[RowId], [CreatedBy], [CreatedOn]"
        SQLParameterPlaceholders = "?, ?, ?"
        SQLParameterValues.append(property.RowId)
        SQLParameterValues.append(property.CreatedBy)
        SQLParameterValues.append(property.CreatedOn)
        
        if property.LastUpdatedBy != nil {
            SQLParameterNames += ", [LastUpdatedBy]"
            SQLParameterPlaceholders += ", ?"
            SQLParameterValues.append(property.LastUpdatedBy!)
        }
        
        if property.LastUpdatedOn != nil {
            SQLParameterNames += ", [LastUpdatedOn]"
            SQLParameterPlaceholders += ", ?"
            SQLParameterValues.append(property.LastUpdatedOn!)
        }
        
        if property.Deleted != nil {
            SQLParameterNames += ", [Deleted]"
            SQLParameterPlaceholders += ", ?"
            SQLParameterValues.append(property.Deleted!)
        }
        SQLParameterNames += ", [SiteId]"
        SQLParameterPlaceholders += ", ?"
        SQLParameterValues.append(property.SiteId)
        SQLParameterNames += ", [Name]"
        SQLParameterPlaceholders += ", ?"
        SQLParameterValues.append(property.Name)
        SQLParameterNames += ", [Healthcare]"
        SQLParameterPlaceholders += ", ?"
        SQLParameterValues.append(property.Healthcare)
        
        SQLStatement = "INSERT INTO [Property] (" + SQLParameterNames + ") VALUES (" + SQLParameterPlaceholders + ")"
        
        sharedModelManager.database!.open()
        let isInserted = sharedModelManager.database!.executeUpdate(SQLStatement, withArgumentsInArray: SQLParameterValues)
        sharedModelManager.database!.close()
        return isInserted
    }
    
    func updateProperty(property: Property) -> Bool {
        //build the sql statemnt
        var SQLStatement: String = String()
        var SQLParameterNames: String = String()
        var SQLParameterValues: [NSObject] = [NSObject]()
        
        SQLParameterNames = "[CreatedBy]=?, [CreatedOn]=?"
        SQLParameterValues.append(property.CreatedBy)
        SQLParameterValues.append(property.CreatedOn)
        
        if property.LastUpdatedBy != nil {
            SQLParameterNames += ", [LastUpdatedBy]=?"
            SQLParameterValues.append(property.LastUpdatedBy!)
        }
        
        if property.LastUpdatedOn != nil {
            SQLParameterNames += ", [LastUpdatedOn]=?"
            SQLParameterValues.append(property.LastUpdatedOn!)
        }
        
        if property.Deleted != nil {
            SQLParameterNames += ", [Deleted]=?"
            SQLParameterValues.append(property.Deleted!)
        }
        SQLParameterNames += ", [SiteId]=?"
        SQLParameterValues.append(property.SiteId)
        SQLParameterNames += ", [Name]=?"
        SQLParameterValues.append(property.Name)
        SQLParameterNames += ", [Healthcare]=?"
        SQLParameterValues.append(property.Healthcare)
        
        SQLParameterValues.append(property.RowId)
        
        SQLStatement = "UPDATE [Property] SET " + SQLParameterNames + "WHERE [RowId]=?"
        
        sharedModelManager.database!.open()
        let isUpdated = sharedModelManager.database!.executeUpdate(SQLStatement, withArgumentsInArray: SQLParameterValues)
        sharedModelManager.database!.close()
        return isUpdated
    }
    
    func deleteProperty(property: Property) -> Bool {
        sharedModelManager.database!.open()
        let isDeleted = sharedModelManager.database!.executeUpdate("DELETE FROM [Property] WHERE [RowId]=?", withArgumentsInArray: [property.RowId])
        sharedModelManager.database!.close()
        return isDeleted
    }
    
    func getProperty(propertyId: String) -> Property? {
        sharedModelManager.database!.open()
        var property: Property? = nil
        
        let resultSet = sharedModelManager.database!.executeQuery("SELECT [RowId], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [Deleted], [SiteId], [Name], [Healthcare] FROM [Property] WHERE [RowId]=?", withArgumentsInArray: [propertyId])
        if (resultSet != nil) {
            while resultSet.next() {
                var resultProperty: Property = Property()
                resultProperty = Property()
                resultProperty.RowId = resultSet.stringForColumn("RowId")
                resultProperty.CreatedBy = resultSet.stringForColumn("CreatedBy")
                resultProperty.CreatedOn = resultSet.dateForColumn("CreatedOn")
                if !resultSet.columnIsNull("LastUpdatedBy")
                {
                    resultProperty.LastUpdatedBy = resultSet.stringForColumn("LastUpdatedBy")
                }
                if !resultSet.columnIsNull("LastUpdatedOn")
                {
                    resultProperty.LastUpdatedOn = resultSet.dateForColumn("LastUpdatedOn")
                }
                if !resultSet.columnIsNull("Deleted")
                {
                    resultProperty.Deleted = resultSet.dateForColumn("Deleted")
                }
                resultProperty.SiteId = resultSet.stringForColumn("SiteId")
                resultProperty.Name = resultSet.stringForColumn("Name")
                resultProperty.Healthcare = resultSet.boolForColumn("Healthcare")
                
                property = resultProperty
            }
        }
        sharedModelManager.database!.close()
        return property
    }
    
    func getAllProperty() -> [Property] {
        sharedModelManager.database!.open()
        let resultSet: FMResultSet! = sharedModelManager.database!.executeQuery("SELECT [RowId], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [Deleted], [SiteId], [Name], [Healthcare] FROM [Property]", withArgumentsInArray: nil)
        var propertyList: [Property] = [Property]()
        if (resultSet != nil) {
            while resultSet.next() {
                let property : Property = Property()
                property.RowId = resultSet.stringForColumn("RowId")
                property.CreatedBy = resultSet.stringForColumn("CreatedBy")
                property.CreatedOn = resultSet.dateForColumn("CreatedOn")
                if !resultSet.columnIsNull("LastUpdatedBy")
                {
                    property.LastUpdatedBy = resultSet.stringForColumn("LastUpdatedBy")
                }
                if !resultSet.columnIsNull("LastUpdatedOn")
                {
                    property.LastUpdatedOn = resultSet.dateForColumn("LastUpdatedOn")
                }
                if !resultSet.columnIsNull("Deleted")
                {
                    property.Deleted = resultSet.dateForColumn("Deleted")
                }
                property.SiteId = resultSet.stringForColumn("SiteId")
                property.Name = resultSet.stringForColumn("Name")
                property.Healthcare = resultSet.boolForColumn("Healthcare")
                
                propertyList.append(property)
            }
        }
        sharedModelManager.database!.close()
        return propertyList
    }
    
    func findPropertyList(criteria: Dictionary<String, AnyObject>) -> [Property] {
        var list: [Property] = [Property]()
        //var count: Int32 = 0
        (list, _) = findPropertyList(criteria, pageSize: nil, pageNumber: nil)
        return list
    }

    func findPropertyList(criteria: Dictionary<String, AnyObject>, pageSize: Int32?, pageNumber: Int32?) -> (List: [Property], Count: Int32) {
        //return variables
        var count: Int32 = 0
        var propertyList: [Property] = [Property]()
        
        //build the order clause
        let orderByClause: String = " ORDER BY [Name]"
        
        //build the where clause
        var whereClause: String = String()
        var whereValues: [AnyObject] = [AnyObject]()
        
        (whereClause, whereValues) = buildWhereClause(criteria)
        
        if (whereClause != "")
        {
            whereClause = "WHERE " + whereClause
        }

        sharedModelManager.database!.open()
        let countSet: FMResultSet! = sharedModelManager.database!.executeQuery("SELECT COUNT([RowId]) FROM [Property] " + whereClause + orderByClause, withArgumentsInArray: whereValues)
        if (countSet != nil) {
            while countSet.next() {
                count = countSet.intForColumnIndex(0)
            }
        }
        
        if (count > 0)
        {
            var pageClause: String = String()
            if (pageSize != nil && pageNumber != nil)
            {
                pageClause = " LIMIT " + String(pageSize!) + " OFFSET " + String((pageNumber! - 1) * pageSize!)
            }
            
            let resultSet: FMResultSet! = sharedModelManager.database!.executeQuery("SELECT [RowId], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [Deleted], [SiteId], [Name], [Healthcare] FROM [Property] " + whereClause + orderByClause + pageClause, withArgumentsInArray: whereValues)
            if (resultSet != nil) {
                while resultSet.next() {
                    let property : Property = Property()
                    property.RowId = resultSet.stringForColumn("RowId")
                    property.CreatedBy = resultSet.stringForColumn("CreatedBy")
                    property.CreatedOn = resultSet.dateForColumn("CreatedOn")
                    if !resultSet.columnIsNull("LastUpdatedBy")
                    {
                        property.LastUpdatedBy = resultSet.stringForColumn("LastUpdatedBy")
                    }
                    if !resultSet.columnIsNull("LastUpdatedOn")
                    {
                        property.LastUpdatedOn = resultSet.dateForColumn("LastUpdatedOn")
                    }
                    if !resultSet.columnIsNull("Deleted")
                    {
                        property.Deleted = resultSet.dateForColumn("Deleted")
                    }
                    property.SiteId = resultSet.stringForColumn("SiteId")
                    property.Name = resultSet.stringForColumn("Name")
                    property.Healthcare = resultSet.boolForColumn("Healthcare")
                    
                    propertyList.append(property)
                }
            }
        }
        
        sharedModelManager.database!.close()
        return (propertyList, count)
    }
    
    // MARK: - ReferenceData
    
    func addReferenceData(referenceData: ReferenceData) -> Bool {
        //build the sql statemnt
        var SQLStatement: String = String()
        var SQLParameterNames: String = String()
        var SQLParameterPlaceholders: String = String()
        var SQLParameterValues: [NSObject] = [NSObject]()
        
        SQLParameterNames = "[RowId], [CreatedBy], [CreatedOn]"
        SQLParameterPlaceholders = "?, ?, ?"
        SQLParameterValues.append(referenceData.RowId)
        SQLParameterValues.append(referenceData.CreatedBy)
        SQLParameterValues.append(referenceData.CreatedOn)
        
        if referenceData.LastUpdatedBy != nil {
            SQLParameterNames += ", [LastUpdatedBy]"
            SQLParameterPlaceholders += ", ?"
            SQLParameterValues.append(referenceData.LastUpdatedBy!)
        }
        
        if referenceData.LastUpdatedOn != nil {
            SQLParameterNames += ", [LastUpdatedOn]"
            SQLParameterPlaceholders += ", ?"
            SQLParameterValues.append(referenceData.LastUpdatedOn!)
        }
        
        if referenceData.Deleted != nil {
            SQLParameterNames += ", [Deleted]"
            SQLParameterPlaceholders += ", ?"
            SQLParameterValues.append(referenceData.Deleted!)
        }
        SQLParameterNames += ", [StartDate]"
        SQLParameterPlaceholders += ", ?"
        SQLParameterValues.append(referenceData.StartDate)
        if referenceData.EndDate != nil {
            SQLParameterNames += ", [EndDate]"
            SQLParameterPlaceholders += ", ?"
            SQLParameterValues.append(referenceData.EndDate!)
        }
        SQLParameterNames += ", [Type]"
        SQLParameterPlaceholders += ", ?"
        SQLParameterValues.append(referenceData.Type)
        SQLParameterNames += ", [Value]"
        SQLParameterPlaceholders += ", ?"
        SQLParameterValues.append(referenceData.Value)
        SQLParameterNames += ", [Ordinal]"
        SQLParameterPlaceholders += ", ?"
        SQLParameterValues.append(String(referenceData.Ordinal))
        SQLParameterNames += ", [Display]"
        SQLParameterPlaceholders += ", ?"
        SQLParameterValues.append(referenceData.Display)
        SQLParameterNames += ", [System]"
        SQLParameterPlaceholders += ", ?"
        SQLParameterValues.append(referenceData.System)
        if referenceData.ParentType != nil {
            SQLParameterNames += ", [ParentType]"
            SQLParameterPlaceholders += ", ?"
            SQLParameterValues.append(referenceData.ParentType!)
        }
        if referenceData.ParentValue != nil {
            SQLParameterNames += ", [ParentValue]"
            SQLParameterPlaceholders += ", ?"
            SQLParameterValues.append(referenceData.ParentValue!)
        }
        
        SQLStatement = "INSERT INTO [ReferenceData] (" + SQLParameterNames + ") VALUES (" + SQLParameterPlaceholders + ")"
        
        sharedModelManager.database!.open()
        let isInserted = sharedModelManager.database!.executeUpdate(SQLStatement, withArgumentsInArray: SQLParameterValues)
        sharedModelManager.database!.close()
        return isInserted
    }
    
    func updateReferenceData(referenceData: ReferenceData) -> Bool {
        //build the sql statemnt
        var SQLStatement: String = String()
        var SQLParameterNames: String = String()
        var SQLParameterValues: [NSObject] = [NSObject]()
        
        SQLParameterNames = "[CreatedBy]=?, [CreatedOn]=?"
        SQLParameterValues.append(referenceData.CreatedBy)
        SQLParameterValues.append(referenceData.CreatedOn)
        
        if referenceData.LastUpdatedBy != nil {
            SQLParameterNames += ", [LastUpdatedBy]=?"
            SQLParameterValues.append(referenceData.LastUpdatedBy!)
        }
        
        if referenceData.LastUpdatedOn != nil {
            SQLParameterNames += ", [LastUpdatedOn]=?"
            SQLParameterValues.append(referenceData.LastUpdatedOn!)
        }
        
        if referenceData.Deleted != nil {
            SQLParameterNames += ", [Deleted]=?"
            SQLParameterValues.append(referenceData.Deleted!)
        }
        SQLParameterNames += ", [StartDate]=?"
        SQLParameterValues.append(referenceData.StartDate)
        if referenceData.EndDate != nil {
            SQLParameterNames += ", [EndDate]=?"
            SQLParameterValues.append(referenceData.EndDate!)
        }
        SQLParameterNames += ", [Type]=?"
        SQLParameterValues.append(referenceData.Type)
        SQLParameterNames += ", [Value]=?"
        SQLParameterValues.append(referenceData.Value)
        SQLParameterNames += ", [Ordinal]=?"
        SQLParameterValues.append(referenceData.Ordinal)
        SQLParameterNames += ", [Display]=?"
        SQLParameterValues.append(referenceData.Display)
        SQLParameterNames += ", [System]=?"
        SQLParameterValues.append(referenceData.System)
        if referenceData.ParentType != nil {
            SQLParameterNames += ", [ParentType]=?"
            SQLParameterValues.append(referenceData.ParentType!)
        }
        if referenceData.ParentValue != nil {
            SQLParameterNames += ", [ParentValue]=?"
            SQLParameterValues.append(referenceData.ParentValue!)
        }
        
        
        SQLParameterValues.append(referenceData.RowId)
        
        SQLStatement = "UPDATE [ReferenceData] SET " + SQLParameterNames + "WHERE [RowId]=?"
        
        sharedModelManager.database!.open()
        let isUpdated = sharedModelManager.database!.executeUpdate(SQLStatement, withArgumentsInArray: SQLParameterValues)
        sharedModelManager.database!.close()
        return isUpdated
    }
    
    func deleteReferenceData(referenceData: ReferenceData) -> Bool {
        sharedModelManager.database!.open()
        let isDeleted = sharedModelManager.database!.executeUpdate("DELETE FROM [ReferenceData] WHERE [RowId]=?", withArgumentsInArray: [referenceData.RowId])
        sharedModelManager.database!.close()
        return isDeleted
    }
    
    func getReferenceData(referenceDataId: String) -> ReferenceData? {
        sharedModelManager.database!.open()
        var referenceData: ReferenceData? = nil
        
        let resultSet = sharedModelManager.database!.executeQuery("SELECT [RowId], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [Deleted], [StartDate], [EndDate], [Type], [Value], [Ordinal], [Display], [System], [ParentType], [ParentValue] FROM [ReferenceData] WHERE [RowId]=?", withArgumentsInArray: [referenceDataId])
        if (resultSet != nil) {
            while resultSet.next() {
                var resultReferenceData: ReferenceData = ReferenceData()
                resultReferenceData = ReferenceData()
                resultReferenceData.RowId = resultSet.stringForColumn("RowId")
                resultReferenceData.CreatedBy = resultSet.stringForColumn("CreatedBy")
                resultReferenceData.CreatedOn = resultSet.dateForColumn("CreatedOn")
                if !resultSet.columnIsNull("LastUpdatedBy")
                {
                    resultReferenceData.LastUpdatedBy = resultSet.stringForColumn("LastUpdatedBy")
                }
                if !resultSet.columnIsNull("LastUpdatedOn")
                {
                    resultReferenceData.LastUpdatedOn = resultSet.dateForColumn("LastUpdatedOn")
                }
                if !resultSet.columnIsNull("Deleted")
                {
                    resultReferenceData.Deleted = resultSet.dateForColumn("Deleted")
                }
                resultReferenceData.StartDate = resultSet.dateForColumn("StartDate")
                if !resultSet.columnIsNull("EndDate") {
                    resultReferenceData.EndDate = resultSet.dateForColumn("EndDate")
                }
                resultReferenceData.Type = resultSet.stringForColumn("Type")
                resultReferenceData.Value = resultSet.stringForColumn("Value")
                resultReferenceData.Ordinal = Int(resultSet.intForColumn("Ordinal"))
                resultReferenceData.Display = resultSet.stringForColumn("Display")
                resultReferenceData.System = resultSet.boolForColumn("System")
                if !resultSet.columnIsNull("ParentType") {
                    resultReferenceData.ParentType = resultSet.stringForColumn("ParentType")
                }
                if !resultSet.columnIsNull("ParentValue") {
                    resultReferenceData.ParentValue = resultSet.stringForColumn("ParentValue")
                }
                
                
                referenceData = resultReferenceData
            }
        }
        sharedModelManager.database!.close()
        return referenceData
    }
    
    func getAllReferenceData() -> [ReferenceData] {
        sharedModelManager.database!.open()
        let resultSet: FMResultSet! = sharedModelManager.database!.executeQuery("SELECT [RowId], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [Deleted], [StartDate], [EndDate], [Type], [Value], [Ordinal], [Display], [System], [ParentType], [ParentValue] FROM [ReferenceData]", withArgumentsInArray: nil)
        var referenceDataList: [ReferenceData] = [ReferenceData]()
        if (resultSet != nil) {
            while resultSet.next() {
                let referenceData : ReferenceData = ReferenceData()
                referenceData.RowId = resultSet.stringForColumn("RowId")
                referenceData.CreatedBy = resultSet.stringForColumn("CreatedBy")
                referenceData.CreatedOn = resultSet.dateForColumn("CreatedOn")
                if !resultSet.columnIsNull("LastUpdatedBy")
                {
                    referenceData.LastUpdatedBy = resultSet.stringForColumn("LastUpdatedBy")
                }
                if !resultSet.columnIsNull("LastUpdatedOn")
                {
                    referenceData.LastUpdatedOn = resultSet.dateForColumn("LastUpdatedOn")
                }
                if !resultSet.columnIsNull("Deleted")
                {
                    referenceData.Deleted = resultSet.dateForColumn("Deleted")
                }
                referenceData.StartDate = resultSet.dateForColumn("StartDate")
                if !resultSet.columnIsNull("EndDate") {
                    referenceData.EndDate = resultSet.dateForColumn("EndDate")
                }
                referenceData.Type = resultSet.stringForColumn("Type")
                referenceData.Value = resultSet.stringForColumn("Value")
                referenceData.Ordinal = Int(resultSet.intForColumn("Ordinal"))
                referenceData.Display = resultSet.stringForColumn("Display")
                referenceData.System = resultSet.boolForColumn("System")
                if !resultSet.columnIsNull("ParentType") {
                    referenceData.ParentType = resultSet.stringForColumn("ParentType")
                }
                if !resultSet.columnIsNull("ParentValue") {
                    referenceData.ParentValue = resultSet.stringForColumn("ParentValue")
                }
                
                referenceDataList.append(referenceData)
            }
        }
        sharedModelManager.database!.close()
        return referenceDataList
    }
    
    func findReferenceDataList(criteria: Dictionary<String, AnyObject>) -> [ReferenceData] {
        var list: [ReferenceData] = [ReferenceData]()
        //var count: Int32 = 0
        (list, _) = findReferenceDataList(criteria, pageSize: nil, pageNumber: nil)
        return list
    }

    func findReferenceDataList(criteria: Dictionary<String, AnyObject>, pageSize: Int32?, pageNumber: Int32?) -> (List: [ReferenceData], Count: Int32) {
        var list: [ReferenceData] = [ReferenceData]()
        var count: Int32 = 0
        (list, count) = findReferenceDataList(criteria, pageSize: nil, pageNumber: nil, sortOrder: ReferenceDataSortOrder.Display)
        return (list, count)
    }
    
    func findReferenceDataList(criteria: Dictionary<String, AnyObject>, pageSize: Int32?, pageNumber: Int32?, sortOrder: ReferenceDataSortOrder) -> (List: [ReferenceData], Count: Int32) {
        //return variables
        var count: Int32 = 0
        var referenceDataList: [ReferenceData] = [ReferenceData]()
        
        //build the order clause
        var orderByClause: String = " ORDER BY "
        
        switch sortOrder {
            
        case .Display:
            orderByClause += "[Display] "
            
        case .Ordinal:
            orderByClause += "[Ordinal] "
            
        }

        //build the where clause
        var whereClause: String = String()
        var whereValues: [AnyObject] = [AnyObject]()
        
        (whereClause, whereValues) = buildWhereClause(criteria)
        
        if (whereClause != "")
        {
            whereClause = "WHERE " + whereClause
        }

        sharedModelManager.database!.open()
        let countSet: FMResultSet! = sharedModelManager.database!.executeQuery("SELECT COUNT([RowId]) FROM [ReferenceData] " + whereClause + orderByClause, withArgumentsInArray: whereValues)
        if (countSet != nil) {
            while countSet.next() {
                count = countSet.intForColumnIndex(0)
            }
        }
        
        if (count > 0)
        {
            var pageClause: String = String()
            if (pageSize != nil && pageNumber != nil)
            {
                pageClause = " LIMIT " + String(pageSize!) + " OFFSET " + String((pageNumber! - 1) * pageSize!)
            }
            
            let resultSet: FMResultSet! = sharedModelManager.database!.executeQuery("SELECT [RowId], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [Deleted], [StartDate], [EndDate], [Type], [Value], [Ordinal], [Display], [System], [ParentType], [ParentValue] FROM [ReferenceData] " + whereClause + orderByClause + pageClause, withArgumentsInArray: whereValues)
            if (resultSet != nil) {
                while resultSet.next() {
                    let referenceData : ReferenceData = ReferenceData()
                    referenceData.RowId = resultSet.stringForColumn("RowId")
                    referenceData.CreatedBy = resultSet.stringForColumn("CreatedBy")
                    referenceData.CreatedOn = resultSet.dateForColumn("CreatedOn")
                    if !resultSet.columnIsNull("LastUpdatedBy")
                    {
                        referenceData.LastUpdatedBy = resultSet.stringForColumn("LastUpdatedBy")
                    }
                    if !resultSet.columnIsNull("LastUpdatedOn")
                    {
                        referenceData.LastUpdatedOn = resultSet.dateForColumn("LastUpdatedOn")
                    }
                    if !resultSet.columnIsNull("Deleted")
                    {
                        referenceData.Deleted = resultSet.dateForColumn("Deleted")
                    }
                    referenceData.StartDate = resultSet.dateForColumn("StartDate")
                    if !resultSet.columnIsNull("EndDate") {
                        referenceData.EndDate = resultSet.dateForColumn("EndDate")
                    }
                    referenceData.Type = resultSet.stringForColumn("Type")
                    referenceData.Value = resultSet.stringForColumn("Value")
                    referenceData.Ordinal = Int(resultSet.intForColumn("Ordinal"))
                    referenceData.Display = resultSet.stringForColumn("Display")
                    referenceData.System = resultSet.boolForColumn("System")
                    if !resultSet.columnIsNull("ParentType") {
                        referenceData.ParentType = resultSet.stringForColumn("ParentType")
                    }
                    if !resultSet.columnIsNull("ParentValue") {
                        referenceData.ParentValue = resultSet.stringForColumn("ParentValue")
                    }
                    referenceDataList.append(referenceData)
                }
            }
        }
        
        sharedModelManager.database!.close()
        return (referenceDataList, count)
    }
    
    // MARK: - Site
    
    func addSite(site: Site) -> Bool {
        //build the sql statemnt
        var SQLStatement: String = String()
        var SQLParameterNames: String = String()
        var SQLParameterPlaceholders: String = String()
        var SQLParameterValues: [NSObject] = [NSObject]()
        
        SQLParameterNames = "[RowId], [CreatedBy], [CreatedOn]"
        SQLParameterPlaceholders = "?, ?, ?"
        SQLParameterValues.append(site.RowId)
        SQLParameterValues.append(site.CreatedBy)
        SQLParameterValues.append(site.CreatedOn)
        
        if site.LastUpdatedBy != nil {
            SQLParameterNames += ", [LastUpdatedBy]"
            SQLParameterPlaceholders += ", ?"
            SQLParameterValues.append(site.LastUpdatedBy!)
        }
        
        if site.LastUpdatedOn != nil {
            SQLParameterNames += ", [LastUpdatedOn]"
            SQLParameterPlaceholders += ", ?"
            SQLParameterValues.append(site.LastUpdatedOn!)
        }
        
        if site.Deleted != nil {
            SQLParameterNames += ", [Deleted]"
            SQLParameterPlaceholders += ", ?"
            SQLParameterValues.append(site.Deleted!)
        }
        SQLParameterNames += ", [OrganisationId]"
        SQLParameterPlaceholders += ", ?"
        SQLParameterValues.append(site.OrganisationId)
        SQLParameterNames += ", [Name]"
        SQLParameterPlaceholders += ", ?"
        SQLParameterValues.append(site.Name)
        
        SQLStatement = "INSERT INTO [Site] (" + SQLParameterNames + ") VALUES (" + SQLParameterPlaceholders + ")"
        
        sharedModelManager.database!.open()
        let isInserted = sharedModelManager.database!.executeUpdate(SQLStatement, withArgumentsInArray: SQLParameterValues)
        sharedModelManager.database!.close()
        return isInserted
    }
    
    func updateSite(site: Site) -> Bool {
        //build the sql statemnt
        var SQLStatement: String = String()
        var SQLParameterNames: String = String()
        var SQLParameterValues: [NSObject] = [NSObject]()
        
        SQLParameterNames = "[CreatedBy]=?, [CreatedOn]=?"
        SQLParameterValues.append(site.CreatedBy)
        SQLParameterValues.append(site.CreatedOn)
        
        if site.LastUpdatedBy != nil {
            SQLParameterNames += ", [LastUpdatedBy]=?"
            SQLParameterValues.append(site.LastUpdatedBy!)
        }
        
        if site.LastUpdatedOn != nil {
            SQLParameterNames += ", [LastUpdatedOn]=?"
            SQLParameterValues.append(site.LastUpdatedOn!)
        }
        
        if site.Deleted != nil {
            SQLParameterNames += ", [Deleted]=?"
            SQLParameterValues.append(site.Deleted!)
        }
        
        SQLParameterNames += ", [OrganisationId]=?"
        SQLParameterValues.append(site.OrganisationId)
        SQLParameterNames += ", [Name]=?"
        SQLParameterValues.append(site.Name)
        
        SQLParameterValues.append(site.RowId)
        
        SQLStatement = "UPDATE [Site] SET " + SQLParameterNames + "WHERE [RowId]=?"
        
        sharedModelManager.database!.open()
        let isUpdated = sharedModelManager.database!.executeUpdate(SQLStatement, withArgumentsInArray: SQLParameterValues)
        sharedModelManager.database!.close()
        return isUpdated
    }
    
    func deleteSite(site: Site) -> Bool {
        sharedModelManager.database!.open()
        let isDeleted = sharedModelManager.database!.executeUpdate("DELETE FROM [Site] WHERE [RowId]=?", withArgumentsInArray: [site.RowId])
        sharedModelManager.database!.close()
        return isDeleted
    }
    
    func getSite(siteId: String) -> Site? {
        sharedModelManager.database!.open()
        var site: Site? = nil
        
        let resultSet = sharedModelManager.database!.executeQuery("SELECT [RowId], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [Deleted], [OrganisationId], [Name] FROM [Site] WHERE [RowId]=?", withArgumentsInArray: [siteId])
        if (resultSet != nil) {
            while resultSet.next() {
                var resultSite: Site = Site()
                resultSite = Site()
                resultSite.RowId = resultSet.stringForColumn("RowId")
                resultSite.CreatedBy = resultSet.stringForColumn("CreatedBy")
                resultSite.CreatedOn = resultSet.dateForColumn("CreatedOn")
                if !resultSet.columnIsNull("LastUpdatedBy")
                {
                    resultSite.LastUpdatedBy = resultSet.stringForColumn("LastUpdatedBy")
                }
                if !resultSet.columnIsNull("LastUpdatedOn")
                {
                    resultSite.LastUpdatedOn = resultSet.dateForColumn("LastUpdatedOn")
                }
                if !resultSet.columnIsNull("Deleted")
                {
                    resultSite.Deleted = resultSet.dateForColumn("Deleted")
                }
                resultSite.OrganisationId = resultSet.stringForColumn("OrganisationId")
                resultSite.Name = resultSet.stringForColumn("Name")
                
                site = resultSite
            }
        }
        sharedModelManager.database!.close()
        return site
    }
    
    func getAllSite() -> [Site] {
        sharedModelManager.database!.open()
        let resultSet: FMResultSet! = sharedModelManager.database!.executeQuery("SELECT [RowId], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [Deleted], [OrganisationId], [Name] FROM [Site]", withArgumentsInArray: nil)
        var siteList: [Site] = [Site]()
        if (resultSet != nil) {
            while resultSet.next() {
                let site : Site = Site()
                site.RowId = resultSet.stringForColumn("RowId")
                site.CreatedBy = resultSet.stringForColumn("CreatedBy")
                site.CreatedOn = resultSet.dateForColumn("CreatedOn")
                if !resultSet.columnIsNull("LastUpdatedBy")
                {
                    site.LastUpdatedBy = resultSet.stringForColumn("LastUpdatedBy")
                }
                if !resultSet.columnIsNull("LastUpdatedOn")
                {
                    site.LastUpdatedOn = resultSet.dateForColumn("LastUpdatedOn")
                }
                if !resultSet.columnIsNull("Deleted")
                {
                    site.Deleted = resultSet.dateForColumn("Deleted")
                }
                site.OrganisationId = resultSet.stringForColumn("OrganisationId")
                site.Name = resultSet.stringForColumn("Name")
                
                siteList.append(site)
            }
        }
        sharedModelManager.database!.close()
        return siteList
    }
    
    func findSiteList(criteria: Dictionary<String, AnyObject>) -> [Site] {
        var list: [Site] = [Site]()
        //var count: Int32 = 0
        (list, _) = findSiteList(criteria, pageSize: nil, pageNumber: nil)
        return list
    }

    func findSiteList(criteria: Dictionary<String, AnyObject>, pageSize: Int32?, pageNumber: Int32?) -> (List: [Site], Count: Int32) {
        //return variables
        var count: Int32 = 0
        var siteList: [Site] = [Site]()
        
        //build the order clause
        let orderByClause: String = " ORDER BY [Name]"
        
        //build the where clause
        var whereClause: String = String()
        var whereValues: [AnyObject] = [AnyObject]()
        
        (whereClause, whereValues) = buildWhereClause(criteria)
        
        if (whereClause != "")
        {
            whereClause = "WHERE " + whereClause
        }
        
        sharedModelManager.database!.open()
        let countSet: FMResultSet! = sharedModelManager.database!.executeQuery("SELECT COUNT([RowId]) FROM [Site] " + whereClause + orderByClause, withArgumentsInArray: whereValues)
        if (countSet != nil) {
            while countSet.next() {
                count = countSet.intForColumnIndex(0)
            }
        }
        
        if (count > 0)
        {
            var pageClause: String = String()
            if (pageSize != nil && pageNumber != nil)
            {
                pageClause = " LIMIT " + String(pageSize!) + " OFFSET " + String((pageNumber! - 1) * pageSize!)
            }
            
            let resultSet: FMResultSet! = sharedModelManager.database!.executeQuery("SELECT [RowId], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [Deleted], [OrganisationId], [Name] FROM [Site] " + whereClause + orderByClause + pageClause, withArgumentsInArray: whereValues)
            if (resultSet != nil) {
                while resultSet.next() {
                    let site : Site = Site()
                    site.RowId = resultSet.stringForColumn("RowId")
                    site.CreatedBy = resultSet.stringForColumn("CreatedBy")
                    site.CreatedOn = resultSet.dateForColumn("CreatedOn")
                    if !resultSet.columnIsNull("LastUpdatedBy")
                    {
                        site.LastUpdatedBy = resultSet.stringForColumn("LastUpdatedBy")
                    }
                    if !resultSet.columnIsNull("LastUpdatedOn")
                    {
                        site.LastUpdatedOn = resultSet.dateForColumn("LastUpdatedOn")
                    }
                    if !resultSet.columnIsNull("Deleted")
                    {
                        site.Deleted = resultSet.dateForColumn("Deleted")
                    }
                    site.OrganisationId = resultSet.stringForColumn("OrganisationId")
                    site.Name = resultSet.stringForColumn("Name")
                    
                    siteList.append(site)
                }
            }
        }
        
        sharedModelManager.database!.close()
        return (siteList, count)
    }
    
    // MARK: - Task
    
    func addTask(task: Task) -> Bool {
        //build the sql statemnt
        var SQLStatement: String = String()
        var SQLParameterNames: String = String()
        var SQLParameterPlaceholders: String = String()
        var SQLParameterValues: [NSObject] = [NSObject]()
        
        SQLParameterNames = "[RowId], [CreatedBy], [CreatedOn]"
        SQLParameterPlaceholders = "?, ?, ?"
        SQLParameterValues.append(task.RowId)
        SQLParameterValues.append(task.CreatedBy)
        SQLParameterValues.append(task.CreatedOn)
        
        if task.LastUpdatedBy != nil {
            SQLParameterNames += ", [LastUpdatedBy]"
            SQLParameterPlaceholders += ", ?"
            SQLParameterValues.append(task.LastUpdatedBy!)
        }
        
        if task.LastUpdatedOn != nil {
            SQLParameterNames += ", [LastUpdatedOn]"
            SQLParameterPlaceholders += ", ?"
            SQLParameterValues.append(task.LastUpdatedOn!)
        }
        
        if task.Deleted != nil {
            SQLParameterNames += ", [Deleted]"
            SQLParameterPlaceholders += ", ?"
            SQLParameterValues.append(task.Deleted!)
        }
        SQLParameterNames += ", [OrganisationId]"
        SQLParameterPlaceholders += ", ?"
        SQLParameterValues.append(task.OrganisationId)
        SQLParameterNames += ", [SiteId]"
        SQLParameterPlaceholders += ", ?"
        SQLParameterValues.append(task.SiteId)
        SQLParameterNames += ", [PropertyId]"
        SQLParameterPlaceholders += ", ?"
        SQLParameterValues.append(task.PropertyId)
        SQLParameterNames += ", [LocationId]"
        SQLParameterPlaceholders += ", ?"
        SQLParameterValues.append(task.LocationId)
        SQLParameterNames += ", [LocationGroupName]"
        SQLParameterPlaceholders += ", ?"
        SQLParameterValues.append(task.LocationGroupName)
        SQLParameterNames += ", [LocationName]"
        SQLParameterPlaceholders += ", ?"
        SQLParameterValues.append(task.LocationName)
        if task.Room != nil {
            SQLParameterNames += ", [Room]"
            SQLParameterPlaceholders += ", ?"
            SQLParameterValues.append(task.Room!)
        }
        if task.TaskTemplateId != nil {
            SQLParameterNames += ", [TaskTemplateId]"
            SQLParameterPlaceholders += ", ?"
            SQLParameterValues.append(task.TaskTemplateId!)
        }
        SQLParameterNames += ", [TaskRef]"
        SQLParameterPlaceholders += ", ?"
        SQLParameterValues.append(task.TaskRef)
        if task.PPMGroup != nil {
            SQLParameterNames += ", [PPMGroup]"
            SQLParameterPlaceholders += ", ?"
            SQLParameterValues.append(task.PPMGroup!)
        }
        if task.AssetType != nil {
            SQLParameterNames += ", [AssetType]"
            SQLParameterPlaceholders += ", ?"
            SQLParameterValues.append(task.AssetType!)
        }
        SQLParameterNames += ", [TaskName]"
        SQLParameterPlaceholders += ", ?"
        SQLParameterValues.append(task.TaskName)
        SQLParameterNames += ", [Frequency]"
        SQLParameterPlaceholders += ", ?"
        SQLParameterValues.append(task.Frequency)
        if task.AssetId != nil {
            SQLParameterNames += ", [AssetId]"
            SQLParameterPlaceholders += ", ?"
            SQLParameterValues.append(task.AssetId!)
        }
        if task.AssetNumber != nil {
            SQLParameterNames += ", [AssetNumber]"
            SQLParameterPlaceholders += ", ?"
            SQLParameterValues.append(task.AssetNumber!)
        }
        SQLParameterNames += ", [ScheduledDate]"
        SQLParameterPlaceholders += ", ?"
        SQLParameterValues.append(task.ScheduledDate)
        if task.CompletedDate != nil {
            SQLParameterNames += ", [CompletedDate]"
            SQLParameterPlaceholders += ", ?"
            SQLParameterValues.append(task.CompletedDate!)
        }
        SQLParameterNames += ", [Status]"
        SQLParameterPlaceholders += ", ?"
        SQLParameterValues.append(task.Status)
        SQLParameterNames += ", [Priority]"
        SQLParameterPlaceholders += ", ?"
        SQLParameterValues.append(task.Priority)
        if task.EstimatedDuration != nil {
            SQLParameterNames += ", [EstimatedDuration]"
            SQLParameterPlaceholders += ", ?"
            SQLParameterValues.append(task.EstimatedDuration!)
        }
        if task.OperativeId != nil {
            SQLParameterNames += ", [OperativeId]"
            SQLParameterPlaceholders += ", ?"
            SQLParameterValues.append(task.OperativeId!)
        }
        if task.ActualDuration != nil {
            SQLParameterNames += ", [ActualDuration]"
            SQLParameterPlaceholders += ", ?"
            SQLParameterValues.append(task.ActualDuration!)
        }
        if task.TravelDuration != nil {
            SQLParameterNames += ", [TravelDuration]"
            SQLParameterPlaceholders += ", ?"
            SQLParameterValues.append(task.TravelDuration!)
        }
        if task.Comments != nil {
            SQLParameterNames += ", [Comments]"
            SQLParameterPlaceholders += ", ?"
            SQLParameterValues.append(task.Comments!)
        }
        if task.AlternateAssetCode != nil {
            SQLParameterNames += ", [AlternateAssetCode]"
            SQLParameterPlaceholders += ", ?"
            SQLParameterValues.append(task.AlternateAssetCode!)
        }
        
        
        SQLStatement = "INSERT INTO [Task] (" + SQLParameterNames + ") VALUES (" + SQLParameterPlaceholders + ")"
        
        sharedModelManager.database!.open()
        let isInserted = sharedModelManager.database!.executeUpdate(SQLStatement, withArgumentsInArray: SQLParameterValues)
        sharedModelManager.database!.close()
        return isInserted
    }
    
    func updateTask(task: Task) -> Bool {
        //build the sql statemnt
        var SQLStatement: String = String()
        var SQLParameterNames: String = String()
        var SQLParameterValues: [NSObject] = [NSObject]()
        
        SQLParameterNames = "[CreatedBy]=?, [CreatedOn]=?"
        SQLParameterValues.append(task.CreatedBy)
        SQLParameterValues.append(task.CreatedOn)
        
        if task.LastUpdatedBy != nil {
            SQLParameterNames += ", [LastUpdatedBy]=?"
            SQLParameterValues.append(task.LastUpdatedBy!)
        }
        
        if task.LastUpdatedOn != nil {
            SQLParameterNames += ", [LastUpdatedOn]=?"
            SQLParameterValues.append(task.LastUpdatedOn!)
        }
        
        if task.Deleted != nil {
            SQLParameterNames += ", [Deleted]=?"
            SQLParameterValues.append(task.Deleted!)
        }
        
        SQLParameterNames += ", [OrganisationId]=?"
        SQLParameterValues.append(task.OrganisationId)
        SQLParameterNames += ", [SiteId]=?"
        SQLParameterValues.append(task.SiteId)
        SQLParameterNames += ", [PropertyId]=?"
        SQLParameterValues.append(task.PropertyId)
        SQLParameterNames += ", [LocationId]=?"
        SQLParameterValues.append(task.LocationId)
        SQLParameterNames += ", [LocationGroupName]=?"
        SQLParameterValues.append(task.LocationGroupName)
        SQLParameterNames += ", [LocationName]=?"
        SQLParameterValues.append(task.LocationName)
        if task.Room != nil {
            SQLParameterNames += ", [Room]=?"
            SQLParameterValues.append(task.Room!)
        }
        if task.TaskTemplateId != nil {
            SQLParameterNames += ", [TaskTemplateId]=?"
            SQLParameterValues.append(task.TaskTemplateId!)
        }
        SQLParameterNames += ", [TaskRef]=?"
        SQLParameterValues.append(task.TaskRef)
        if task.PPMGroup != nil {
            SQLParameterNames += ", [PPMGroup]=?"
            SQLParameterValues.append(task.PPMGroup!)
        }
        if task.AssetType != nil {
            SQLParameterNames += ", [AssetType]=?"
            SQLParameterValues.append(task.AssetType!)
        }
        SQLParameterNames += ", [TaskName]=?"
        SQLParameterValues.append(task.TaskName)
        SQLParameterNames += ", [Frequency]=?"
        SQLParameterValues.append(task.Frequency)
        if task.AssetId != nil {
            SQLParameterNames += ", [AssetId]=?"
            SQLParameterValues.append(task.AssetId!)
        }
        if task.AssetNumber != nil {
            SQLParameterNames += ", [AssetNumber]=?"
            SQLParameterValues.append(task.AssetNumber!)
        }
        SQLParameterNames += ", [ScheduledDate]=?"
        SQLParameterValues.append(task.ScheduledDate)
        if task.CompletedDate != nil {
            SQLParameterNames += ", [CompletedDate]=?"
            SQLParameterValues.append(task.CompletedDate!)
        }
        SQLParameterNames += ", [Status]=?"
        SQLParameterValues.append(task.Status)
        SQLParameterNames += ", [Priority]=?"
        SQLParameterValues.append(task.Priority)
        if task.EstimatedDuration != nil {
            SQLParameterNames += ", [EstimatedDuration]=?"
            SQLParameterValues.append(task.EstimatedDuration!)
        }
        if task.OperativeId != nil {
            SQLParameterNames += ", [OperativeId]=?"
            SQLParameterValues.append(task.OperativeId!)
        }
        if task.ActualDuration != nil {
            SQLParameterNames += ", [ActualDuration]=?"
            SQLParameterValues.append(task.ActualDuration!)
        }
        if task.TravelDuration != nil {
            SQLParameterNames += ", [TravelDuration]=?"
            SQLParameterValues.append(task.TravelDuration!)
        }
        if task.Comments != nil {
            SQLParameterNames += ", [Comments]=?"
            SQLParameterValues.append(task.Comments!)
        }
        if task.AlternateAssetCode != nil {
            SQLParameterNames += ", [AlternateAssetCode]=?"
            SQLParameterValues.append(task.AlternateAssetCode!)
        }
        
        
        SQLParameterValues.append(task.RowId)
        
        SQLStatement = "UPDATE [Task] SET " + SQLParameterNames + "WHERE [RowId]=?"
        
        sharedModelManager.database!.open()
        let isUpdated = sharedModelManager.database!.executeUpdate(SQLStatement, withArgumentsInArray: SQLParameterValues)
        sharedModelManager.database!.close()
        return isUpdated
    }
    
    func deleteTask(task: Task) -> Bool {
        sharedModelManager.database!.open()
        let isDeleted = sharedModelManager.database!.executeUpdate("DELETE FROM [Task] WHERE [RowId]=?", withArgumentsInArray: [task.RowId])
        sharedModelManager.database!.close()
        return isDeleted
    }
    
    func getTask(taskId: String) -> Task? {
        sharedModelManager.database!.open()
        var task: Task? = nil
        
        let resultSet = sharedModelManager.database!.executeQuery("SELECT [RowId], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [Deleted], [OrganisationId], [SiteId], [PropertyId], [LocationId], [LocationGroupName], [LocationName], [Room], [TaskTemplateId], [TaskRef], [PPMGroup], [AssetType], [TaskName], [Frequency], [AssetId], [AssetNumber], [ScheduledDate], [CompletedDate], [Status], [Priority], [EstimatedDuration], [OperativeId], [ActualDuration], [TravelDuration], [Comments], [AlternateAssetCode] FROM [Task] WHERE [RowId]=?", withArgumentsInArray: [taskId])
        if (resultSet != nil) {
            while resultSet.next() {
                var resultTask: Task = Task()
                resultTask = Task()
                resultTask.RowId = resultSet.stringForColumn("RowId")
                resultTask.CreatedBy = resultSet.stringForColumn("CreatedBy")
                resultTask.CreatedOn = resultSet.dateForColumn("CreatedOn")
                if !resultSet.columnIsNull("LastUpdatedBy")
                {
                    resultTask.LastUpdatedBy = resultSet.stringForColumn("LastUpdatedBy")
                }
                if !resultSet.columnIsNull("LastUpdatedOn")
                {
                    resultTask.LastUpdatedOn = resultSet.dateForColumn("LastUpdatedOn")
                }
                if !resultSet.columnIsNull("Deleted")
                {
                    resultTask.Deleted = resultSet.dateForColumn("Deleted")
                }
                resultTask.OrganisationId = resultSet.stringForColumn("OrganisationId")
                resultTask.SiteId = resultSet.stringForColumn("SiteId")
                resultTask.PropertyId = resultSet.stringForColumn("PropertyId")
                resultTask.LocationId = resultSet.stringForColumn("LocationId")
                resultTask.LocationGroupName = resultSet.stringForColumn("LocationGroupName")
                resultTask.LocationName = resultSet.stringForColumn("LocationName")
                if !resultSet.columnIsNull("Room") {
                    resultTask.Room = resultSet.stringForColumn("Room")
                }
                if !resultSet.columnIsNull("TaskTemplateId") {
                    resultTask.TaskTemplateId = resultSet.stringForColumn("TaskTemplateId")
                }
                resultTask.TaskRef = resultSet.stringForColumn("TaskRef")
                if !resultSet.columnIsNull("PPMGroup") {
                    resultTask.PPMGroup = resultSet.stringForColumn("PPMGroup")
                }
                if !resultSet.columnIsNull("AssetType") {
                    resultTask.AssetType = resultSet.stringForColumn("AssetType")
                }
                resultTask.TaskName = resultSet.stringForColumn("TaskName")
                resultTask.Frequency = resultSet.stringForColumn("Frequency")
                if !resultSet.columnIsNull("AssetId") {
                    resultTask.AssetId = resultSet.stringForColumn("AssetId")
                }
                if !resultSet.columnIsNull("AssetNumber") {
                    resultTask.AssetNumber = resultSet.stringForColumn("AssetNumber")
                }
                resultTask.ScheduledDate = resultSet.dateForColumn("ScheduledDate")
                if !resultSet.columnIsNull("CompletedDate") {
                    resultTask.CompletedDate = resultSet.dateForColumn("CompletedDate")
                }
                resultTask.Status = resultSet.stringForColumn("Status")
                resultTask.Priority = Int(resultSet.intForColumn("Priority"))
                if !resultSet.columnIsNull("EstimatedDuration") {
                    resultTask.EstimatedDuration = Int(resultSet.intForColumn("EstimatedDuration"))
                }
                if !resultSet.columnIsNull("OperativeId") {
                    resultTask.OperativeId = resultSet.stringForColumn("OperativeId")
                }
                if !resultSet.columnIsNull("ActualDuration") {
                    resultTask.ActualDuration = Int(resultSet.intForColumn("ActualDuration"))
                }
                if !resultSet.columnIsNull("TravelDuration") {
                    resultTask.TravelDuration = Int(resultSet.intForColumn("TravelDuration"))
                }
                if !resultSet.columnIsNull("Comments") {
                    resultTask.Comments = resultSet.stringForColumn("Comments")
                }
                if !resultSet.columnIsNull("AlternateAssetCode") {
                    resultTask.AlternateAssetCode = resultSet.stringForColumn("AlternateAssetCode")
                }
                
                task = resultTask
            }
        }
        sharedModelManager.database!.close()
        return task
    }
    
    func getAllTask() -> [Task] {
        sharedModelManager.database!.open()
        let resultSet: FMResultSet! = sharedModelManager.database!.executeQuery("SELECT [RowId], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [Deleted], [OrganisationId], [SiteId], [PropertyId], [LocationId], [LocationGroupName], [LocationName], [Room], [TaskTemplateId], [TaskRef], [PPMGroup], [AssetType], [TaskName], [Frequency], [AssetId], [AssetNumber], [ScheduledDate], [CompletedDate], [Status], [Priority], [EstimatedDuration], [OperativeId], [ActualDuration], [TravelDuration], [Comments], [AlternateAssetCode] FROM [Task]", withArgumentsInArray: nil)
        var taskList: [Task] = [Task]()
        if (resultSet != nil) {
            while resultSet.next() {
                let task : Task = Task()
                task.RowId = resultSet.stringForColumn("RowId")
                task.CreatedBy = resultSet.stringForColumn("CreatedBy")
                task.CreatedOn = resultSet.dateForColumn("CreatedOn")
                if !resultSet.columnIsNull("LastUpdatedBy")
                {
                    task.LastUpdatedBy = resultSet.stringForColumn("LastUpdatedBy")
                }
                if !resultSet.columnIsNull("LastUpdatedOn")
                {
                    task.LastUpdatedOn = resultSet.dateForColumn("LastUpdatedOn")
                }
                if !resultSet.columnIsNull("Deleted")
                {
                    task.Deleted = resultSet.dateForColumn("Deleted")
                }
                task.OrganisationId = resultSet.stringForColumn("OrganisationId")
                task.SiteId = resultSet.stringForColumn("SiteId")
                task.PropertyId = resultSet.stringForColumn("PropertyId")
                task.LocationId = resultSet.stringForColumn("LocationId")
                task.LocationGroupName = resultSet.stringForColumn("LocationGroupName")
                task.LocationName = resultSet.stringForColumn("LocationName")
                if !resultSet.columnIsNull("Room") {
                    task.Room = resultSet.stringForColumn("Room")
                }
                if !resultSet.columnIsNull("TaskTemplateId") {
                    task.TaskTemplateId = resultSet.stringForColumn("TaskTemplateId")
                }
                task.TaskRef = resultSet.stringForColumn("TaskRef")
                if !resultSet.columnIsNull("PPMGroup") {
                    task.PPMGroup = resultSet.stringForColumn("PPMGroup")
                }
                if !resultSet.columnIsNull("AssetType") {
                    task.AssetType = resultSet.stringForColumn("AssetType")
                }
                task.TaskName = resultSet.stringForColumn("TaskName")
                task.Frequency = resultSet.stringForColumn("Frequency")
                if !resultSet.columnIsNull("AssetId") {
                    task.AssetId = resultSet.stringForColumn("AssetId")
                }
                if !resultSet.columnIsNull("AssetNumber") {
                    task.AssetNumber = resultSet.stringForColumn("AssetNumber")
                }
                task.ScheduledDate = resultSet.dateForColumn("ScheduledDate")
                if !resultSet.columnIsNull("CompletedDate") {
                    task.CompletedDate = resultSet.dateForColumn("CompletedDate")
                }
                task.Status = resultSet.stringForColumn("Status")
                task.Priority = Int(resultSet.intForColumn("Priority"))
                if !resultSet.columnIsNull("EstimatedDuration") {
                    task.EstimatedDuration = Int(resultSet.intForColumn("EstimatedDuration"))
                }
                if !resultSet.columnIsNull("OperativeId") {
                    task.OperativeId = resultSet.stringForColumn("OperativeId")
                }
                if !resultSet.columnIsNull("ActualDuration") {
                    task.ActualDuration = Int(resultSet.intForColumn("ActualDuration"))
                }
                if !resultSet.columnIsNull("TravelDuration") {
                    task.TravelDuration = Int(resultSet.intForColumn("TravelDuration"))
                }
                if !resultSet.columnIsNull("Comments") {
                    task.Comments = resultSet.stringForColumn("Comments")
                }
                if !resultSet.columnIsNull("AlternateAssetCode") {
                    task.AlternateAssetCode = resultSet.stringForColumn("AlternateAssetCode")
                }
                
                taskList.append(task)
            }
        }
        sharedModelManager.database!.close()
        return taskList
    }
    
    func findTaskList(criteria: Dictionary<String, AnyObject>, onlyPending: Bool) -> [Task] {
        var list: [Task] = [Task]()
        //var count: Int32 = 0
        (list, _) = findTaskList(criteria, onlyPending: true, pageSize: nil, pageNumber: nil, sortOrder: TaskSortOrder.Date)
        return list
    }

    func findTaskList(criteria: Dictionary<String, AnyObject>, onlyPending: Bool, pageSize: Int32?, pageNumber: Int32?) -> (List: [Task], Count: Int32) {
        var list: [Task] = [Task]()
        var count: Int32 = 0
        (list, count) = findTaskList(criteria, onlyPending: true, pageSize: nil, pageNumber: nil, sortOrder: TaskSortOrder.Date)
        return (list, count)
    }          
    func findTaskList(criteria: Dictionary<String, AnyObject>, onlyPending: Bool, pageSize: Int32?, pageNumber: Int32?, sortOrder: TaskSortOrder) -> (List: [Task], Count: Int32) {
       //return variables
        var count: Int32 = 0
        var taskList: [Task] = [Task]()
        
        //build the order clause
        var orderByClause: String = " ORDER BY "
        
        switch sortOrder {
            
        case .Date: 
            orderByClause += "[ScheduledDate] "
            
        case .Location:
            orderByClause += "[LocationName] "
            
        case .AssetType:
            orderByClause += "[PPMGroup] "
           
        case .Task:
            orderByClause += "[TaskName] "
            
        }
        
        var whereCriteria: Dictionary<String, AnyObject> = criteria
        
        whereCriteria["Period"] = nil  //remove the period criteria
        whereCriteria["Status"] = nil
        
        //build the where clause
        var whereClause: String = String()
        var whereValues: [AnyObject] = [AnyObject]()
        
        (whereClause, whereValues) = buildWhereClause(whereCriteria)

        
        if (criteria.keys.contains("Period"))
        {
            switch criteria["Period"] as! String
            {
            case DueTodayText:
                 
                let endOfToday: NSDate = NSDate().endOfDay()
                
                whereClause += (whereClause != "" ? " AND " : " ")
                whereClause += " [ScheduledDate] <= ? "
                whereValues.append(endOfToday)
                
            case DueNext7DaysText:
                
                let endOfThisWeek: NSDate = NSDate().endOfWeek()
            
                whereClause += (whereClause != "" ? " AND " : " ")
                whereClause += " [ScheduledDate] <= ? "
                whereValues.append(endOfThisWeek)
                
            case DueCalendarMonthText:
                
                let endOfThisMonth: NSDate = NSDate().endOfMonth()
                
                whereClause += (whereClause != "" ? " AND " : " ")
                whereClause += " [ScheduledDate] <= ? "
                whereValues.append(endOfThisMonth)
                
            case DueThisMonthText:
  
                let startOfNextMonth: NSDate = NSDate().startOfNextMonth()
                let endOfNextMonth: NSDate = NSDate().endOfNextMonth()
                whereClause += (whereClause != "" ? " AND " : " ")
                whereClause += " [ScheduledDate] >= ? AND [ScheduledDate] <= ? "
                whereValues.append(startOfNextMonth)
                whereValues.append(endOfNextMonth)
                
            case "All":
                //nothing to do
                print("Catch All")
            
            default:
                //nothing to do
                print("Default")
                
            }
        }
        
        var whereClausePredicate: String = String()
        if (onlyPending)
        {
            whereClausePredicate = "WHERE [Status] IN ('Pending','Outstanding') AND "
        }
        else
        {
            whereClausePredicate = "WHERE [Status] IN ('Complete') AND "
        }
        
        if (whereClause != "")
        {
            whereClause = whereClausePredicate + whereClause
        }
         
        if (!whereClause.containsString("OperativeId"))
        {
            whereClause += " AND (OperativeId IS NULL OR OperativeId = '00000000-0000-0000-0000-000000000000' OR OperativeId = '" + Session.OperativeId! + "')"
        }
        
        sharedModelManager.database!.open()
        let countSet: FMResultSet! = sharedModelManager.database!.executeQuery("SELECT COUNT([RowId]) FROM [Task] " + whereClause + orderByClause, withArgumentsInArray: whereValues)
        if (countSet != nil) {
            while countSet.next() {
                count = countSet.intForColumnIndex(0)
            }
        }
        
        if (count > 0)
        {
            var pageClause: String = String()
            if (pageSize != nil && pageNumber != nil)
            {
                pageClause = " LIMIT " + String(pageSize!) + " OFFSET " + String((pageNumber! - 1) * pageSize!)
            }
            
            let resultSet: FMResultSet! = sharedModelManager.database!.executeQuery("SELECT [RowId], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [Deleted], [OrganisationId], [SiteId], [PropertyId], [LocationId], [LocationGroupName], [LocationName], [Room], [TaskTemplateId], [TaskRef], [PPMGroup], [AssetType], [TaskName], [Frequency], [AssetId], [AssetNumber], [ScheduledDate], [CompletedDate], [Status], [Priority], [EstimatedDuration], [OperativeId], [ActualDuration], [TravelDuration], [Comments], [AlternateAssetCode] FROM [Task] " + whereClause  + orderByClause + pageClause, withArgumentsInArray: whereValues)
            if (resultSet != nil) {
                while resultSet.next() {
                    let task : Task = Task()
                    task.RowId = resultSet.stringForColumn("RowId")
                    task.CreatedBy = resultSet.stringForColumn("CreatedBy")
                    task.CreatedOn = resultSet.dateForColumn("CreatedOn")
                    if !resultSet.columnIsNull("LastUpdatedBy")
                    {
                        task.LastUpdatedBy = resultSet.stringForColumn("LastUpdatedBy")
                    }
                    if !resultSet.columnIsNull("LastUpdatedOn")
                    {
                        task.LastUpdatedOn = resultSet.dateForColumn("LastUpdatedOn")
                    }
                    if !resultSet.columnIsNull("Deleted")
                    {
                        task.Deleted = resultSet.dateForColumn("Deleted")
                    }
                    task.OrganisationId = resultSet.stringForColumn("OrganisationId")
                    task.SiteId = resultSet.stringForColumn("SiteId")
                    task.PropertyId = resultSet.stringForColumn("PropertyId")
                    task.LocationId = resultSet.stringForColumn("LocationId")
                    task.LocationGroupName = resultSet.stringForColumn("LocationGroupName")
                    task.LocationName = resultSet.stringForColumn("LocationName")
                    if !resultSet.columnIsNull("Room") {
                        task.Room = resultSet.stringForColumn("Room")
                    }
                    if !resultSet.columnIsNull("TaskTemplateId") {
                        task.TaskTemplateId = resultSet.stringForColumn("TaskTemplateId")
                    }
                    task.TaskRef = resultSet.stringForColumn("TaskRef")
                    if !resultSet.columnIsNull("PPMGroup") {
                        task.PPMGroup = resultSet.stringForColumn("PPMGroup")
                    }
                    if !resultSet.columnIsNull("AssetType") {
                        task.AssetType = resultSet.stringForColumn("AssetType")
                    }
                    task.TaskName = resultSet.stringForColumn("TaskName")
                    task.Frequency = resultSet.stringForColumn("Frequency")
                    if !resultSet.columnIsNull("AssetId") {
                        task.AssetId = resultSet.stringForColumn("AssetId")
                    }
                    if !resultSet.columnIsNull("AssetNumber") {
                        task.AssetNumber = resultSet.stringForColumn("AssetNumber")
                    }
                    task.ScheduledDate = resultSet.dateForColumn("ScheduledDate")
                    if !resultSet.columnIsNull("CompletedDate") {
                        task.CompletedDate = resultSet.dateForColumn("CompletedDate")
                    }
                    task.Status = resultSet.stringForColumn("Status")
                    task.Priority = Int(resultSet.intForColumn("Priority"))
                    if !resultSet.columnIsNull("EstimatedDuration") {
                        task.EstimatedDuration = Int(resultSet.intForColumn("EstimatedDuration"))
                    }
                    if !resultSet.columnIsNull("OperativeId") {
                        task.OperativeId = resultSet.stringForColumn("OperativeId")
                    }
                    if !resultSet.columnIsNull("ActualDuration") {
                        task.ActualDuration = Int(resultSet.intForColumn("ActualDuration"))
                    }
                    if !resultSet.columnIsNull("TravelDuration") {
                        task.TravelDuration = Int(resultSet.intForColumn("TravelDuration"))
                    }
                    if !resultSet.columnIsNull("Comments") {
                        task.Comments = resultSet.stringForColumn("Comments")
                    }
                    if !resultSet.columnIsNull("AlternateAssetCode") {
                        task.AlternateAssetCode = resultSet.stringForColumn("AlternateAssetCode")
                    }
                    
                    taskList.append(task)
                }
            }
        }
        
        sharedModelManager.database!.close()
        return (taskList, count)
    }
    
    // MARK: - TaskParameter
    
    func addTaskParameter(taskParameter: TaskParameter) -> Bool {
        //build the sql statemnt
        var SQLStatement: String = String()
        var SQLParameterNames: String = String()
        var SQLParameterPlaceholders: String = String()
        var SQLParameterValues: [NSObject] = [NSObject]()
        
        SQLParameterNames = "[RowId], [CreatedBy], [CreatedOn]"
        SQLParameterPlaceholders = "?, ?, ?"
        SQLParameterValues.append(taskParameter.RowId)
        SQLParameterValues.append(taskParameter.CreatedBy)
        SQLParameterValues.append(taskParameter.CreatedOn)
        
        if taskParameter.LastUpdatedBy != nil {
            SQLParameterNames += ", [LastUpdatedBy]"
            SQLParameterPlaceholders += ", ?"
            SQLParameterValues.append(taskParameter.LastUpdatedBy!)
        }
        
        if taskParameter.LastUpdatedOn != nil {
            SQLParameterNames += ", [LastUpdatedOn]"
            SQLParameterPlaceholders += ", ?"
            SQLParameterValues.append(taskParameter.LastUpdatedOn!)
        }
        
        if taskParameter.Deleted != nil {
            SQLParameterNames += ", [Deleted]"
            SQLParameterPlaceholders += ", ?"
            SQLParameterValues.append(taskParameter.Deleted!)
        }
        
        if taskParameter.TaskTemplateParameterId != nil {
            SQLParameterNames += ", [TaskTemplateParameterId]"
            SQLParameterPlaceholders += ", ?"
            SQLParameterValues.append(taskParameter.TaskTemplateParameterId!)
        }
        SQLParameterNames += ", [TaskId]"
        SQLParameterPlaceholders += ", ?"
        SQLParameterValues.append(taskParameter.TaskId)
        SQLParameterNames += ", [ParameterName]"
        SQLParameterPlaceholders += ", ?"
        SQLParameterValues.append(taskParameter.ParameterName)
        SQLParameterNames += ", [ParameterType]"
        SQLParameterPlaceholders += ", ?"
        SQLParameterValues.append(taskParameter.ParameterType)
        SQLParameterNames += ", [ParameterDisplay]"
        SQLParameterPlaceholders += ", ?"
        SQLParameterValues.append(taskParameter.ParameterDisplay)
        SQLParameterNames += ", [Collect]"
        SQLParameterPlaceholders += ", ?"
        SQLParameterValues.append(taskParameter.Collect)
        SQLParameterNames += ", [ParameterValue]"
        SQLParameterPlaceholders += ", ?"
        SQLParameterValues.append(taskParameter.ParameterValue)
        
        SQLStatement = "INSERT INTO [TaskParameter] (" + SQLParameterNames + ") VALUES (" + SQLParameterPlaceholders + ")"
        
        sharedModelManager.database!.open()
        let isInserted = sharedModelManager.database!.executeUpdate(SQLStatement, withArgumentsInArray: SQLParameterValues)
        sharedModelManager.database!.close()
        return isInserted
    }
    
    func updateTaskParameter(taskParameter: TaskParameter) -> Bool {
        //build the sql statemnt
        var SQLStatement: String = String()
        var SQLParameterNames: String = String()
        var SQLParameterValues: [NSObject] = [NSObject]()
        
        SQLParameterNames = "[CreatedBy]=?, [CreatedOn]=?"
        SQLParameterValues.append(taskParameter.CreatedBy)
        SQLParameterValues.append(taskParameter.CreatedOn)
        
        if taskParameter.LastUpdatedBy != nil {
            SQLParameterNames += ", [LastUpdatedBy]=?"
            SQLParameterValues.append(taskParameter.LastUpdatedBy!)
        }
        
        if taskParameter.LastUpdatedOn != nil {
            SQLParameterNames += ", [LastUpdatedOn]=?"
            SQLParameterValues.append(taskParameter.LastUpdatedOn!)
        }
        
        if taskParameter.Deleted != nil {
            SQLParameterNames += ", [Deleted]=?"
            SQLParameterValues.append(taskParameter.Deleted!)
        }
        
        if taskParameter.TaskTemplateParameterId != nil {
            SQLParameterNames += ", [TaskTemplateParameterId]=?"
            SQLParameterValues.append(taskParameter.TaskTemplateParameterId!)
        }
        SQLParameterNames += ", [TaskId]=?"
        SQLParameterValues.append(taskParameter.TaskId)
        SQLParameterNames += ", [ParameterName]=?"
        SQLParameterValues.append(taskParameter.ParameterName)
        SQLParameterNames += ", [ParameterType]=?"
        SQLParameterValues.append(taskParameter.ParameterType)
        SQLParameterNames += ", [ParameterDisplay]=?"
        SQLParameterValues.append(taskParameter.ParameterDisplay)
        SQLParameterNames += ", [Collect]=?"
        SQLParameterValues.append(taskParameter.Collect)
        SQLParameterNames += ", [ParameterValue]=?"
        SQLParameterValues.append(taskParameter.ParameterValue)
        
        SQLParameterValues.append(taskParameter.RowId)
        
        SQLStatement = "UPDATE [TaskParameter] SET " + SQLParameterNames + "WHERE [RowId]=?"
        
        sharedModelManager.database!.open()
        let isUpdated = sharedModelManager.database!.executeUpdate(SQLStatement, withArgumentsInArray: SQLParameterValues)
        sharedModelManager.database!.close()
        return isUpdated
    }
    
    func deleteTaskParameter(taskParameter: TaskParameter) -> Bool {
        sharedModelManager.database!.open()
        let isDeleted = sharedModelManager.database!.executeUpdate("DELETE FROM [TaskParameter] WHERE [RowId]=?", withArgumentsInArray: [taskParameter.RowId])
        sharedModelManager.database!.close()
        return isDeleted
    }
    
    func getTaskParameter(taskParameterId: String) -> TaskParameter? {
        sharedModelManager.database!.open()
        var taskParameter: TaskParameter? = nil
        
        let resultSet = sharedModelManager.database!.executeQuery("SELECT [RowId], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [Deleted], [TaskTemplateParameterId], [TaskId], [ParameterName], [ParameterType], [ParameterDisplay], [Collect], [ParameterValue] FROM [TaskParameter] WHERE [RowId]=?", withArgumentsInArray: [taskParameterId])
        if (resultSet != nil) {
            while resultSet.next() {
                var resultTaskParameter: TaskParameter = TaskParameter()
                resultTaskParameter = TaskParameter()
                resultTaskParameter.RowId = resultSet.stringForColumn("RowId")
                resultTaskParameter.CreatedBy = resultSet.stringForColumn("CreatedBy")
                resultTaskParameter.CreatedOn = resultSet.dateForColumn("CreatedOn")
                if !resultSet.columnIsNull("LastUpdatedBy")
                {
                    resultTaskParameter.LastUpdatedBy = resultSet.stringForColumn("LastUpdatedBy")
                }
                if !resultSet.columnIsNull("LastUpdatedOn")
                {
                    resultTaskParameter.LastUpdatedOn = resultSet.dateForColumn("LastUpdatedOn")
                }
                if !resultSet.columnIsNull("Deleted")
                {
                    resultTaskParameter.Deleted = resultSet.dateForColumn("Deleted")
                }
                if !resultSet.columnIsNull("TaskTemplateParameterId") {
                    resultTaskParameter.TaskTemplateParameterId = resultSet.stringForColumn("TaskTemplateParameterId")
                }
                resultTaskParameter.TaskId = resultSet.stringForColumn("TaskId")
                resultTaskParameter.ParameterName = resultSet.stringForColumn("ParameterName")
                resultTaskParameter.ParameterType = resultSet.stringForColumn("ParameterType")
                resultTaskParameter.ParameterDisplay = resultSet.stringForColumn("ParameterDisplay")
                resultTaskParameter.Collect = resultSet.boolForColumn("Collect")
                resultTaskParameter.ParameterValue = resultSet.stringForColumn("ParameterValue")
                
                taskParameter = resultTaskParameter
            }
        }
        sharedModelManager.database!.close()
        return taskParameter
    }
    
    func getAllTaskParameter() -> [TaskParameter] {
        sharedModelManager.database!.open()
        let resultSet: FMResultSet! = sharedModelManager.database!.executeQuery("SELECT [RowId], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [Deleted], [TaskTemplateParameterId], [TaskId], [ParameterName], [ParameterType], [ParameterDisplay], [Collect], [ParameterValue] FROM [TaskParameter]", withArgumentsInArray: nil)
        var taskParameterList: [TaskParameter] = [TaskParameter]()
        if (resultSet != nil) {
            while resultSet.next() {
                let taskParameter : TaskParameter = TaskParameter()
                taskParameter.RowId = resultSet.stringForColumn("RowId")
                taskParameter.CreatedBy = resultSet.stringForColumn("CreatedBy")
                taskParameter.CreatedOn = resultSet.dateForColumn("CreatedOn")
                if !resultSet.columnIsNull("LastUpdatedBy")
                {
                    taskParameter.LastUpdatedBy = resultSet.stringForColumn("LastUpdatedBy")
                }
                if !resultSet.columnIsNull("LastUpdatedOn")
                {
                    taskParameter.LastUpdatedOn = resultSet.dateForColumn("LastUpdatedOn")
                }
                if !resultSet.columnIsNull("Deleted")
                {
                    taskParameter.Deleted = resultSet.dateForColumn("Deleted")
                }
                if !resultSet.columnIsNull("TaskTemplateParameterId") {
                    taskParameter.TaskTemplateParameterId = resultSet.stringForColumn("TaskTemplateParameterId")
                }
                taskParameter.TaskId = resultSet.stringForColumn("TaskId")
                taskParameter.ParameterName = resultSet.stringForColumn("ParameterName")
                taskParameter.ParameterType = resultSet.stringForColumn("ParameterType")
                taskParameter.ParameterDisplay = resultSet.stringForColumn("ParameterDisplay")
                taskParameter.Collect = resultSet.boolForColumn("Collect")
                taskParameter.ParameterValue = resultSet.stringForColumn("ParameterValue")
                
                taskParameterList.append(taskParameter)
            }
        }
        sharedModelManager.database!.close()
        return taskParameterList
    }
    
    func findTaskParameterList(criteria: Dictionary<String, AnyObject>) -> [TaskParameter] {
        var list: [TaskParameter] = [TaskParameter]()
        //var count: Int32 = 0
        (list, _) = findTaskParameterList(criteria, pageSize: nil, pageNumber: nil)
        return list
    }

    func findTaskParameterList(criteria: Dictionary<String, AnyObject>, pageSize: Int32?, pageNumber: Int32?) -> (List: [TaskParameter], Count: Int32) {
        //return variables
        var count: Int32 = 0
        var taskParameterList: [TaskParameter] = [TaskParameter]()
        
        //build the order clause
        let orderByClause: String = " ORDER BY [CreatedOn]"
        
        //build the where clause
        var whereClause: String = String()
        var whereValues: [AnyObject] = [AnyObject]()
        
        (whereClause, whereValues) = buildWhereClause(criteria)
        
        if (whereClause != "")
        {
            whereClause = "WHERE " + whereClause
        }

        sharedModelManager.database!.open()
        let countSet: FMResultSet! = sharedModelManager.database!.executeQuery("SELECT COUNT([RowId]) FROM [TaskParameter] " + whereClause + orderByClause, withArgumentsInArray: whereValues)
        if (countSet != nil) {
            while countSet.next() {
                count = countSet.intForColumnIndex(0)
            }
        }
        
        if (count > 0)
        {
            var pageClause: String = String()
            if (pageSize != nil && pageNumber != nil)
            {
                pageClause = " LIMIT " + String(pageSize!) + " OFFSET " + String((pageNumber! - 1) * pageSize!)
            }
            
            let resultSet: FMResultSet! = sharedModelManager.database!.executeQuery("SELECT [RowId], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [Deleted], [TaskTemplateParameterId], [TaskId], [ParameterName], [ParameterType], [ParameterDisplay], [Collect], [ParameterValue] FROM [TaskParameter] " + whereClause + orderByClause + pageClause, withArgumentsInArray: whereValues)
            if (resultSet != nil) {
                while resultSet.next() {
                    let taskParameter : TaskParameter = TaskParameter()
                    taskParameter.RowId = resultSet.stringForColumn("RowId")
                    taskParameter.CreatedBy = resultSet.stringForColumn("CreatedBy")
                    taskParameter.CreatedOn = resultSet.dateForColumn("CreatedOn")
                    if !resultSet.columnIsNull("LastUpdatedBy")
                    {
                        taskParameter.LastUpdatedBy = resultSet.stringForColumn("LastUpdatedBy")
                    }
                    if !resultSet.columnIsNull("LastUpdatedOn")
                    {
                        taskParameter.LastUpdatedOn = resultSet.dateForColumn("LastUpdatedOn")
                    }
                    if !resultSet.columnIsNull("Deleted")
                    {
                        taskParameter.Deleted = resultSet.dateForColumn("Deleted")
                    }
                    if !resultSet.columnIsNull("TaskTemplateParameterId") {
                        taskParameter.TaskTemplateParameterId = resultSet.stringForColumn("TaskTemplateParameterId")
                    }
                    taskParameter.TaskId = resultSet.stringForColumn("TaskId")
                    taskParameter.ParameterName = resultSet.stringForColumn("ParameterName")
                    taskParameter.ParameterType = resultSet.stringForColumn("ParameterType")
                    taskParameter.ParameterDisplay = resultSet.stringForColumn("ParameterDisplay")
                    taskParameter.Collect = resultSet.boolForColumn("Collect")
                    taskParameter.ParameterValue = resultSet.stringForColumn("ParameterValue")
                    
                    taskParameterList.append(taskParameter)
                }
            }
        }
        
        sharedModelManager.database!.close()
        return (taskParameterList, count)
    }
    
    // MARK: - TaskTemplate
    
    func addTaskTemplate(taskTemplate: TaskTemplate) -> Bool {
        //build the sql statemnt
        var SQLStatement: String = String()
        var SQLParameterNames: String = String()
        var SQLParameterPlaceholders: String = String()
        var SQLParameterValues: [NSObject] = [NSObject]()
        
        SQLParameterNames = "[RowId], [CreatedBy], [CreatedOn]"
        SQLParameterPlaceholders = "?, ?, ?"
        SQLParameterValues.append(taskTemplate.RowId)
        SQLParameterValues.append(taskTemplate.CreatedBy)
        SQLParameterValues.append(taskTemplate.CreatedOn)
        
        if taskTemplate.LastUpdatedBy != nil {
            SQLParameterNames += ", [LastUpdatedBy]"
            SQLParameterPlaceholders += ", ?"
            SQLParameterValues.append(taskTemplate.LastUpdatedBy!)
        }
        
        if taskTemplate.LastUpdatedOn != nil {
            SQLParameterNames += ", [LastUpdatedOn]"
            SQLParameterPlaceholders += ", ?"
            SQLParameterValues.append(taskTemplate.LastUpdatedOn!)
        }
        
        if taskTemplate.Deleted != nil {
            SQLParameterNames += ", [Deleted]"
            SQLParameterPlaceholders += ", ?"
            SQLParameterValues.append(taskTemplate.Deleted!)
        }
        
        SQLParameterNames += ", [OrganisationId]"
        SQLParameterPlaceholders += ", ?"
        SQLParameterValues.append(taskTemplate.OrganisationId)
        SQLParameterNames += ", [AssetType]"
        SQLParameterPlaceholders += ", ?"
        SQLParameterValues.append(taskTemplate.AssetType)
        SQLParameterNames += ", [TaskName]"
        SQLParameterPlaceholders += ", ?"
        SQLParameterValues.append(taskTemplate.TaskName)
        SQLParameterNames += ", [Priority]"
        SQLParameterPlaceholders += ", ?"
        SQLParameterValues.append(taskTemplate.Priority)
        SQLParameterNames += ", [EstimatedDuration]"
        SQLParameterPlaceholders += ", ?"
        SQLParameterValues.append(taskTemplate.EstimatedDuration)
        
        SQLStatement = "INSERT INTO [TaskTemplate] (" + SQLParameterNames + ") VALUES (" + SQLParameterPlaceholders + ")"
        
        sharedModelManager.database!.open()
        let isInserted = sharedModelManager.database!.executeUpdate(SQLStatement, withArgumentsInArray: SQLParameterValues)
        sharedModelManager.database!.close()
        return isInserted
    }
    
    func updateTaskTemplate(taskTemplate: TaskTemplate) -> Bool {
        //build the sql statemnt
        var SQLStatement: String = String()
        var SQLParameterNames: String = String()
        var SQLParameterValues: [NSObject] = [NSObject]()
        
        SQLParameterNames = "[CreatedBy]=?, [CreatedOn]=?"
        SQLParameterValues.append(taskTemplate.CreatedBy)
        SQLParameterValues.append(taskTemplate.CreatedOn)
        
        if taskTemplate.LastUpdatedBy != nil {
            SQLParameterNames += ", [LastUpdatedBy]=?"
            SQLParameterValues.append(taskTemplate.LastUpdatedBy!)
        }
        
        if taskTemplate.LastUpdatedOn != nil {
            SQLParameterNames += ", [LastUpdatedOn]=?"
            SQLParameterValues.append(taskTemplate.LastUpdatedOn!)
        }
        
        if taskTemplate.Deleted != nil {
            SQLParameterNames += ", [Deleted]=?"
            SQLParameterValues.append(taskTemplate.Deleted!)
        }
        
        SQLParameterNames += ", [OrganisationId]=?"
        SQLParameterValues.append(taskTemplate.OrganisationId)
        SQLParameterNames += ", [AssetType]=?"
        SQLParameterValues.append(taskTemplate.AssetType)
        SQLParameterNames += ", [TaskName]=?"
        SQLParameterValues.append(taskTemplate.TaskName)
        SQLParameterNames += ", [Priority]=?"
        SQLParameterValues.append(taskTemplate.Priority)
        SQLParameterNames += ", [EstimatedDuration]=?"
        SQLParameterValues.append(taskTemplate.EstimatedDuration)
        
        SQLParameterValues.append(taskTemplate.RowId)
        
        SQLStatement = "UPDATE [TaskTemplate] SET " + SQLParameterNames + "WHERE [RowId]=?"
        
        sharedModelManager.database!.open()
        let isUpdated = sharedModelManager.database!.executeUpdate(SQLStatement, withArgumentsInArray: SQLParameterValues)
        sharedModelManager.database!.close()
        return isUpdated
    }
    
    func deleteTaskTemplate(taskTemplate: TaskTemplate) -> Bool {
        sharedModelManager.database!.open()
        let isDeleted = sharedModelManager.database!.executeUpdate("DELETE FROM [TaskTemplate] WHERE [RowId]=?", withArgumentsInArray: [taskTemplate.RowId])
        sharedModelManager.database!.close()
        return isDeleted
    }
    
    func getTaskTemplate(taskTemplateId: String) -> TaskTemplate? {
        sharedModelManager.database!.open()
        var taskTemplate: TaskTemplate? = nil
        
        let resultSet = sharedModelManager.database!.executeQuery("SELECT [RowId], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [Deleted], [OrganisationId], [AssetType], [TaskName], [Priority], [EstimatedDuration] FROM [TaskTemplate] WHERE [RowId]=?", withArgumentsInArray: [taskTemplateId])
        if (resultSet != nil) {
            while resultSet.next() {
                var resultTaskTemplate: TaskTemplate = TaskTemplate()
                resultTaskTemplate = TaskTemplate()
                resultTaskTemplate.RowId = resultSet.stringForColumn("RowId")
                resultTaskTemplate.CreatedBy = resultSet.stringForColumn("CreatedBy")
                resultTaskTemplate.CreatedOn = resultSet.dateForColumn("CreatedOn")
                if !resultSet.columnIsNull("LastUpdatedBy")
                {
                    resultTaskTemplate.LastUpdatedBy = resultSet.stringForColumn("LastUpdatedBy")
                }
                if !resultSet.columnIsNull("LastUpdatedOn")
                {
                    resultTaskTemplate.LastUpdatedOn = resultSet.dateForColumn("LastUpdatedOn")
                }
                if !resultSet.columnIsNull("Deleted")
                {
                    resultTaskTemplate.Deleted = resultSet.dateForColumn("Deleted")
                }
                resultTaskTemplate.OrganisationId = resultSet.stringForColumn("OrganisationId")
                resultTaskTemplate.AssetType = resultSet.stringForColumn("AssetType")
                resultTaskTemplate.TaskName = resultSet.stringForColumn("TaskName")
                resultTaskTemplate.Priority = Int(resultSet.intForColumn("Priority"))
                resultTaskTemplate.EstimatedDuration = Int(resultSet.intForColumn("EstimatedDuration"))
                
                taskTemplate = resultTaskTemplate
            }
        }
        sharedModelManager.database!.close()
        return taskTemplate
    }
    
    func getAllTaskTemplate() -> [TaskTemplate] {
        sharedModelManager.database!.open()
        let resultSet: FMResultSet! = sharedModelManager.database!.executeQuery("SELECT [RowId], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [Deleted], [OrganisationId], [AssetType], [TaskName], [Priority], [EstimatedDuration] FROM [TaskTemplate]", withArgumentsInArray: nil)
        var taskTemplateList: [TaskTemplate] = [TaskTemplate]()
        if (resultSet != nil) {
            while resultSet.next() {
                let taskTemplate : TaskTemplate = TaskTemplate()
                taskTemplate.RowId = resultSet.stringForColumn("RowId")
                taskTemplate.CreatedBy = resultSet.stringForColumn("CreatedBy")
                taskTemplate.CreatedOn = resultSet.dateForColumn("CreatedOn")
                if !resultSet.columnIsNull("LastUpdatedBy")
                {
                    taskTemplate.LastUpdatedBy = resultSet.stringForColumn("LastUpdatedBy")
                }
                if !resultSet.columnIsNull("LastUpdatedOn")
                {
                    taskTemplate.LastUpdatedOn = resultSet.dateForColumn("LastUpdatedOn")
                }
                if !resultSet.columnIsNull("Deleted")
                {
                    taskTemplate.Deleted = resultSet.dateForColumn("Deleted")
                }
                taskTemplate.OrganisationId = resultSet.stringForColumn("OrganisationId")
                taskTemplate.AssetType = resultSet.stringForColumn("AssetType")
                taskTemplate.TaskName = resultSet.stringForColumn("TaskName")
                taskTemplate.Priority = Int(resultSet.intForColumn("Priority"))
                taskTemplate.EstimatedDuration = Int(resultSet.intForColumn("EstimatedDuration"))
                
                taskTemplateList.append(taskTemplate)
            }
        }
        sharedModelManager.database!.close()
        return taskTemplateList
    }
    
    func findTaskTemplateList(criteria: Dictionary<String, AnyObject>) -> [TaskTemplate] {
        var list: [TaskTemplate] = [TaskTemplate]()
        //var count: Int32 = 0
        (list, _) = findTaskTemplateList(criteria, pageSize: nil, pageNumber: nil)
        return list
    }

    func findTaskTemplateList(criteria: Dictionary<String, AnyObject>, pageSize: Int32?, pageNumber: Int32?) -> (List: [TaskTemplate], Count: Int32) {
        //return variables
        var count: Int32 = 0
        var taskTemplateList: [TaskTemplate] = [TaskTemplate]()
        
        //build the order clause
        let orderByClause: String = " ORDER BY [Priority]"
        
        //build the where clause
        var whereClause: String = String()
        var whereValues: [AnyObject] = [AnyObject]()
        
        (whereClause, whereValues) = buildWhereClause(criteria)
        
        if (whereClause != "")
        {
            whereClause = "WHERE " + whereClause
        }

        sharedModelManager.database!.open()
        let countSet: FMResultSet! = sharedModelManager.database!.executeQuery("SELECT COUNT([RowId]) FROM [TaskTemplate] " + whereClause + orderByClause, withArgumentsInArray: whereValues)
        if (countSet != nil) {
            while countSet.next() {
                count = countSet.intForColumnIndex(0)
            }
        }
        
        if (count > 0)
        {
            var pageClause: String = String()
            if (pageSize != nil && pageNumber != nil)
            {
                pageClause = " LIMIT " + String(pageSize!) + " OFFSET " + String((pageNumber! - 1) * pageSize!)
            }
            
            let resultSet: FMResultSet! = sharedModelManager.database!.executeQuery("SELECT [RowId], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [Deleted], [OrganisationId], [AssetType], [TaskName], [Priority], [EstimatedDuration]FROM [TaskTemplate] " + whereClause + orderByClause + pageClause, withArgumentsInArray: whereValues)
            if (resultSet != nil) {
                while resultSet.next() {
                    let taskTemplate : TaskTemplate = TaskTemplate()
                    taskTemplate.RowId = resultSet.stringForColumn("RowId")
                    taskTemplate.CreatedBy = resultSet.stringForColumn("CreatedBy")
                    taskTemplate.CreatedOn = resultSet.dateForColumn("CreatedOn")
                    if !resultSet.columnIsNull("LastUpdatedBy")
                    {
                        taskTemplate.LastUpdatedBy = resultSet.stringForColumn("LastUpdatedBy")
                    }
                    if !resultSet.columnIsNull("LastUpdatedOn")
                    {
                        taskTemplate.LastUpdatedOn = resultSet.dateForColumn("LastUpdatedOn")
                    }
                    if !resultSet.columnIsNull("Deleted")
                    {
                        taskTemplate.Deleted = resultSet.dateForColumn("Deleted")
                    }
                    taskTemplate.OrganisationId = resultSet.stringForColumn("OrganisationId")
                    taskTemplate.AssetType = resultSet.stringForColumn("AssetType")
                    taskTemplate.TaskName = resultSet.stringForColumn("TaskName")
                    taskTemplate.Priority = Int(resultSet.intForColumn("Priority"))
                    taskTemplate.EstimatedDuration = Int(resultSet.intForColumn("EstimatedDuration"))
                    
                    taskTemplateList.append(taskTemplate)
                }
            }
        }
        
        sharedModelManager.database!.close()
        return (taskTemplateList, count)
    }
    
    // MARK: - TaskTemplateParameter
    
    func addTaskTemplateParameter(taskTemplateParameter: TaskTemplateParameter) -> Bool {
        //build the sql statemnt
        var SQLStatement: String = String()
        var SQLParameterNames: String = String()
        var SQLParameterPlaceholders: String = String()
        var SQLParameterValues: [NSObject] = [NSObject]()
        
        SQLParameterNames = "[RowId], [CreatedBy], [CreatedOn]"
        SQLParameterPlaceholders = "?, ?, ?"
        SQLParameterValues.append(taskTemplateParameter.RowId)
        SQLParameterValues.append(taskTemplateParameter.CreatedBy)
        SQLParameterValues.append(taskTemplateParameter.CreatedOn)
        
        if taskTemplateParameter.LastUpdatedBy != nil {
            SQLParameterNames += ", [LastUpdatedBy]"
            SQLParameterPlaceholders += ", ?"
            SQLParameterValues.append(taskTemplateParameter.LastUpdatedBy!)
        }
        
        if taskTemplateParameter.LastUpdatedOn != nil {
            SQLParameterNames += ", [LastUpdatedOn]"
            SQLParameterPlaceholders += ", ?"
            SQLParameterValues.append(taskTemplateParameter.LastUpdatedOn!)
        }
        
        if taskTemplateParameter.Deleted != nil {
            SQLParameterNames += ", [Deleted]"
            SQLParameterPlaceholders += ", ?"
            SQLParameterValues.append(taskTemplateParameter.Deleted!)
        }
        
        SQLParameterNames += ", [TaskTemplateId]"
        SQLParameterPlaceholders += ", ?"
        SQLParameterValues.append(taskTemplateParameter.TaskTemplateId)
        SQLParameterNames += ", [ParameterName]"
        SQLParameterPlaceholders += ", ?"
        SQLParameterValues.append(taskTemplateParameter.ParameterName)
        SQLParameterNames += ", [ParameterType]"
        SQLParameterPlaceholders += ", ?"
        SQLParameterValues.append(taskTemplateParameter.ParameterType)
        SQLParameterNames += ", [ParameterDisplay]"
        SQLParameterPlaceholders += ", ?"
        SQLParameterValues.append(taskTemplateParameter.ParameterDisplay)
        SQLParameterNames += ", [Collect]"
        SQLParameterPlaceholders += ", ?"
        SQLParameterValues.append(taskTemplateParameter.Collect)
        
        if taskTemplateParameter.ReferenceDataType != nil {
            SQLParameterNames += ", [ReferenceDataType]"
            SQLParameterPlaceholders += ", ?"
            SQLParameterValues.append(taskTemplateParameter.ReferenceDataType!)
        }
        if taskTemplateParameter.ReferenceDataExtendedType != nil {
            SQLParameterNames += ", [ReferenceDataExtendedType]"
            SQLParameterPlaceholders += ", ?"
            SQLParameterValues.append(taskTemplateParameter.ReferenceDataExtendedType!)
        }
        SQLParameterNames += ", [Ordinal]"
        SQLParameterPlaceholders += ", ?"
        SQLParameterValues.append(taskTemplateParameter.Ordinal)
        
        if taskTemplateParameter.Predecessor != nil {
            SQLParameterNames += ", [Predecessor]"
            SQLParameterPlaceholders += ", ?"
            SQLParameterValues.append(taskTemplateParameter.Predecessor!)
        }
        if taskTemplateParameter.PredecessorTrueValue != nil {
            SQLParameterNames += ", [PredecessorTrueValue]"
            SQLParameterPlaceholders += ", ?"
            SQLParameterValues.append(taskTemplateParameter.PredecessorTrueValue!)
        }

        
        
        SQLStatement = "INSERT INTO [TaskTemplateParameter] (" + SQLParameterNames + ") VALUES (" + SQLParameterPlaceholders + ")"
        
        sharedModelManager.database!.open()
        let isInserted = sharedModelManager.database!.executeUpdate(SQLStatement, withArgumentsInArray: SQLParameterValues)
        sharedModelManager.database!.close()
        return isInserted
    }
    
    func updateTaskTemplateParameter(taskTemplateParameter: TaskTemplateParameter) -> Bool {
        //build the sql statemnt
        var SQLStatement: String = String()
        var SQLParameterNames: String = String()
        var SQLParameterValues: [NSObject] = [NSObject]()
        
        SQLParameterNames = "[CreatedBy]=?, [CreatedOn]=?"
        SQLParameterValues.append(taskTemplateParameter.CreatedBy)
        SQLParameterValues.append(taskTemplateParameter.CreatedOn)
        
        if taskTemplateParameter.LastUpdatedBy != nil {
            SQLParameterNames += ", [LastUpdatedBy]=?"
            SQLParameterValues.append(taskTemplateParameter.LastUpdatedBy!)
        }
        
        if taskTemplateParameter.LastUpdatedOn != nil {
            SQLParameterNames += ", [LastUpdatedOn]=?"
            SQLParameterValues.append(taskTemplateParameter.LastUpdatedOn!)
        }
        
        if taskTemplateParameter.Deleted != nil {
            SQLParameterNames += ", [Deleted]=?"
            SQLParameterValues.append(taskTemplateParameter.Deleted!)
        }
        
        SQLParameterNames += ", [TaskTemplateId]=?"
        SQLParameterValues.append(taskTemplateParameter.TaskTemplateId)
        SQLParameterNames += ", [ParameterName]=?"
        SQLParameterValues.append(taskTemplateParameter.ParameterName)
        SQLParameterNames += ", [ParameterType]=?"
        SQLParameterValues.append(taskTemplateParameter.ParameterType)
        SQLParameterNames += ", [ParameterDisplay]=?"
        SQLParameterValues.append(taskTemplateParameter.ParameterDisplay)
        SQLParameterNames += ", [Collect]=?"
        SQLParameterValues.append(taskTemplateParameter.Collect)
        if taskTemplateParameter.ReferenceDataType != nil {
            SQLParameterNames += ", [ReferenceDataType]=?"
            SQLParameterValues.append(taskTemplateParameter.ReferenceDataType!)
        }
        if taskTemplateParameter.ReferenceDataExtendedType != nil {
            SQLParameterNames += ", [ReferenceDataExtendedType]=?"
            SQLParameterValues.append(taskTemplateParameter.ReferenceDataExtendedType!)
        }
        SQLParameterNames += ", [Ordinal]=?"
        SQLParameterValues.append(taskTemplateParameter.Ordinal)
        
        if taskTemplateParameter.Predecessor != nil {
            SQLParameterNames += ", [Predecessor]=?"
            SQLParameterValues.append(taskTemplateParameter.Predecessor!)
        }
        if taskTemplateParameter.PredecessorTrueValue != nil {
            SQLParameterNames += ", [PredecessorTrueValue]=?"
            SQLParameterValues.append(taskTemplateParameter.PredecessorTrueValue!)
        }

        SQLParameterValues.append(taskTemplateParameter.RowId)
        
        SQLStatement = "UPDATE [TaskTemplateParameter] SET " + SQLParameterNames + "WHERE [RowId]=?"
        
        sharedModelManager.database!.open()
        let isUpdated = sharedModelManager.database!.executeUpdate(SQLStatement, withArgumentsInArray: SQLParameterValues)
        sharedModelManager.database!.close()
        return isUpdated
    }
    
    func deleteTaskTemplateParameter(taskTemplateParameter: TaskTemplateParameter) -> Bool {
        sharedModelManager.database!.open()
        let isDeleted = sharedModelManager.database!.executeUpdate("DELETE FROM [TaskTemplateParameter] WHERE [RowId]=?", withArgumentsInArray: [taskTemplateParameter.RowId])
        sharedModelManager.database!.close()
        return isDeleted
    }
    
    func getTaskTemplateParameter(taskTemplateParameterId: String) -> TaskTemplateParameter? {
        sharedModelManager.database!.open()
        var taskTemplateParameter: TaskTemplateParameter? = nil
        
        let resultSet = sharedModelManager.database!.executeQuery("SELECT [RowId], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [Deleted], [TaskTemplateId], [ParameterName], [ParameterType], [ParameterDisplay], [Collect], [ReferenceDataType], [ReferenceDataExtendedType], [Ordinal], [Predecessor], [PredecessorTrueValue] FROM [TaskTemplateParameter] WHERE [RowId]=?", withArgumentsInArray: [taskTemplateParameterId])
        if (resultSet != nil) {
            while resultSet.next() {
                var resultTaskTemplateParameter: TaskTemplateParameter = TaskTemplateParameter()
                resultTaskTemplateParameter = TaskTemplateParameter()
                resultTaskTemplateParameter.RowId = resultSet.stringForColumn("RowId")
                resultTaskTemplateParameter.CreatedBy = resultSet.stringForColumn("CreatedBy")
                resultTaskTemplateParameter.CreatedOn = resultSet.dateForColumn("CreatedOn")
                if !resultSet.columnIsNull("LastUpdatedBy")
                {
                    resultTaskTemplateParameter.LastUpdatedBy = resultSet.stringForColumn("LastUpdatedBy")
                }
                if !resultSet.columnIsNull("LastUpdatedOn")
                {
                    resultTaskTemplateParameter.LastUpdatedOn = resultSet.dateForColumn("LastUpdatedOn")
                }
                if !resultSet.columnIsNull("Deleted")
                {
                    resultTaskTemplateParameter.Deleted = resultSet.dateForColumn("Deleted")
                }
                resultTaskTemplateParameter.TaskTemplateId = resultSet.stringForColumn("TaskTemplateId")
                resultTaskTemplateParameter.ParameterName = resultSet.stringForColumn("ParameterName")
                resultTaskTemplateParameter.ParameterType = resultSet.stringForColumn("ParameterType")
                resultTaskTemplateParameter.ParameterDisplay = resultSet.stringForColumn("ParameterDisplay")
                resultTaskTemplateParameter.Collect = resultSet.boolForColumn("Collect")
                if !resultSet.columnIsNull("ReferenceDataType") {
                    resultTaskTemplateParameter.ReferenceDataType = resultSet.stringForColumn("ReferenceDataType")
                }
                if !resultSet.columnIsNull("ReferenceDataExtendedType") {
                    resultTaskTemplateParameter.ReferenceDataExtendedType = resultSet.stringForColumn("ReferenceDataExtendedType")
                }
                resultTaskTemplateParameter.Ordinal = Int(resultSet.intForColumn("Ordinal"))
                if !resultSet.columnIsNull("Predecessor") {
                    resultTaskTemplateParameter.Predecessor = resultSet.stringForColumn("Predecessor")
                }
                if !resultSet.columnIsNull("PredecessorTrueValue") {
                    resultTaskTemplateParameter.PredecessorTrueValue = resultSet.stringForColumn("PredecessorTrueValue")
                }
                taskTemplateParameter = resultTaskTemplateParameter
            }
        }
        sharedModelManager.database!.close()
        return taskTemplateParameter
    }
    
    func getAllTaskTemplateParameter() -> [TaskTemplateParameter] {
        sharedModelManager.database!.open()
        let resultSet: FMResultSet! = sharedModelManager.database!.executeQuery("SELECT [RowId], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [Deleted], [TaskTemplateId], [ParameterName], [ParameterType], [ParameterDisplay], [Collect], [ReferenceDataType], [ReferenceDataExtendedType], [Ordinal], [Predecessor], [PredecessorTrueValue] FROM [TaskTemplateParameter]", withArgumentsInArray: nil)
        var taskTemplateParameterList: [TaskTemplateParameter] = [TaskTemplateParameter]()
        if (resultSet != nil) {
            while resultSet.next() {
                let taskTemplateParameter : TaskTemplateParameter = TaskTemplateParameter()
                taskTemplateParameter.RowId = resultSet.stringForColumn("RowId")
                taskTemplateParameter.CreatedBy = resultSet.stringForColumn("CreatedBy")
                taskTemplateParameter.CreatedOn = resultSet.dateForColumn("CreatedOn")
                if !resultSet.columnIsNull("LastUpdatedBy")
                {
                    taskTemplateParameter.LastUpdatedBy = resultSet.stringForColumn("LastUpdatedBy")
                }
                if !resultSet.columnIsNull("LastUpdatedOn")
                {
                    taskTemplateParameter.LastUpdatedOn = resultSet.dateForColumn("LastUpdatedOn")
                }
                if !resultSet.columnIsNull("Deleted")
                {
                    taskTemplateParameter.Deleted = resultSet.dateForColumn("Deleted")
                }
                taskTemplateParameter.TaskTemplateId = resultSet.stringForColumn("TaskTemplateId")
                taskTemplateParameter.ParameterName = resultSet.stringForColumn("ParameterName")
                taskTemplateParameter.ParameterType = resultSet.stringForColumn("ParameterType")
                taskTemplateParameter.ParameterDisplay = resultSet.stringForColumn("ParameterDisplay")
                taskTemplateParameter.Collect = resultSet.boolForColumn("Collect")
                if !resultSet.columnIsNull("ReferenceDataType") {
                    taskTemplateParameter.ReferenceDataType = resultSet.stringForColumn("ReferenceDataType")
                }
                if !resultSet.columnIsNull("ReferenceDataExtendedType") {
                    taskTemplateParameter.ReferenceDataExtendedType = resultSet.stringForColumn("ReferenceDataExtendedType")
                }
                taskTemplateParameter.Ordinal = Int(resultSet.intForColumn("Ordinal"))
                if !resultSet.columnIsNull("Predecessor") {
                    taskTemplateParameter.Predecessor = resultSet.stringForColumn("Predecessor")
                }
                if !resultSet.columnIsNull("PredecessorTrueValue") {
                    taskTemplateParameter.PredecessorTrueValue = resultSet.stringForColumn("PredecessorTrueValue")
                }
                taskTemplateParameterList.append(taskTemplateParameter)
            }
        }
        sharedModelManager.database!.close()
        return taskTemplateParameterList
    }
    
    func findTaskTemplateParameterList(criteria: Dictionary<String, AnyObject>) -> [TaskTemplateParameter] {
        var list: [TaskTemplateParameter] = [TaskTemplateParameter]()
        //var count: Int32 = 0
        (list, _) = findTaskTemplateParameterList(criteria, pageSize: nil, pageNumber: nil)
        return list
    }
    
    func findTaskTemplateParameterList(criteria: Dictionary<String, AnyObject>, pageSize: Int32?, pageNumber: Int32?) -> (List: [TaskTemplateParameter], Count: Int32) {
        //return variables
        var count: Int32 = 0
        var taskTemplateParameterList: [TaskTemplateParameter] = [TaskTemplateParameter]()
        
        //build the order clause
        let orderByClause: String = " ORDER BY [Ordinal]"
        
        //build the where clause
        var whereClause: String = String()
        var whereValues: [AnyObject] = [AnyObject]()
        
        (whereClause, whereValues) = buildWhereClause(criteria)
        
        if (whereClause != "")
        {
            whereClause = "WHERE " + whereClause
        }

        sharedModelManager.database!.open()
        let countSet: FMResultSet! = sharedModelManager.database!.executeQuery("SELECT COUNT([RowId]) FROM [TaskTemplateParameter] " + whereClause + orderByClause, withArgumentsInArray: whereValues)
        if (countSet != nil) {
            while countSet.next() {
                count = countSet.intForColumnIndex(0)
            }
        }
        
        if (count > 0)
        {
            var pageClause: String = String()
            if (pageSize != nil && pageNumber != nil)
            {
                pageClause = " LIMIT " + String(pageSize!) + " OFFSET " + String((pageNumber! - 1) * pageSize!)
            }
            
            let resultSet: FMResultSet! = sharedModelManager.database!.executeQuery("SELECT [RowId], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [Deleted], [TaskTemplateId], [ParameterName], [ParameterType], [ParameterDisplay], [Collect], [ReferenceDataType], [ReferenceDataExtendedType], [Ordinal], [Predecessor], [PredecessorTrueValue] FROM [TaskTemplateParameter] " + whereClause + orderByClause + pageClause, withArgumentsInArray: whereValues)
            if (resultSet != nil) {
                while resultSet.next() {
                    let taskTemplateParameter : TaskTemplateParameter = TaskTemplateParameter()
                    taskTemplateParameter.RowId = resultSet.stringForColumn("RowId")
                    taskTemplateParameter.CreatedBy = resultSet.stringForColumn("CreatedBy")
                    taskTemplateParameter.CreatedOn = resultSet.dateForColumn("CreatedOn")
                    if !resultSet.columnIsNull("LastUpdatedBy")
                    {
                        taskTemplateParameter.LastUpdatedBy = resultSet.stringForColumn("LastUpdatedBy")
                    }
                    if !resultSet.columnIsNull("LastUpdatedOn")
                    {
                        taskTemplateParameter.LastUpdatedOn = resultSet.dateForColumn("LastUpdatedOn")
                    }
                    if !resultSet.columnIsNull("Deleted")
                    {
                        taskTemplateParameter.Deleted = resultSet.dateForColumn("Deleted")
                    }
                    taskTemplateParameter.TaskTemplateId = resultSet.stringForColumn("TaskTemplateId")
                    taskTemplateParameter.ParameterName = resultSet.stringForColumn("ParameterName")
                    taskTemplateParameter.ParameterType = resultSet.stringForColumn("ParameterType")
                    taskTemplateParameter.ParameterDisplay = resultSet.stringForColumn("ParameterDisplay")
                    taskTemplateParameter.Collect = resultSet.boolForColumn("Collect")
                    if !resultSet.columnIsNull("ReferenceDataType") {
                        taskTemplateParameter.ReferenceDataType = resultSet.stringForColumn("ReferenceDataType")
                    }
                    if !resultSet.columnIsNull("ReferenceDataExtendedType") {
                        taskTemplateParameter.ReferenceDataExtendedType = resultSet.stringForColumn("ReferenceDataExtendedType")
                    }
                    taskTemplateParameter.Ordinal = Int(resultSet.intForColumn("Ordinal"))

                    if !resultSet.columnIsNull("Predecessor") {
                        taskTemplateParameter.Predecessor = resultSet.stringForColumn("Predecessor")
                    }
                    if !resultSet.columnIsNull("PredecessorTrueValue") {
                        taskTemplateParameter.PredecessorTrueValue = resultSet.stringForColumn("PredecessorTrueValue")
                    }
                    
                    taskTemplateParameterList.append(taskTemplateParameter)
                }
            }
        }
        
        sharedModelManager.database!.close()
        return (taskTemplateParameterList, count)
    }
}

