//
// ModelManager.swift
// COMPASSMOBILE
//
// Created by Andrew Harper on 20/01/2016.
// Copyright © 2016 HYDOP E.C.S. All rights reserved.
//

import UIKit
import FMDB

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
    
    func CheckDatabaseStructure() -> Bool {
        var returnValue: Bool = true;
        sharedModelManager.database!.open()
        var SQLStatement: String = String()
        
        let SQLParameterValues: [NSObject] = [NSObject]()

        //check for the TaskInstruction Table
        if (returnValue){
            SQLStatement = " SELECT name FROM sqlite_master WHERE type = 'table' and name='TaskInstruction'"
            let resultSet = sharedModelManager.database!.executeQuery(SQLStatement, withArgumentsIn: SQLParameterValues)
            if !resultSet!.next()
            {
                //create the table
                SQLStatement = "CREATE TABLE TaskInstruction (RowId VARCHAR (36) NOT NULL CONSTRAINT PK_TaskInstructionId PRIMARY KEY COLLATE NOCASE, CreatedBy VARCHAR (36) NOT NULL COLLATE NOCASE, CreatedOn DATETIME NOT NULL, LastUpdatedBy VARCHAR (36) COLLATE NOCASE, LastUpdatedOn DATETIME, Deleted DATETIME, TaskId VARCHAR (36) NOT NULL COLLATE NOCASE, EntityType VARCHAR (50) NOT NULL COLLATE NOCASE, EntityId VARCHAR (36) NOT NULL COLLATE NOCASE, OutletId VARCHAR (36) COLLATE NOCASE, FlushType VARCHAR (50) COLLATE NOCASE);"
                returnValue = sharedModelManager.database!.executeStatements(SQLStatement)
            }
        }
        
        //check for the TestSuite Table
        if (returnValue){
            SQLStatement = " SELECT name FROM sqlite_master WHERE type = 'table' and name='TestSuite'"
            let resultSet = sharedModelManager.database!.executeQuery(SQLStatement, withArgumentsIn: SQLParameterValues)
            if !resultSet!.next()
            {
                //create the table
                SQLStatement = "CREATE TABLE TestSuite (RowId VARCHAR (36) NOT NULL CONSTRAINT PK_TestSuiteId PRIMARY KEY COLLATE NOCASE, CreatedBy VARCHAR (36) NOT NULL COLLATE NOCASE, CreatedOn DATETIME NOT NULL, LastUpdatedBy VARCHAR (36) COLLATE NOCASE, LastUpdatedOn DATETIME, Deleted DATETIME, OrganisationId VARCHAR (36) NOT NULL COLLATE NOCASE, Name VARCHAR (100) NOT NULL COLLATE NOCASE, Description VARCHAR (250) NOT NULL COLLATE NOCASE, TestSuiteType VARCHAR (100) NOT NULL COLLATE NOCASE, FlushType VARCHAR (50) COLLATE NOCASE);"
                returnValue = sharedModelManager.database!.executeStatements(SQLStatement)
            }
        }
        
        //check for the TestSuiteItem Table
        if (returnValue){
            SQLStatement = " SELECT name FROM sqlite_master WHERE type = 'table' and name='TestSuiteItem'"
            let resultSet = sharedModelManager.database!.executeQuery(SQLStatement, withArgumentsIn: SQLParameterValues)
            if !resultSet!.next()
            {
                //create the table
                SQLStatement = "CREATE TABLE TestSuiteItem (RowId VARCHAR (36) NOT NULL CONSTRAINT PK_TestSuiteItemId PRIMARY KEY COLLATE NOCASE, CreatedBy VARCHAR (36) NOT NULL COLLATE NOCASE, CreatedOn DATETIME NOT NULL, LastUpdatedBy VARCHAR (36) COLLATE NOCASE, LastUpdatedOn DATETIME, Deleted DATETIME, TestSuiteId VARCHAR (36) NOT NULL COLLATE NOCASE, Ordinal INTEGER NOT NULL, BacteriumType VARCHAR (100) NOT NULL COLLATE NOCASE);"
                returnValue = sharedModelManager.database!.executeStatements(SQLStatement)
            }
        }
        
        //check for the AssetOutlet Table
        if (returnValue){
            SQLStatement = " SELECT name FROM sqlite_master WHERE type = 'table' and name='AssetOutlet'"
            let resultSet = sharedModelManager.database!.executeQuery(SQLStatement, withArgumentsIn: SQLParameterValues)
            if !resultSet!.next()
            {
                //create the table
                SQLStatement = "CREATE TABLE AssetOutlet (RowId VARCHAR (36) NOT NULL CONSTRAINT PK_AssetOutletId PRIMARY KEY COLLATE NOCASE, CreatedBy VARCHAR (36) NOT NULL COLLATE NOCASE, CreatedOn DATETIME NOT NULL, LastUpdatedBy VARCHAR (36) COLLATE NOCASE, LastUpdatedOn DATETIME, Deleted DATETIME, OutletType VARCHAR(100) NOT NULL COLLATE NOCASE, FacilityId VARCHAR (36) NOT NULL COLLATE NOCASE, HydropName VARCHAR (20) COLLATE NOCASE, ClientName VARCHAR (50) COLLATE NOCASE, ScanCode VARCHAR (50) COLLATE NOCASE, Integral BIT);"
                returnValue = sharedModelManager.database!.executeStatements(SQLStatement)
            }
        }
        
        //check for the OperativeGroup Tables
        if (returnValue){
            SQLStatement = "SELECT name FROM sqlite_master WHERE type = 'table' and name = 'OperativeGroup'"
            let resultSet = sharedModelManager.database!.executeQuery(SQLStatement, withArgumentsIn: SQLParameterValues)
            if !resultSet!.next()
            {
                //create the table
                SQLStatement = "CREATE TABLE OperativeGroup (RowId VARCHAR (36) NOT NULL CONSTRAINT PK_OperativeGroupId PRIMARY KEY COLLATE NOCASE, CreatedBy VARCHAR (36) NOT NULL COLLATE NOCASE, CreatedOn DATETIME NOT NULL, LastUpdatedBy VARCHAR (36) COLLATE NOCASE, LastUpdatedOn DATETIME, Deleted DATETIME, OrganisationId VARCHAR (36) NOT NULL COLLATE NOCASE, Name VARCHAR (50) COLLATE NOCASE);"
                returnValue = sharedModelManager.database!.executeStatements(SQLStatement)
            }
        }
        
        if (returnValue){
            SQLStatement = " SELECT name FROM sqlite_master WHERE type = 'table' and name='OperativeGroupMembership'"
            let resultSet = sharedModelManager.database!.executeQuery(SQLStatement, withArgumentsIn: SQLParameterValues)
            if !resultSet!.next()
            {
                //create the table
                SQLStatement = "CREATE TABLE OperativeGroupMembership (RowId VARCHAR (36) NOT NULL CONSTRAINT PK_OperativeGroupMembershipId PRIMARY KEY COLLATE NOCASE, CreatedBy VARCHAR (36) NOT NULL COLLATE NOCASE, CreatedOn DATETIME NOT NULL, LastUpdatedBy VARCHAR (36) COLLATE NOCASE, LastUpdatedOn DATETIME, Deleted DATETIME, OperativeGroupId VARCHAR (36) NOT NULL COLLATE NOCASE, OperativeId VARCHAR (36) NOT NULL COLLATE NOCASE);"
                returnValue = sharedModelManager.database!.executeStatements(SQLStatement)
            }
        }
        
        if (returnValue){
            SQLStatement = " SELECT name FROM sqlite_master WHERE type = 'table' and name='OperativeGroupTaskTemplateMembership'"
            let resultSet = sharedModelManager.database!.executeQuery(SQLStatement, withArgumentsIn: SQLParameterValues)
            if !resultSet!.next()
            {
                //create the table
                SQLStatement = "CREATE TABLE OperativeGroupTaskTemplateMembership (RowId VARCHAR (36) NOT NULL CONSTRAINT PK_OperativeGroupMembershipId PRIMARY KEY COLLATE NOCASE, CreatedBy VARCHAR (36) NOT NULL COLLATE NOCASE, CreatedOn DATETIME NOT NULL, LastUpdatedBy VARCHAR (36) COLLATE NOCASE, LastUpdatedOn DATETIME, Deleted DATETIME, OperativeGroupId VARCHAR (36) NOT NULL COLLATE NOCASE, TaskTemplateId VARCHAR (36) NOT NULL COLLATE NOCASE);"
                returnValue = sharedModelManager.database!.executeStatements(SQLStatement)
            }
        }
        
        if (returnValue){
            SQLStatement = "SELECT m.name as tableName, p.name as columnName FROM sqlite_master m left outer join pragma_table_info((m.name)) p on m.name <> p.name where tableName = 'TaskTemplate' and columnName ='CanCreateFromDevice'"
            let resultSet = sharedModelManager.database!.executeQuery(SQLStatement, withArgumentsIn: SQLParameterValues)
            if !resultSet!.next()
            {
                //create the table
                SQLStatement = "ALTER TABLE TaskTemplate ADD COLUMN CanCreateFromDevice BIT;"
                returnValue = sharedModelManager.database!.executeStatements(SQLStatement)
                if(returnValue)
                {
                    Session.ResetTaskTemplateDates = true
                }
            }
        }
   
        if (returnValue){
            SQLStatement = "SELECT m.name as tableName, p.name as columnName FROM sqlite_master m left outer join pragma_table_info((m.name)) p on m.name <> p.name where tableName = 'Task' and columnName ='Level'"
            let resultSet = sharedModelManager.database!.executeQuery(SQLStatement, withArgumentsIn: SQLParameterValues)
            if !resultSet!.next()
            {
                //create the table
                SQLStatement = "ALTER TABLE Task ADD COLUMN Level NVARCHAR(50) COLLATE NOCASE;"
                returnValue = sharedModelManager.database!.executeStatements(SQLStatement)
                if(returnValue)
                {
                    Session.ResetTaskTemplateDates = true
                }
            }
        }
        
        return returnValue
    }
    
    func executeDirectNoParameters(_ SQLStatement: String) -> Bool{
        sharedModelManager.database!.open()
        let isExecuted: Bool = sharedModelManager.database!.executeStatements(SQLStatement)
        sharedModelManager.database!.close()
        return isExecuted
    }
    
    func executeDirect(_ SQLStatement: String, SQLParameterValues: [NSObject]) -> Bool{
        sharedModelManager.database!.open()
        let isExecuted: Bool = sharedModelManager.database!.executeUpdate(SQLStatement, withArgumentsIn: SQLParameterValues)
        sharedModelManager.database!.close()
        return isExecuted
    }
    
    func executeSingleValueReader(_ SQLStatement: String, SQLParameterValues: [NSObject]) -> NSObject?{
        var returnValue: NSObject = NSObject()
        sharedModelManager.database!.open()
        let resultSet = sharedModelManager.database!.executeQuery(SQLStatement, withArgumentsIn: SQLParameterValues)
        if (resultSet != nil) {
            while (resultSet?.next())! {
                returnValue = resultSet?.object(forColumnIndex: 0) as! NSObject
            }
        }
        sharedModelManager.database!.close()
        return returnValue
    }
    
    func executeSingleDateReader(_ SQLStatement: String, SQLParameterValues: [NSObject]) -> Date?{
        sharedModelManager.database!.open()
        let resultSet = sharedModelManager.database!.executeQuery(SQLStatement, withArgumentsIn: SQLParameterValues)
        if (resultSet != nil) {
            while (resultSet?.next())! {
                return resultSet?.date(forColumnIndex: 0)
            }
        }
        sharedModelManager.database!.close()
        return nil
    }
    
    func buildWhereClause(_ criteria: Dictionary<String, AnyObject>) -> (whereClause: String, whereValues: [AnyObject]) {
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
 
    func buildWhereClauseWithNulls(_ criteria: Dictionary<String, AnyObject>) -> (whereClause: String, whereValues: [AnyObject]) {
        var whereClause: String = String()
        var loopCount: Int32 = 0
        var whereValues: [AnyObject] = [AnyObject]()
        for (itemKey, itemValue) in criteria
        {
            whereClause += (loopCount > 0 ? " AND " : " ")
            
            if (itemValue as! String? == nil)
            {
                whereClause += (itemKey) + " IS ? "
            }
            else if (itemValue is String)
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
    
    func addAsset(_ asset: Asset) -> Bool {
        //build the sql statemnt
        var SQLStatement: String = String()
        var SQLParameterNames: String = String()
        var SQLParameterPlaceholders: String = String()
        var SQLParameterValues: [NSObject] = [NSObject]()
        
        SQLParameterNames = "[RowId], [CreatedBy], [CreatedOn]"
        SQLParameterPlaceholders = "?, ?, ?"
        SQLParameterValues.append(asset.RowId as NSObject)
        SQLParameterValues.append(asset.CreatedBy as NSObject)
        SQLParameterValues.append(asset.CreatedOn as NSObject)
        
        if asset.LastUpdatedBy != nil {
            SQLParameterNames += ", [LastUpdatedBy]"
            SQLParameterPlaceholders += ", ?"
            SQLParameterValues.append(asset.LastUpdatedBy! as NSObject)
        }
        
        if asset.LastUpdatedOn != nil {
            SQLParameterNames += ", [LastUpdatedOn]"
            SQLParameterPlaceholders += ", ?"
            SQLParameterValues.append(asset.LastUpdatedOn! as NSObject)
        }
        
        if asset.Deleted != nil {
            SQLParameterNames += ", [Deleted]"
            SQLParameterPlaceholders += ", ?"
            SQLParameterValues.append(asset.Deleted! as NSObject)
        }
        
        SQLParameterNames += ", [AssetType]"
        SQLParameterPlaceholders += ", ?"
        SQLParameterValues.append(asset.AssetType as NSObject)
        SQLParameterNames += ", [PropertyId]"
        SQLParameterPlaceholders += ", ?"
        SQLParameterValues.append(asset.PropertyId as NSObject)
        SQLParameterNames += ", [LocationId]"
        SQLParameterPlaceholders += ", ?"
        SQLParameterValues.append(asset.LocationId as NSObject)
        if asset.HydropName != nil {
            SQLParameterNames += ", [HydropName]"
            SQLParameterPlaceholders += ", ?"
            SQLParameterValues.append(asset.HydropName! as NSObject)
        }
        if asset.ClientName != nil {
            SQLParameterNames += ", [ClientName]"
            SQLParameterPlaceholders += ", ?"
            SQLParameterValues.append(asset.ClientName! as NSObject)
        }
        if asset.ScanCode != nil {
            SQLParameterNames += ", [ScanCode]"
            SQLParameterPlaceholders += ", ?"
            SQLParameterValues.append(asset.ScanCode! as NSObject)
        }
        if asset.HotType != nil {
            SQLParameterNames += ", [HotType]"
            SQLParameterPlaceholders += ", ?"
            SQLParameterValues.append(asset.HotType! as NSObject)
        }
        if asset.ColdType != nil {
            SQLParameterNames += ", [ColdType]"
            SQLParameterPlaceholders += ", ?"
            SQLParameterValues.append(asset.ColdType! as NSObject)
        }
        
        SQLStatement = "INSERT INTO [Asset] (" + SQLParameterNames + ") VALUES (" + SQLParameterPlaceholders + ")"
        
        sharedModelManager.database!.open()
        let isInserted = sharedModelManager.database!.executeUpdate(SQLStatement, withArgumentsIn: SQLParameterValues)
        sharedModelManager.database!.close()
        return isInserted
    }
    
    func updateAsset(_ asset: Asset) -> Bool {
        //build the sql statemnt
        var SQLStatement: String = String()
        var SQLParameterNames: String = String()
        var SQLParameterValues: [NSObject] = [NSObject]()
        
        SQLParameterNames = "[CreatedBy]=?, [CreatedOn]=?"
        SQLParameterValues.append(asset.CreatedBy as NSObject)
        SQLParameterValues.append(asset.CreatedOn as NSObject)
        
        if asset.LastUpdatedBy != nil {
            SQLParameterNames += ", [LastUpdatedBy]=?"
            SQLParameterValues.append(asset.LastUpdatedBy! as NSObject)
        }
        
        if asset.LastUpdatedOn != nil {
            SQLParameterNames += ", [LastUpdatedOn]=?"
            SQLParameterValues.append(asset.LastUpdatedOn! as NSObject)
        }
        
        if asset.Deleted != nil {
            SQLParameterNames += ", [Deleted]=?"
            SQLParameterValues.append(asset.Deleted! as NSObject)
        }
        
        SQLParameterNames += ", [AssetType]=?"
        SQLParameterValues.append(asset.AssetType as NSObject)
        SQLParameterNames += ", [PropertyId]=?"
        SQLParameterValues.append(asset.PropertyId as NSObject)
        SQLParameterNames += ", [LocationId]=?"
        SQLParameterValues.append(asset.LocationId as NSObject)
        if asset.HydropName != nil {
            SQLParameterNames += ", [HydropName]=?"
            SQLParameterValues.append(asset.HydropName! as NSObject)
        }
        if asset.ClientName != nil {
            SQLParameterNames += ", [ClientName]=?"
            SQLParameterValues.append(asset.ClientName! as NSObject)
        }
        if asset.ScanCode != nil {
            SQLParameterNames += ", [ScanCode]=?"
            SQLParameterValues.append(asset.ScanCode! as NSObject)
        }
        if asset.HotType != nil {
            SQLParameterNames += ", [HotType]=?"
            SQLParameterValues.append(asset.HotType! as NSObject)
        }
        if asset.ColdType != nil {
            SQLParameterNames += ", [ColdType]=?"
            SQLParameterValues.append(asset.ColdType! as NSObject)
        }
        
        SQLParameterValues.append(asset.RowId as NSObject)
        
        SQLStatement = "UPDATE [Asset] SET " + SQLParameterNames + "WHERE [RowId]=?"
        
        sharedModelManager.database!.open()
        let isUpdated = sharedModelManager.database!.executeUpdate(SQLStatement, withArgumentsIn: SQLParameterValues)
        sharedModelManager.database!.close()
        return isUpdated
    }
    
    func deleteAsset(_ asset: Asset) -> Bool {
        sharedModelManager.database!.open()
        let isDeleted = sharedModelManager.database!.executeUpdate("DELETE FROM [Asset] WHERE [RowId]=?", withArgumentsIn: [asset.RowId])
        sharedModelManager.database!.close()
        return isDeleted
    }
    
    func getAsset(_ assetId: String) -> Asset? {
        sharedModelManager.database!.open()
        var asset: Asset? = nil
        
        let resultSet = sharedModelManager.database!.executeQuery("SELECT [RowId], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [Deleted], [AssetType], [PropertyId], [LocationId], [HydropName], [ClientName], [ScanCode], [HotType], [ColdType] FROM [Asset] WHERE [RowId]=?", withArgumentsIn: [assetId])
        if (resultSet != nil) {
            while (resultSet?.next())! {
                var resultAsset: Asset = Asset()
                resultAsset = Asset()
                resultAsset.RowId = (resultSet?.string(forColumn: "RowId"))!
                resultAsset.CreatedBy = (resultSet?.string(forColumn: "CreatedBy"))!
                resultAsset.CreatedOn = (resultSet?.date(forColumn: "CreatedOn"))!
                if !(resultSet?.columnIsNull("LastUpdatedBy"))!
                {
                    resultAsset.LastUpdatedBy = resultSet?.string(forColumn: "LastUpdatedBy")
                }
                if !(resultSet?.columnIsNull("LastUpdatedOn"))!
                {
                    resultAsset.LastUpdatedOn = resultSet?.date(forColumn: "LastUpdatedOn")
                }
                if !(resultSet?.columnIsNull("Deleted"))!
                {
                    resultAsset.Deleted = resultSet?.date(forColumn: "Deleted")
                }
                resultAsset.AssetType = (resultSet?.string(forColumn: "AssetType"))!
                resultAsset.PropertyId = (resultSet?.string(forColumn: "PropertyId"))!
                resultAsset.LocationId = (resultSet?.string(forColumn: "LocationId"))!
                if !(resultSet?.columnIsNull("HydropName"))! {
                    resultAsset.HydropName = resultSet?.string(forColumn: "HydropName")
                }
                if !(resultSet?.columnIsNull("ClientName"))! {
                    resultAsset.ClientName = resultSet?.string(forColumn: "ClientName")
                }
                if !(resultSet?.columnIsNull("ScanCode"))! {
                    resultAsset.ScanCode = resultSet?.string(forColumn: "ScanCode")
                }
                if !(resultSet?.columnIsNull("HotType"))! {
                    resultAsset.HotType = resultSet?.string(forColumn: "HotType")
                }
                if !(resultSet?.columnIsNull("ColdType"))! {
                    resultAsset.ColdType = resultSet?.string(forColumn: "ColdType")
                }
                
                asset = resultAsset
            }
        }
        sharedModelManager.database!.close()
        return asset
    }
    
    func getAllAsset() -> [Asset] {
        sharedModelManager.database!.open()
        let resultSet: FMResultSet! = sharedModelManager.database!.executeQuery("SELECT [RowId], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [Deleted], [AssetType], [PropertyId], [LocationId], [HydropName], [ClientName], [ScanCode], [HotType], [ColdType] FROM [Asset]", withArgumentsIn: [])
        var assetList: [Asset] = [Asset]()
        if (resultSet != nil) {
            while resultSet.next() {
                let asset : Asset = Asset()
                asset.RowId = resultSet.string(forColumn: "RowId")!
                asset.CreatedBy = resultSet.string(forColumn: "CreatedBy")!
                asset.CreatedOn = resultSet.date(forColumn: "CreatedOn")!
                if !resultSet.columnIsNull("LastUpdatedBy")
                {
                    asset.LastUpdatedBy = resultSet.string(forColumn: "LastUpdatedBy")
                }
                if !resultSet.columnIsNull("LastUpdatedOn")
                {
                    asset.LastUpdatedOn = resultSet.date(forColumn: "LastUpdatedOn")
                }
                if !resultSet.columnIsNull("Deleted")
                {
                    asset.Deleted = resultSet.date(forColumn: "Deleted")
                }
                asset.AssetType = resultSet.string(forColumn: "AssetType")!
                asset.PropertyId = resultSet.string(forColumn: "PropertyId")!
                asset.LocationId = resultSet.string(forColumn: "LocationId")!
                if !resultSet.columnIsNull("HydropName") {
                    asset.HydropName = resultSet.string(forColumn: "HydropName")
                }
                if !resultSet.columnIsNull("ClientName") {
                    asset.ClientName = resultSet.string(forColumn: "ClientName")
                }
                if !resultSet.columnIsNull("ScanCode") {
                    asset.ScanCode = resultSet.string(forColumn: "ScanCode")
                }
                if !resultSet.columnIsNull("HotType") {
                    asset.HotType = resultSet.string(forColumn: "HotType")
                }
                if !resultSet.columnIsNull("ColdType") {
                    asset.ColdType = resultSet.string(forColumn: "ColdType")
                }
                
                assetList.append(asset)
            }
        }
        sharedModelManager.database!.close()
        return assetList
    }
    
    func findAssetList(_ criteria: Dictionary<String, AnyObject>) -> [Asset] {
        var list: [Asset] = [Asset]()
        //var count: Int32 = 0
        (list, _) = findAssetList(criteria, pageSize: nil, pageNumber: nil)
        return list
    }
    
    func findAssetList(_ criteria: Dictionary<String, AnyObject>, pageSize: Int32?, pageNumber: Int32?) -> (List: [Asset], Count: Int32) {
        
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
        let countSet: FMResultSet! = sharedModelManager.database!.executeQuery("SELECT COUNT([RowId]) FROM [Asset] " + whereClause, withArgumentsIn: whereValues)
        if (countSet != nil) {
            while countSet.next() {
                count = countSet.int(forColumnIndex: 0)
            }
        }
        
        if (count > 0)
        {
            var pageClause: String = String()
            if (pageSize != nil && pageNumber != nil)
            {
                pageClause = " LIMIT " + String(pageSize!) + " OFFSET " + String((pageNumber! - 1) * pageSize!)
            }
            
            let resultSet: FMResultSet! = sharedModelManager.database!.executeQuery("SELECT [RowId], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [Deleted], [AssetType], [PropertyId], [LocationId], [HydropName], [ClientName], [ScanCode], [HotType], [ColdType] FROM [Asset] " + whereClause + pageClause, withArgumentsIn: whereValues)
            if (resultSet != nil) {
                while resultSet.next() {
                    let asset : Asset = Asset()
                    asset.RowId = resultSet.string(forColumn: "RowId")!
                    asset.CreatedBy = resultSet.string(forColumn: "CreatedBy")!
                    asset.CreatedOn = resultSet.date(forColumn: "CreatedOn")!
                    if !resultSet.columnIsNull("LastUpdatedBy")
                    {
                        asset.LastUpdatedBy = resultSet.string(forColumn: "LastUpdatedBy")
                    }
                    if !resultSet.columnIsNull("LastUpdatedOn")
                    {
                        asset.LastUpdatedOn = resultSet.date(forColumn: "LastUpdatedOn")
                    }
                    if !resultSet.columnIsNull("Deleted")
                    {
                        asset.Deleted = resultSet.date(forColumn: "Deleted")
                    }
                    asset.AssetType = resultSet.string(forColumn: "AssetType")!
                    asset.PropertyId = resultSet.string(forColumn: "PropertyId")!
                    asset.LocationId = resultSet.string(forColumn: "LocationId")!
                    if !resultSet.columnIsNull("HydropName") {
                        asset.HydropName = resultSet.string(forColumn: "HydropName")
                    }
                    if !resultSet.columnIsNull("ClientName") {
                        asset.ClientName = resultSet.string(forColumn: "ClientName")
                    }
                    if !resultSet.columnIsNull("ScanCode") {
                        asset.ScanCode = resultSet.string(forColumn: "ScanCode")
                    }
                    if !resultSet.columnIsNull("HotType") {
                        asset.HotType = resultSet.string(forColumn: "HotType")
                    }
                    if !resultSet.columnIsNull("ColdType") {
                        asset.ColdType = resultSet.string(forColumn: "ColdType")
                    }
                    
                    assetList.append(asset)
                }
            }
        }
        
        sharedModelManager.database!.close()
        
        return (assetList, count)
    }
    
    // MARK: - AssetOutlet
    
    func addAssetOutlet(_ assetOutlet: AssetOutlet) -> Bool {
        //build the sql statemnt
        var SQLStatement: String = String()
        var SQLParameterNames: String = String()
        var SQLParameterPlaceholders: String = String()
        var SQLParameterValues: [NSObject] = [NSObject]()
        
        SQLParameterNames = "[RowId], [CreatedBy], [CreatedOn]"
        SQLParameterPlaceholders = "?, ?, ?"
        SQLParameterValues.append(assetOutlet.RowId as NSObject)
        SQLParameterValues.append(assetOutlet.CreatedBy as NSObject)
        SQLParameterValues.append(assetOutlet.CreatedOn as NSObject)
        
        if assetOutlet.LastUpdatedBy != nil {
            SQLParameterNames += ", [LastUpdatedBy]"
            SQLParameterPlaceholders += ", ?"
            SQLParameterValues.append(assetOutlet.LastUpdatedBy! as NSObject)
        }
        
        if assetOutlet.LastUpdatedOn != nil {
            SQLParameterNames += ", [LastUpdatedOn]"
            SQLParameterPlaceholders += ", ?"
            SQLParameterValues.append(assetOutlet.LastUpdatedOn! as NSObject)
        }
        
        if assetOutlet.Deleted != nil {
            SQLParameterNames += ", [Deleted]"
            SQLParameterPlaceholders += ", ?"
            SQLParameterValues.append(assetOutlet.Deleted! as NSObject)
        }
        
        SQLParameterNames += ", [OutletType]"
        SQLParameterPlaceholders += ", ?"
        SQLParameterValues.append(assetOutlet.OutletType as NSObject)
        SQLParameterNames += ", [FacilityId]"
        SQLParameterPlaceholders += ", ?"
        SQLParameterValues.append(assetOutlet.FacilityId as NSObject)
        if assetOutlet.HydropName != nil {
            SQLParameterNames += ", [HydropName]"
            SQLParameterPlaceholders += ", ?"
            SQLParameterValues.append(assetOutlet.HydropName! as NSObject)
        }
        if assetOutlet.ClientName != nil {
            SQLParameterNames += ", [ClientName]"
            SQLParameterPlaceholders += ", ?"
            SQLParameterValues.append(assetOutlet.ClientName! as NSObject)
        }
        if assetOutlet.ScanCode != nil {
            SQLParameterNames += ", [ScanCode]"
            SQLParameterPlaceholders += ", ?"
            SQLParameterValues.append(assetOutlet.ScanCode! as NSObject)
        }
        SQLParameterNames += ", [Integral]"
        SQLParameterPlaceholders += ", ?"
        SQLParameterValues.append(assetOutlet.Integral as NSObject)
        
        SQLStatement = "INSERT INTO [AssetOutlet] (" + SQLParameterNames + ") VALUES (" + SQLParameterPlaceholders + ")"
        
        sharedModelManager.database!.open()
        let isInserted = sharedModelManager.database!.executeUpdate(SQLStatement, withArgumentsIn: SQLParameterValues)
        sharedModelManager.database!.close()
        return isInserted
    }
    
    func updateAssetOutlet(_ assetOutlet: AssetOutlet) -> Bool {
        //build the sql statemnt
        var SQLStatement: String = String()
        var SQLParameterNames: String = String()
        var SQLParameterValues: [NSObject] = [NSObject]()
        
        SQLParameterNames = "[CreatedBy]=?, [CreatedOn]=?"
        SQLParameterValues.append(assetOutlet.CreatedBy as NSObject)
        SQLParameterValues.append(assetOutlet.CreatedOn as NSObject)
        
        if assetOutlet.LastUpdatedBy != nil {
            SQLParameterNames += ", [LastUpdatedBy]=?"
            SQLParameterValues.append(assetOutlet.LastUpdatedBy! as NSObject)
        }
        
        if assetOutlet.LastUpdatedOn != nil {
            SQLParameterNames += ", [LastUpdatedOn]=?"
            SQLParameterValues.append(assetOutlet.LastUpdatedOn! as NSObject)
        }
        
        if assetOutlet.Deleted != nil {
            SQLParameterNames += ", [Deleted]=?"
            SQLParameterValues.append(assetOutlet.Deleted! as NSObject)
        }
        
        SQLParameterNames += ", [OutletType]=?"
        SQLParameterValues.append(assetOutlet.OutletType as NSObject)
        SQLParameterNames += ", [FacilityId]=?"
        SQLParameterValues.append(assetOutlet.FacilityId as NSObject)
        if assetOutlet.HydropName != nil {
            SQLParameterNames += ", [HydropName]=?"
            SQLParameterValues.append(assetOutlet.HydropName! as NSObject)
        }
        if assetOutlet.ClientName != nil {
            SQLParameterNames += ", [ClientName]=?"
            SQLParameterValues.append(assetOutlet.ClientName! as NSObject)
        }
        if assetOutlet.ScanCode != nil {
            SQLParameterNames += ", [ScanCode]=?"
            SQLParameterValues.append(assetOutlet.ScanCode! as NSObject)
        }
        SQLParameterNames += ", [Integral]=?"
        SQLParameterValues.append(assetOutlet.Integral as NSObject)
        
        SQLParameterValues.append(assetOutlet.RowId as NSObject)
        
        SQLStatement = "UPDATE [AssetOutlet] SET " + SQLParameterNames + "WHERE [RowId]=?"
        
        sharedModelManager.database!.open()
        let isUpdated = sharedModelManager.database!.executeUpdate(SQLStatement, withArgumentsIn: SQLParameterValues)
        sharedModelManager.database!.close()
        return isUpdated
    }
    
    func deleteAssetOutlet(_ assetOutlet: AssetOutlet) -> Bool {
        sharedModelManager.database!.open()
        let isDeleted = sharedModelManager.database!.executeUpdate("DELETE FROM [AssetOutlet] WHERE [RowId]=?", withArgumentsIn: [assetOutlet.RowId])
        sharedModelManager.database!.close()
        return isDeleted
    }
    
    func getAssetOutlet(_ assetOutletId: String) -> AssetOutlet? {
        sharedModelManager.database!.open()
        var assetOutlet: AssetOutlet? = nil
        
        let resultSet = sharedModelManager.database!.executeQuery("SELECT [RowId], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [Deleted], [OutletType], [FacilityId], [HydropName], [ClientName], [ScanCode], [Integral] FROM [AssetOutlet] WHERE [RowId]=?", withArgumentsIn: [assetOutletId])
        if (resultSet != nil) {
            while (resultSet?.next())! {
                var resultAssetOutlet: AssetOutlet = AssetOutlet()
                resultAssetOutlet = AssetOutlet()
                resultAssetOutlet.RowId = (resultSet?.string(forColumn: "RowId"))!
                resultAssetOutlet.CreatedBy = (resultSet?.string(forColumn: "CreatedBy"))!
                resultAssetOutlet.CreatedOn = (resultSet?.date(forColumn: "CreatedOn"))!
                if !(resultSet?.columnIsNull("LastUpdatedBy"))!
                {
                    resultAssetOutlet.LastUpdatedBy = resultSet?.string(forColumn: "LastUpdatedBy")
                }
                if !(resultSet?.columnIsNull("LastUpdatedOn"))!
                {
                    resultAssetOutlet.LastUpdatedOn = resultSet?.date(forColumn: "LastUpdatedOn")
                }
                if !(resultSet?.columnIsNull("Deleted"))!
                {
                    resultAssetOutlet.Deleted = resultSet?.date(forColumn: "Deleted")
                }
                resultAssetOutlet.OutletType = (resultSet?.string(forColumn: "OutletType"))!
                resultAssetOutlet.FacilityId = (resultSet?.string(forColumn: "FacilityId"))!
                if !(resultSet?.columnIsNull("HydropName"))! {
                    resultAssetOutlet.HydropName = resultSet?.string(forColumn: "HydropName")
                }
                if !(resultSet?.columnIsNull("ClientName"))! {
                    resultAssetOutlet.ClientName = resultSet?.string(forColumn: "ClientName")
                }
                if !(resultSet?.columnIsNull("ScanCode"))! {
                    resultAssetOutlet.ScanCode = resultSet?.string(forColumn: "ScanCode")
                }
                resultAssetOutlet.Integral = (resultSet?.bool(forColumn: "Integral"))!
                
                assetOutlet = resultAssetOutlet
            }
        }
        sharedModelManager.database!.close()
        return assetOutlet
    }
    
    func getAllAssetOutlet() -> [AssetOutlet] {
        sharedModelManager.database!.open()
        let resultSet: FMResultSet! = sharedModelManager.database!.executeQuery("SELECT [RowId], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [Deleted], [OutletType], [FacilityId], [HydropName], [ClientName], [ScanCode], [Integral] FROM [AssetOutlet]", withArgumentsIn: [])
        var assetOutletList: [AssetOutlet] = [AssetOutlet]()
        if (resultSet != nil) {
            while resultSet.next() {
                let assetOutlet : AssetOutlet = AssetOutlet()
                assetOutlet.RowId = resultSet.string(forColumn: "RowId")!
                assetOutlet.CreatedBy = resultSet.string(forColumn: "CreatedBy")!
                assetOutlet.CreatedOn = resultSet.date(forColumn: "CreatedOn")!
                if !resultSet.columnIsNull("LastUpdatedBy")
                {
                    assetOutlet.LastUpdatedBy = resultSet.string(forColumn: "LastUpdatedBy")
                }
                if !resultSet.columnIsNull("LastUpdatedOn")
                {
                    assetOutlet.LastUpdatedOn = resultSet.date(forColumn: "LastUpdatedOn")
                }
                if !resultSet.columnIsNull("Deleted")
                {
                    assetOutlet.Deleted = resultSet.date(forColumn: "Deleted")
                }
                assetOutlet.OutletType = resultSet.string(forColumn: "OutletType")!
                assetOutlet.FacilityId = resultSet.string(forColumn: "FacilityId")!
                if !resultSet.columnIsNull("HydropName") {
                    assetOutlet.HydropName = resultSet.string(forColumn: "HydropName")
                }
                if !resultSet.columnIsNull("ClientName") {
                    assetOutlet.ClientName = resultSet.string(forColumn: "ClientName")
                }
                if !resultSet.columnIsNull("ScanCode") {
                    assetOutlet.ScanCode = resultSet.string(forColumn: "ScanCode")
                }
                assetOutlet.Integral = resultSet.bool(forColumn: "Integral")
                
                assetOutletList.append(assetOutlet)
            }
        }
        sharedModelManager.database!.close()
        return assetOutletList
    }
    
    func findAssetOutletList(_ criteria: Dictionary<String, AnyObject>) -> [AssetOutlet] {
        var list: [AssetOutlet] = [AssetOutlet]()
        //var count: Int32 = 0
        (list, _) = findAssetOutletList(criteria, pageSize: nil, pageNumber: nil)
        return list
    }
    
    func findAssetOutletList(_ criteria: Dictionary<String, AnyObject>, pageSize: Int32?, pageNumber: Int32?) -> (List: [AssetOutlet], Count: Int32) {
        
        //return variables
        var count: Int32 = 0
        var assetOutletList: [AssetOutlet] = [AssetOutlet]()
        
        //build the where clause
        var whereClause: String = String()
        var whereValues: [AnyObject] = [AnyObject]()
        
        (whereClause, whereValues) = buildWhereClause(criteria)
        
        if (whereClause != "")
        {
            whereClause = "WHERE " + whereClause
        }
        
        sharedModelManager.database!.open()
        let countSet: FMResultSet! = sharedModelManager.database!.executeQuery("SELECT COUNT([RowId]) FROM [AssetOutlet] " + whereClause, withArgumentsIn: whereValues)
        if (countSet != nil) {
            while countSet.next() {
                count = countSet.int(forColumnIndex: 0)
            }
        }
        
        if (count > 0)
        {
            var pageClause: String = String()
            if (pageSize != nil && pageNumber != nil)
            {
                pageClause = " LIMIT " + String(pageSize!) + " OFFSET " + String((pageNumber! - 1) * pageSize!)
            }
            
            let resultSet: FMResultSet! = sharedModelManager.database!.executeQuery("SELECT [RowId], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [Deleted], [OutletType], [FacilityId], [HydropName], [ClientName], [ScanCode], [Integral] FROM [AssetOutlet] " + whereClause + pageClause, withArgumentsIn: whereValues)
            if (resultSet != nil) {
                while resultSet.next() {
                    let assetOutlet : AssetOutlet = AssetOutlet()
                    assetOutlet.RowId = resultSet.string(forColumn: "RowId")!
                    assetOutlet.CreatedBy = resultSet.string(forColumn: "CreatedBy")!
                    assetOutlet.CreatedOn = resultSet.date(forColumn: "CreatedOn")!
                    if !resultSet.columnIsNull("LastUpdatedBy")
                    {
                        assetOutlet.LastUpdatedBy = resultSet.string(forColumn: "LastUpdatedBy")
                    }
                    if !resultSet.columnIsNull("LastUpdatedOn")
                    {
                        assetOutlet.LastUpdatedOn = resultSet.date(forColumn: "LastUpdatedOn")
                    }
                    if !resultSet.columnIsNull("Deleted")
                    {
                        assetOutlet.Deleted = resultSet.date(forColumn: "Deleted")
                    }
                    assetOutlet.OutletType = resultSet.string(forColumn: "OutletType")!
                    assetOutlet.FacilityId = resultSet.string(forColumn: "FacilityId")!
                    if !resultSet.columnIsNull("HydropName") {
                        assetOutlet.HydropName = resultSet.string(forColumn: "HydropName")
                    }
                    if !resultSet.columnIsNull("ClientName") {
                        assetOutlet.ClientName = resultSet.string(forColumn: "ClientName")
                    }
                    if !resultSet.columnIsNull("ScanCode") {
                        assetOutlet.ScanCode = resultSet.string(forColumn: "ScanCode")
                    }
                    assetOutlet.Integral = resultSet.bool(forColumn: "Integral")
                    
                    assetOutletList.append(assetOutlet)
                }
            }
        }
        
        sharedModelManager.database!.close()
        
        return (assetOutletList, count)
    }

    // MARK: - Location
    
    func addLocation(_ location: Location) -> Bool {
        //build the sql statemnt
        var SQLStatement: String = String()
        var SQLParameterNames: String = String()
        var SQLParameterPlaceholders: String = String()
        var SQLParameterValues: [NSObject] = [NSObject]()
        
        SQLParameterNames = "[RowId], [CreatedBy], [CreatedOn]"
        SQLParameterPlaceholders = "?, ?, ?"
        SQLParameterValues.append(location.RowId as NSObject)
        SQLParameterValues.append(location.CreatedBy as NSObject)
        SQLParameterValues.append(location.CreatedOn as NSObject)
        
        if location.LastUpdatedBy != nil {
            SQLParameterNames += ", [LastUpdatedBy]"
            SQLParameterPlaceholders += ", ?"
            SQLParameterValues.append(location.LastUpdatedBy! as NSObject)
        }
        
        if location.LastUpdatedOn != nil {
            SQLParameterNames += ", [LastUpdatedOn]"
            SQLParameterPlaceholders += ", ?"
            SQLParameterValues.append(location.LastUpdatedOn! as NSObject)
        }
        
        if location.Deleted != nil {
            SQLParameterNames += ", [Deleted]"
            SQLParameterPlaceholders += ", ?"
            SQLParameterValues.append(location.Deleted! as NSObject)
        }
        
        SQLParameterNames += ", [PropertyId]"
        SQLParameterPlaceholders += ", ?"
        SQLParameterValues.append(location.PropertyId as NSObject)
        SQLParameterNames += ", [Name]"
        SQLParameterPlaceholders += ", ?"
        SQLParameterValues.append(location.Name as NSObject)
        if location.Description != nil {
            SQLParameterNames += ", [Description]"
            SQLParameterPlaceholders += ", ?"
            SQLParameterValues.append(location.Description! as NSObject)
        }
        if location.Level != nil {
            SQLParameterNames += ", [Level]"
            SQLParameterPlaceholders += ", ?"
            SQLParameterValues.append(location.Level! as NSObject)
        }
        if location.Number != nil {
            SQLParameterNames += ", [Number]"
            SQLParameterPlaceholders += ", ?"
            SQLParameterValues.append(location.Number! as NSObject)
        }
        if location.SubNumber != nil {
            SQLParameterNames += ", [SubNumber]"
            SQLParameterPlaceholders += ", ?"
            SQLParameterValues.append(location.SubNumber! as NSObject)
        }
        if location.Use != nil {
            SQLParameterNames += ", [Use]"
            SQLParameterPlaceholders += ", ?"
            SQLParameterValues.append(location.Use! as NSObject)
        }
        if location.ClientLocationName != nil {
            SQLParameterNames += ", [ClientLocationName]"
            SQLParameterPlaceholders += ", ?"
            SQLParameterValues.append(location.ClientLocationName! as NSObject)
        }
        
        
        SQLStatement = "INSERT INTO [Location] (" + SQLParameterNames + ") VALUES (" + SQLParameterPlaceholders + ")"
        
        sharedModelManager.database!.open()
        let isInserted = sharedModelManager.database!.executeUpdate(SQLStatement, withArgumentsIn: SQLParameterValues)
        sharedModelManager.database!.close()
        return isInserted
    }
    
    func updateLocation(_ location: Location) -> Bool {
        //build the sql statemnt
        var SQLStatement: String = String()
        var SQLParameterNames: String = String()
        var SQLParameterValues: [NSObject] = [NSObject]()
        
        SQLParameterNames = "[CreatedBy]=?, [CreatedOn]=?"
        SQLParameterValues.append(location.CreatedBy as NSObject)
        SQLParameterValues.append(location.CreatedOn as NSObject)
        
        if location.LastUpdatedBy != nil {
            SQLParameterNames += ", [LastUpdatedBy]=?"
            SQLParameterValues.append(location.LastUpdatedBy! as NSObject)
        }
        
        if location.LastUpdatedOn != nil {
            SQLParameterNames += ", [LastUpdatedOn]=?"
            SQLParameterValues.append(location.LastUpdatedOn! as NSObject)
        }
        
        if location.Deleted != nil {
            SQLParameterNames += ", [Deleted]=?"
            SQLParameterValues.append(location.Deleted! as NSObject)
        }
        
        SQLParameterNames += ", [PropertyId]=?"
        SQLParameterValues.append(location.PropertyId as NSObject)
        SQLParameterNames += ", [Name]=?"
        SQLParameterValues.append(location.Name as NSObject)
        if location.Description != nil {
            SQLParameterNames += ", [Description]=?"
            SQLParameterValues.append(location.Description! as NSObject)
        }
        if location.Level != nil {
            SQLParameterNames += ", [Level]=?"
            SQLParameterValues.append(location.Level! as NSObject)
        }
        if location.Number != nil {
            SQLParameterNames += ", [Number]=?"
            SQLParameterValues.append(location.Number! as NSObject)
        }
        if location.SubNumber != nil {
            SQLParameterNames += ", [SubNumber]=?"
            SQLParameterValues.append(location.SubNumber! as NSObject)
        }
        if location.Use != nil {
            SQLParameterNames += ", [Use]=?"
            SQLParameterValues.append(location.Use! as NSObject)
        }
        if location.ClientLocationName != nil {
            SQLParameterNames += ", [ClientLocationName]=?"
            SQLParameterValues.append(location.ClientLocationName! as NSObject)
        }
        
        
        SQLParameterValues.append(location.RowId as NSObject)
        
        SQLStatement = "UPDATE [Location] SET " + SQLParameterNames + "WHERE [RowId]=?"
        
        sharedModelManager.database!.open()
        let isUpdated = sharedModelManager.database!.executeUpdate(SQLStatement, withArgumentsIn: SQLParameterValues)
        sharedModelManager.database!.close()
        return isUpdated
    }
    
    func deleteLocation(_ location: Location) -> Bool {
        sharedModelManager.database!.open()
        let isDeleted = sharedModelManager.database!.executeUpdate("DELETE FROM [Location] WHERE [RowId]=?", withArgumentsIn: [location.RowId])
        sharedModelManager.database!.close()
        return isDeleted
    }
    
    func getLocation(_ locationId: String) -> Location? {
        sharedModelManager.database!.open()
        var location: Location? = nil
        
        let resultSet = sharedModelManager.database!.executeQuery("SELECT [RowId], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [Deleted], [PropertyId], [Name], [Description], [Level], [Number], [SubNumber], [Use], [ClientLocationName] FROM [Location] WHERE [RowId]=?", withArgumentsIn: [locationId])
        if (resultSet != nil) {
            while (resultSet?.next())! {
                var resultLocation: Location = Location()
                resultLocation = Location()
                resultLocation.RowId = (resultSet?.string(forColumn: "RowId"))!
                resultLocation.CreatedBy = (resultSet?.string(forColumn: "CreatedBy"))!
                resultLocation.CreatedOn = resultSet!.date(forColumn: "CreatedOn")!
                if !(resultSet?.columnIsNull("LastUpdatedBy"))!
                {
                    resultLocation.LastUpdatedBy = resultSet?.string(forColumn: "LastUpdatedBy")
                }
                if !(resultSet?.columnIsNull("LastUpdatedOn"))!
                {
                    resultLocation.LastUpdatedOn = resultSet?.date(forColumn: "LastUpdatedOn")
                }
                if !(resultSet?.columnIsNull("Deleted"))!
                {
                    resultLocation.Deleted = resultSet?.date(forColumn: "Deleted")
                }
                resultLocation.PropertyId = (resultSet?.string(forColumn: "PropertyId"))!
                resultLocation.Name = (resultSet?.string(forColumn: "Name"))!
                if !(resultSet?.columnIsNull("Description"))! {
                    resultLocation.Description = resultSet?.string(forColumn: "Description")
                }
                if !(resultSet?.columnIsNull("Level"))! {
                    resultLocation.Level = resultSet?.string(forColumn: "Level")
                }
                if !(resultSet?.columnIsNull("Number"))! {
                    resultLocation.Number = resultSet?.string(forColumn: "Number")
                }
                if !(resultSet?.columnIsNull("SubNumber"))! {
                    resultLocation.SubNumber = resultSet?.string(forColumn: "SubNumber")
                }
                if !(resultSet?.columnIsNull("Use"))! {
                    resultLocation.Use = resultSet?.string(forColumn: "Use")
                }
                if !(resultSet?.columnIsNull("ClientLocationName"))! {
                    resultLocation.ClientLocationName = resultSet?.string(forColumn: "ClientLocationName")
                }
                
                location = resultLocation
            }
        }
        sharedModelManager.database!.close()
        return location
    }
    
    func getAllLocation() -> [Location] {
        sharedModelManager.database!.open()
        let resultSet: FMResultSet! = sharedModelManager.database!.executeQuery("SELECT [RowId], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [Deleted], [PropertyId], [Name], [Description], [Level], [Number], [SubNumber], [Use], [ClientLocationName] FROM [Location]", withArgumentsIn: [])
        var locationList : [Location] = [Location]()
        if (resultSet != nil) {
            while resultSet.next() {
                let location : Location = Location()
                location.RowId = resultSet.string(forColumn: "RowId")!
                location.CreatedBy = resultSet.string(forColumn: "CreatedBy")!
                location.CreatedOn = resultSet.date(forColumn: "CreatedOn")!
                if !resultSet.columnIsNull("LastUpdatedBy")
                {
                    location.LastUpdatedBy = resultSet.string(forColumn: "LastUpdatedBy")
                }
                if !resultSet.columnIsNull("LastUpdatedOn")
                {
                    location.LastUpdatedOn = resultSet.date(forColumn: "LastUpdatedOn")
                }
                if !resultSet.columnIsNull("Deleted")
                {
                    location.Deleted = resultSet.date(forColumn: "Deleted")
                }
                location.PropertyId = resultSet.string(forColumn: "PropertyId")!
                location.Name = resultSet.string(forColumn: "Name")!
                if !resultSet.columnIsNull("Description") {
                    location.Description = resultSet.string(forColumn: "Description")
                }
                if !resultSet.columnIsNull("Level") {
                    location.Level = resultSet.string(forColumn: "Level")
                }
                if !resultSet.columnIsNull("Number") {
                    location.Number = resultSet.string(forColumn: "Number")
                }
                if !resultSet.columnIsNull("SubNumber") {
                    location.SubNumber = resultSet.string(forColumn: "SubNumber")
                }
                if !resultSet.columnIsNull("Use") {
                    location.Use = resultSet.string(forColumn: "Use")
                }
                if !resultSet.columnIsNull("ClientLocationName") {
                    location.ClientLocationName = resultSet.string(forColumn: "ClientLocationName")
                }
                
                locationList.append(location)
            }
        }
        sharedModelManager.database!.close()
        return locationList
    }
    
    func findLocationList(_ criteria: Dictionary<String, AnyObject>) -> [Location] {
        var list: [Location] = [Location]()
        //var count: Int32 = 0
        (list, _) = findLocationList(criteria, pageSize: nil, pageNumber: nil)
        return list
    }
    
    func findLocationList(_ criteria: Dictionary<String, AnyObject>, pageSize: Int32?, pageNumber: Int32?) -> (List: [Location], Count: Int32) {
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
        let countSet: FMResultSet! = sharedModelManager.database!.executeQuery("SELECT COUNT([RowId]) FROM [Location] " + whereClause + orderByClause, withArgumentsIn: whereValues)
        if (countSet != nil) {
            while countSet.next() {
                count = countSet.int(forColumnIndex: 0)
            }
        }
        
        if (count > 0)
        {
            var pageClause: String = String()
            if (pageSize != nil && pageNumber != nil)
            {
                pageClause = " LIMIT " + String(pageSize!) + " OFFSET " + String((pageNumber! - 1) * pageSize!)
            }
            
            let resultSet: FMResultSet! = sharedModelManager.database!.executeQuery("SELECT [RowId], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [Deleted], [PropertyId], [Name], [Description], [Level], [Number], [SubNumber], [Use], [ClientLocationName] FROM [Location] " + whereClause + orderByClause + pageClause, withArgumentsIn: whereValues)
            
            if (resultSet != nil) {
                while resultSet.next() {
                    let location : Location = Location()
                    location.RowId = resultSet.string(forColumn: "RowId")!
                    location.CreatedBy = resultSet.string(forColumn: "CreatedBy")!
                    location.CreatedOn = resultSet.date(forColumn: "CreatedOn")!
                    if !resultSet.columnIsNull("LastUpdatedBy") {
                        location.LastUpdatedBy = resultSet.string(forColumn: "LastUpdatedBy")
                    }
                    if !resultSet.columnIsNull("LastUpdatedOn")
                    {
                        location.LastUpdatedOn = resultSet.date(forColumn: "LastUpdatedOn")
                    }
                    if !resultSet.columnIsNull("Deleted")
                    {
                        location.Deleted = resultSet.date(forColumn: "Deleted")
                    }
                    location.PropertyId = resultSet.string(forColumn: "PropertyId")!
                    location.Name = resultSet.string(forColumn: "Name")!
                    if !resultSet.columnIsNull("Description") {
                        location.Description = resultSet.string(forColumn: "Description")
                    }
                    if !resultSet.columnIsNull("Level") {
                        location.Level = resultSet.string(forColumn: "Level")
                    }
                    if !resultSet.columnIsNull("Number") {
                        location.Number = resultSet.string(forColumn: "Number")
                    }
                    if !resultSet.columnIsNull("SubNumber") {
                        location.SubNumber = resultSet.string(forColumn: "SubNumber")
                    }
                    if !resultSet.columnIsNull("Use") {
                        location.Use = resultSet.string(forColumn: "Use")
                    }
                    if !resultSet.columnIsNull("ClientLocationName") {
                        location.ClientLocationName = resultSet.string(forColumn: "ClientLocationName")
                    }
                    
                    locationList.append(location)
                }
            }
        }
        
        sharedModelManager.database!.close()
        return (locationList, count)
    }
    
    func findLocationListByLocationGroup(_ LocationGroupId: String, criteria: Dictionary<String, AnyObject>, pageSize: Int32?, pageNumber: Int32?) -> (List: [Location], Count: Int32) {
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
        whereValues.append(LocationGroupId as AnyObject)
        
        if (whereClause != "")
        {
            whereClause = "WHERE " + whereClause
        }
        
        sharedModelManager.database!.open()
        let countSet: FMResultSet! = sharedModelManager.database!.executeQuery("SELECT COUNT([Location].[RowId]) FROM [Location] INNER JOIN [LocationGroupMembership] ON [Location].[RowId] = [LocationGroupMembership].[LocationId] " + whereClause + orderByClause, withArgumentsIn: whereValues)
        if (countSet != nil) {
            while countSet.next() {
                count = countSet.int(forColumnIndex: 0)
            }
        }
        
        if (count > 0)
        {
            var pageClause: String = String()
            if (pageSize != nil && pageNumber != nil)
            {
                pageClause = " LIMIT " + String(pageSize!) + " OFFSET " + String((pageNumber! - 1) * pageSize!)
            }
            
            let resultSet: FMResultSet! = sharedModelManager.database!.executeQuery("SELECT [Location].[RowId], [Location].[CreatedBy], [Location].[CreatedOn], [Location].[LastUpdatedBy], [Location].[LastUpdatedOn], [Location].[Deleted], [Location].[PropertyId], [Location].[Name], [Location].[Description], [Location].[Level], [Location].[Number], [Location].[SubNumber], [Location].[Use], [Location].[ClientLocationName] FROM [Location] INNER JOIN [LocationGroupMembership] ON [Location].[RowId] = [LocationGroupMembership].[LocationId] " + whereClause + orderByClause + pageClause, withArgumentsIn: whereValues)
            
            if (resultSet != nil) {
                while resultSet.next() {
                    let location : Location = Location()
                    location.RowId = resultSet.string(forColumn: "RowId")!
                    location.CreatedBy = resultSet.string(forColumn: "CreatedBy")!
                    location.CreatedOn = resultSet.date(forColumn: "CreatedOn")!
                    if !resultSet.columnIsNull("LastUpdatedBy") {
                        location.LastUpdatedBy = resultSet.string(forColumn: "LastUpdatedBy")
                    }
                    if !resultSet.columnIsNull("LastUpdatedOn")
                    {
                        location.LastUpdatedOn = resultSet.date(forColumn: "LastUpdatedOn")
                    }
                    if !resultSet.columnIsNull("Deleted")
                    {
                        location.Deleted = resultSet.date(forColumn: "Deleted")
                    }
                    location.PropertyId = resultSet.string(forColumn: "PropertyId")!
                    location.Name = resultSet.string(forColumn: "Name")!
                    if !resultSet.columnIsNull("Description") {
                        location.Description = resultSet.string(forColumn: "Description")
                    }
                    if !resultSet.columnIsNull("Level") {
                        location.Level = resultSet.string(forColumn: "Level")
                    }
                    if !resultSet.columnIsNull("Number") {
                        location.Number = resultSet.string(forColumn: "Number")
                    }
                    if !resultSet.columnIsNull("SubNumber") {
                        location.SubNumber = resultSet.string(forColumn: "SubNumber")
                    }
                    if !resultSet.columnIsNull("Use") {
                        location.Use = resultSet.string(forColumn: "Use")
                    }
                    if !resultSet.columnIsNull("ClientLocationName") {
                        location.ClientLocationName = resultSet.string(forColumn: "ClientLocationName")
                    }
                    
                    locationList.append(location)
                }
            }
        }
        
        sharedModelManager.database!.close()
        return (locationList, count)
    }
    
    // MARK: - LocationGroup
    
    func addLocationGroup(_ locationGroup: LocationGroup) -> Bool {
        //build the sql statemnt
        var SQLStatement: String = String()
        var SQLParameterNames: String = String()
        var SQLParameterPlaceholders: String = String()
        var SQLParameterValues: [NSObject] = [NSObject]()
        
        SQLParameterNames = "[RowId], [CreatedBy], [CreatedOn]"
        SQLParameterPlaceholders = "?, ?, ?"
        SQLParameterValues.append(locationGroup.RowId as NSObject)
        SQLParameterValues.append(locationGroup.CreatedBy as NSObject)
        SQLParameterValues.append(locationGroup.CreatedOn as NSObject)
        
        if locationGroup.LastUpdatedBy != nil {
            SQLParameterNames += ", [LastUpdatedBy]"
            SQLParameterPlaceholders += ", ?"
            SQLParameterValues.append(locationGroup.LastUpdatedBy! as NSObject)
        }
        
        if locationGroup.LastUpdatedOn != nil {
            SQLParameterNames += ", [LastUpdatedOn]"
            SQLParameterPlaceholders += ", ?"
            SQLParameterValues.append(locationGroup.LastUpdatedOn! as NSObject)
        }
        
        if locationGroup.Deleted != nil {
            SQLParameterNames += ", [Deleted]"
            SQLParameterPlaceholders += ", ?"
            SQLParameterValues.append(locationGroup.Deleted! as NSObject)
        }
        SQLParameterNames += ", [PropertyId]"
        SQLParameterPlaceholders += ", ?"
        SQLParameterValues.append(locationGroup.PropertyId as NSObject)
        if locationGroup.LocationGroupType != nil {
            SQLParameterNames += ", [Type]"
            SQLParameterPlaceholders += ", ?"
            SQLParameterValues.append(locationGroup.LocationGroupType! as NSObject)
        }
        if locationGroup.Name != nil {
            SQLParameterNames += ", [Name]"
            SQLParameterPlaceholders += ", ?"
            SQLParameterValues.append(locationGroup.Name! as NSObject)
        }
        if locationGroup.Description != nil {
            SQLParameterNames += ", [Description]"
            SQLParameterPlaceholders += ", ?"
            SQLParameterValues.append(locationGroup.Description! as NSObject)
        }
        if locationGroup.OccupantRiskFactor != nil {
            SQLParameterNames += ", [OccupantRiskFactor]"
            SQLParameterPlaceholders += ", ?"
            SQLParameterValues.append(locationGroup.OccupantRiskFactor! as NSObject)
        }
        
        SQLStatement = "INSERT INTO [LocationGroup] (" + SQLParameterNames + ") VALUES (" + SQLParameterPlaceholders + ")"
        
        sharedModelManager.database!.open()
        let isInserted = sharedModelManager.database!.executeUpdate(SQLStatement, withArgumentsIn: SQLParameterValues)
        sharedModelManager.database!.close()
        return isInserted
    }
    
    func updateLocationGroup(_ locationGroup: LocationGroup) -> Bool {
        //build the sql statemnt
        var SQLStatement: String = String()
        var SQLParameterNames: String = String()
        var SQLParameterValues: [NSObject] = [NSObject]()
        
        SQLParameterNames = "[CreatedBy]=?, [CreatedOn]=?"
        SQLParameterValues.append(locationGroup.CreatedBy as NSObject)
        SQLParameterValues.append(locationGroup.CreatedOn as NSObject)
        
        if locationGroup.LastUpdatedBy != nil {
            SQLParameterNames += ", [LastUpdatedBy]=?"
            SQLParameterValues.append(locationGroup.LastUpdatedBy! as NSObject)
        }
        
        if locationGroup.LastUpdatedOn != nil {
            SQLParameterNames += ", [LastUpdatedOn]=?"
            SQLParameterValues.append(locationGroup.LastUpdatedOn! as NSObject)
        }
        
        if locationGroup.Deleted != nil {
            SQLParameterNames += ", [Deleted]=?"
            SQLParameterValues.append(locationGroup.Deleted! as NSObject)
        }
        SQLParameterNames += ", [PropertyId]=?"
        SQLParameterValues.append(locationGroup.PropertyId as NSObject)
        if locationGroup.LocationGroupType != nil {
            SQLParameterNames += ", [Type]=?"
            SQLParameterValues.append(locationGroup.LocationGroupType! as NSObject)
        }
        if locationGroup.Name != nil {
            SQLParameterNames += ", [Name]=?"
            SQLParameterValues.append(locationGroup.Name! as NSObject)
        }
        if locationGroup.Description != nil {
            SQLParameterNames += ", [Description]=?"
            SQLParameterValues.append(locationGroup.Description! as NSObject)
        }
        if locationGroup.OccupantRiskFactor != nil {
            SQLParameterNames += ", [OccupantRiskFactor]=?"
            SQLParameterValues.append(locationGroup.OccupantRiskFactor! as NSObject)
        }
        
        
        SQLParameterValues.append(locationGroup.RowId as NSObject)
        
        SQLStatement = "UPDATE [LocationGroup] SET " + SQLParameterNames + "WHERE [RowId]=?"
        
        sharedModelManager.database!.open()
        let isUpdated = sharedModelManager.database!.executeUpdate(SQLStatement, withArgumentsIn: SQLParameterValues)
        sharedModelManager.database!.close()
        return isUpdated
    }
    
    func deleteLocationGroup(_ locationGroup: LocationGroup) -> Bool {
        sharedModelManager.database!.open()
        let isDeleted = sharedModelManager.database!.executeUpdate("DELETE FROM [LocationGroup] WHERE [RowId]=?", withArgumentsIn: [locationGroup.RowId])
        sharedModelManager.database!.close()
        return isDeleted
    }
    
    func getLocationGroup(_ locationGroupId: String) -> LocationGroup? {
        sharedModelManager.database!.open()
        var locationGroup: LocationGroup? = nil
        
        let resultSet = sharedModelManager.database!.executeQuery("SELECT [RowId], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [Deleted], [PropertyId], [Type], [Name], [Description], [OccupantRiskFactor] FROM [LocationGroup] WHERE [RowId]=?", withArgumentsIn: [locationGroupId])
        if (resultSet != nil) {
            while (resultSet?.next())! {
                var resultLocationGroup: LocationGroup = LocationGroup()
                resultLocationGroup = LocationGroup()
                resultLocationGroup.RowId = (resultSet?.string(forColumn: "RowId"))!
                resultLocationGroup.CreatedBy = (resultSet?.string(forColumn: "CreatedBy"))!
                resultLocationGroup.CreatedOn = resultSet!.date(forColumn: "CreatedOn")!
                if !(resultSet?.columnIsNull("LastUpdatedBy"))!
                {
                    resultLocationGroup.LastUpdatedBy = resultSet?.string(forColumn: "LastUpdatedBy")
                }
                if !(resultSet?.columnIsNull("LastUpdatedOn"))!
                {
                    resultLocationGroup.LastUpdatedOn = resultSet?.date(forColumn: "LastUpdatedOn")
                }
                if !(resultSet?.columnIsNull("Deleted"))!
                {
                    resultLocationGroup.Deleted = resultSet?.date(forColumn: "Deleted")
                }
                resultLocationGroup.PropertyId = (resultSet?.string(forColumn: "PropertyId"))!
                if !(resultSet?.columnIsNull("Type"))! {
                    resultLocationGroup.LocationGroupType = resultSet?.string(forColumn: "Type")
                }
                if !(resultSet?.columnIsNull("Name"))! {
                    resultLocationGroup.Name = resultSet?.string(forColumn: "Name")
                }
                if !(resultSet?.columnIsNull("Description"))! {
                    resultLocationGroup.Description = resultSet?.string(forColumn: "Description")
                }
                if !(resultSet?.columnIsNull("OccupantRiskFactor"))! {
                    resultLocationGroup.OccupantRiskFactor = resultSet?.string(forColumn: "OccupantRiskFactor")
                }
                
                
                locationGroup = resultLocationGroup
            }
        }
        sharedModelManager.database!.close()
        return locationGroup
    }
    
    func getAllLocationGroup() -> [LocationGroup] {
        sharedModelManager.database!.open()
        let resultSet: FMResultSet! = sharedModelManager.database!.executeQuery("SELECT [RowId], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [Deleted], [PropertyId], [Type], [Name], [Description], [OccupantRiskFactor] FROM [LocationGroup]", withArgumentsIn: [])
        var locationGroupList : [LocationGroup] = [LocationGroup]()
        if (resultSet != nil) {
            while resultSet.next() {
                let locationGroup : LocationGroup = LocationGroup()
                locationGroup.RowId = resultSet.string(forColumn: "RowId")!
                locationGroup.CreatedBy = resultSet.string(forColumn: "CreatedBy")!
                locationGroup.CreatedOn = resultSet.date(forColumn: "CreatedOn")!
                if !resultSet.columnIsNull("LastUpdatedBy")
                {
                    locationGroup.LastUpdatedBy = resultSet.string(forColumn: "LastUpdatedBy")
                }
                if !resultSet.columnIsNull("LastUpdatedOn")
                {
                    locationGroup.LastUpdatedOn = resultSet.date(forColumn: "LastUpdatedOn")
                }
                if !resultSet.columnIsNull("Deleted")
                {
                    locationGroup.Deleted = resultSet.date(forColumn: "Deleted")
                }
                locationGroup.PropertyId = resultSet.string(forColumn: "PropertyId")!
                if !resultSet.columnIsNull("Type") {
                    locationGroup.LocationGroupType = resultSet.string(forColumn: "Type")
                }
                if !resultSet.columnIsNull("Name") {
                    locationGroup.Name = resultSet.string(forColumn: "Name")
                }
                if !resultSet.columnIsNull("Description") {
                    locationGroup.Description = resultSet.string(forColumn: "Description")
                }
                if !resultSet.columnIsNull("OccupantRiskFactor") {
                    locationGroup.OccupantRiskFactor = resultSet.string(forColumn: "OccupantRiskFactor")
                }
                
                locationGroupList.append(locationGroup)
            }
        }
        sharedModelManager.database!.close()
        return locationGroupList
    }
    
    func findLocationGroupList(_ criteria: Dictionary<String, AnyObject>) -> [LocationGroup] {
        var list: [LocationGroup] = [LocationGroup]()
        //var count: Int32 = 0
        (list, _) = findLocationGroupList(criteria, pageSize: nil, pageNumber: nil)
        return list
    }
    
    func findLocationGroupList(_ criteria: Dictionary<String, AnyObject>, pageSize: Int32?, pageNumber: Int32?) -> (List: [LocationGroup], Count: Int32) {
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
        let countSet: FMResultSet! = sharedModelManager.database!.executeQuery("SELECT COUNT([RowId]) FROM [LocationGroup] " + whereClause + orderByClause, withArgumentsIn: whereValues)
        if (countSet != nil) {
            while countSet.next() {
                count = countSet.int(forColumnIndex: 0)
            }
        }
        
        if (count > 0)
        {
            var pageClause: String = String()
            if (pageSize != nil && pageNumber != nil)
            {
                pageClause = " LIMIT " + String(pageSize!) + " OFFSET " + String((pageNumber! - 1) * pageSize!)
            }
            
            let resultSet: FMResultSet! = sharedModelManager.database!.executeQuery("SELECT [RowId], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [Deleted], [PropertyId], [Type], [Name], [Description], [OccupantRiskFactor] FROM [LocationGroup] " + whereClause + orderByClause + pageClause, withArgumentsIn: whereValues)
            if (resultSet != nil) {
                while resultSet.next() {
                    let locationGroup : LocationGroup = LocationGroup()
                    locationGroup.RowId = resultSet.string(forColumn: "RowId")!
                    locationGroup.CreatedBy = resultSet.string(forColumn: "CreatedBy")!
                    locationGroup.CreatedOn = resultSet.date(forColumn: "CreatedOn")!
                    if !resultSet.columnIsNull("LastUpdatedBy")
                    {
                        locationGroup.LastUpdatedBy = resultSet.string(forColumn: "LastUpdatedBy")
                    }
                    if !resultSet.columnIsNull("LastUpdatedOn")
                    {
                        locationGroup.LastUpdatedOn = resultSet.date(forColumn: "LastUpdatedOn")
                    }
                    if !resultSet.columnIsNull("Deleted")
                    {
                        locationGroup.Deleted = resultSet.date(forColumn: "Deleted")
                    }
                    locationGroup.PropertyId = resultSet.string(forColumn: "PropertyId")!
                    if !resultSet.columnIsNull("Type") {
                        locationGroup.LocationGroupType = resultSet.string(forColumn: "Type")
                    }
                    if !resultSet.columnIsNull("Name") {
                        locationGroup.Name = resultSet.string(forColumn: "Name")
                    }
                    if !resultSet.columnIsNull("Description") {
                        locationGroup.Description = resultSet.string(forColumn: "Description")
                    }
                    if !resultSet.columnIsNull("OccupantRiskFactor") {
                        locationGroup.OccupantRiskFactor = resultSet.string(forColumn: "OccupantRiskFactor")
                    }
                    
                    
                    locationGroupList.append(locationGroup)
                }
            }
        }
        
        sharedModelManager.database!.close()
        return (locationGroupList, count)
    }
    
    // MARK: - LocationGroupMembership
    
    func addLocationGroupMembership(_ locationGroupMembership: LocationGroupMembership) -> Bool {
        //build the sql statemnt
        var SQLStatement: String = String()
        var SQLParameterNames: String = String()
        var SQLParameterPlaceholders: String = String()
        var SQLParameterValues: [NSObject] = [NSObject]()
        
        SQLParameterNames = "[RowId], [CreatedBy], [CreatedOn]"
        SQLParameterPlaceholders = "?, ?, ?"
        SQLParameterValues.append(locationGroupMembership.RowId as NSObject)
        SQLParameterValues.append(locationGroupMembership.CreatedBy as NSObject)
        SQLParameterValues.append(locationGroupMembership.CreatedOn as NSObject)
        
        if locationGroupMembership.LastUpdatedBy != nil {
            SQLParameterNames += ", [LastUpdatedBy]"
            SQLParameterPlaceholders += ", ?"
            SQLParameterValues.append(locationGroupMembership.LastUpdatedBy! as NSObject)
        }
        
        if locationGroupMembership.LastUpdatedOn != nil {
            SQLParameterNames += ", [LastUpdatedOn]"
            SQLParameterPlaceholders += ", ?"
            SQLParameterValues.append(locationGroupMembership.LastUpdatedOn! as NSObject)
        }
        
        if locationGroupMembership.Deleted != nil {
            SQLParameterNames += ", [Deleted]"
            SQLParameterPlaceholders += ", ?"
            SQLParameterValues.append(locationGroupMembership.Deleted! as NSObject)
        }
        SQLParameterNames += ", [LocationGroupId]"
        SQLParameterPlaceholders += ", ?"
        SQLParameterValues.append(locationGroupMembership.LocationGroupId as NSObject)
        SQLParameterNames += ", [LocationId]"
        SQLParameterPlaceholders += ", ?"
        SQLParameterValues.append(locationGroupMembership.LocationId as NSObject)
        
        SQLStatement = "INSERT INTO [LocationGroupMembership] (" + SQLParameterNames + ") VALUES (" + SQLParameterPlaceholders + ")"
        
        sharedModelManager.database!.open()
        let isInserted = sharedModelManager.database!.executeUpdate(SQLStatement, withArgumentsIn: SQLParameterValues)
        sharedModelManager.database!.close()
        return isInserted
    }
    
    func updateLocationGroupMembership(_ locationGroupMembership: LocationGroupMembership) -> Bool {
        //build the sql statemnt
        var SQLStatement: String = String()
        var SQLParameterNames: String = String()
        var SQLParameterValues: [NSObject] = [NSObject]()
        
        SQLParameterNames = "[CreatedBy]=?, [CreatedOn]=?"
        SQLParameterValues.append(locationGroupMembership.CreatedBy as NSObject)
        SQLParameterValues.append(locationGroupMembership.CreatedOn as NSObject)
        
        if locationGroupMembership.LastUpdatedBy != nil {
            SQLParameterNames += ", [LastUpdatedBy]=?"
            SQLParameterValues.append(locationGroupMembership.LastUpdatedBy! as NSObject)
        }
        
        if locationGroupMembership.LastUpdatedOn != nil {
            SQLParameterNames += ", [LastUpdatedOn]=?"
            SQLParameterValues.append(locationGroupMembership.LastUpdatedOn! as NSObject)
        }
        
        if locationGroupMembership.Deleted != nil {
            SQLParameterNames += ", [Deleted]=?"
            SQLParameterValues.append(locationGroupMembership.Deleted! as NSObject)
        }
        SQLParameterNames += ", [LocationGroupId]=?"
        SQLParameterValues.append(locationGroupMembership.LocationGroupId as NSObject)
        SQLParameterNames += ", [LocationId]=?"
        SQLParameterValues.append(locationGroupMembership.LocationId as NSObject)
        
        SQLParameterValues.append(locationGroupMembership.RowId as NSObject)
        
        SQLStatement = "UPDATE [LocationGroupMembership] SET " + SQLParameterNames + "WHERE [RowId]=?"
        
        sharedModelManager.database!.open()
        let isUpdated = sharedModelManager.database!.executeUpdate(SQLStatement, withArgumentsIn: SQLParameterValues)
        sharedModelManager.database!.close()
        return isUpdated
    }
    
    func deleteLocationGroupMembership(_ locationGroupMembership: LocationGroupMembership) -> Bool {
        sharedModelManager.database!.open()
        let isDeleted = sharedModelManager.database!.executeUpdate("DELETE FROM [LocationGroupMembership] WHERE [RowId]=?", withArgumentsIn: [locationGroupMembership.RowId])
        sharedModelManager.database!.close()
        return isDeleted
    }
    
    func getLocationGroupMembership(_ locationGroupMembershipId: String) -> LocationGroupMembership? {
        sharedModelManager.database!.open()
        var locationGroupMembership: LocationGroupMembership? = nil
        
        let resultSet = sharedModelManager.database!.executeQuery("SELECT [RowId], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [Deleted], [LocationGroupId], [LocationId] FROM [LocationGroupMembership] WHERE [RowId]=?", withArgumentsIn: [locationGroupMembershipId])
        if (resultSet != nil) {
            while (resultSet?.next())! {
                var resultLocationGroupMembership: LocationGroupMembership = LocationGroupMembership()
                resultLocationGroupMembership = LocationGroupMembership()
                resultLocationGroupMembership.RowId = (resultSet?.string(forColumn: "RowId"))!
                resultLocationGroupMembership.CreatedBy = (resultSet?.string(forColumn: "CreatedBy"))!
                resultLocationGroupMembership.CreatedOn = resultSet!.date(forColumn: "CreatedOn")!
                if !(resultSet?.columnIsNull("LastUpdatedBy"))!
                {
                    resultLocationGroupMembership.LastUpdatedBy = resultSet?.string(forColumn: "LastUpdatedBy")
                }
                if !(resultSet?.columnIsNull("LastUpdatedOn"))!
                {
                    resultLocationGroupMembership.LastUpdatedOn = resultSet?.date(forColumn: "LastUpdatedOn")
                }
                if !(resultSet?.columnIsNull("Deleted"))!
                {
                    resultLocationGroupMembership.Deleted = resultSet?.date(forColumn: "Deleted")
                }
                resultLocationGroupMembership.LocationGroupId = (resultSet?.string(forColumn: "LocationGroupId"))!
                resultLocationGroupMembership.LocationId = (resultSet?.string(forColumn: "LocationId"))!
                
                locationGroupMembership = resultLocationGroupMembership
            }
        }
        sharedModelManager.database!.close()
        return locationGroupMembership
    }
    
    func getAllLocationGroupMembership() -> [LocationGroupMembership] {
        sharedModelManager.database!.open()
        let resultSet: FMResultSet! = sharedModelManager.database!.executeQuery("SELECT [RowId], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [Deleted], [LocationGroupId], [LocationId] FROM [LocationGroupMembership]", withArgumentsIn: [])
        var locationGroupMembershipList : [LocationGroupMembership] = [LocationGroupMembership]()
        if (resultSet != nil) {
            while resultSet.next() {
                let locationGroupMembership : LocationGroupMembership = LocationGroupMembership()
                locationGroupMembership.RowId = resultSet.string(forColumn: "RowId")!
                locationGroupMembership.CreatedBy = resultSet.string(forColumn: "CreatedBy")!
                locationGroupMembership.CreatedOn = resultSet.date(forColumn: "CreatedOn")!
                if !resultSet.columnIsNull("LastUpdatedBy")
                {
                    locationGroupMembership.LastUpdatedBy = resultSet.string(forColumn: "LastUpdatedBy")
                }
                if !resultSet.columnIsNull("LastUpdatedOn")
                {
                    locationGroupMembership.LastUpdatedOn = resultSet.date(forColumn: "LastUpdatedOn")
                }
                if !resultSet.columnIsNull("Deleted")
                {
                    locationGroupMembership.Deleted = resultSet.date(forColumn: "Deleted")
                }
                locationGroupMembership.LocationGroupId = resultSet.string(forColumn: "LocationGroupId")!
                locationGroupMembership.LocationId = resultSet.string(forColumn: "LocationId")!
                
                locationGroupMembershipList.append(locationGroupMembership)
            }
        }
        sharedModelManager.database!.close()
        return locationGroupMembershipList
    }
    
    func findLocationGroupMembershipList(_ criteria: Dictionary<String, AnyObject>) -> [LocationGroupMembership] {
        var list: [LocationGroupMembership] = [LocationGroupMembership]()
        //var count: Int32 = 0
        (list, _) = findLocationGroupMembershipList(criteria, pageSize: nil, pageNumber: nil)
        return list
    }
    
    func findLocationGroupMembershipList(_ criteria: Dictionary<String, AnyObject>, pageSize: Int32?, pageNumber: Int32?) -> (List: [LocationGroupMembership], Count: Int32) {
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
        let countSet: FMResultSet! = sharedModelManager.database!.executeQuery("SELECT COUNT([RowId]) FROM [LocationGroupMembership] " + whereClause, withArgumentsIn: whereValues)
        if (countSet != nil) {
            while countSet.next() {
                count = countSet.int(forColumnIndex: 0)
            }
        }
        
        if (count > 0)
        {
            var pageClause: String = String()
            if (pageSize != nil && pageNumber != nil)
            {
                pageClause = " LIMIT " + String(pageSize!) + " OFFSET " + String((pageNumber! - 1) * pageSize!)
            }
            
            let resultSet: FMResultSet! = sharedModelManager.database!.executeQuery("SELECT [RowId], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [Deleted], [LocationGroupId], [LocationId] FROM [LocationGroupMembership] " + whereClause + pageClause, withArgumentsIn: whereValues)
            if (resultSet != nil) {
                while resultSet.next() {
                    let locationGroupMembership : LocationGroupMembership = LocationGroupMembership()
                    locationGroupMembership.RowId = resultSet.string(forColumn: "RowId")!
                    locationGroupMembership.CreatedBy = resultSet.string(forColumn: "CreatedBy")!
                    locationGroupMembership.CreatedOn = resultSet.date(forColumn: "CreatedOn")!
                    if !resultSet.columnIsNull("LastUpdatedBy")
                    {
                        locationGroupMembership.LastUpdatedBy = resultSet.string(forColumn: "LastUpdatedBy")
                    }
                    if !resultSet.columnIsNull("LastUpdatedOn")
                    {
                        locationGroupMembership.LastUpdatedOn = resultSet.date(forColumn: "LastUpdatedOn")
                    }
                    if !resultSet.columnIsNull("Deleted")
                    {
                        locationGroupMembership.Deleted = resultSet.date(forColumn: "Deleted")
                    }
                    locationGroupMembership.LocationGroupId = resultSet.string(forColumn: "LocationGroupId")!
                    locationGroupMembership.LocationId = resultSet.string(forColumn: "LocationId")!
                    
                    locationGroupMembershipList.append(locationGroupMembership)
                }
            }
        }
        sharedModelManager.database!.close()
        return (locationGroupMembershipList, count)
    }
    
    // MARK: - Operative
    
    func addOperative(_ operative: Operative) -> Bool {
        //build the sql statemnt
        var SQLStatement: String = String()
        var SQLParameterNames: String = String()
        var SQLParameterPlaceholders: String = String()
        var SQLParameterValues: [NSObject] = [NSObject]()
        
        SQLParameterNames = "[RowId], [CreatedBy], [CreatedOn]"
        SQLParameterPlaceholders = "?, ?, ?"
        SQLParameterValues.append(operative.RowId as NSObject)
        SQLParameterValues.append(operative.CreatedBy as NSObject)
        SQLParameterValues.append(operative.CreatedOn as NSObject)
        
        if operative.LastUpdatedBy != nil {
            SQLParameterNames += ", [LastUpdatedBy]"
            SQLParameterPlaceholders += ", ?"
            SQLParameterValues.append(operative.LastUpdatedBy! as NSObject)
        }
        
        if operative.LastUpdatedOn != nil {
            SQLParameterNames += ", [LastUpdatedOn]"
            SQLParameterPlaceholders += ", ?"
            SQLParameterValues.append(operative.LastUpdatedOn! as NSObject)
        }
        
        if operative.Deleted != nil {
            SQLParameterNames += ", [Deleted]"
            SQLParameterPlaceholders += ", ?"
            SQLParameterValues.append(operative.Deleted! as NSObject)
        }
        
        SQLParameterNames += ", [OrganisationId], [Username], [Password]"
        SQLParameterPlaceholders += ", ?, ?, ?"
        SQLParameterValues.append(operative.OrganisationId as NSObject)
        SQLParameterValues.append(operative.Username as NSObject)
        SQLParameterValues.append(operative.Password as NSObject)
        
        SQLStatement = "INSERT INTO [OPERATIVE] (" + SQLParameterNames + ") VALUES (" + SQLParameterPlaceholders + ")"
        
        sharedModelManager.database!.open()
        let isInserted = sharedModelManager.database!.executeUpdate(SQLStatement, withArgumentsIn: SQLParameterValues)
        sharedModelManager.database!.close()
        return isInserted
    }
    
    func updateOperative(_ operative: Operative) -> Bool {
        //build the sql statemnt
        var SQLStatement: String = String()
        var SQLParameterNames: String = String()
        var SQLParameterValues: [NSObject] = [NSObject]()
        
        SQLParameterNames = "[CreatedBy]=?, [CreatedOn]=?"
        SQLParameterValues.append(operative.CreatedBy as NSObject)
        SQLParameterValues.append(operative.CreatedOn as NSObject)
        
        if operative.LastUpdatedBy != nil {
            SQLParameterNames += ", [LastUpdatedBy]=?"
            SQLParameterValues.append(operative.LastUpdatedBy! as NSObject)
        }
        
        if operative.LastUpdatedOn != nil {
            SQLParameterNames += ", [LastUpdatedOn]=?"
            SQLParameterValues.append(operative.LastUpdatedOn! as NSObject)
        }
        
        if operative.Deleted != nil {
            SQLParameterNames += ", [Deleted]=?"
            SQLParameterValues.append(operative.Deleted! as NSObject)
        }
        
        SQLParameterNames += ", [OrganisationId]=?, [Username]=?, [Password]=?"
        SQLParameterValues.append(operative.OrganisationId as NSObject)
        SQLParameterValues.append(operative.Username as NSObject)
        SQLParameterValues.append(operative.Password as NSObject)
        
        SQLParameterValues.append(operative.RowId as NSObject)
        
        SQLStatement = "UPDATE [OPERATIVE] SET " + SQLParameterNames + "WHERE [RowId]=?"
        
        sharedModelManager.database!.open()
        let isUpdated = sharedModelManager.database!.executeUpdate(SQLStatement, withArgumentsIn: SQLParameterValues)
        sharedModelManager.database!.close()
        return isUpdated
    }
    
    func deleteOperative(_ operative: Operative) -> Bool {
        sharedModelManager.database!.open()
        let isDeleted = sharedModelManager.database!.executeUpdate("DELETE FROM [OPERATIVE] WHERE [RowId]=?", withArgumentsIn: [operative.RowId])
        sharedModelManager.database!.close()
        return isDeleted
    }
    
    func getOperative(_ operativeId: String) -> Operative? {
        sharedModelManager.database!.open()
        var operative: Operative? = nil
        
        let resultSet = sharedModelManager.database!.executeQuery("SELECT [RowId], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [Deleted], [OrganisationId], [Username], [Password] FROM [Operative] WHERE [RowId]=?", withArgumentsIn: [operativeId])
        if (resultSet != nil) {
            while (resultSet?.next())! {
                var resultOperative: Operative = Operative()
                resultOperative = Operative()
                resultOperative.RowId = (resultSet?.string(forColumn: "RowId"))!
                resultOperative.CreatedBy = (resultSet?.string(forColumn: "CreatedBy"))!
                resultOperative.CreatedOn = resultSet!.date(forColumn: "CreatedOn")!
                if !(resultSet?.columnIsNull("LastUpdatedBy"))!
                {
                    resultOperative.LastUpdatedBy = resultSet?.string(forColumn: "LastUpdatedBy")
                }
                if !(resultSet?.columnIsNull("LastUpdatedOn"))!
                {
                    resultOperative.LastUpdatedOn = resultSet?.date(forColumn: "LastUpdatedOn")
                }
                if !(resultSet?.columnIsNull("Deleted"))!
                {
                    resultOperative.Deleted = resultSet?.date(forColumn: "Deleted")
                }
                resultOperative.OrganisationId = (resultSet?.string(forColumn: "OrganisationId"))!
                resultOperative.Username = (resultSet?.string(forColumn: "Username"))!
                resultOperative.Password = (resultSet?.string(forColumn: "Password"))!
                
                operative = resultOperative
            }
        }
        sharedModelManager.database!.close()
        return operative
    }
    
    func getAllOperative() -> [Operative] {
        sharedModelManager.database!.open()
        let resultSet: FMResultSet! = sharedModelManager.database!.executeQuery("SELECT [RowId], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [Deleted], [OrganisationId], [Username], [Password] FROM [Operative]", withArgumentsIn: [])
        var operativeList: [Operative] = [Operative]()
        if (resultSet != nil) {
            while resultSet.next() {
                let operative : Operative = Operative()
                operative.RowId = resultSet.string(forColumn: "RowId")!
                operative.CreatedBy = resultSet.string(forColumn: "CreatedBy")!
                operative.CreatedOn = resultSet.date(forColumn: "CreatedOn")!
                if !resultSet.columnIsNull("LastUpdatedBy")
                {
                    operative.LastUpdatedBy = resultSet.string(forColumn: "LastUpdatedBy")
                }
                if !resultSet.columnIsNull("LastUpdatedOn")
                {
                    operative.LastUpdatedOn = resultSet.date(forColumn: "LastUpdatedOn")
                }
                if !resultSet.columnIsNull("Deleted")
                {
                    operative.Deleted = resultSet.date(forColumn: "Deleted")
                }
                operative.OrganisationId = resultSet.string(forColumn: "OrganisationId")!
                operative.Username = resultSet.string(forColumn: "Username")!
                operative.Password = resultSet.string(forColumn: "Password")!
                
                operativeList.append(operative)
            }
        }
        sharedModelManager.database!.close()
        return operativeList
    }
    
    func findOperativeList(_ criteria: Dictionary<String, AnyObject>) -> [Operative] {
        var list: [Operative] = [Operative]()
        //var count: Int32 = 0
        (list, _) = findOperativeList(criteria, pageSize: nil, pageNumber: nil)
        return list
    }
    
    func findOperativeList(_ criteria: Dictionary<String, AnyObject>, pageSize: Int32?, pageNumber: Int32?) -> (List: [Operative], Count: Int32) {
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
        let countSet: FMResultSet! = sharedModelManager.database!.executeQuery("SELECT COUNT([RowId]) FROM [Operative] " + whereClause + orderByClause, withArgumentsIn: whereValues)
        if (countSet != nil) {
            while countSet.next() {
                count = countSet.int(forColumnIndex: 0)
            }
        }
        
        if (count > 0)
        {
            var pageClause: String = String()
            if (pageSize != nil && pageNumber != nil)
            {
                pageClause = " LIMIT " + String(pageSize!) + " OFFSET " + String((pageNumber! - 1) * pageSize!)
            }
            
            let resultSet: FMResultSet! = sharedModelManager.database!.executeQuery("SELECT [RowId], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [Deleted], [OrganisationId], [Username], [Password] FROM [Operative] " + whereClause + orderByClause + pageClause, withArgumentsIn: whereValues)
            if (resultSet != nil) {
                while resultSet.next() {
                    let operative : Operative = Operative()
                    operative.RowId = resultSet.string(forColumn: "RowId")!
                    operative.CreatedBy = resultSet.string(forColumn: "CreatedBy")!
                    operative.CreatedOn = resultSet.date(forColumn: "CreatedOn")!
                    if !resultSet.columnIsNull("LastUpdatedBy")
                    {
                        operative.LastUpdatedBy = resultSet.string(forColumn: "LastUpdatedBy")
                    }
                    if !resultSet.columnIsNull("LastUpdatedOn")
                    {
                        operative.LastUpdatedOn = resultSet.date(forColumn: "LastUpdatedOn")
                    }
                    if !resultSet.columnIsNull("Deleted")
                    {
                        operative.Deleted = resultSet.date(forColumn: "Deleted")
                    }
                    operative.OrganisationId = resultSet.string(forColumn: "OrganisationId")!
                    operative.Username = resultSet.string(forColumn: "Username")!
                    operative.Password = resultSet.string(forColumn: "Password")!
                    
                    operativeList.append(operative)
                }
            }
        }
        
        sharedModelManager.database!.close()
        return (operativeList, count)
    }
    
    // MARK: - OperativeGroup
    
    func addOperativeGroup(_ operativeGroup: OperativeGroup) -> Bool {
        //build the sql statemnt
        var SQLStatement: String = String()
        var SQLParameterNames: String = String()
        var SQLParameterPlaceholders: String = String()
        var SQLParameterValues: [NSObject] = [NSObject]()
        
        SQLParameterNames = "[RowId], [CreatedBy], [CreatedOn]"
        SQLParameterPlaceholders = "?, ?, ?"
        SQLParameterValues.append(operativeGroup.RowId as NSObject)
        SQLParameterValues.append(operativeGroup.CreatedBy as NSObject)
        SQLParameterValues.append(operativeGroup.CreatedOn as NSObject)
        
        if operativeGroup.LastUpdatedBy != nil {
            SQLParameterNames += ", [LastUpdatedBy]"
            SQLParameterPlaceholders += ", ?"
            SQLParameterValues.append(operativeGroup.LastUpdatedBy! as NSObject)
        }
        
        if operativeGroup.LastUpdatedOn != nil {
            SQLParameterNames += ", [LastUpdatedOn]"
            SQLParameterPlaceholders += ", ?"
            SQLParameterValues.append(operativeGroup.LastUpdatedOn! as NSObject)
        }
        
        if operativeGroup.Deleted != nil {
            SQLParameterNames += ", [Deleted]"
            SQLParameterPlaceholders += ", ?"
            SQLParameterValues.append(operativeGroup.Deleted! as NSObject)
        }
        SQLParameterNames += ", [OrganisationId]"
        SQLParameterPlaceholders += ", ?"
        SQLParameterValues.append(operativeGroup.OrganisationId as NSObject)
        if operativeGroup.Name != nil {
            SQLParameterNames += ", [Name]"
            SQLParameterPlaceholders += ", ?"
            SQLParameterValues.append(operativeGroup.Name! as NSObject)
        }
        SQLStatement = "INSERT INTO [OperativeGroup] (" + SQLParameterNames + ") VALUES (" + SQLParameterPlaceholders + ")"
        
        sharedModelManager.database!.open()
        let isInserted = sharedModelManager.database!.executeUpdate(SQLStatement, withArgumentsIn: SQLParameterValues)
        sharedModelManager.database!.close()
        return isInserted
    }
    
    func updateOperativeGroup(_ operativeGroup: OperativeGroup) -> Bool {
        //build the sql statemnt
        var SQLStatement: String = String()
        var SQLParameterNames: String = String()
        var SQLParameterValues: [NSObject] = [NSObject]()
        
        SQLParameterNames = "[CreatedBy]=?, [CreatedOn]=?"
        SQLParameterValues.append(operativeGroup.CreatedBy as NSObject)
        SQLParameterValues.append(operativeGroup.CreatedOn as NSObject)
        
        if operativeGroup.LastUpdatedBy != nil {
            SQLParameterNames += ", [LastUpdatedBy]=?"
            SQLParameterValues.append(operativeGroup.LastUpdatedBy! as NSObject)
        }
        
        if operativeGroup.LastUpdatedOn != nil {
            SQLParameterNames += ", [LastUpdatedOn]=?"
            SQLParameterValues.append(operativeGroup.LastUpdatedOn! as NSObject)
        }
        
        if operativeGroup.Deleted != nil {
            SQLParameterNames += ", [Deleted]=?"
            SQLParameterValues.append(operativeGroup.Deleted! as NSObject)
        }
        SQLParameterNames += ", [OrganisationId]=?"
        SQLParameterValues.append(operativeGroup.OrganisationId as NSObject)
        if operativeGroup.Name != nil {
            SQLParameterNames += ", [Name]=?"
            SQLParameterValues.append(operativeGroup.Name! as NSObject)
        }
        
        SQLParameterValues.append(operativeGroup.RowId as NSObject)
        
        SQLStatement = "UPDATE [OperativeGroup] SET " + SQLParameterNames + "WHERE [RowId]=?"
        
        sharedModelManager.database!.open()
        let isUpdated = sharedModelManager.database!.executeUpdate(SQLStatement, withArgumentsIn: SQLParameterValues)
        sharedModelManager.database!.close()
        return isUpdated
    }
    
    func deleteOperativeGroup(_ operativeGroup: OperativeGroup) -> Bool {
        sharedModelManager.database!.open()
        let isDeleted = sharedModelManager.database!.executeUpdate("DELETE FROM [OperativeGroup] WHERE [RowId]=?", withArgumentsIn: [operativeGroup.RowId])
        sharedModelManager.database!.close()
        return isDeleted
    }
    
    func getOperativeGroup(_ operativeGroupId: String) -> OperativeGroup? {
        sharedModelManager.database!.open()
        var operativeGroup: OperativeGroup? = nil
        
        let resultSet = sharedModelManager.database!.executeQuery("SELECT [RowId], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [Deleted], [OrganisationId], [Name] FROM [OperativeGroup] WHERE [RowId]=?", withArgumentsIn: [operativeGroupId])
        if (resultSet != nil) {
            while (resultSet?.next())! {
                var resultOperativeGroup: OperativeGroup = OperativeGroup()
                resultOperativeGroup = OperativeGroup()
                resultOperativeGroup.RowId = (resultSet?.string(forColumn: "RowId"))!
                resultOperativeGroup.CreatedBy = (resultSet?.string(forColumn: "CreatedBy"))!
                resultOperativeGroup.CreatedOn = resultSet!.date(forColumn: "CreatedOn")!
                if !(resultSet?.columnIsNull("LastUpdatedBy"))!
                {
                    resultOperativeGroup.LastUpdatedBy = resultSet?.string(forColumn: "LastUpdatedBy")
                }
                if !(resultSet?.columnIsNull("LastUpdatedOn"))!
                {
                    resultOperativeGroup.LastUpdatedOn = resultSet?.date(forColumn: "LastUpdatedOn")
                }
                if !(resultSet?.columnIsNull("Deleted"))!
                {
                    resultOperativeGroup.Deleted = resultSet?.date(forColumn: "Deleted")
                }
                resultOperativeGroup.OrganisationId = (resultSet?.string(forColumn: "OrganisationId"))!
                if !(resultSet?.columnIsNull("Name"))! {
                    resultOperativeGroup.Name = resultSet?.string(forColumn: "Name")
                }
                
                operativeGroup = resultOperativeGroup
            }
        }
        sharedModelManager.database!.close()
        return operativeGroup
    }
    
    func getAllOperativeGroup() -> [OperativeGroup] {
        sharedModelManager.database!.open()
        let resultSet: FMResultSet! = sharedModelManager.database!.executeQuery("SELECT [RowId], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [Deleted], [OrganisationId], [Name] FROM [OperativeGroup]", withArgumentsIn: [])
        var operativeGroupList : [OperativeGroup] = [OperativeGroup]()
        if (resultSet != nil) {
            while resultSet.next() {
                let operativeGroup : OperativeGroup = OperativeGroup()
                operativeGroup.RowId = resultSet.string(forColumn: "RowId")!
                operativeGroup.CreatedBy = resultSet.string(forColumn: "CreatedBy")!
                operativeGroup.CreatedOn = resultSet.date(forColumn: "CreatedOn")!
                if !resultSet.columnIsNull("LastUpdatedBy")
                {
                    operativeGroup.LastUpdatedBy = resultSet.string(forColumn: "LastUpdatedBy")
                }
                if !resultSet.columnIsNull("LastUpdatedOn")
                {
                    operativeGroup.LastUpdatedOn = resultSet.date(forColumn: "LastUpdatedOn")
                }
                if !resultSet.columnIsNull("Deleted")
                {
                    operativeGroup.Deleted = resultSet.date(forColumn: "Deleted")
                }
                operativeGroup.OrganisationId = resultSet.string(forColumn: "OrganisationId")!
                if !resultSet.columnIsNull("Name") {
                    operativeGroup.Name = resultSet.string(forColumn: "Name")
                }
                operativeGroupList.append(operativeGroup)
                
            }
        }
        sharedModelManager.database!.close()
        return operativeGroupList
    }
    
    func findOperativeGroupList(_ criteria: Dictionary<String, AnyObject>) -> [OperativeGroup] {
        var list: [OperativeGroup] = [OperativeGroup]()
        //var count: Int32 = 0
        (list, _) = findOperativeGroupList(criteria, pageSize: nil, pageNumber: nil)
        return list
    }
    
    func findOperativeGroupList(_ criteria: Dictionary<String, AnyObject>, pageSize: Int32?, pageNumber: Int32?) -> (List: [OperativeGroup], Count: Int32) {
        //return variables
        var count: Int32 = 0
        var operativeGroupList: [OperativeGroup] = [OperativeGroup]()
        
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
        let countSet: FMResultSet! = sharedModelManager.database!.executeQuery("SELECT COUNT([RowId]) FROM [OperativeGroup] " + whereClause + orderByClause, withArgumentsIn: whereValues)
        if (countSet != nil) {
            while countSet.next() {
                count = countSet.int(forColumnIndex: 0)
            }
        }
        
        if (count > 0)
        {
            var pageClause: String = String()
            if (pageSize != nil && pageNumber != nil)
            {
                pageClause = " LIMIT " + String(pageSize!) + " OFFSET " + String((pageNumber! - 1) * pageSize!)
            }
            
            let resultSet: FMResultSet! = sharedModelManager.database!.executeQuery("SELECT [RowId], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [Deleted], [OrganisationId], [Name] FROM [OperativeGroup] " + whereClause + orderByClause + pageClause, withArgumentsIn: whereValues)
            if (resultSet != nil) {
                while resultSet.next() {
                    let operativeGroup : OperativeGroup = OperativeGroup()
                    operativeGroup.RowId = resultSet.string(forColumn: "RowId")!
                    operativeGroup.CreatedBy = resultSet.string(forColumn: "CreatedBy")!
                    operativeGroup.CreatedOn = resultSet.date(forColumn: "CreatedOn")!
                    if !resultSet.columnIsNull("LastUpdatedBy")
                    {
                        operativeGroup.LastUpdatedBy = resultSet.string(forColumn: "LastUpdatedBy")
                    }
                    if !resultSet.columnIsNull("LastUpdatedOn")
                    {
                        operativeGroup.LastUpdatedOn = resultSet.date(forColumn: "LastUpdatedOn")
                    }
                    if !resultSet.columnIsNull("Deleted")
                    {
                        operativeGroup.Deleted = resultSet.date(forColumn: "Deleted")
                    }
                    operativeGroup.OrganisationId = resultSet.string(forColumn: "OrganisationId")!
                    if !resultSet.columnIsNull("Name") {
                        operativeGroup.Name = resultSet.string(forColumn: "Name")
                    }
                    
                    operativeGroupList.append(operativeGroup)
                }
            }
        }
        
        sharedModelManager.database!.close()
        return (operativeGroupList, count)
    }
    
    // MARK: - OperativeGroupMembership
    
    func addOperativeGroupMembership(_ operativeGroupMembership: OperativeGroupMembership) -> Bool {
        //build the sql statemnt
        var SQLStatement: String = String()
        var SQLParameterNames: String = String()
        var SQLParameterPlaceholders: String = String()
        var SQLParameterValues: [NSObject] = [NSObject]()
        
        SQLParameterNames = "[RowId], [CreatedBy], [CreatedOn]"
        SQLParameterPlaceholders = "?, ?, ?"
        SQLParameterValues.append(operativeGroupMembership.RowId as NSObject)
        SQLParameterValues.append(operativeGroupMembership.CreatedBy as NSObject)
        SQLParameterValues.append(operativeGroupMembership.CreatedOn as NSObject)
        
        if operativeGroupMembership.LastUpdatedBy != nil {
            SQLParameterNames += ", [LastUpdatedBy]"
            SQLParameterPlaceholders += ", ?"
            SQLParameterValues.append(operativeGroupMembership.LastUpdatedBy! as NSObject)
        }
        
        if operativeGroupMembership.LastUpdatedOn != nil {
            SQLParameterNames += ", [LastUpdatedOn]"
            SQLParameterPlaceholders += ", ?"
            SQLParameterValues.append(operativeGroupMembership.LastUpdatedOn! as NSObject)
        }
        
        if operativeGroupMembership.Deleted != nil {
            SQLParameterNames += ", [Deleted]"
            SQLParameterPlaceholders += ", ?"
            SQLParameterValues.append(operativeGroupMembership.Deleted! as NSObject)
        }
        SQLParameterNames += ", [OperativeGroupId]"
        SQLParameterPlaceholders += ", ?"
        SQLParameterValues.append(operativeGroupMembership.OperativeGroupId as NSObject)
        SQLParameterNames += ", [OperativeId]"
        SQLParameterPlaceholders += ", ?"
        SQLParameterValues.append(operativeGroupMembership.OperativeId as NSObject)
        
        SQLStatement = "INSERT INTO [OperativeGroupMembership] (" + SQLParameterNames + ") VALUES (" + SQLParameterPlaceholders + ")"
        
        sharedModelManager.database!.open()
        let isInserted = sharedModelManager.database!.executeUpdate(SQLStatement, withArgumentsIn: SQLParameterValues)
        sharedModelManager.database!.close()
        return isInserted
    }
    
    func updateOperativeGroupMembership(_ operativeGroupMembership: OperativeGroupMembership) -> Bool {
        //build the sql statemnt
        var SQLStatement: String = String()
        var SQLParameterNames: String = String()
        var SQLParameterValues: [NSObject] = [NSObject]()
        
        SQLParameterNames = "[CreatedBy]=?, [CreatedOn]=?"
        SQLParameterValues.append(operativeGroupMembership.CreatedBy as NSObject)
        SQLParameterValues.append(operativeGroupMembership.CreatedOn as NSObject)
        
        if operativeGroupMembership.LastUpdatedBy != nil {
            SQLParameterNames += ", [LastUpdatedBy]=?"
            SQLParameterValues.append(operativeGroupMembership.LastUpdatedBy! as NSObject)
        }
        
        if operativeGroupMembership.LastUpdatedOn != nil {
            SQLParameterNames += ", [LastUpdatedOn]=?"
            SQLParameterValues.append(operativeGroupMembership.LastUpdatedOn! as NSObject)
        }
        
        if operativeGroupMembership.Deleted != nil {
            SQLParameterNames += ", [Deleted]=?"
            SQLParameterValues.append(operativeGroupMembership.Deleted! as NSObject)
        }
        SQLParameterNames += ", [OperativeGroupId]=?"
        SQLParameterValues.append(operativeGroupMembership.OperativeGroupId as NSObject)
        SQLParameterNames += ", [OperativeId]=?"
        SQLParameterValues.append(operativeGroupMembership.OperativeId as NSObject)
        
        SQLParameterValues.append(operativeGroupMembership.RowId as NSObject)
        
        SQLStatement = "UPDATE [OperativeGroupMembership] SET " + SQLParameterNames + "WHERE [RowId]=?"
        
        sharedModelManager.database!.open()
        let isUpdated = sharedModelManager.database!.executeUpdate(SQLStatement, withArgumentsIn: SQLParameterValues)
        sharedModelManager.database!.close()
        return isUpdated
    }
    
    func deleteOperativeGroupMembership(_ operativeGroupMembership: OperativeGroupMembership) -> Bool {
        sharedModelManager.database!.open()
        let isDeleted = sharedModelManager.database!.executeUpdate("DELETE FROM [OperativeGroupMembership] WHERE [RowId]=?", withArgumentsIn: [operativeGroupMembership.RowId])
        sharedModelManager.database!.close()
        return isDeleted
    }
    
    func getOperativeGroupMembership(_ operativeGroupMembershipId: String) -> OperativeGroupMembership? {
        sharedModelManager.database!.open()
        var operativeGroupMembership: OperativeGroupMembership? = nil
        
        let resultSet = sharedModelManager.database!.executeQuery("SELECT [RowId], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [Deleted], [OperativeGroupId], [OperativeId] FROM [OperativeGroupMembership] WHERE [RowId]=?", withArgumentsIn: [operativeGroupMembershipId])
        if (resultSet != nil) {
            while (resultSet?.next())! {
                var resultOperativeGroupMembership: OperativeGroupMembership = OperativeGroupMembership()
                resultOperativeGroupMembership = OperativeGroupMembership()
                resultOperativeGroupMembership.RowId = (resultSet?.string(forColumn: "RowId"))!
                resultOperativeGroupMembership.CreatedBy = (resultSet?.string(forColumn: "CreatedBy"))!
                resultOperativeGroupMembership.CreatedOn = resultSet!.date(forColumn: "CreatedOn")!
                if !(resultSet?.columnIsNull("LastUpdatedBy"))!
                {
                    resultOperativeGroupMembership.LastUpdatedBy = resultSet?.string(forColumn: "LastUpdatedBy")
                }
                if !(resultSet?.columnIsNull("LastUpdatedOn"))!
                {
                    resultOperativeGroupMembership.LastUpdatedOn = resultSet?.date(forColumn: "LastUpdatedOn")
                }
                if !(resultSet?.columnIsNull("Deleted"))!
                {
                    resultOperativeGroupMembership.Deleted = resultSet?.date(forColumn: "Deleted")
                }
                resultOperativeGroupMembership.OperativeGroupId = (resultSet?.string(forColumn: "OperativeGroupId"))!
                resultOperativeGroupMembership.OperativeId = (resultSet?.string(forColumn: "OperativeId"))!
                
                operativeGroupMembership = resultOperativeGroupMembership
            }
        }
        sharedModelManager.database!.close()
        return operativeGroupMembership
    }
    
    func getAllOperativeGroupMembership() -> [OperativeGroupMembership] {
        sharedModelManager.database!.open()
        let resultSet: FMResultSet! = sharedModelManager.database!.executeQuery("SELECT [RowId], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [Deleted], [OperativeGroupId], [OperativeId] FROM [OperativeGroupMembership]", withArgumentsIn: [])
        var operativeGroupMembershipList : [OperativeGroupMembership] = [OperativeGroupMembership]()
        if (resultSet != nil) {
            while resultSet.next() {
                let operativeGroupMembership : OperativeGroupMembership = OperativeGroupMembership()
                operativeGroupMembership.RowId = resultSet.string(forColumn: "RowId")!
                operativeGroupMembership.CreatedBy = resultSet.string(forColumn: "CreatedBy")!
                operativeGroupMembership.CreatedOn = resultSet.date(forColumn: "CreatedOn")!
                if !resultSet.columnIsNull("LastUpdatedBy")
                {
                    operativeGroupMembership.LastUpdatedBy = resultSet.string(forColumn: "LastUpdatedBy")
                }
                if !resultSet.columnIsNull("LastUpdatedOn")
                {
                    operativeGroupMembership.LastUpdatedOn = resultSet.date(forColumn: "LastUpdatedOn")
                }
                if !resultSet.columnIsNull("Deleted")
                {
                    operativeGroupMembership.Deleted = resultSet.date(forColumn: "Deleted")
                }
                operativeGroupMembership.OperativeGroupId = resultSet.string(forColumn: "OperativeGroupId")!
                operativeGroupMembership.OperativeId = resultSet.string(forColumn: "OperativeId")!
                
                operativeGroupMembershipList.append(operativeGroupMembership)
            }
        }
        sharedModelManager.database!.close()
        return operativeGroupMembershipList
    }
    
    func findOperativeGroupMembershipList(_ criteria: Dictionary<String, AnyObject>) -> [OperativeGroupMembership] {
        var list: [OperativeGroupMembership] = [OperativeGroupMembership]()
        //var count: Int32 = 0
        (list, _) = findOperativeGroupMembershipList(criteria, pageSize: nil, pageNumber: nil)
        return list
    }
    
    func findOperativeGroupMembershipList(_ criteria: Dictionary<String, AnyObject>, pageSize: Int32?, pageNumber: Int32?) -> (List: [OperativeGroupMembership], Count: Int32) {
        //return variables
        var count: Int32 = 0
        var operativeGroupMembershipList: [OperativeGroupMembership] = [OperativeGroupMembership]()
        
        //build the where clause
        var whereClause: String = String()
        var whereValues: [AnyObject] = [AnyObject]()
        
        (whereClause, whereValues) = buildWhereClause(criteria)
        
        if (whereClause != "")
        {
            whereClause = "WHERE " + whereClause
        }
        
        sharedModelManager.database!.open()
        let countSet: FMResultSet! = sharedModelManager.database!.executeQuery("SELECT COUNT([RowId]) FROM [OperativeGroupMembership] " + whereClause, withArgumentsIn: whereValues)
        if (countSet != nil) {
            while countSet.next() {
                count = countSet.int(forColumnIndex: 0)
            }
        }
        
        if (count > 0)
        {
            var pageClause: String = String()
            if (pageSize != nil && pageNumber != nil)
            {
                pageClause = " LIMIT " + String(pageSize!) + " OFFSET " + String((pageNumber! - 1) * pageSize!)
            }
            
            let resultSet: FMResultSet! = sharedModelManager.database!.executeQuery("SELECT [RowId], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [Deleted], [OperativeGroupId], [OperativeId] FROM [OperativeGroupMembership] " + whereClause + pageClause, withArgumentsIn: whereValues)
            if (resultSet != nil) {
                while resultSet.next() {
                    let operativeGroupMembership : OperativeGroupMembership = OperativeGroupMembership()
                    operativeGroupMembership.RowId = resultSet.string(forColumn: "RowId")!
                    operativeGroupMembership.CreatedBy = resultSet.string(forColumn: "CreatedBy")!
                    operativeGroupMembership.CreatedOn = resultSet.date(forColumn: "CreatedOn")!
                    if !resultSet.columnIsNull("LastUpdatedBy")
                    {
                        operativeGroupMembership.LastUpdatedBy = resultSet.string(forColumn: "LastUpdatedBy")
                    }
                    if !resultSet.columnIsNull("LastUpdatedOn")
                    {
                        operativeGroupMembership.LastUpdatedOn = resultSet.date(forColumn: "LastUpdatedOn")
                    }
                    if !resultSet.columnIsNull("Deleted")
                    {
                        operativeGroupMembership.Deleted = resultSet.date(forColumn: "Deleted")
                    }
                    operativeGroupMembership.OperativeGroupId = resultSet.string(forColumn: "OperativeGroupId")!
                    operativeGroupMembership.OperativeId = resultSet.string(forColumn: "OperativeId")!
                    
                    operativeGroupMembershipList.append(operativeGroupMembership)
                }
            }
        }
        sharedModelManager.database!.close()
        return (operativeGroupMembershipList, count)
    }
    
    // MARK: - OperativeGroupTaskTemplateMembership
    
    func addOperativeGroupTaskTemplateMembership(_ operativeGroupTaskTemplateMembership: OperativeGroupTaskTemplateMembership) -> Bool {
        //build the sql statemnt
        var SQLStatement: String = String()
        var SQLParameterNames: String = String()
        var SQLParameterPlaceholders: String = String()
        var SQLParameterValues: [NSObject] = [NSObject]()
        
        SQLParameterNames = "[RowId], [CreatedBy], [CreatedOn]"
        SQLParameterPlaceholders = "?, ?, ?"
        SQLParameterValues.append(operativeGroupTaskTemplateMembership.RowId as NSObject)
        SQLParameterValues.append(operativeGroupTaskTemplateMembership.CreatedBy as NSObject)
        SQLParameterValues.append(operativeGroupTaskTemplateMembership.CreatedOn as NSObject)
        
        if operativeGroupTaskTemplateMembership.LastUpdatedBy != nil {
            SQLParameterNames += ", [LastUpdatedBy]"
            SQLParameterPlaceholders += ", ?"
            SQLParameterValues.append(operativeGroupTaskTemplateMembership.LastUpdatedBy! as NSObject)
        }
        
        if operativeGroupTaskTemplateMembership.LastUpdatedOn != nil {
            SQLParameterNames += ", [LastUpdatedOn]"
            SQLParameterPlaceholders += ", ?"
            SQLParameterValues.append(operativeGroupTaskTemplateMembership.LastUpdatedOn! as NSObject)
        }
        
        if operativeGroupTaskTemplateMembership.Deleted != nil {
            SQLParameterNames += ", [Deleted]"
            SQLParameterPlaceholders += ", ?"
            SQLParameterValues.append(operativeGroupTaskTemplateMembership.Deleted! as NSObject)
        }
        SQLParameterNames += ", [OperativeGroupId]"
        SQLParameterPlaceholders += ", ?"
        SQLParameterValues.append(operativeGroupTaskTemplateMembership.OperativeGroupId as NSObject)
        SQLParameterNames += ", [TaskTemplateId]"
        SQLParameterPlaceholders += ", ?"
        SQLParameterValues.append(operativeGroupTaskTemplateMembership.TaskTemplateId as NSObject)
        
        SQLStatement = "INSERT INTO [OperativeGroupTaskTemplateMembership] (" + SQLParameterNames + ") VALUES (" + SQLParameterPlaceholders + ")"
        
        sharedModelManager.database!.open()
        let isInserted = sharedModelManager.database!.executeUpdate(SQLStatement, withArgumentsIn: SQLParameterValues)
        sharedModelManager.database!.close()
        return isInserted
    }
    
    func updateOperativeGroupTaskTemplateMembership(_ operativeGroupTaskTemplateMembership: OperativeGroupTaskTemplateMembership) -> Bool {
        //build the sql statemnt
        var SQLStatement: String = String()
        var SQLParameterNames: String = String()
        var SQLParameterValues: [NSObject] = [NSObject]()
        
        SQLParameterNames = "[CreatedBy]=?, [CreatedOn]=?"
        SQLParameterValues.append(operativeGroupTaskTemplateMembership.CreatedBy as NSObject)
        SQLParameterValues.append(operativeGroupTaskTemplateMembership.CreatedOn as NSObject)
        
        if operativeGroupTaskTemplateMembership.LastUpdatedBy != nil {
            SQLParameterNames += ", [LastUpdatedBy]=?"
            SQLParameterValues.append(operativeGroupTaskTemplateMembership.LastUpdatedBy! as NSObject)
        }
        
        if operativeGroupTaskTemplateMembership.LastUpdatedOn != nil {
            SQLParameterNames += ", [LastUpdatedOn]=?"
            SQLParameterValues.append(operativeGroupTaskTemplateMembership.LastUpdatedOn! as NSObject)
        }
        
        if operativeGroupTaskTemplateMembership.Deleted != nil {
            SQLParameterNames += ", [Deleted]=?"
            SQLParameterValues.append(operativeGroupTaskTemplateMembership.Deleted! as NSObject)
        }
        SQLParameterNames += ", [OperativeGroupId]=?"
        SQLParameterValues.append(operativeGroupTaskTemplateMembership.OperativeGroupId as NSObject)
        SQLParameterNames += ", [TaskTemplateId]=?"
        SQLParameterValues.append(operativeGroupTaskTemplateMembership.TaskTemplateId as NSObject)
        
        SQLParameterValues.append(operativeGroupTaskTemplateMembership.RowId as NSObject)
        
        SQLStatement = "UPDATE [OperativeGroupTaskTemplateMembership] SET " + SQLParameterNames + "WHERE [RowId]=?"
        
        sharedModelManager.database!.open()
        let isUpdated = sharedModelManager.database!.executeUpdate(SQLStatement, withArgumentsIn: SQLParameterValues)
        sharedModelManager.database!.close()
        return isUpdated
    }
    
    func deleteOperativeGroupTaskTemplateMembership(_ operativeGroupTaskTemplateMembership: OperativeGroupTaskTemplateMembership) -> Bool {
        sharedModelManager.database!.open()
        let isDeleted = sharedModelManager.database!.executeUpdate("DELETE FROM [OperativeGroupTaskTemplateMembership] WHERE [RowId]=?", withArgumentsIn: [operativeGroupTaskTemplateMembership.RowId])
        sharedModelManager.database!.close()
        return isDeleted
    }
    
    func getOperativeGroupTaskTemplateMembership(_ operativeGroupTaskTemplateMembershipId: String) -> OperativeGroupTaskTemplateMembership? {
        sharedModelManager.database!.open()
        var operativeGroupTaskTemplateMembership: OperativeGroupTaskTemplateMembership? = nil
        
        let resultSet = sharedModelManager.database!.executeQuery("SELECT [RowId], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [Deleted], [OperativeGroupId], [TaskTemplateId] FROM [OperativeGroupTaskTemplateMembership] WHERE [RowId]=?", withArgumentsIn: [operativeGroupTaskTemplateMembershipId])
        if (resultSet != nil) {
            while (resultSet?.next())! {
                var resultOperativeGroupTaskTemplateMembership: OperativeGroupTaskTemplateMembership = OperativeGroupTaskTemplateMembership()
                resultOperativeGroupTaskTemplateMembership = OperativeGroupTaskTemplateMembership()
                resultOperativeGroupTaskTemplateMembership.RowId = (resultSet?.string(forColumn: "RowId"))!
                resultOperativeGroupTaskTemplateMembership.CreatedBy = (resultSet?.string(forColumn: "CreatedBy"))!
                resultOperativeGroupTaskTemplateMembership.CreatedOn = resultSet!.date(forColumn: "CreatedOn")!
                if !(resultSet?.columnIsNull("LastUpdatedBy"))!
                {
                    resultOperativeGroupTaskTemplateMembership.LastUpdatedBy = resultSet?.string(forColumn: "LastUpdatedBy")
                }
                if !(resultSet?.columnIsNull("LastUpdatedOn"))!
                {
                    resultOperativeGroupTaskTemplateMembership.LastUpdatedOn = resultSet?.date(forColumn: "LastUpdatedOn")
                }
                if !(resultSet?.columnIsNull("Deleted"))!
                {
                    resultOperativeGroupTaskTemplateMembership.Deleted = resultSet?.date(forColumn: "Deleted")
                }
                resultOperativeGroupTaskTemplateMembership.OperativeGroupId = (resultSet?.string(forColumn: "OperativeGroupId"))!
                resultOperativeGroupTaskTemplateMembership.TaskTemplateId = (resultSet?.string(forColumn: "TaskTemplateId"))!
                
                operativeGroupTaskTemplateMembership = resultOperativeGroupTaskTemplateMembership
            }
        }
        sharedModelManager.database!.close()
        return operativeGroupTaskTemplateMembership
    }
    
    func getAllOperativeGroupTaskTemplateMembership() -> [OperativeGroupTaskTemplateMembership] {
        sharedModelManager.database!.open()
        let resultSet: FMResultSet! = sharedModelManager.database!.executeQuery("SELECT [RowId], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [Deleted], [OperativeGroupId], [TaskTemplateId] FROM [OperativeGroupTaskTemplateMembership]", withArgumentsIn: [])
        var operativeGroupTaskTemplateMembershipList : [OperativeGroupTaskTemplateMembership] = [OperativeGroupTaskTemplateMembership]()
        if (resultSet != nil) {
            while resultSet.next() {
                let operativeGroupTaskTemplateMembership : OperativeGroupTaskTemplateMembership = OperativeGroupTaskTemplateMembership()
                operativeGroupTaskTemplateMembership.RowId = resultSet.string(forColumn: "RowId")!
                operativeGroupTaskTemplateMembership.CreatedBy = resultSet.string(forColumn: "CreatedBy")!
                operativeGroupTaskTemplateMembership.CreatedOn = resultSet.date(forColumn: "CreatedOn")!
                if !resultSet.columnIsNull("LastUpdatedBy")
                {
                    operativeGroupTaskTemplateMembership.LastUpdatedBy = resultSet.string(forColumn: "LastUpdatedBy")
                }
                if !resultSet.columnIsNull("LastUpdatedOn")
                {
                    operativeGroupTaskTemplateMembership.LastUpdatedOn = resultSet.date(forColumn: "LastUpdatedOn")
                }
                if !resultSet.columnIsNull("Deleted")
                {
                    operativeGroupTaskTemplateMembership.Deleted = resultSet.date(forColumn: "Deleted")
                }
                operativeGroupTaskTemplateMembership.OperativeGroupId = resultSet.string(forColumn: "OperativeGroupId")!
                operativeGroupTaskTemplateMembership.TaskTemplateId = resultSet.string(forColumn: "TaskTemplateId")!
                
                operativeGroupTaskTemplateMembershipList.append(operativeGroupTaskTemplateMembership)
            }
        }
        sharedModelManager.database!.close()
        return operativeGroupTaskTemplateMembershipList
    }
    
    func findOperativeGroupTaskTemplateMembershipList(_ criteria: Dictionary<String, AnyObject>) -> [OperativeGroupTaskTemplateMembership] {
        var list: [OperativeGroupTaskTemplateMembership] = [OperativeGroupTaskTemplateMembership]()
        //var count: Int32 = 0
        (list, _) = findOperativeGroupTaskTemplateMembershipList(criteria, pageSize: nil, pageNumber: nil)
        return list
    }
    
    func findOperativeGroupTaskTemplateMembershipList(_ criteria: Dictionary<String, AnyObject>, pageSize: Int32?, pageNumber: Int32?) -> (List: [OperativeGroupTaskTemplateMembership], Count: Int32) {
        //return variables
        var count: Int32 = 0
        var operativeGroupTaskTemplateMembershipList: [OperativeGroupTaskTemplateMembership] = [OperativeGroupTaskTemplateMembership]()
        
        //build the where clause
        var whereClause: String = String()
        var whereValues: [AnyObject] = [AnyObject]()
        
        (whereClause, whereValues) = buildWhereClause(criteria)
        
        if (whereClause != "")
        {
            whereClause = "WHERE " + whereClause
        }
        
        sharedModelManager.database!.open()
        let countSet: FMResultSet! = sharedModelManager.database!.executeQuery("SELECT COUNT([RowId]) FROM [OperativeGroupTaskTemplateMembership] " + whereClause, withArgumentsIn: whereValues)
        if (countSet != nil) {
            while countSet.next() {
                count = countSet.int(forColumnIndex: 0)
            }
        }
        
        if (count > 0)
        {
            var pageClause: String = String()
            if (pageSize != nil && pageNumber != nil)
            {
                pageClause = " LIMIT " + String(pageSize!) + " OFFSET " + String((pageNumber! - 1) * pageSize!)
            }
            
            let resultSet: FMResultSet! = sharedModelManager.database!.executeQuery("SELECT [RowId], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [Deleted], [OperativeGroupId], [TaskTemplateId] FROM [OperativeGroupTaskTemplateMembership] " + whereClause + pageClause, withArgumentsIn: whereValues)
            if (resultSet != nil) {
                while resultSet.next() {
                    let operativeGroupTaskTemplateMembership : OperativeGroupTaskTemplateMembership = OperativeGroupTaskTemplateMembership()
                    operativeGroupTaskTemplateMembership.RowId = resultSet.string(forColumn: "RowId")!
                    operativeGroupTaskTemplateMembership.CreatedBy = resultSet.string(forColumn: "CreatedBy")!
                    operativeGroupTaskTemplateMembership.CreatedOn = resultSet.date(forColumn: "CreatedOn")!
                    if !resultSet.columnIsNull("LastUpdatedBy")
                    {
                        operativeGroupTaskTemplateMembership.LastUpdatedBy = resultSet.string(forColumn: "LastUpdatedBy")
                    }
                    if !resultSet.columnIsNull("LastUpdatedOn")
                    {
                        operativeGroupTaskTemplateMembership.LastUpdatedOn = resultSet.date(forColumn: "LastUpdatedOn")
                    }
                    if !resultSet.columnIsNull("Deleted")
                    {
                        operativeGroupTaskTemplateMembership.Deleted = resultSet.date(forColumn: "Deleted")
                    }
                    operativeGroupTaskTemplateMembership.OperativeGroupId = resultSet.string(forColumn: "OperativeGroupId")!
                    operativeGroupTaskTemplateMembership.TaskTemplateId = resultSet.string(forColumn: "TaskTemplateId")!
                    
                    operativeGroupTaskTemplateMembershipList.append(operativeGroupTaskTemplateMembership)
                }
            }
        }
        sharedModelManager.database!.close()
        return (operativeGroupTaskTemplateMembershipList, count)
    }
    
    // MARK: - Organisation
    
    func addOrganisation(_ organisation: Organisation) -> Bool {
        //build the sql statemnt
        var SQLStatement: String = String()
        var SQLParameterNames: String = String()
        var SQLParameterPlaceholders: String = String()
        var SQLParameterValues: [NSObject] = [NSObject]()
        
        SQLParameterNames = "[RowId], [CreatedBy], [CreatedOn]"
        SQLParameterPlaceholders = "?, ?, ?"
        SQLParameterValues.append(organisation.RowId as NSObject)
        SQLParameterValues.append(organisation.CreatedBy as NSObject)
        SQLParameterValues.append(organisation.CreatedOn as NSObject)
        
        if organisation.LastUpdatedBy != nil {
            SQLParameterNames += ", [LastUpdatedBy]"
            SQLParameterPlaceholders += ", ?"
            SQLParameterValues.append(organisation.LastUpdatedBy! as NSObject)
        }
        
        if organisation.LastUpdatedOn != nil {
            SQLParameterNames += ", [LastUpdatedOn]"
            SQLParameterPlaceholders += ", ?"
            SQLParameterValues.append(organisation.LastUpdatedOn! as NSObject)
        }
        
        if organisation.Deleted != nil {
            SQLParameterNames += ", [Deleted]"
            SQLParameterPlaceholders += ", ?"
            SQLParameterValues.append(organisation.Deleted! as NSObject)
        }
        
        SQLParameterNames += ", [ParentOrganisationId]"
        SQLParameterPlaceholders += ", ?"
        SQLParameterValues.append(organisation.ParentOrganisationId as NSObject)
        SQLParameterNames += ", [Name]"
        SQLParameterPlaceholders += ", ?"
        SQLParameterValues.append(organisation.Name as NSObject)
        
        SQLStatement = "INSERT INTO [Organisation] (" + SQLParameterNames + ") VALUES (" + SQLParameterPlaceholders + ")"
        
        sharedModelManager.database!.open()
        let isInserted = sharedModelManager.database!.executeUpdate(SQLStatement, withArgumentsIn: SQLParameterValues)
        sharedModelManager.database!.close()
        return isInserted
    }
    
    func updateOrganisation(_ organisation: Organisation) -> Bool {
        //build the sql statemnt
        var SQLStatement: String = String()
        var SQLParameterNames: String = String()
        var SQLParameterValues: [NSObject] = [NSObject]()
        
        SQLParameterNames = "[CreatedBy]=?, [CreatedOn]=?"
        SQLParameterValues.append(organisation.CreatedBy as NSObject)
        SQLParameterValues.append(organisation.CreatedOn as NSObject)
        
        if organisation.LastUpdatedBy != nil {
            SQLParameterNames += ", [LastUpdatedBy]=?"
            SQLParameterValues.append(organisation.LastUpdatedBy! as NSObject)
        }
        
        if organisation.LastUpdatedOn != nil {
            SQLParameterNames += ", [LastUpdatedOn]=?"
            SQLParameterValues.append(organisation.LastUpdatedOn! as NSObject)
        }
        
        if organisation.Deleted != nil {
            SQLParameterNames += ", [Deleted]=?"
            SQLParameterValues.append(organisation.Deleted! as NSObject)
        }
        SQLParameterNames += ", [ParentOrganisationId]=?"
        SQLParameterValues.append(organisation.ParentOrganisationId as NSObject)
        SQLParameterNames += ", [Name]=?"
        SQLParameterValues.append(organisation.Name as NSObject)
        
        
        SQLParameterValues.append(organisation.RowId as NSObject)
        
        SQLStatement = "UPDATE [Organisation] SET " + SQLParameterNames + "WHERE [RowId]=?"
        
        sharedModelManager.database!.open()
        let isUpdated = sharedModelManager.database!.executeUpdate(SQLStatement, withArgumentsIn: SQLParameterValues)
        sharedModelManager.database!.close()
        return isUpdated
    }
    
    func deleteOrganisation(_ organisation: Organisation) -> Bool {
        sharedModelManager.database!.open()
        let isDeleted = sharedModelManager.database!.executeUpdate("DELETE FROM [Organisation] WHERE [RowId]=?", withArgumentsIn: [organisation.RowId])
        sharedModelManager.database!.close()
        return isDeleted
    }
    
    func getOrganisation(_ organisationId: String) -> Organisation? {
        sharedModelManager.database!.open()
        var organisation: Organisation? = nil
        
        let resultSet = sharedModelManager.database!.executeQuery("SELECT [RowId], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [Deleted], [ParentOrganisationId], [Name] FROM [Organisation] WHERE [RowId]=?", withArgumentsIn: [organisationId])
        if (resultSet != nil) {
            while (resultSet?.next())! {
                var resultOrganisation: Organisation = Organisation()
                resultOrganisation = Organisation()
                resultOrganisation.RowId = (resultSet?.string(forColumn: "RowId"))!
                resultOrganisation.CreatedBy = (resultSet?.string(forColumn: "CreatedBy"))!
                resultOrganisation.CreatedOn = resultSet!.date(forColumn: "CreatedOn")!
                if !(resultSet?.columnIsNull("LastUpdatedBy"))!
                {
                    resultOrganisation.LastUpdatedBy = resultSet?.string(forColumn: "LastUpdatedBy")
                }
                if !(resultSet?.columnIsNull("LastUpdatedOn"))!
                {
                    resultOrganisation.LastUpdatedOn = resultSet?.date(forColumn: "LastUpdatedOn")
                }
                if !(resultSet?.columnIsNull("Deleted"))!
                {
                    resultOrganisation.Deleted = resultSet?.date(forColumn: "Deleted")
                }
                resultOrganisation.ParentOrganisationId = (resultSet?.string(forColumn: "ParentOrganisationId"))!
                resultOrganisation.Name = (resultSet?.string(forColumn: "Name"))!
                
                organisation = resultOrganisation
            }
        }
        sharedModelManager.database!.close()
        return organisation
    }
    
    func getAllOrganisation() -> [Organisation] {
        sharedModelManager.database!.open()
        let resultSet: FMResultSet! = sharedModelManager.database!.executeQuery("SELECT [RowId], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [Deleted], [ParentOrganisationId], [Name] FROM [Organisation]", withArgumentsIn: [])
        var organisationList: [Organisation] = [Organisation]()
        if (resultSet != nil) {
            while resultSet.next() {
                let organisation : Organisation = Organisation()
                organisation.RowId = resultSet.string(forColumn: "RowId")!
                organisation.CreatedBy = resultSet.string(forColumn: "CreatedBy")!
                organisation.CreatedOn = resultSet.date(forColumn: "CreatedOn")!
                if !resultSet.columnIsNull("LastUpdatedBy")
                {
                    organisation.LastUpdatedBy = resultSet.string(forColumn: "LastUpdatedBy")
                }
                if !resultSet.columnIsNull("LastUpdatedOn")
                {
                    organisation.LastUpdatedOn = resultSet.date(forColumn: "LastUpdatedOn")
                }
                if !resultSet.columnIsNull("Deleted")
                {
                    organisation.Deleted = resultSet.date(forColumn: "Deleted")
                }
                organisation.ParentOrganisationId = resultSet.string(forColumn: "ParentOrganisationId")!
                organisation.Name = resultSet.string(forColumn: "Name")!
                
                organisationList.append(organisation)
            }
        }
        sharedModelManager.database!.close()
        return organisationList
    }
    
    func findOrganisationList(_ criteria: Dictionary<String, AnyObject>) -> [Organisation] {
        var list: [Organisation] = [Organisation]()
        //var count: Int32 = 0
        (list, _) = findOrganisationList(criteria, pageSize: nil, pageNumber: nil)
        return list
    }
    
    func findOrganisationList(_ criteria: Dictionary<String, AnyObject>, pageSize: Int32?, pageNumber: Int32?) -> (List: [Organisation], Count: Int32) {
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
        let countSet: FMResultSet! = sharedModelManager.database!.executeQuery("SELECT COUNT([RowId]) FROM [Organisation] " + whereClause + orderByClause, withArgumentsIn: whereValues)
        if (countSet != nil) {
            while countSet.next() {
                count = countSet.int(forColumnIndex: 0)
            }
        }
        
        if (count > 0)
        {
            var pageClause: String = String()
            if (pageSize != nil && pageNumber != nil)
            {
                pageClause = " LIMIT " + String(pageSize!) + " OFFSET " + String((pageNumber! - 1) * pageSize!)
            }
            
            let resultSet: FMResultSet! = sharedModelManager.database!.executeQuery("SELECT [RowId], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [Deleted], [ParentOrganisationId], [Name] FROM [Organisation] " + whereClause + orderByClause + pageClause, withArgumentsIn: whereValues)
            if (resultSet != nil) {
                while resultSet.next() {
                    let organisation : Organisation = Organisation()
                    organisation.RowId = resultSet.string(forColumn: "RowId")!
                    organisation.CreatedBy = resultSet.string(forColumn: "CreatedBy")!
                    organisation.CreatedOn = resultSet.date(forColumn: "CreatedOn")!
                    if !resultSet.columnIsNull("LastUpdatedBy")
                    {
                        organisation.LastUpdatedBy = resultSet.string(forColumn: "LastUpdatedBy")
                    }
                    if !resultSet.columnIsNull("LastUpdatedOn")
                    {
                        organisation.LastUpdatedOn = resultSet.date(forColumn: "LastUpdatedOn")
                    }
                    if !resultSet.columnIsNull("Deleted")
                    {
                        organisation.Deleted = resultSet.date(forColumn: "Deleted")
                    }
                    organisation.ParentOrganisationId = resultSet.string(forColumn: "ParentOrganisationId")!
                    organisation.Name = resultSet.string(forColumn: "Name")!
                    
                    organisationList.append(organisation)
                }
            }
        }
        
        sharedModelManager.database!.close()
        return (organisationList, count)
    }
    
    // MARK: - Property
    
    func addProperty(_ property: Property) -> Bool {
        //build the sql statemnt
        var SQLStatement: String = String()
        var SQLParameterNames: String = String()
        var SQLParameterPlaceholders: String = String()
        var SQLParameterValues: [NSObject] = [NSObject]()
        
        SQLParameterNames = "[RowId], [CreatedBy], [CreatedOn]"
        SQLParameterPlaceholders = "?, ?, ?"
        SQLParameterValues.append(property.RowId as NSObject)
        SQLParameterValues.append(property.CreatedBy as NSObject)
        SQLParameterValues.append(property.CreatedOn as NSObject)
        
        if property.LastUpdatedBy != nil {
            SQLParameterNames += ", [LastUpdatedBy]"
            SQLParameterPlaceholders += ", ?"
            SQLParameterValues.append(property.LastUpdatedBy! as NSObject)
        }
        
        if property.LastUpdatedOn != nil {
            SQLParameterNames += ", [LastUpdatedOn]"
            SQLParameterPlaceholders += ", ?"
            SQLParameterValues.append(property.LastUpdatedOn! as NSObject)
        }
        
        if property.Deleted != nil {
            SQLParameterNames += ", [Deleted]"
            SQLParameterPlaceholders += ", ?"
            SQLParameterValues.append(property.Deleted! as NSObject)
        }
        SQLParameterNames += ", [SiteId]"
        SQLParameterPlaceholders += ", ?"
        SQLParameterValues.append(property.SiteId as NSObject)
        SQLParameterNames += ", [Name]"
        SQLParameterPlaceholders += ", ?"
        SQLParameterValues.append(property.Name as NSObject)
        SQLParameterNames += ", [Healthcare]"
        SQLParameterPlaceholders += ", ?"
        SQLParameterValues.append(property.Healthcare as NSObject)
        
        SQLStatement = "INSERT INTO [Property] (" + SQLParameterNames + ") VALUES (" + SQLParameterPlaceholders + ")"
        
        sharedModelManager.database!.open()
        let isInserted = sharedModelManager.database!.executeUpdate(SQLStatement, withArgumentsIn: SQLParameterValues)
        NSLog("Property inserted - " + property.Name)
        sharedModelManager.database!.close()
        return isInserted
    }
    
    func updateProperty(_ property: Property) -> Bool {
        //build the sql statemnt
        var SQLStatement: String = String()
        var SQLParameterNames: String = String()
        var SQLParameterValues: [NSObject] = [NSObject]()
        
        SQLParameterNames = "[CreatedBy]=?, [CreatedOn]=?"
        SQLParameterValues.append(property.CreatedBy as NSObject)
        SQLParameterValues.append(property.CreatedOn as NSObject)
        
        if property.LastUpdatedBy != nil {
            SQLParameterNames += ", [LastUpdatedBy]=?"
            SQLParameterValues.append(property.LastUpdatedBy! as NSObject)
        }
        
        if property.LastUpdatedOn != nil {
            SQLParameterNames += ", [LastUpdatedOn]=?"
            SQLParameterValues.append(property.LastUpdatedOn! as NSObject)
        }
        
        if property.Deleted != nil {
            SQLParameterNames += ", [Deleted]=?"
            SQLParameterValues.append(property.Deleted! as NSObject)
        }
        SQLParameterNames += ", [SiteId]=?"
        SQLParameterValues.append(property.SiteId as NSObject)
        SQLParameterNames += ", [Name]=?"
        SQLParameterValues.append(property.Name as NSObject)
        SQLParameterNames += ", [Healthcare]=?"
        SQLParameterValues.append(property.Healthcare as NSObject)
        
        SQLParameterValues.append(property.RowId as NSObject)
        
        SQLStatement = "UPDATE [Property] SET " + SQLParameterNames + "WHERE [RowId]=?"
        
        sharedModelManager.database!.open()
        let isUpdated = sharedModelManager.database!.executeUpdate(SQLStatement, withArgumentsIn: SQLParameterValues)
        NSLog("Property updated - " + property.Name)
        sharedModelManager.database!.close()
        return isUpdated
    }
    
    func deleteProperty(_ property: Property) -> Bool {
        sharedModelManager.database!.open()
        let isDeleted = sharedModelManager.database!.executeUpdate("DELETE FROM [Property] WHERE [RowId]=?", withArgumentsIn: [property.RowId])
        sharedModelManager.database!.close()
        return isDeleted
    }
    
    func getProperty(_ propertyId: String) -> Property? {
        sharedModelManager.database!.open()
        var property: Property? = nil
        
        let resultSet = sharedModelManager.database!.executeQuery("SELECT [RowId], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [Deleted], [SiteId], [Name], [Healthcare] FROM [Property] WHERE [RowId]=?", withArgumentsIn: [propertyId])
        if (resultSet != nil) {
            while (resultSet?.next())! {
                var resultProperty: Property = Property()
                resultProperty = Property()
                resultProperty.RowId = (resultSet?.string(forColumn: "RowId"))!
                resultProperty.CreatedBy = (resultSet?.string(forColumn: "CreatedBy"))!
                resultProperty.CreatedOn = resultSet!.date(forColumn: "CreatedOn")!
                if !(resultSet?.columnIsNull("LastUpdatedBy"))!
                {
                    resultProperty.LastUpdatedBy = resultSet?.string(forColumn: "LastUpdatedBy")
                }
                if !(resultSet?.columnIsNull("LastUpdatedOn"))!
                {
                    resultProperty.LastUpdatedOn = resultSet?.date(forColumn: "LastUpdatedOn")
                }
                if !(resultSet?.columnIsNull("Deleted"))!
                {
                    resultProperty.Deleted = resultSet?.date(forColumn: "Deleted")
                }
                resultProperty.SiteId = (resultSet?.string(forColumn: "SiteId"))!
                resultProperty.Name = (resultSet?.string(forColumn: "Name"))!
                resultProperty.Healthcare = (resultSet?.bool(forColumn: "Healthcare"))!
                
                property = resultProperty
            }
        }
        sharedModelManager.database!.close()
        return property
    }
    
    func getAllProperty() -> [Property] {
        sharedModelManager.database!.open()
        let resultSet: FMResultSet! = sharedModelManager.database!.executeQuery("SELECT [RowId], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [Deleted], [SiteId], [Name], [Healthcare] FROM [Property]", withArgumentsIn: [])
        var propertyList: [Property] = [Property]()
        if (resultSet != nil) {
            while resultSet.next() {
                let property : Property = Property()
                property.RowId = resultSet.string(forColumn: "RowId")!
                property.CreatedBy = resultSet.string(forColumn: "CreatedBy")!
                property.CreatedOn = resultSet.date(forColumn: "CreatedOn")!
                if !resultSet.columnIsNull("LastUpdatedBy")
                {
                    property.LastUpdatedBy = resultSet.string(forColumn: "LastUpdatedBy")
                }
                if !resultSet.columnIsNull("LastUpdatedOn")
                {
                    property.LastUpdatedOn = resultSet.date(forColumn: "LastUpdatedOn")
                }
                if !resultSet.columnIsNull("Deleted")
                {
                    property.Deleted = resultSet.date(forColumn: "Deleted")
                }
                property.SiteId = resultSet.string(forColumn: "SiteId")!
                property.Name = resultSet.string(forColumn: "Name")!
                property.Healthcare = resultSet.bool(forColumn: "Healthcare")
                
                propertyList.append(property)
            }
        }
        sharedModelManager.database!.close()
        return propertyList
    }
    
    func findPropertyList(_ criteria: Dictionary<String, AnyObject>) -> [Property] {
        var list: [Property] = [Property]()
        //var count: Int32 = 0
        (list, _) = findPropertyList(criteria, pageSize: nil, pageNumber: nil)
        return list
    }
    
    func findPropertyList(_ criteria: Dictionary<String, AnyObject>, pageSize: Int32?, pageNumber: Int32?) -> (List: [Property], Count: Int32) {
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
        let countSet: FMResultSet! = sharedModelManager.database!.executeQuery("SELECT COUNT([RowId]) FROM [Property] " + whereClause + orderByClause, withArgumentsIn: whereValues)
        if (countSet != nil) {
            while countSet.next() {
                count = countSet.int(forColumnIndex: 0)
            }
        }
        
        if (count > 0)
        {
            var pageClause: String = String()
            if (pageSize != nil && pageNumber != nil)
            {
                pageClause = " LIMIT " + String(pageSize!) + " OFFSET " + String((pageNumber! - 1) * pageSize!)
            }
            
            let resultSet: FMResultSet! = sharedModelManager.database!.executeQuery("SELECT [RowId], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [Deleted], [SiteId], [Name], [Healthcare] FROM [Property] " + whereClause + orderByClause + pageClause, withArgumentsIn: whereValues)
            if (resultSet != nil) {
                while resultSet.next() {
                    let property : Property = Property()
                    property.RowId = resultSet.string(forColumn: "RowId")!
                    property.CreatedBy = resultSet.string(forColumn: "CreatedBy")!
                    property.CreatedOn = resultSet.date(forColumn: "CreatedOn")!
                    if !resultSet.columnIsNull("LastUpdatedBy")
                    {
                        property.LastUpdatedBy = resultSet.string(forColumn: "LastUpdatedBy")
                    }
                    if !resultSet.columnIsNull("LastUpdatedOn")
                    {
                        property.LastUpdatedOn = resultSet.date(forColumn: "LastUpdatedOn")
                    }
                    if !resultSet.columnIsNull("Deleted")
                    {
                        property.Deleted = resultSet.date(forColumn: "Deleted")
                    }
                    property.SiteId = resultSet.string(forColumn: "SiteId")!
                    property.Name = resultSet.string(forColumn: "Name")!
                    property.Healthcare = resultSet.bool(forColumn: "Healthcare")
                    
                    propertyList.append(property)
                }
            }
        }
        
        sharedModelManager.database!.close()
        return (propertyList, count)
    }
    
    // MARK: - ReferenceData
    
    func addReferenceData(_ referenceData: ReferenceData) -> Bool {
        //build the sql statemnt
        var SQLStatement: String = String()
        var SQLParameterNames: String = String()
        var SQLParameterPlaceholders: String = String()
        var SQLParameterValues: [NSObject] = [NSObject]()
        
        SQLParameterNames = "[RowId], [CreatedBy], [CreatedOn]"
        SQLParameterPlaceholders = "?, ?, ?"
        SQLParameterValues.append(referenceData.RowId as NSObject)
        SQLParameterValues.append(referenceData.CreatedBy as NSObject)
        SQLParameterValues.append(referenceData.CreatedOn as NSObject)
        
        if referenceData.LastUpdatedBy != nil {
            SQLParameterNames += ", [LastUpdatedBy]"
            SQLParameterPlaceholders += ", ?"
            SQLParameterValues.append(referenceData.LastUpdatedBy! as NSObject)
        }
        
        if referenceData.LastUpdatedOn != nil {
            SQLParameterNames += ", [LastUpdatedOn]"
            SQLParameterPlaceholders += ", ?"
            SQLParameterValues.append(referenceData.LastUpdatedOn! as NSObject)
        }
        
        if referenceData.Deleted != nil {
            SQLParameterNames += ", [Deleted]"
            SQLParameterPlaceholders += ", ?"
            SQLParameterValues.append(referenceData.Deleted! as NSObject)
        }
        SQLParameterNames += ", [StartDate]"
        SQLParameterPlaceholders += ", ?"
        SQLParameterValues.append(referenceData.StartDate as NSObject)
        if referenceData.EndDate != nil {
            SQLParameterNames += ", [EndDate]"
            SQLParameterPlaceholders += ", ?"
            SQLParameterValues.append(referenceData.EndDate! as NSObject)
        }
        SQLParameterNames += ", [Type]"
        SQLParameterPlaceholders += ", ?"
        SQLParameterValues.append(referenceData.ReferenceType as NSObject)
        SQLParameterNames += ", [Value]"
        SQLParameterPlaceholders += ", ?"
        SQLParameterValues.append(referenceData.Value as NSObject)
        SQLParameterNames += ", [Ordinal]"
        SQLParameterPlaceholders += ", ?"
        SQLParameterValues.append(String(referenceData.Ordinal) as NSObject)
        SQLParameterNames += ", [Display]"
        SQLParameterPlaceholders += ", ?"
        SQLParameterValues.append(referenceData.Display as NSObject)
        SQLParameterNames += ", [System]"
        SQLParameterPlaceholders += ", ?"
        SQLParameterValues.append(referenceData.System as NSObject)
        if referenceData.ParentType != nil {
            SQLParameterNames += ", [ParentType]"
            SQLParameterPlaceholders += ", ?"
            SQLParameterValues.append(referenceData.ParentType! as NSObject)
        }
        if referenceData.ParentValue != nil {
            SQLParameterNames += ", [ParentValue]"
            SQLParameterPlaceholders += ", ?"
            SQLParameterValues.append(referenceData.ParentValue! as NSObject)
        }
        
        SQLStatement = "INSERT INTO [ReferenceData] (" + SQLParameterNames + ") VALUES (" + SQLParameterPlaceholders + ")"
        
        sharedModelManager.database!.open()
        let isInserted = sharedModelManager.database!.executeUpdate(SQLStatement, withArgumentsIn: SQLParameterValues)
        sharedModelManager.database!.close()
        return isInserted
    }
    
    func updateReferenceData(_ referenceData: ReferenceData) -> Bool {
        //build the sql statemnt
        var SQLStatement: String = String()
        var SQLParameterNames: String = String()
        var SQLParameterValues: [NSObject] = [NSObject]()
        
        SQLParameterNames = "[CreatedBy]=?, [CreatedOn]=?"
        SQLParameterValues.append(referenceData.CreatedBy as NSObject)
        SQLParameterValues.append(referenceData.CreatedOn as NSObject)
        
        if referenceData.LastUpdatedBy != nil {
            SQLParameterNames += ", [LastUpdatedBy]=?"
            SQLParameterValues.append(referenceData.LastUpdatedBy! as NSObject)
        }
        
        if referenceData.LastUpdatedOn != nil {
            SQLParameterNames += ", [LastUpdatedOn]=?"
            SQLParameterValues.append(referenceData.LastUpdatedOn! as NSObject)
        }
        
        if referenceData.Deleted != nil {
            SQLParameterNames += ", [Deleted]=?"
            SQLParameterValues.append(referenceData.Deleted! as NSObject)
        }
        SQLParameterNames += ", [StartDate]=?"
        SQLParameterValues.append(referenceData.StartDate as NSObject)
        if referenceData.EndDate != nil {
            SQLParameterNames += ", [EndDate]=?"
            SQLParameterValues.append(referenceData.EndDate! as NSObject)
        }
        SQLParameterNames += ", [Type]=?"
        SQLParameterValues.append(referenceData.ReferenceType as NSObject)
        SQLParameterNames += ", [Value]=?"
        SQLParameterValues.append(referenceData.Value as NSObject)
        SQLParameterNames += ", [Ordinal]=?"
        SQLParameterValues.append(referenceData.Ordinal as NSObject)
        SQLParameterNames += ", [Display]=?"
        SQLParameterValues.append(referenceData.Display as NSObject)
        SQLParameterNames += ", [System]=?"
        SQLParameterValues.append(referenceData.System as NSObject)
        if referenceData.ParentType != nil {
            SQLParameterNames += ", [ParentType]=?"
            SQLParameterValues.append(referenceData.ParentType! as NSObject)
        }
        if referenceData.ParentValue != nil {
            SQLParameterNames += ", [ParentValue]=?"
            SQLParameterValues.append(referenceData.ParentValue! as NSObject)
        }
        
        
        SQLParameterValues.append(referenceData.RowId as NSObject)
        
        SQLStatement = "UPDATE [ReferenceData] SET " + SQLParameterNames + "WHERE [RowId]=?"
        
        sharedModelManager.database!.open()
        let isUpdated = sharedModelManager.database!.executeUpdate(SQLStatement, withArgumentsIn: SQLParameterValues)
        sharedModelManager.database!.close()
        return isUpdated
    }
    
    func deleteReferenceData(_ referenceData: ReferenceData) -> Bool {
        sharedModelManager.database!.open()
        let isDeleted = sharedModelManager.database!.executeUpdate("DELETE FROM [ReferenceData] WHERE [RowId]=?", withArgumentsIn: [referenceData.RowId])
        sharedModelManager.database!.close()
        return isDeleted
    }
    
    func getReferenceData(_ referenceDataId: String) -> ReferenceData? {
        sharedModelManager.database!.open()
        var referenceData: ReferenceData? = nil
        
        let resultSet = sharedModelManager.database!.executeQuery("SELECT [RowId], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [Deleted], [StartDate], [EndDate], [Type], [Value], [Ordinal], [Display], [System], [ParentType], [ParentValue] FROM [ReferenceData] WHERE [RowId]=?", withArgumentsIn: [referenceDataId])
        if (resultSet != nil) {
            while (resultSet?.next())! {
                var resultReferenceData: ReferenceData = ReferenceData()
                resultReferenceData = ReferenceData()
                resultReferenceData.RowId = (resultSet?.string(forColumn: "RowId"))!
                resultReferenceData.CreatedBy = (resultSet?.string(forColumn: "CreatedBy"))!
                resultReferenceData.CreatedOn = resultSet!.date(forColumn: "CreatedOn")!
                if !(resultSet?.columnIsNull("LastUpdatedBy"))!
                {
                    resultReferenceData.LastUpdatedBy = resultSet?.string(forColumn: "LastUpdatedBy")
                }
                if !(resultSet?.columnIsNull("LastUpdatedOn"))!
                {
                    resultReferenceData.LastUpdatedOn = resultSet?.date(forColumn: "LastUpdatedOn")
                }
                if !(resultSet?.columnIsNull("Deleted"))!
                {
                    resultReferenceData.Deleted = resultSet?.date(forColumn: "Deleted")
                }
                resultReferenceData.StartDate = resultSet!.date(forColumn: "StartDate")!
                if !(resultSet?.columnIsNull("EndDate"))! {
                    resultReferenceData.EndDate = resultSet?.date(forColumn: "EndDate")
                }
                resultReferenceData.ReferenceType = (resultSet?.string(forColumn: "Type"))!
                resultReferenceData.Value = (resultSet?.string(forColumn: "Value"))!
                resultReferenceData.Ordinal = Int((resultSet?.int(forColumn: "Ordinal"))!)
                resultReferenceData.Display = (resultSet?.string(forColumn: "Display"))!
                resultReferenceData.System = (resultSet?.bool(forColumn: "System"))!
                if !(resultSet?.columnIsNull("ParentType"))! {
                    resultReferenceData.ParentType = resultSet?.string(forColumn: "ParentType")
                }
                if !(resultSet?.columnIsNull("ParentValue"))! {
                    resultReferenceData.ParentValue = resultSet?.string(forColumn: "ParentValue")
                }
                
                
                referenceData = resultReferenceData
            }
        }
        sharedModelManager.database!.close()
        return referenceData
    }
    
    func getAllReferenceData() -> [ReferenceData] {
        sharedModelManager.database!.open()
        let resultSet: FMResultSet! = sharedModelManager.database!.executeQuery("SELECT [RowId], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [Deleted], [StartDate], [EndDate], [Type], [Value], [Ordinal], [Display], [System], [ParentType], [ParentValue] FROM [ReferenceData]", withArgumentsIn: [])
        var referenceDataList: [ReferenceData] = [ReferenceData]()
        if (resultSet != nil) {
            while resultSet.next() {
                let referenceData : ReferenceData = ReferenceData()
                referenceData.RowId = resultSet.string(forColumn: "RowId")!
                referenceData.CreatedBy = resultSet.string(forColumn: "CreatedBy")!
                referenceData.CreatedOn = resultSet.date(forColumn: "CreatedOn")!
                if !resultSet.columnIsNull("LastUpdatedBy")
                {
                    referenceData.LastUpdatedBy = resultSet.string(forColumn: "LastUpdatedBy")
                }
                if !resultSet.columnIsNull("LastUpdatedOn")
                {
                    referenceData.LastUpdatedOn = resultSet.date(forColumn: "LastUpdatedOn")
                }
                if !resultSet.columnIsNull("Deleted")
                {
                    referenceData.Deleted = resultSet.date(forColumn: "Deleted")
                }
                referenceData.StartDate = resultSet.date(forColumn: "StartDate")!
                if !resultSet.columnIsNull("EndDate") {
                    referenceData.EndDate = resultSet.date(forColumn: "EndDate")
                }
                referenceData.ReferenceType = resultSet.string(forColumn: "Type")!
                referenceData.Value = resultSet.string(forColumn: "Value")!
                referenceData.Ordinal = Int(resultSet.int(forColumn: "Ordinal"))
                referenceData.Display = resultSet.string(forColumn: "Display")!
                referenceData.System = resultSet.bool(forColumn: "System")
                if !resultSet.columnIsNull("ParentType") {
                    referenceData.ParentType = resultSet.string(forColumn: "ParentType")
                }
                if !resultSet.columnIsNull("ParentValue") {
                    referenceData.ParentValue = resultSet.string(forColumn: "ParentValue")
                }
                
                referenceDataList.append(referenceData)
            }
        }
        sharedModelManager.database!.close()
        return referenceDataList
    }
    
    func findReferenceDataList(_ criteria: Dictionary<String, AnyObject>) -> [ReferenceData] {
        var list: [ReferenceData] = [ReferenceData]()
        //var count: Int32 = 0
        (list, _) = findReferenceDataList(criteria, pageSize: nil, pageNumber: nil)
        return list
    }
    
    func findReferenceDataList(_ criteria: Dictionary<String, AnyObject>, pageSize: Int32?, pageNumber: Int32?) -> (List: [ReferenceData], Count: Int32) {
        var list: [ReferenceData] = [ReferenceData]()
        var count: Int32 = 0
        (list, count) = findReferenceDataList(criteria, pageSize: nil, pageNumber: nil, sortOrder: ReferenceDataSortOrder.display)
        return (list, count)
    }
    
    func findReferenceDataList(_ criteria: Dictionary<String, AnyObject>, pageSize: Int32?, pageNumber: Int32?, sortOrder: ReferenceDataSortOrder) -> (List: [ReferenceData], Count: Int32) {
        //return variables
        var count: Int32 = 0
        var referenceDataList: [ReferenceData] = [ReferenceData]()
        
        //build the order clause
        var orderByClause: String = " ORDER BY "
        
        switch sortOrder {
            
        case .display:
            orderByClause += "[Display] "
            
        case .ordinal:
            orderByClause += "[Ordinal] "
            
        }
        
        //build the where clause
        var whereClause: String = String()
        var whereValues: [AnyObject] = [AnyObject]()
        
        (whereClause, whereValues) = buildWhereClause(criteria)
        
        if (whereClause != "")
        {
            if (whereClause.contains("ParentType"))
            {
                whereClause = "WHERE " + whereClause
            }
            else
            {
                //whereClause = "WHERE ParentType IS NULL AND" + whereClause
                whereClause = "WHERE " + whereClause
            }
                
        }
        
        sharedModelManager.database!.open()
        let countSet: FMResultSet! = sharedModelManager.database!.executeQuery("SELECT COUNT([RowId]) FROM [ReferenceData] " + whereClause + orderByClause, withArgumentsIn: whereValues)
        if (countSet != nil) {
            while countSet.next() {
                count = countSet.int(forColumnIndex: 0)
            }
        }
        
        if (count > 0)
        {
            var pageClause: String = String()
            if (pageSize != nil && pageNumber != nil)
            {
                pageClause = " LIMIT " + String(pageSize!) + " OFFSET " + String((pageNumber! - 1) * pageSize!)
            }

            let resultSet: FMResultSet! = sharedModelManager.database!.executeQuery("SELECT [RowId], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [Deleted], [StartDate], [EndDate], [Type], [Value], [Ordinal], [Display], [System], [ParentType], [ParentValue] FROM [ReferenceData] " + whereClause + orderByClause + pageClause, withArgumentsIn: whereValues)
            if (resultSet != nil) {
                while resultSet.next() {
                    let referenceData : ReferenceData = ReferenceData()
                    referenceData.RowId = resultSet.string(forColumn: "RowId")!
                    referenceData.CreatedBy = resultSet.string(forColumn: "CreatedBy")!
                    referenceData.CreatedOn = resultSet.date(forColumn: "CreatedOn")!
                    if !resultSet.columnIsNull("LastUpdatedBy")
                    {
                        referenceData.LastUpdatedBy = resultSet.string(forColumn: "LastUpdatedBy")
                    }
                    if !resultSet.columnIsNull("LastUpdatedOn")
                    {
                        referenceData.LastUpdatedOn = resultSet.date(forColumn: "LastUpdatedOn")
                    }
                    if !resultSet.columnIsNull("Deleted")
                    {
                        referenceData.Deleted = resultSet.date(forColumn: "Deleted")
                    }
                    referenceData.StartDate = resultSet.date(forColumn: "StartDate")!
                    if !resultSet.columnIsNull("EndDate") {
                        referenceData.EndDate = resultSet.date(forColumn: "EndDate")
                    }
                    referenceData.ReferenceType = resultSet.string(forColumn: "Type")!
                    referenceData.Value = resultSet.string(forColumn: "Value")!
                    referenceData.Ordinal = Int(resultSet.int(forColumn: "Ordinal"))
                    referenceData.Display = resultSet.string(forColumn: "Display")!
                    referenceData.System = resultSet.bool(forColumn: "System")
                    if !resultSet.columnIsNull("ParentType") {
                        referenceData.ParentType = resultSet.string(forColumn: "ParentType")
                    }
                    if !resultSet.columnIsNull("ParentValue") {
                        referenceData.ParentValue = resultSet.string(forColumn: "ParentValue")
                    }
                    referenceDataList.append(referenceData)
                }
            }
        }
        
        sharedModelManager.database!.close()
        return (referenceDataList, count)
    }
    
    // MARK: - Site
    
    func addSite(_ site: Site) -> Bool {
        //build the sql statemnt
        var SQLStatement: String = String()
        var SQLParameterNames: String = String()
        var SQLParameterPlaceholders: String = String()
        var SQLParameterValues: [NSObject] = [NSObject]()
        
        SQLParameterNames = "[RowId], [CreatedBy], [CreatedOn]"
        SQLParameterPlaceholders = "?, ?, ?"
        SQLParameterValues.append(site.RowId as NSObject)
        SQLParameterValues.append(site.CreatedBy as NSObject)
        SQLParameterValues.append(site.CreatedOn as NSObject)
        
        if site.LastUpdatedBy != nil {
            SQLParameterNames += ", [LastUpdatedBy]"
            SQLParameterPlaceholders += ", ?"
            SQLParameterValues.append(site.LastUpdatedBy! as NSObject)
        }
        
        if site.LastUpdatedOn != nil {
            SQLParameterNames += ", [LastUpdatedOn]"
            SQLParameterPlaceholders += ", ?"
            SQLParameterValues.append(site.LastUpdatedOn! as NSObject)
        }
        
        if site.Deleted != nil {
            SQLParameterNames += ", [Deleted]"
            SQLParameterPlaceholders += ", ?"
            SQLParameterValues.append(site.Deleted! as NSObject)
        }
        SQLParameterNames += ", [OrganisationId]"
        SQLParameterPlaceholders += ", ?"
        SQLParameterValues.append(site.OrganisationId as NSObject)
        SQLParameterNames += ", [Name]"
        SQLParameterPlaceholders += ", ?"
        SQLParameterValues.append(site.Name as NSObject)
        
        SQLStatement = "INSERT INTO [Site] (" + SQLParameterNames + ") VALUES (" + SQLParameterPlaceholders + ")"
        
        sharedModelManager.database!.open()
        let isInserted = sharedModelManager.database!.executeUpdate(SQLStatement, withArgumentsIn: SQLParameterValues)
        sharedModelManager.database!.close()
        return isInserted
    }
    
    func updateSite(_ site: Site) -> Bool {
        //build the sql statemnt
        var SQLStatement: String = String()
        var SQLParameterNames: String = String()
        var SQLParameterValues: [NSObject] = [NSObject]()
        
        SQLParameterNames = "[CreatedBy]=?, [CreatedOn]=?"
        SQLParameterValues.append(site.CreatedBy as NSObject)
        SQLParameterValues.append(site.CreatedOn as NSObject)
        
        if site.LastUpdatedBy != nil {
            SQLParameterNames += ", [LastUpdatedBy]=?"
            SQLParameterValues.append(site.LastUpdatedBy! as NSObject)
        }
        
        if site.LastUpdatedOn != nil {
            SQLParameterNames += ", [LastUpdatedOn]=?"
            SQLParameterValues.append(site.LastUpdatedOn! as NSObject)
        }
        
        if site.Deleted != nil {
            SQLParameterNames += ", [Deleted]=?"
            SQLParameterValues.append(site.Deleted! as NSObject)
        }
        
        SQLParameterNames += ", [OrganisationId]=?"
        SQLParameterValues.append(site.OrganisationId as NSObject)
        SQLParameterNames += ", [Name]=?"
        SQLParameterValues.append(site.Name as NSObject)
        
        SQLParameterValues.append(site.RowId as NSObject)
        
        SQLStatement = "UPDATE [Site] SET " + SQLParameterNames + "WHERE [RowId]=?"
        
        sharedModelManager.database!.open()
        let isUpdated = sharedModelManager.database!.executeUpdate(SQLStatement, withArgumentsIn: SQLParameterValues)
        sharedModelManager.database!.close()
        return isUpdated
    }
    
    func deleteSite(_ site: Site) -> Bool {
        sharedModelManager.database!.open()
        let isDeleted = sharedModelManager.database!.executeUpdate("DELETE FROM [Site] WHERE [RowId]=?", withArgumentsIn: [site.RowId])
        sharedModelManager.database!.close()
        return isDeleted
    }
    
    func getSite(_ siteId: String) -> Site? {
        sharedModelManager.database!.open()
        var site: Site? = nil
        
        let resultSet = sharedModelManager.database!.executeQuery("SELECT [RowId], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [Deleted], [OrganisationId], [Name] FROM [Site] WHERE [RowId]=?", withArgumentsIn: [siteId])
        if (resultSet != nil) {
            while (resultSet?.next())! {
                var resultSite: Site = Site()
                resultSite = Site()
                resultSite.RowId = (resultSet?.string(forColumn: "RowId"))!
                resultSite.CreatedBy = (resultSet?.string(forColumn: "CreatedBy"))!
                resultSite.CreatedOn = resultSet!.date(forColumn: "CreatedOn")!
                if !(resultSet?.columnIsNull("LastUpdatedBy"))!
                {
                    resultSite.LastUpdatedBy = resultSet?.string(forColumn: "LastUpdatedBy")
                }
                if !(resultSet?.columnIsNull("LastUpdatedOn"))!
                {
                    resultSite.LastUpdatedOn = resultSet?.date(forColumn: "LastUpdatedOn")
                }
                if !(resultSet?.columnIsNull("Deleted"))!
                {
                    resultSite.Deleted = resultSet?.date(forColumn: "Deleted")
                }
                resultSite.OrganisationId = (resultSet?.string(forColumn: "OrganisationId"))!
                resultSite.Name = (resultSet?.string(forColumn: "Name"))!
                
                site = resultSite
            }
        }
        sharedModelManager.database!.close()
        return site
    }
    
    func getAllSite() -> [Site] {
        sharedModelManager.database!.open()
        let resultSet: FMResultSet! = sharedModelManager.database!.executeQuery("SELECT [RowId], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [Deleted], [OrganisationId], [Name] FROM [Site]", withArgumentsIn: [])
        var siteList: [Site] = [Site]()
        if (resultSet != nil) {
            while resultSet.next() {
                let site : Site = Site()
                site.RowId = resultSet.string(forColumn: "RowId")!
                site.CreatedBy = resultSet.string(forColumn: "CreatedBy")!
                site.CreatedOn = resultSet.date(forColumn: "CreatedOn")!
                if !resultSet.columnIsNull("LastUpdatedBy")
                {
                    site.LastUpdatedBy = resultSet.string(forColumn: "LastUpdatedBy")
                }
                if !resultSet.columnIsNull("LastUpdatedOn")
                {
                    site.LastUpdatedOn = resultSet.date(forColumn: "LastUpdatedOn")
                }
                if !resultSet.columnIsNull("Deleted")
                {
                    site.Deleted = resultSet.date(forColumn: "Deleted")
                }
                site.OrganisationId = resultSet.string(forColumn: "OrganisationId")!
                site.Name = resultSet.string(forColumn: "Name")!
                
                siteList.append(site)
            }
        }
        sharedModelManager.database!.close()
        return siteList
    }
    
    func findSiteList(_ criteria: Dictionary<String, AnyObject>) -> [Site] {
        var list: [Site] = [Site]()
        //var count: Int32 = 0
        (list, _) = findSiteList(criteria, pageSize: nil, pageNumber: nil)
        return list
    }
    
    func findSiteList(_ criteria: Dictionary<String, AnyObject>, pageSize: Int32?, pageNumber: Int32?) -> (List: [Site], Count: Int32) {
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
        let countSet: FMResultSet! = sharedModelManager.database!.executeQuery("SELECT COUNT([RowId]) FROM [Site] " + whereClause + orderByClause, withArgumentsIn: whereValues)
        if (countSet != nil) {
            while countSet.next() {
                count = countSet.int(forColumnIndex: 0)
            }
        }
        
        if (count > 0)
        {
            var pageClause: String = String()
            if (pageSize != nil && pageNumber != nil)
            {
                pageClause = " LIMIT " + String(pageSize!) + " OFFSET " + String((pageNumber! - 1) * pageSize!)
            }
            
            let resultSet: FMResultSet! = sharedModelManager.database!.executeQuery("SELECT [RowId], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [Deleted], [OrganisationId], [Name] FROM [Site] " + whereClause + orderByClause + pageClause, withArgumentsIn: whereValues)
            if (resultSet != nil) {
                while resultSet.next() {
                    let site : Site = Site()
                    site.RowId = resultSet.string(forColumn: "RowId")!
                    site.CreatedBy = resultSet.string(forColumn: "CreatedBy")!
                    site.CreatedOn = resultSet.date(forColumn: "CreatedOn")!
                    if !resultSet.columnIsNull("LastUpdatedBy")
                    {
                        site.LastUpdatedBy = resultSet.string(forColumn: "LastUpdatedBy")
                    }
                    if !resultSet.columnIsNull("LastUpdatedOn")
                    {
                        site.LastUpdatedOn = resultSet.date(forColumn: "LastUpdatedOn")
                    }
                    if !resultSet.columnIsNull("Deleted")
                    {
                        site.Deleted = resultSet.date(forColumn: "Deleted")
                    }
                    site.OrganisationId = resultSet.string(forColumn: "OrganisationId")!
                    site.Name = resultSet.string(forColumn: "Name")!
                    
                    siteList.append(site)
                }
            }
        }
        
        sharedModelManager.database!.close()
        return (siteList, count)
    }
    
    // MARK: - Task
    
    func addTask(_ task: Task) -> Bool {
        //build the sql statemnt
        var SQLStatement: String = String()
        var SQLParameterNames: String = String()
        var SQLParameterPlaceholders: String = String()
        var SQLParameterValues: [NSObject] = [NSObject]()
        
        SQLParameterNames = "[RowId], [CreatedBy], [CreatedOn]"
        SQLParameterPlaceholders = "?, ?, ?"
        SQLParameterValues.append(task.RowId as NSObject)
        SQLParameterValues.append(task.CreatedBy as NSObject)
        SQLParameterValues.append(task.CreatedOn as NSObject)
        
        if task.LastUpdatedBy != nil {
            SQLParameterNames += ", [LastUpdatedBy]"
            SQLParameterPlaceholders += ", ?"
            SQLParameterValues.append(task.LastUpdatedBy! as NSObject)
        }
        
        if task.LastUpdatedOn != nil {
            SQLParameterNames += ", [LastUpdatedOn]"
            SQLParameterPlaceholders += ", ?"
            SQLParameterValues.append(task.LastUpdatedOn! as NSObject)
        }
        
        if task.Deleted != nil {
            SQLParameterNames += ", [Deleted]"
            SQLParameterPlaceholders += ", ?"
            SQLParameterValues.append(task.Deleted! as NSObject)
        }
        SQLParameterNames += ", [OrganisationId]"
        SQLParameterPlaceholders += ", ?"
        SQLParameterValues.append(task.OrganisationId as NSObject)
        SQLParameterNames += ", [SiteId]"
        SQLParameterPlaceholders += ", ?"
        SQLParameterValues.append(task.SiteId as NSObject)
        SQLParameterNames += ", [PropertyId]"
        SQLParameterPlaceholders += ", ?"
        SQLParameterValues.append(task.PropertyId as NSObject)
        SQLParameterNames += ", [LocationId]"
        SQLParameterPlaceholders += ", ?"
        SQLParameterValues.append(task.LocationId as NSObject)
        SQLParameterNames += ", [LocationGroupName]"
        SQLParameterPlaceholders += ", ?"
        SQLParameterValues.append(task.LocationGroupName as NSObject)
        SQLParameterNames += ", [LocationName]"
        SQLParameterPlaceholders += ", ?"
        SQLParameterValues.append(task.LocationName as NSObject)
        if task.Room != nil {
            SQLParameterNames += ", [Room]"
            SQLParameterPlaceholders += ", ?"
            SQLParameterValues.append(task.Room! as NSObject)
        }
        if task.TaskTemplateId != nil {
            SQLParameterNames += ", [TaskTemplateId]"
            SQLParameterPlaceholders += ", ?"
            SQLParameterValues.append(task.TaskTemplateId! as NSObject)
        }
        SQLParameterNames += ", [TaskRef]"
        SQLParameterPlaceholders += ", ?"
        SQLParameterValues.append(task.TaskRef as NSObject)
        if task.PPMGroup != nil {
            SQLParameterNames += ", [PPMGroup]"
            SQLParameterPlaceholders += ", ?"
            SQLParameterValues.append(task.PPMGroup! as NSObject)
        }
        if task.AssetType != nil {
            SQLParameterNames += ", [AssetType]"
            SQLParameterPlaceholders += ", ?"
            SQLParameterValues.append(task.AssetType! as NSObject)
        }
        SQLParameterNames += ", [TaskName]"
        SQLParameterPlaceholders += ", ?"
        SQLParameterValues.append(task.TaskName as NSObject)
        SQLParameterNames += ", [Frequency]"
        SQLParameterPlaceholders += ", ?"
        SQLParameterValues.append(task.Frequency as NSObject)
        if task.AssetId != nil {
            SQLParameterNames += ", [AssetId]"
            SQLParameterPlaceholders += ", ?"
            SQLParameterValues.append(task.AssetId! as NSObject)
        }
        if task.AssetNumber != nil {
            SQLParameterNames += ", [AssetNumber]"
            SQLParameterPlaceholders += ", ?"
            SQLParameterValues.append(task.AssetNumber! as NSObject)
        }
        SQLParameterNames += ", [ScheduledDate]"
        SQLParameterPlaceholders += ", ?"
        SQLParameterValues.append(task.ScheduledDate as NSObject)
        if task.CompletedDate != nil {
            SQLParameterNames += ", [CompletedDate]"
            SQLParameterPlaceholders += ", ?"
            SQLParameterValues.append(task.CompletedDate! as NSObject)
        }
        SQLParameterNames += ", [Status]"
        SQLParameterPlaceholders += ", ?"
        SQLParameterValues.append(task.Status as NSObject)
        SQLParameterNames += ", [Priority]"
        SQLParameterPlaceholders += ", ?"
        SQLParameterValues.append(task.Priority as NSObject)
        if task.EstimatedDuration != nil {
            SQLParameterNames += ", [EstimatedDuration]"
            SQLParameterPlaceholders += ", ?"
            SQLParameterValues.append(task.EstimatedDuration! as NSObject)
        }
        if task.OperativeId != nil {
            SQLParameterNames += ", [OperativeId]"
            SQLParameterPlaceholders += ", ?"
            SQLParameterValues.append(task.OperativeId! as NSObject)
        }
        if task.ActualDuration != nil {
            SQLParameterNames += ", [ActualDuration]"
            SQLParameterPlaceholders += ", ?"
            SQLParameterValues.append(task.ActualDuration! as NSObject)
        }
        if task.TravelDuration != nil {
            SQLParameterNames += ", [TravelDuration]"
            SQLParameterPlaceholders += ", ?"
            SQLParameterValues.append(task.TravelDuration! as NSObject)
        }
        if task.Comments != nil {
            SQLParameterNames += ", [Comments]"
            SQLParameterPlaceholders += ", ?"
            SQLParameterValues.append(task.Comments! as NSObject)
        }
        if task.AlternateAssetCode != nil {
            SQLParameterNames += ", [AlternateAssetCode]"
            SQLParameterPlaceholders += ", ?"
            SQLParameterValues.append(task.AlternateAssetCode! as NSObject)
        }
        if task.Level != nil {
            SQLParameterNames += ", [Level]"
            SQLParameterPlaceholders += ", ?"
            SQLParameterValues.append(task.Level! as NSObject)
        }
        
        SQLStatement = "INSERT INTO [Task] (" + SQLParameterNames + ") VALUES (" + SQLParameterPlaceholders + ")"
        
        sharedModelManager.database!.open()
        let isInserted = sharedModelManager.database!.executeUpdate(SQLStatement, withArgumentsIn: SQLParameterValues)
        sharedModelManager.database!.close()
        return isInserted
    }
    
    func updateTask(_ task: Task) -> Bool {
        //build the sql statemnt
        var SQLStatement: String = String()
        var SQLParameterNames: String = String()
        var SQLParameterValues: [NSObject] = [NSObject]()
        
        SQLParameterNames = "[CreatedBy]=?, [CreatedOn]=?"
        SQLParameterValues.append(task.CreatedBy as NSObject)
        SQLParameterValues.append(task.CreatedOn as NSObject)
        
        if task.LastUpdatedBy != nil {
            SQLParameterNames += ", [LastUpdatedBy]=?"
            SQLParameterValues.append(task.LastUpdatedBy! as NSObject)
        }
        
        if task.LastUpdatedOn != nil {
            SQLParameterNames += ", [LastUpdatedOn]=?"
            SQLParameterValues.append(task.LastUpdatedOn! as NSObject)
        }
        
        if task.Deleted != nil {
            SQLParameterNames += ", [Deleted]=?"
            SQLParameterValues.append(task.Deleted! as NSObject)
        }
        
        SQLParameterNames += ", [OrganisationId]=?"
        SQLParameterValues.append(task.OrganisationId as NSObject)
        SQLParameterNames += ", [SiteId]=?"
        SQLParameterValues.append(task.SiteId as NSObject)
        SQLParameterNames += ", [PropertyId]=?"
        SQLParameterValues.append(task.PropertyId as NSObject)
        SQLParameterNames += ", [LocationId]=?"
        SQLParameterValues.append(task.LocationId as NSObject)
        SQLParameterNames += ", [LocationGroupName]=?"
        SQLParameterValues.append(task.LocationGroupName as NSObject)
        SQLParameterNames += ", [LocationName]=?"
        SQLParameterValues.append(task.LocationName as NSObject)
        if task.Room != nil {
            SQLParameterNames += ", [Room]=?"
            SQLParameterValues.append(task.Room! as NSObject)
        }
        if task.TaskTemplateId != nil {
            SQLParameterNames += ", [TaskTemplateId]=?"
            SQLParameterValues.append(task.TaskTemplateId! as NSObject)
        }
        SQLParameterNames += ", [TaskRef]=?"
        SQLParameterValues.append(task.TaskRef as NSObject)
        if task.PPMGroup != nil {
            SQLParameterNames += ", [PPMGroup]=?"
            SQLParameterValues.append(task.PPMGroup! as NSObject)
        }
        if task.AssetType != nil {
            SQLParameterNames += ", [AssetType]=?"
            SQLParameterValues.append(task.AssetType! as NSObject)
        }
        SQLParameterNames += ", [TaskName]=?"
        SQLParameterValues.append(task.TaskName as NSObject)
        SQLParameterNames += ", [Frequency]=?"
        SQLParameterValues.append(task.Frequency as NSObject)
        if task.AssetId != nil {
            SQLParameterNames += ", [AssetId]=?"
            SQLParameterValues.append(task.AssetId! as NSObject)
        }
        if task.AssetNumber != nil {
            SQLParameterNames += ", [AssetNumber]=?"
            SQLParameterValues.append(task.AssetNumber! as NSObject)
        }
        SQLParameterNames += ", [ScheduledDate]=?"
        SQLParameterValues.append(task.ScheduledDate as NSObject)
        if task.CompletedDate != nil {
            SQLParameterNames += ", [CompletedDate]=?"
            SQLParameterValues.append(task.CompletedDate! as NSObject)
        }
        SQLParameterNames += ", [Status]=?"
        SQLParameterValues.append(task.Status as NSObject)
        SQLParameterNames += ", [Priority]=?"
        SQLParameterValues.append(task.Priority as NSObject)
        if task.EstimatedDuration != nil {
            SQLParameterNames += ", [EstimatedDuration]=?"
            SQLParameterValues.append(task.EstimatedDuration! as NSObject)
        }
        if task.OperativeId != nil {
            SQLParameterNames += ", [OperativeId]=?"
            SQLParameterValues.append(task.OperativeId! as NSObject)
        }
        if task.ActualDuration != nil {
            SQLParameterNames += ", [ActualDuration]=?"
            SQLParameterValues.append(task.ActualDuration! as NSObject)
        }
        if task.TravelDuration != nil {
            SQLParameterNames += ", [TravelDuration]=?"
            SQLParameterValues.append(task.TravelDuration! as NSObject)
        }
        if task.Comments != nil {
            SQLParameterNames += ", [Comments]=?"
            SQLParameterValues.append(task.Comments! as NSObject)
        }
        if task.AlternateAssetCode != nil {
            SQLParameterNames += ", [AlternateAssetCode]=?"
            SQLParameterValues.append(task.AlternateAssetCode! as NSObject)
        }
        if task.Level != nil {
            SQLParameterNames += ", [Level]=?"
            SQLParameterValues.append(task.Level! as NSObject)
        }
        
        SQLParameterValues.append(task.RowId as NSObject)
        
        SQLStatement = "UPDATE [Task] SET " + SQLParameterNames + "WHERE [RowId]=?"
        
        sharedModelManager.database!.open()
        let isUpdated = sharedModelManager.database!.executeUpdate(SQLStatement, withArgumentsIn: SQLParameterValues)
        sharedModelManager.database!.close()
        return isUpdated
    }
    
    func deleteTask(_ task: Task) -> Bool {
        sharedModelManager.database!.open()
        let isDeleted = sharedModelManager.database!.executeUpdate("DELETE FROM [Task] WHERE [RowId]=?", withArgumentsIn: [task.RowId])
        sharedModelManager.database!.close()
        return isDeleted
    }
    
    func getTask(_ taskId: String) -> Task? {
        sharedModelManager.database!.open()
        var task: Task? = nil
        
        let resultSet = sharedModelManager.database!.executeQuery("SELECT [RowId], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [Deleted], [OrganisationId], [SiteId], [PropertyId], [LocationId], [LocationGroupName], [LocationName], [Room], [TaskTemplateId], [TaskRef], [PPMGroup], [AssetType], [TaskName], [Frequency], [AssetId], [AssetNumber], [ScheduledDate], [CompletedDate], [Status], [Priority], [EstimatedDuration], [OperativeId], [ActualDuration], [TravelDuration], [Comments], [AlternateAssetCode], [Level] FROM [Task] WHERE [RowId]=?", withArgumentsIn: [taskId])
        if (resultSet != nil) {
            while (resultSet?.next())! {
                var resultTask: Task = Task()
                resultTask = Task()
                resultTask.RowId = (resultSet?.string(forColumn: "RowId"))!
                resultTask.CreatedBy = (resultSet?.string(forColumn: "CreatedBy"))!
                resultTask.CreatedOn = resultSet!.date(forColumn: "CreatedOn")!
                if !(resultSet?.columnIsNull("LastUpdatedBy"))!
                {
                    resultTask.LastUpdatedBy = resultSet?.string(forColumn: "LastUpdatedBy")
                }
                if !(resultSet?.columnIsNull("LastUpdatedOn"))!
                {
                    resultTask.LastUpdatedOn = resultSet?.date(forColumn: "LastUpdatedOn")
                }
                if !(resultSet?.columnIsNull("Deleted"))!
                {
                    resultTask.Deleted = resultSet?.date(forColumn: "Deleted")
                }
                resultTask.OrganisationId = (resultSet?.string(forColumn: "OrganisationId"))!
                resultTask.SiteId = (resultSet?.string(forColumn: "SiteId"))!
                resultTask.PropertyId = (resultSet?.string(forColumn: "PropertyId"))!
                resultTask.LocationId = (resultSet?.string(forColumn: "LocationId"))!
                resultTask.LocationGroupName = (resultSet?.string(forColumn: "LocationGroupName"))!
                resultTask.LocationName = (resultSet?.string(forColumn: "LocationName"))!
                if !(resultSet?.columnIsNull("Room"))! {
                    resultTask.Room = resultSet?.string(forColumn: "Room")
                }
                if !(resultSet?.columnIsNull("TaskTemplateId"))! {
                    resultTask.TaskTemplateId = resultSet?.string(forColumn: "TaskTemplateId")
                }
                resultTask.TaskRef = (resultSet?.string(forColumn: "TaskRef"))!
                if !(resultSet?.columnIsNull("PPMGroup"))! {
                    resultTask.PPMGroup = resultSet?.string(forColumn: "PPMGroup")
                }
                if !(resultSet?.columnIsNull("AssetType"))! {
                    resultTask.AssetType = resultSet?.string(forColumn: "AssetType")
                }
                resultTask.TaskName = (resultSet?.string(forColumn: "TaskName"))!
                resultTask.Frequency = (resultSet?.string(forColumn: "Frequency"))!
                if !(resultSet?.columnIsNull("AssetId"))! {
                    resultTask.AssetId = resultSet?.string(forColumn: "AssetId")
                }
                if !(resultSet?.columnIsNull("AssetNumber"))! {
                    resultTask.AssetNumber = resultSet?.string(forColumn: "AssetNumber")
                }
                resultTask.ScheduledDate = resultSet!.date(forColumn: "ScheduledDate")!
                if !(resultSet?.columnIsNull("CompletedDate"))! {
                    resultTask.CompletedDate = resultSet?.date(forColumn: "CompletedDate")
                }
                resultTask.Status = (resultSet?.string(forColumn: "Status"))!
                resultTask.Priority = Int((resultSet?.int(forColumn: "Priority"))!)
                if !(resultSet?.columnIsNull("EstimatedDuration"))! {
                    resultTask.EstimatedDuration = Int((resultSet?.int(forColumn: "EstimatedDuration"))!)
                }
                if !(resultSet?.columnIsNull("OperativeId"))! {
                    resultTask.OperativeId = resultSet?.string(forColumn: "OperativeId")
                }
                if !(resultSet?.columnIsNull("ActualDuration"))! {
                    resultTask.ActualDuration = Int((resultSet?.int(forColumn: "ActualDuration"))!)
                }
                if !(resultSet?.columnIsNull("TravelDuration"))! {
                    resultTask.TravelDuration = Int((resultSet?.int(forColumn: "TravelDuration"))!)
                }
                if !(resultSet?.columnIsNull("Comments"))! {
                    resultTask.Comments = resultSet?.string(forColumn: "Comments")
                }
                if !(resultSet?.columnIsNull("AlternateAssetCode"))! {
                    resultTask.AlternateAssetCode = resultSet?.string(forColumn: "AlternateAssetCode")
                }
                if !(resultSet?.columnIsNull("Level"))! {
                    resultTask.Level = resultSet?.string(forColumn: "Level")
                }
                task = resultTask
            }
        }
        sharedModelManager.database!.close()
        return task
    }
    
    func getAllTask() -> [Task] {
        sharedModelManager.database!.open()
        let resultSet: FMResultSet! = sharedModelManager.database!.executeQuery("SELECT [RowId], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [Deleted], [OrganisationId], [SiteId], [PropertyId], [LocationId], [LocationGroupName], [LocationName], [Room], [TaskTemplateId], [TaskRef], [PPMGroup], [AssetType], [TaskName], [Frequency], [AssetId], [AssetNumber], [ScheduledDate], [CompletedDate], [Status], [Priority], [EstimatedDuration], [OperativeId], [ActualDuration], [TravelDuration], [Comments], [AlternateAssetCode], [Level] FROM [Task]", withArgumentsIn: [])
        var taskList: [Task] = [Task]()
        if (resultSet != nil) {
            while resultSet.next() {
                let task : Task = Task()
                task.RowId = resultSet.string(forColumn: "RowId")!
                task.CreatedBy = resultSet.string(forColumn: "CreatedBy")!
                task.CreatedOn = resultSet.date(forColumn: "CreatedOn")!
                if !resultSet.columnIsNull("LastUpdatedBy")
                {
                    task.LastUpdatedBy = resultSet.string(forColumn: "LastUpdatedBy")
                }
                if !resultSet.columnIsNull("LastUpdatedOn")
                {
                    task.LastUpdatedOn = resultSet.date(forColumn: "LastUpdatedOn")
                }
                if !resultSet.columnIsNull("Deleted")
                {
                    task.Deleted = resultSet.date(forColumn: "Deleted")
                }
                task.OrganisationId = resultSet.string(forColumn: "OrganisationId")!
                task.SiteId = resultSet.string(forColumn: "SiteId")!
                task.PropertyId = resultSet.string(forColumn: "PropertyId")!
                task.LocationId = resultSet.string(forColumn: "LocationId")!
                task.LocationGroupName = resultSet.string(forColumn: "LocationGroupName")!
                task.LocationName = resultSet.string(forColumn: "LocationName")!
                if !resultSet.columnIsNull("Room") {
                    task.Room = resultSet.string(forColumn: "Room")
                }
                if !resultSet.columnIsNull("TaskTemplateId") {
                    task.TaskTemplateId = resultSet.string(forColumn: "TaskTemplateId")
                }
                task.TaskRef = resultSet.string(forColumn: "TaskRef")!
                if !resultSet.columnIsNull("PPMGroup") {
                    task.PPMGroup = resultSet.string(forColumn: "PPMGroup")
                }
                if !resultSet.columnIsNull("AssetType") {
                    task.AssetType = resultSet.string(forColumn: "AssetType")
                }
                task.TaskName = resultSet.string(forColumn: "TaskName")!
                task.Frequency = resultSet.string(forColumn: "Frequency")!
                if !resultSet.columnIsNull("AssetId") {
                    task.AssetId = resultSet.string(forColumn: "AssetId")
                }
                if !resultSet.columnIsNull("AssetNumber") {
                    task.AssetNumber = resultSet.string(forColumn: "AssetNumber")
                }
                task.ScheduledDate = resultSet.date(forColumn: "ScheduledDate")!
                if !resultSet.columnIsNull("CompletedDate") {
                    task.CompletedDate = resultSet.date(forColumn: "CompletedDate")
                }
                task.Status = resultSet.string(forColumn: "Status")!
                task.Priority = Int(resultSet.int(forColumn: "Priority"))
                if !resultSet.columnIsNull("EstimatedDuration") {
                    task.EstimatedDuration = Int(resultSet.int(forColumn: "EstimatedDuration"))
                }
                if !resultSet.columnIsNull("OperativeId") {
                    task.OperativeId = resultSet.string(forColumn: "OperativeId")
                }
                if !resultSet.columnIsNull("ActualDuration") {
                    task.ActualDuration = Int(resultSet.int(forColumn: "ActualDuration"))
                }
                if !resultSet.columnIsNull("TravelDuration") {
                    task.TravelDuration = Int(resultSet.int(forColumn: "TravelDuration"))
                }
                if !resultSet.columnIsNull("Comments") {
                    task.Comments = resultSet.string(forColumn: "Comments")
                }
                if !resultSet.columnIsNull("AlternateAssetCode") {
                    task.AlternateAssetCode = resultSet.string(forColumn: "AlternateAssetCode")
                }
                if !resultSet.columnIsNull("Level") {
                    task.Level = resultSet.string(forColumn: "Level")
                }
                taskList.append(task)
            }
        }
        sharedModelManager.database!.close()
        return taskList
    }
    
    func findTaskList(_ criteria: Dictionary<String, AnyObject>, onlyPending: Bool) -> [Task] {
        var list: [Task] = [Task]()
        //var count: Int32 = 0
        (list, _) = findTaskList(criteria, onlyPending: true, pageSize: nil, pageNumber: nil, sortOrder: TaskSortOrder.date)
        return list
    }
    
    func findTaskList(_ criteria: Dictionary<String, AnyObject>, onlyPending: Bool, pageSize: Int32?, pageNumber: Int32?) -> (List: [Task], Count: Int32) {
        var list: [Task] = [Task]()
        var count: Int32 = 0
        (list, count) = findTaskList(criteria, onlyPending: true, pageSize: nil, pageNumber: nil, sortOrder: TaskSortOrder.date)
        return (list, count)
    }
    
    func findTaskList(_ criteria: Dictionary<String, AnyObject>, onlyPending: Bool, pageSize: Int32?, pageNumber: Int32?, sortOrder: TaskSortOrder) -> (List: [Task], Count: Int32) {
        //return variables
        var count: Int32 = 0
        var taskList: [Task] = [Task]()
        
        //build the order clause
        var orderByClause: String = " ORDER BY "
        
        switch sortOrder {
            
        case .date:
            orderByClause += "[ScheduledDate], [LocationName], [PPMGroup], [AssetNumber] "
            
        case .location:
            orderByClause += "[LocationName], [PPMGroup], [AssetNumber], [ScheduledDate] "
            
        case .assetType:
            orderByClause += "[PPMGroup], [AssetNumber], [LocationName], [ScheduledDate] "
            
        case .task:
            orderByClause += "[TaskRef], [ScheduledDate], [LocationName], [PPMGroup], [AssetNumber] "

        case .priority:
            orderByClause += "[Priority], [LocationName], [ScheduledDate], [PPMGroup], [AssetNumber], [TaskRef]"
        }
        
        var whereCriteria: Dictionary<String, AnyObject> = criteria
        
        whereCriteria["Period"] = nil  //remove the period criteria
        whereCriteria["Status"] = nil
        whereCriteria["OperativeId"] = nil
        
        //build the where clause
        var whereClause: String = String()
        var whereValues: [AnyObject] = [AnyObject]()
        
        (whereClause, whereValues) = buildWhereClause(whereCriteria)
        
        if (criteria.keys.contains("Period"))
        {
            switch criteria["Period"] as! String
            {
            case DueTodayText:
                
                let endOfToday: Date = Date().endOfDay()
                
                whereClause += (whereClause != "" ? " AND " : " ")
                whereClause += " [ScheduledDate] <= ? "
                whereValues.append(endOfToday as AnyObject)
                
            case DueNext7DaysText:
                
                let endOfThisWeek: Date = Date().endOfWeek()
                
                whereClause += (whereClause != "" ? " AND " : " ")
                whereClause += " [ScheduledDate] <= ? "
                whereValues.append(endOfThisWeek as AnyObject)
                
            case DueCalendarMonthText:
                
                let endOfThisMonth: Date = Date().endOfMonth()
                
                whereClause += (whereClause != "" ? " AND " : " ")
                whereClause += " [ScheduledDate] <= ? "
                whereValues.append(endOfThisMonth as AnyObject)
                
            case DueThisMonthText:
                
                let startOfNextMonth: Date = Date().startOfNextMonth()
                let endOfNextMonth: Date = Date().endOfNextMonth()
                whereClause += (whereClause != "" ? " AND " : " ")
                whereClause += " [ScheduledDate] >= ? AND [ScheduledDate] <= ? "
                whereValues.append(startOfNextMonth as AnyObject)
                whereValues.append(endOfNextMonth as AnyObject)
                
            case "All":
                //nothing to do
                print("Catch All")
                
            default:
                //nothing to do
                print("Default")
                
            }
        }
        
        let whereClausePredicate: String = "WHERE "
        
        if (whereClause != "")
        {
            whereClause = whereClausePredicate + whereClause
        }
        
        sharedModelManager.database!.open()
        if(Session.FilterJustMyTasks)
        {
            whereClause += ModelUtility.getInstance().GetFilterJustMyTasksClause()
        }
        else
        {
            if (!whereClause.contains("OperativeId"))
            {
                whereClause += " AND (OperativeId IS NULL OR OperativeId = '00000000-0000-0000-0000-000000000000' OR OperativeId = '" + Session.OperativeId! + "')"
            }
        }
  
        if (onlyPending)
        {
            whereClause += " AND [Status] IN ('Pending','Outstanding') "
        }
        else
        {
            whereClause += " AND [Status] IN ('Complete','Dockable') "
        }

        let countSet: FMResultSet! = sharedModelManager.database!.executeQuery("SELECT COUNT([RowId]) FROM [Task] " + whereClause + orderByClause, withArgumentsIn: whereValues)
        if (countSet != nil) {
            while countSet.next() {
                count = countSet.int(forColumnIndex: 0)
            }
        }
        
        if (count > 0)
        {
            var pageClause: String = String()
            if (pageSize != nil && pageNumber != nil)
            {
                pageClause = " LIMIT " + String(pageSize!) + " OFFSET " + String((pageNumber! - 1) * pageSize!)
            }
            
            let resultSet: FMResultSet! = sharedModelManager.database!.executeQuery("SELECT [RowId], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [Deleted], [OrganisationId], [SiteId], [PropertyId], [LocationId], [LocationGroupName], [LocationName], [Room], [TaskTemplateId], [TaskRef], [PPMGroup], [AssetType], [TaskName], [Frequency], [AssetId], [AssetNumber], [ScheduledDate], [CompletedDate], [Status], [Priority], [EstimatedDuration], [OperativeId], [ActualDuration], [TravelDuration], [Comments], [AlternateAssetCode], [Level] FROM [Task] " + whereClause  + orderByClause + pageClause, withArgumentsIn: whereValues)
            if (resultSet != nil) {
                while resultSet.next() {
                    let task : Task = Task()
                    task.RowId = resultSet.string(forColumn: "RowId")!
                    task.CreatedBy = resultSet.string(forColumn: "CreatedBy")!
                    task.CreatedOn = resultSet.date(forColumn: "CreatedOn")!
                    if !resultSet.columnIsNull("LastUpdatedBy")
                    {
                        task.LastUpdatedBy = resultSet.string(forColumn: "LastUpdatedBy")
                    }
                    if !resultSet.columnIsNull("LastUpdatedOn")
                    {
                        task.LastUpdatedOn = resultSet.date(forColumn: "LastUpdatedOn")
                    }
                    if !resultSet.columnIsNull("Deleted")
                    {
                        task.Deleted = resultSet.date(forColumn: "Deleted")
                    }
                    task.OrganisationId = resultSet.string(forColumn: "OrganisationId")!
                    task.SiteId = resultSet.string(forColumn: "SiteId")!
                    task.PropertyId = resultSet.string(forColumn: "PropertyId")!
                    task.LocationId = resultSet.string(forColumn: "LocationId")!
                    task.LocationGroupName = resultSet.string(forColumn: "LocationGroupName")!
                    task.LocationName = resultSet.string(forColumn: "LocationName")!
                    if !resultSet.columnIsNull("Room") {
                        task.Room = resultSet.string(forColumn: "Room")
                    }
                    if !resultSet.columnIsNull("TaskTemplateId") {
                        task.TaskTemplateId = resultSet.string(forColumn: "TaskTemplateId")
                    }
                    task.TaskRef = resultSet.string(forColumn: "TaskRef")!
                    if !resultSet.columnIsNull("PPMGroup") {
                        task.PPMGroup = resultSet.string(forColumn: "PPMGroup")
                    }
                    if !resultSet.columnIsNull("AssetType") {
                        task.AssetType = resultSet.string(forColumn: "AssetType")
                    }
                    task.TaskName = resultSet.string(forColumn: "TaskName")!
                    task.Frequency = resultSet.string(forColumn: "Frequency")!
                    if !resultSet.columnIsNull("AssetId") {
                        task.AssetId = resultSet.string(forColumn: "AssetId")
                    }
                    if !resultSet.columnIsNull("AssetNumber") {
                        task.AssetNumber = resultSet.string(forColumn: "AssetNumber")
                    }
                    task.ScheduledDate = resultSet.date(forColumn: "ScheduledDate")!
                    if !resultSet.columnIsNull("CompletedDate") {
                        task.CompletedDate = resultSet.date(forColumn: "CompletedDate")
                    }
                    task.Status = resultSet.string(forColumn: "Status")!
                    task.Priority = Int(resultSet.int(forColumn: "Priority"))
                    if !resultSet.columnIsNull("EstimatedDuration") {
                        task.EstimatedDuration = Int(resultSet.int(forColumn: "EstimatedDuration"))
                    }
                    if !resultSet.columnIsNull("OperativeId") {
                        task.OperativeId = resultSet.string(forColumn: "OperativeId")
                    }
                    if !resultSet.columnIsNull("ActualDuration") {
                        task.ActualDuration = Int(resultSet.int(forColumn: "ActualDuration"))
                    }
                    if !resultSet.columnIsNull("TravelDuration") {
                        task.TravelDuration = Int(resultSet.int(forColumn: "TravelDuration"))
                    }
                    if !resultSet.columnIsNull("Comments") {
                        task.Comments = resultSet.string(forColumn: "Comments")
                    }
                    if !resultSet.columnIsNull("AlternateAssetCode") {
                        task.AlternateAssetCode = resultSet.string(forColumn: "AlternateAssetCode")
                    }
                    if !resultSet.columnIsNull("Level") {
                        task.Level = resultSet.string(forColumn: "Level")
                    }
                    taskList.append(task)
                }
            }
        }
        
        sharedModelManager.database!.close()
        return (taskList, count)
    }
    
    // MARK: - TaskInstruction
    
    func addTaskInstruction(_ taskInstruction: TaskInstruction) -> Bool {
        //build the sql statemnt
        var SQLStatement: String = String()
        var SQLParameterNames: String = String()
        var SQLParameterPlaceholders: String = String()
        var SQLParameterValues: [NSObject] = [NSObject]()
        
        SQLParameterNames = "[RowId], [CreatedBy], [CreatedOn]"
        SQLParameterPlaceholders = "?, ?, ?"
        SQLParameterValues.append(taskInstruction.RowId as NSObject)
        SQLParameterValues.append(taskInstruction.CreatedBy as NSObject)
        SQLParameterValues.append(taskInstruction.CreatedOn as NSObject)
        
        if taskInstruction.LastUpdatedBy != nil {
            SQLParameterNames += ", [LastUpdatedBy]"
            SQLParameterPlaceholders += ", ?"
            SQLParameterValues.append(taskInstruction.LastUpdatedBy! as NSObject)
        }
        
        if taskInstruction.LastUpdatedOn != nil {
            SQLParameterNames += ", [LastUpdatedOn]"
            SQLParameterPlaceholders += ", ?"
            SQLParameterValues.append(taskInstruction.LastUpdatedOn! as NSObject)
        }
        
        if taskInstruction.Deleted != nil {
            SQLParameterNames += ", [Deleted]"
            SQLParameterPlaceholders += ", ?"
            SQLParameterValues.append(taskInstruction.Deleted! as NSObject)
        }
        SQLParameterNames += ", [TaskId]"
        SQLParameterPlaceholders += ", ?"
        SQLParameterValues.append(taskInstruction.TaskId as NSObject)
        SQLParameterNames += ", [EntityType]"
        SQLParameterPlaceholders += ", ?"
        SQLParameterValues.append(taskInstruction.EntityType as NSObject)
        SQLParameterNames += ", [EntityId]"
        SQLParameterPlaceholders += ", ?"
        SQLParameterValues.append(taskInstruction.EntityId as NSObject)
        if taskInstruction.OutletId != nil {
            SQLParameterNames += ", [OutletId]"
            SQLParameterPlaceholders += ", ?"
            SQLParameterValues.append(taskInstruction.OutletId! as NSObject)
        }
        if taskInstruction.FlushType != nil {
            SQLParameterNames += ", [FlushType]"
            SQLParameterPlaceholders += ", ?"
            SQLParameterValues.append(taskInstruction.FlushType! as NSObject)
        }
        
        SQLStatement = "INSERT INTO [TaskInstruction] (" + SQLParameterNames + ") VALUES (" + SQLParameterPlaceholders + ")"
        
        sharedModelManager.database!.open()
        let isInserted = sharedModelManager.database!.executeUpdate(SQLStatement, withArgumentsIn: SQLParameterValues)
        sharedModelManager.database!.close()
        return isInserted
    }
    
    func updateTaskInstruction(_ taskInstruction: TaskInstruction) -> Bool {
        //build the sql statemnt
        var SQLStatement: String = String()
        var SQLParameterNames: String = String()
        var SQLParameterValues: [NSObject] = [NSObject]()
        
        SQLParameterNames = "[CreatedBy]=?, [CreatedOn]=?"
        SQLParameterValues.append(taskInstruction.CreatedBy as NSObject)
        SQLParameterValues.append(taskInstruction.CreatedOn as NSObject)
        
        if taskInstruction.LastUpdatedBy != nil {
            SQLParameterNames += ", [LastUpdatedBy]=?"
            SQLParameterValues.append(taskInstruction.LastUpdatedBy! as NSObject)
        }
        
        if taskInstruction.LastUpdatedOn != nil {
            SQLParameterNames += ", [LastUpdatedOn]=?"
            SQLParameterValues.append(taskInstruction.LastUpdatedOn! as NSObject)
        }
        
        if taskInstruction.Deleted != nil {
            SQLParameterNames += ", [Deleted]=?"
            SQLParameterValues.append(taskInstruction.Deleted! as NSObject)
        }
        
        SQLParameterNames += ", [TaskId]=?"
        SQLParameterValues.append(taskInstruction.TaskId as NSObject)
        SQLParameterNames += ", [EntityType]=?"
        SQLParameterValues.append(taskInstruction.EntityType as NSObject)
        SQLParameterNames += ", [EntityId]=?"
        SQLParameterValues.append(taskInstruction.EntityId as NSObject)
        if taskInstruction.OutletId != nil {
            SQLParameterNames += ", [OutletId]=?"
            SQLParameterValues.append(taskInstruction.OutletId! as NSObject)
        }
        if taskInstruction.FlushType != nil {
            SQLParameterNames += ", [FlushType]=?"
            SQLParameterValues.append(taskInstruction.FlushType! as NSObject)
        }
        
        SQLParameterValues.append(taskInstruction.RowId as NSObject)
        
        SQLStatement = "UPDATE [TaskInstruction] SET " + SQLParameterNames + "WHERE [RowId]=?"
        
        sharedModelManager.database!.open()
        let isUpdated = sharedModelManager.database!.executeUpdate(SQLStatement, withArgumentsIn: SQLParameterValues)
        sharedModelManager.database!.close()
        return isUpdated
    }
    
    func deleteTaskInstruction(_ taskInstruction: TaskInstruction) -> Bool {
        sharedModelManager.database!.open()
        let isDeleted = sharedModelManager.database!.executeUpdate("DELETE FROM [TaskInstruction] WHERE [RowId]=?", withArgumentsIn: [taskInstruction.RowId])
        sharedModelManager.database!.close()
        return isDeleted
    }
    
    func getTaskInstruction(_ taskInstructionId: String) -> TaskInstruction? {
        sharedModelManager.database!.open()
        var taskInstruction: TaskInstruction? = nil
        
        let resultSet = sharedModelManager.database!.executeQuery("SELECT [RowId], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [Deleted], [TaskId], [EntityType], [EntityId], [OutletId], [FlushType] FROM [TaskInstruction] WHERE [RowId]=?", withArgumentsIn: [taskInstructionId])
        if (resultSet != nil) {
            while (resultSet?.next())! {
                var resultTaskInstruction: TaskInstruction = TaskInstruction()
                resultTaskInstruction = TaskInstruction()
                resultTaskInstruction.RowId = (resultSet?.string(forColumn: "RowId"))!
                resultTaskInstruction.CreatedBy = (resultSet?.string(forColumn: "CreatedBy"))!
                resultTaskInstruction.CreatedOn = resultSet!.date(forColumn: "CreatedOn")!
                if !(resultSet?.columnIsNull("LastUpdatedBy"))!
                {
                    resultTaskInstruction.LastUpdatedBy = resultSet?.string(forColumn: "LastUpdatedBy")
                }
                if !(resultSet?.columnIsNull("LastUpdatedOn"))!
                {
                    resultTaskInstruction.LastUpdatedOn = resultSet?.date(forColumn: "LastUpdatedOn")
                }
                if !(resultSet?.columnIsNull("Deleted"))!
                {
                    resultTaskInstruction.Deleted = resultSet?.date(forColumn: "Deleted")
                }
                resultTaskInstruction.TaskId = (resultSet?.string(forColumn: "TaskId"))!
                resultTaskInstruction.EntityType = (resultSet?.string(forColumn: "EntityType"))!
                resultTaskInstruction.EntityId = (resultSet?.string(forColumn: "EntityId"))!
                if !(resultSet?.columnIsNull("OutletId"))! {
                    resultTaskInstruction.OutletId = resultSet?.string(forColumn: "OutletId")
                }
                if !(resultSet?.columnIsNull("FlushType"))! {
                    resultTaskInstruction.FlushType = resultSet?.string(forColumn: "FlushType")
                }
                taskInstruction = resultTaskInstruction
            }
        }
        sharedModelManager.database!.close()
        return taskInstruction
    }
    
    func getAllTaskInstruction() -> [TaskInstruction] {
        sharedModelManager.database!.open()
        let resultSet: FMResultSet! = sharedModelManager.database!.executeQuery("SELECT [RowId], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [Deleted], [TaskId], [EntityType], [EntityId], [OutletId], [FlushType] FROM [TaskInstruction]", withArgumentsIn: [])
        var taskInstructionList: [TaskInstruction] = [TaskInstruction]()
        if (resultSet != nil) {
            while resultSet.next() {
                let taskInstruction : TaskInstruction = TaskInstruction()
                taskInstruction.RowId = resultSet.string(forColumn: "RowId")!
                taskInstruction.CreatedBy = resultSet.string(forColumn: "CreatedBy")!
                taskInstruction.CreatedOn = resultSet.date(forColumn: "CreatedOn")!
                if !resultSet.columnIsNull("LastUpdatedBy")
                {
                    taskInstruction.LastUpdatedBy = resultSet.string(forColumn: "LastUpdatedBy")
                }
                if !resultSet.columnIsNull("LastUpdatedOn")
                {
                    taskInstruction.LastUpdatedOn = resultSet.date(forColumn: "LastUpdatedOn")
                }
                if !resultSet.columnIsNull("Deleted")
                {
                    taskInstruction.Deleted = resultSet.date(forColumn: "Deleted")
                }
                taskInstruction.TaskId = resultSet.string(forColumn: "TaskId")!
                taskInstruction.EntityType = resultSet.string(forColumn: "EntityType")!
                taskInstruction.EntityId = resultSet.string(forColumn: "EntityId")!
                if !resultSet.columnIsNull("OutletId") {
                    taskInstruction.OutletId = resultSet.string(forColumn: "OutletId")
                }
                if !resultSet.columnIsNull("FlushType") {
                    taskInstruction.FlushType = resultSet.string(forColumn: "FlushType")
                }
               taskInstructionList.append(taskInstruction)
            }
        }
        sharedModelManager.database!.close()
        return taskInstructionList
    }
    
    func findTaskInstructionList(_ criteria: Dictionary<String, AnyObject>) -> [TaskInstruction] {
        var list: [TaskInstruction] = [TaskInstruction]()
        //var count: Int32 = 0
        (list, _) = findTaskInstructionList(criteria, pageSize: nil, pageNumber: nil)
        return list
    }
    
    func findTaskInstructionList(_ criteria: Dictionary<String, AnyObject>, pageSize: Int32?, pageNumber: Int32?) -> (List: [TaskInstruction], Count: Int32) {
        
        //return variables
        var count: Int32 = 0
        var taskInstructionList: [TaskInstruction] = [TaskInstruction]()
        
        //build the where clause
        var whereClause: String = String()
        var whereValues: [AnyObject] = [AnyObject]()
        
        (whereClause, whereValues) = buildWhereClause(criteria)
        
        if (whereClause != "")
        {
            whereClause = "WHERE " + whereClause
        }
        
        sharedModelManager.database!.open()
        let countSet: FMResultSet! = sharedModelManager.database!.executeQuery("SELECT COUNT([RowId]) FROM [TaskInstruction] " + whereClause, withArgumentsIn: whereValues)
        if (countSet != nil) {
            while countSet.next() {
                count = countSet.int(forColumnIndex: 0)
            }
        }
        
        if (count > 0)
        {
            var pageClause: String = String()
            if (pageSize != nil && pageNumber != nil)
            {
                pageClause = " LIMIT " + String(pageSize!) + " OFFSET " + String((pageNumber! - 1) * pageSize!)
            }
            
            let resultSet: FMResultSet! = sharedModelManager.database!.executeQuery("SELECT [RowId], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [Deleted], [TaskId], [EntityType], [EntityId], [OutletId], [FlushType] FROM [TaskInstruction] " + whereClause + pageClause, withArgumentsIn: whereValues)
            if (resultSet != nil) {
                while resultSet.next() {
                    let taskInstruction : TaskInstruction = TaskInstruction()
                    taskInstruction.RowId = resultSet.string(forColumn: "RowId")!
                    taskInstruction.CreatedBy = resultSet.string(forColumn: "CreatedBy")!
                    taskInstruction.CreatedOn = resultSet.date(forColumn: "CreatedOn")!
                    if !resultSet.columnIsNull("LastUpdatedBy")
                    {
                        taskInstruction.LastUpdatedBy = resultSet.string(forColumn: "LastUpdatedBy")
                    }
                    if !resultSet.columnIsNull("LastUpdatedOn")
                    {
                        taskInstruction.LastUpdatedOn = resultSet.date(forColumn: "LastUpdatedOn")
                    }
                    if !resultSet.columnIsNull("Deleted")
                    {
                        taskInstruction.Deleted = resultSet.date(forColumn: "Deleted")
                    }
                    taskInstruction.TaskId = resultSet.string(forColumn: "TaskId")!
                    taskInstruction.EntityType = resultSet.string(forColumn: "EntityType")!
                    taskInstruction.EntityId = resultSet.string(forColumn: "EntityId")!
                    if !resultSet.columnIsNull("OutletId") {
                        taskInstruction.OutletId = resultSet.string(forColumn: "OutletId")
                    }
                    if !resultSet.columnIsNull("FlushType") {
                        taskInstruction.FlushType = resultSet.string(forColumn: "FlushType")
                    }
                    
                    taskInstructionList.append(taskInstruction)
                }
            }
        }
        
        sharedModelManager.database!.close()
        
        return (taskInstructionList, count)
    }
    
    // MARK: - TaskParameter
    
    func addTaskParameter(_ taskParameter: TaskParameter) -> Bool {
        //build the sql statemnt
        var SQLStatement: String = String()
        var SQLParameterNames: String = String()
        var SQLParameterPlaceholders: String = String()
        var SQLParameterValues: [NSObject] = [NSObject]()
        
        SQLParameterNames = "[RowId], [CreatedBy], [CreatedOn]"
        SQLParameterPlaceholders = "?, ?, ?"
        SQLParameterValues.append(taskParameter.RowId as NSObject)
        SQLParameterValues.append(taskParameter.CreatedBy as NSObject)
        SQLParameterValues.append(taskParameter.CreatedOn as NSObject)
        
        if taskParameter.LastUpdatedBy != nil {
            SQLParameterNames += ", [LastUpdatedBy]"
            SQLParameterPlaceholders += ", ?"
            SQLParameterValues.append(taskParameter.LastUpdatedBy! as NSObject)
        }
        
        if taskParameter.LastUpdatedOn != nil {
            SQLParameterNames += ", [LastUpdatedOn]"
            SQLParameterPlaceholders += ", ?"
            SQLParameterValues.append(taskParameter.LastUpdatedOn! as NSObject)
        }
        
        if taskParameter.Deleted != nil {
            SQLParameterNames += ", [Deleted]"
            SQLParameterPlaceholders += ", ?"
            SQLParameterValues.append(taskParameter.Deleted! as NSObject)
        }
        
        if taskParameter.TaskTemplateParameterId != nil {
            SQLParameterNames += ", [TaskTemplateParameterId]"
            SQLParameterPlaceholders += ", ?"
            SQLParameterValues.append(taskParameter.TaskTemplateParameterId! as NSObject)
        }
        SQLParameterNames += ", [TaskId]"
        SQLParameterPlaceholders += ", ?"
        SQLParameterValues.append(taskParameter.TaskId as NSObject)
        SQLParameterNames += ", [ParameterName]"
        SQLParameterPlaceholders += ", ?"
        SQLParameterValues.append(taskParameter.ParameterName as NSObject)
        SQLParameterNames += ", [ParameterType]"
        SQLParameterPlaceholders += ", ?"
        SQLParameterValues.append(taskParameter.ParameterType as NSObject)
        SQLParameterNames += ", [ParameterDisplay]"
        SQLParameterPlaceholders += ", ?"
        SQLParameterValues.append(taskParameter.ParameterDisplay as NSObject)
        SQLParameterNames += ", [Collect]"
        SQLParameterPlaceholders += ", ?"
        SQLParameterValues.append(taskParameter.Collect as NSObject)
        SQLParameterNames += ", [ParameterValue]"
        SQLParameterPlaceholders += ", ?"
        SQLParameterValues.append(taskParameter.ParameterValue as NSObject)
        
        SQLStatement = "INSERT INTO [TaskParameter] (" + SQLParameterNames + ") VALUES (" + SQLParameterPlaceholders + ")"
        
        sharedModelManager.database!.open()
        let isInserted = sharedModelManager.database!.executeUpdate(SQLStatement, withArgumentsIn: SQLParameterValues)
        sharedModelManager.database!.close()
        return isInserted
    }
    
    func updateTaskParameter(_ taskParameter: TaskParameter) -> Bool {
        //build the sql statemnt
        var SQLStatement: String = String()
        var SQLParameterNames: String = String()
        var SQLParameterValues: [NSObject] = [NSObject]()
        
        SQLParameterNames = "[CreatedBy]=?, [CreatedOn]=?"
        SQLParameterValues.append(taskParameter.CreatedBy as NSObject)
        SQLParameterValues.append(taskParameter.CreatedOn as NSObject)
        
        if taskParameter.LastUpdatedBy != nil {
            SQLParameterNames += ", [LastUpdatedBy]=?"
            SQLParameterValues.append(taskParameter.LastUpdatedBy! as NSObject)
        }
        
        if taskParameter.LastUpdatedOn != nil {
            SQLParameterNames += ", [LastUpdatedOn]=?"
            SQLParameterValues.append(taskParameter.LastUpdatedOn! as NSObject)
        }
        
        if taskParameter.Deleted != nil {
            SQLParameterNames += ", [Deleted]=?"
            SQLParameterValues.append(taskParameter.Deleted! as NSObject)
        }
        
        if taskParameter.TaskTemplateParameterId != nil {
            SQLParameterNames += ", [TaskTemplateParameterId]=?"
            SQLParameterValues.append(taskParameter.TaskTemplateParameterId! as NSObject)
        }
        SQLParameterNames += ", [TaskId]=?"
        SQLParameterValues.append(taskParameter.TaskId as NSObject)
        SQLParameterNames += ", [ParameterName]=?"
        SQLParameterValues.append(taskParameter.ParameterName as NSObject)
        SQLParameterNames += ", [ParameterType]=?"
        SQLParameterValues.append(taskParameter.ParameterType as NSObject)
        SQLParameterNames += ", [ParameterDisplay]=?"
        SQLParameterValues.append(taskParameter.ParameterDisplay as NSObject)
        SQLParameterNames += ", [Collect]=?"
        SQLParameterValues.append(taskParameter.Collect as NSObject)
        SQLParameterNames += ", [ParameterValue]=?"
        SQLParameterValues.append(taskParameter.ParameterValue as NSObject)
        
        SQLParameterValues.append(taskParameter.RowId as NSObject)
        
        SQLStatement = "UPDATE [TaskParameter] SET " + SQLParameterNames + "WHERE [RowId]=?"
        
        sharedModelManager.database!.open()
        let isUpdated = sharedModelManager.database!.executeUpdate(SQLStatement, withArgumentsIn: SQLParameterValues)
        sharedModelManager.database!.close()
        return isUpdated
    }
    
    func deleteTaskParameter(_ taskParameter: TaskParameter) -> Bool {
        sharedModelManager.database!.open()
        let isDeleted = sharedModelManager.database!.executeUpdate("DELETE FROM [TaskParameter] WHERE [RowId]=?", withArgumentsIn: [taskParameter.RowId])
        sharedModelManager.database!.close()
        return isDeleted
    }
    
    func getTaskParameter(_ taskParameterId: String) -> TaskParameter? {
        sharedModelManager.database!.open()
        var taskParameter: TaskParameter? = nil
        
        let resultSet = sharedModelManager.database!.executeQuery("SELECT [RowId], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [Deleted], [TaskTemplateParameterId], [TaskId], [ParameterName], [ParameterType], [ParameterDisplay], [Collect], [ParameterValue] FROM [TaskParameter] WHERE [RowId]=?", withArgumentsIn: [taskParameterId])
        if (resultSet != nil) {
            while (resultSet?.next())! {
                var resultTaskParameter: TaskParameter = TaskParameter()
                resultTaskParameter = TaskParameter()
                resultTaskParameter.RowId = (resultSet?.string(forColumn: "RowId"))!
                resultTaskParameter.CreatedBy = (resultSet?.string(forColumn: "CreatedBy"))!
                resultTaskParameter.CreatedOn = resultSet!.date(forColumn: "CreatedOn")!
                if !(resultSet?.columnIsNull("LastUpdatedBy"))!
                {
                    resultTaskParameter.LastUpdatedBy = resultSet?.string(forColumn: "LastUpdatedBy")
                }
                if !(resultSet?.columnIsNull("LastUpdatedOn"))!
                {
                    resultTaskParameter.LastUpdatedOn = resultSet?.date(forColumn: "LastUpdatedOn")
                }
                if !(resultSet?.columnIsNull("Deleted"))!
                {
                    resultTaskParameter.Deleted = resultSet?.date(forColumn: "Deleted")
                }
                if !(resultSet?.columnIsNull("TaskTemplateParameterId"))! {
                    resultTaskParameter.TaskTemplateParameterId = resultSet?.string(forColumn: "TaskTemplateParameterId")
                }
                resultTaskParameter.TaskId = (resultSet?.string(forColumn: "TaskId"))!
                resultTaskParameter.ParameterName = (resultSet?.string(forColumn: "ParameterName"))!
                resultTaskParameter.ParameterType = (resultSet?.string(forColumn: "ParameterType"))!
                resultTaskParameter.ParameterDisplay = (resultSet?.string(forColumn: "ParameterDisplay"))!
                resultTaskParameter.Collect = (resultSet?.bool(forColumn: "Collect"))!
                resultTaskParameter.ParameterValue = (resultSet?.string(forColumn: "ParameterValue"))!
                
                taskParameter = resultTaskParameter
            }
        }
        sharedModelManager.database!.close()
        return taskParameter
    }
    
    func getAllTaskParameter() -> [TaskParameter] {
        sharedModelManager.database!.open()
        let resultSet: FMResultSet! = sharedModelManager.database!.executeQuery("SELECT [RowId], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [Deleted], [TaskTemplateParameterId], [TaskId], [ParameterName], [ParameterType], [ParameterDisplay], [Collect], [ParameterValue] FROM [TaskParameter]", withArgumentsIn: [])
        var taskParameterList: [TaskParameter] = [TaskParameter]()
        if (resultSet != nil) {
            while resultSet.next() {
                let taskParameter : TaskParameter = TaskParameter()
                taskParameter.RowId = resultSet.string(forColumn: "RowId")!
                taskParameter.CreatedBy = resultSet.string(forColumn: "CreatedBy")!
                taskParameter.CreatedOn = resultSet.date(forColumn: "CreatedOn")!
                if !resultSet.columnIsNull("LastUpdatedBy")
                {
                    taskParameter.LastUpdatedBy = resultSet.string(forColumn: "LastUpdatedBy")
                }
                if !resultSet.columnIsNull("LastUpdatedOn")
                {
                    taskParameter.LastUpdatedOn = resultSet.date(forColumn: "LastUpdatedOn")
                }
                if !resultSet.columnIsNull("Deleted")
                {
                    taskParameter.Deleted = resultSet.date(forColumn: "Deleted")
                }
                if !resultSet.columnIsNull("TaskTemplateParameterId") {
                    taskParameter.TaskTemplateParameterId = resultSet.string(forColumn: "TaskTemplateParameterId")
                }
                taskParameter.TaskId = resultSet.string(forColumn: "TaskId")!
                taskParameter.ParameterName = resultSet.string(forColumn: "ParameterName")!
                taskParameter.ParameterType = resultSet.string(forColumn: "ParameterType")!
                taskParameter.ParameterDisplay = resultSet.string(forColumn: "ParameterDisplay")!
                taskParameter.Collect = resultSet.bool(forColumn: "Collect")
                taskParameter.ParameterValue = resultSet.string(forColumn: "ParameterValue")!
                
                taskParameterList.append(taskParameter)
            }
        }
        sharedModelManager.database!.close()
        return taskParameterList
    }
    
    func findTaskParameterList(_ criteria: Dictionary<String, AnyObject>) -> [TaskParameter] {
        var list: [TaskParameter] = [TaskParameter]()
        //var count: Int32 = 0
        (list, _) = findTaskParameterList(criteria, pageSize: nil, pageNumber: nil)
        return list
    }
    
    func findTaskParameterList(_ criteria: Dictionary<String, AnyObject>, pageSize: Int32?, pageNumber: Int32?) -> (List: [TaskParameter], Count: Int32) {
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
        let countSet: FMResultSet! = sharedModelManager.database!.executeQuery("SELECT COUNT([RowId]) FROM [TaskParameter] " + whereClause + orderByClause, withArgumentsIn: whereValues)
        if (countSet != nil) {
            while countSet.next() {
                count = countSet.int(forColumnIndex: 0)
            }
        }
        
        if (count > 0)
        {
            var pageClause: String = String()
            if (pageSize != nil && pageNumber != nil)
            {
                pageClause = " LIMIT " + String(pageSize!) + " OFFSET " + String((pageNumber! - 1) * pageSize!)
            }
            
            let resultSet: FMResultSet! = sharedModelManager.database!.executeQuery("SELECT [RowId], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [Deleted], [TaskTemplateParameterId], [TaskId], [ParameterName], [ParameterType], [ParameterDisplay], [Collect], [ParameterValue] FROM [TaskParameter] " + whereClause + orderByClause + pageClause, withArgumentsIn: whereValues)
            if (resultSet != nil) {
                while resultSet.next() {
                    let taskParameter : TaskParameter = TaskParameter()
                    taskParameter.RowId = resultSet.string(forColumn: "RowId")!
                    taskParameter.CreatedBy = resultSet.string(forColumn: "CreatedBy")!
                    taskParameter.CreatedOn = resultSet.date(forColumn: "CreatedOn")!
                    if !resultSet.columnIsNull("LastUpdatedBy")
                    {
                        taskParameter.LastUpdatedBy = resultSet.string(forColumn: "LastUpdatedBy")
                    }
                    if !resultSet.columnIsNull("LastUpdatedOn")
                    {
                        taskParameter.LastUpdatedOn = resultSet.date(forColumn: "LastUpdatedOn")
                    }
                    if !resultSet.columnIsNull("Deleted")
                    {
                        taskParameter.Deleted = resultSet.date(forColumn: "Deleted")
                    }
                    if !resultSet.columnIsNull("TaskTemplateParameterId") {
                        taskParameter.TaskTemplateParameterId = resultSet.string(forColumn: "TaskTemplateParameterId")
                    }
                    taskParameter.TaskId = resultSet.string(forColumn: "TaskId")!
                    taskParameter.ParameterName = resultSet.string(forColumn: "ParameterName")!
                    taskParameter.ParameterType = resultSet.string(forColumn: "ParameterType")!
                    taskParameter.ParameterDisplay = resultSet.string(forColumn: "ParameterDisplay")!
                    taskParameter.Collect = resultSet.bool(forColumn: "Collect")
                    taskParameter.ParameterValue = resultSet.string(forColumn: "ParameterValue")!
                    
                    taskParameterList.append(taskParameter)
                }
            }
        }
        
        sharedModelManager.database!.close()
        return (taskParameterList, count)
    }
    
    // MARK: - TaskTemplate
    
    func addTaskTemplate(_ taskTemplate: TaskTemplate) -> Bool {
        //build the sql statemnt
        var SQLStatement: String = String()
        var SQLParameterNames: String = String()
        var SQLParameterPlaceholders: String = String()
        var SQLParameterValues: [NSObject] = [NSObject]()
        
        SQLParameterNames = "[RowId], [CreatedBy], [CreatedOn]"
        SQLParameterPlaceholders = "?, ?, ?"
        SQLParameterValues.append(taskTemplate.RowId as NSObject)
        SQLParameterValues.append(taskTemplate.CreatedBy as NSObject)
        SQLParameterValues.append(taskTemplate.CreatedOn as NSObject)
        
        if taskTemplate.LastUpdatedBy != nil {
            SQLParameterNames += ", [LastUpdatedBy]"
            SQLParameterPlaceholders += ", ?"
            SQLParameterValues.append(taskTemplate.LastUpdatedBy! as NSObject)
        }
        
        if taskTemplate.LastUpdatedOn != nil {
            SQLParameterNames += ", [LastUpdatedOn]"
            SQLParameterPlaceholders += ", ?"
            SQLParameterValues.append(taskTemplate.LastUpdatedOn! as NSObject)
        }
        
        if taskTemplate.Deleted != nil {
            SQLParameterNames += ", [Deleted]"
            SQLParameterPlaceholders += ", ?"
            SQLParameterValues.append(taskTemplate.Deleted! as NSObject)
        }
        
        SQLParameterNames += ", [OrganisationId]"
        SQLParameterPlaceholders += ", ?"
        SQLParameterValues.append(taskTemplate.OrganisationId as NSObject)
        SQLParameterNames += ", [AssetType]"
        SQLParameterPlaceholders += ", ?"
        SQLParameterValues.append(taskTemplate.AssetType as NSObject)
        SQLParameterNames += ", [TaskName]"
        SQLParameterPlaceholders += ", ?"
        SQLParameterValues.append(taskTemplate.TaskName as NSObject)
        SQLParameterNames += ", [Priority]"
        SQLParameterPlaceholders += ", ?"
        SQLParameterValues.append(taskTemplate.Priority as NSObject)
        SQLParameterNames += ", [EstimatedDuration]"
        SQLParameterPlaceholders += ", ?"
        SQLParameterValues.append(taskTemplate.EstimatedDuration as NSObject)
        SQLParameterNames += ", [CanCreateFromDevice]"
        SQLParameterPlaceholders += ", ?"
        SQLParameterValues.append(taskTemplate.CanCreateFromDevice as NSObject)
        
        SQLStatement = "INSERT INTO [TaskTemplate] (" + SQLParameterNames + ") VALUES (" + SQLParameterPlaceholders + ")"
        
        sharedModelManager.database!.open()
        let isInserted = sharedModelManager.database!.executeUpdate(SQLStatement, withArgumentsIn: SQLParameterValues)
        sharedModelManager.database!.close()
        return isInserted
    }
    
    func updateTaskTemplate(_ taskTemplate: TaskTemplate) -> Bool {
        //build the sql statemnt
        var SQLStatement: String = String()
        var SQLParameterNames: String = String()
        var SQLParameterValues: [NSObject] = [NSObject]()
        
        SQLParameterNames = "[CreatedBy]=?, [CreatedOn]=?"
        SQLParameterValues.append(taskTemplate.CreatedBy as NSObject)
        SQLParameterValues.append(taskTemplate.CreatedOn as NSObject)
        
        if taskTemplate.LastUpdatedBy != nil {
            SQLParameterNames += ", [LastUpdatedBy]=?"
            SQLParameterValues.append(taskTemplate.LastUpdatedBy! as NSObject)
        }
        
        if taskTemplate.LastUpdatedOn != nil {
            SQLParameterNames += ", [LastUpdatedOn]=?"
            SQLParameterValues.append(taskTemplate.LastUpdatedOn! as NSObject)
        }
        
        if taskTemplate.Deleted != nil {
            SQLParameterNames += ", [Deleted]=?"
            SQLParameterValues.append(taskTemplate.Deleted! as NSObject)
        }
        
        SQLParameterNames += ", [OrganisationId]=?"
        SQLParameterValues.append(taskTemplate.OrganisationId as NSObject)
        SQLParameterNames += ", [AssetType]=?"
        SQLParameterValues.append(taskTemplate.AssetType as NSObject)
        SQLParameterNames += ", [TaskName]=?"
        SQLParameterValues.append(taskTemplate.TaskName as NSObject)
        SQLParameterNames += ", [Priority]=?"
        SQLParameterValues.append(taskTemplate.Priority as NSObject)
        SQLParameterNames += ", [EstimatedDuration]=?"
        SQLParameterValues.append(taskTemplate.EstimatedDuration as NSObject)
        SQLParameterNames += ", [CanCreateFromDevice]=?"
        SQLParameterValues.append(taskTemplate.CanCreateFromDevice as NSObject)
        
        SQLParameterValues.append(taskTemplate.RowId as NSObject)
        
        SQLStatement = "UPDATE [TaskTemplate] SET " + SQLParameterNames + "WHERE [RowId]=?"
        
        sharedModelManager.database!.open()
        let isUpdated = sharedModelManager.database!.executeUpdate(SQLStatement, withArgumentsIn: SQLParameterValues)
        sharedModelManager.database!.close()
        return isUpdated
    }
    
    func deleteTaskTemplate(_ taskTemplate: TaskTemplate) -> Bool {
        sharedModelManager.database!.open()
        let isDeleted = sharedModelManager.database!.executeUpdate("DELETE FROM [TaskTemplate] WHERE [RowId]=?", withArgumentsIn: [taskTemplate.RowId])
        sharedModelManager.database!.close()
        return isDeleted
    }
    
    func getTaskTemplate(_ taskTemplateId: String) -> TaskTemplate? {
        sharedModelManager.database!.open()
        var taskTemplate: TaskTemplate? = nil
        
        let resultSet = sharedModelManager.database!.executeQuery("SELECT [RowId], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [Deleted], [OrganisationId], [AssetType], [TaskName], [Priority], [EstimatedDuration], [CanCreateFromDevice] FROM [TaskTemplate] WHERE [RowId]=?", withArgumentsIn: [taskTemplateId])
        if (resultSet != nil) {
            while (resultSet?.next())! {
                var resultTaskTemplate: TaskTemplate = TaskTemplate()
                resultTaskTemplate = TaskTemplate()
                resultTaskTemplate.RowId = (resultSet?.string(forColumn: "RowId"))!
                resultTaskTemplate.CreatedBy = (resultSet?.string(forColumn: "CreatedBy"))!
                resultTaskTemplate.CreatedOn = resultSet!.date(forColumn: "CreatedOn")!
                if !(resultSet?.columnIsNull("LastUpdatedBy"))!
                {
                    resultTaskTemplate.LastUpdatedBy = resultSet?.string(forColumn: "LastUpdatedBy")
                }
                if !(resultSet?.columnIsNull("LastUpdatedOn"))!
                {
                    resultTaskTemplate.LastUpdatedOn = resultSet?.date(forColumn: "LastUpdatedOn")
                }
                if !(resultSet?.columnIsNull("Deleted"))!
                {
                    resultTaskTemplate.Deleted = resultSet?.date(forColumn: "Deleted")
                }
                resultTaskTemplate.OrganisationId = (resultSet?.string(forColumn: "OrganisationId"))!
                resultTaskTemplate.AssetType = (resultSet?.string(forColumn: "AssetType"))!
                resultTaskTemplate.TaskName = (resultSet?.string(forColumn: "TaskName"))!
                resultTaskTemplate.Priority = Int((resultSet?.int(forColumn: "Priority"))!)
                resultTaskTemplate.EstimatedDuration = Int((resultSet?.int(forColumn: "EstimatedDuration"))!)
                resultTaskTemplate.CanCreateFromDevice = (resultSet?.bool(forColumn: "CanCreateFromDevice"))!
                
                taskTemplate = resultTaskTemplate
            }
        }
        sharedModelManager.database!.close()
        return taskTemplate
    }
    
    func getAllTaskTemplate() -> [TaskTemplate] {
        sharedModelManager.database!.open()
        let resultSet: FMResultSet! = sharedModelManager.database!.executeQuery("SELECT [RowId], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [Deleted], [OrganisationId], [AssetType], [TaskName], [Priority], [EstimatedDuration], [CanCreateFromDevice] FROM [TaskTemplate]", withArgumentsIn: [])
        var taskTemplateList: [TaskTemplate] = [TaskTemplate]()
        if (resultSet != nil) {
            while resultSet.next() {
                let taskTemplate : TaskTemplate = TaskTemplate()
                taskTemplate.RowId = resultSet.string(forColumn: "RowId")!
                taskTemplate.CreatedBy = resultSet.string(forColumn: "CreatedBy")!
                taskTemplate.CreatedOn = resultSet.date(forColumn: "CreatedOn")!
                if !resultSet.columnIsNull("LastUpdatedBy")
                {
                    taskTemplate.LastUpdatedBy = resultSet.string(forColumn: "LastUpdatedBy")
                }
                if !resultSet.columnIsNull("LastUpdatedOn")
                {
                    taskTemplate.LastUpdatedOn = resultSet.date(forColumn: "LastUpdatedOn")
                }
                if !resultSet.columnIsNull("Deleted")
                {
                    taskTemplate.Deleted = resultSet.date(forColumn: "Deleted")
                }
                taskTemplate.OrganisationId = resultSet.string(forColumn: "OrganisationId")!
                taskTemplate.AssetType = resultSet.string(forColumn: "AssetType")!
                taskTemplate.TaskName = resultSet.string(forColumn: "TaskName")!
                taskTemplate.Priority = Int(resultSet.int(forColumn: "Priority"))
                taskTemplate.EstimatedDuration = Int(resultSet.int(forColumn: "EstimatedDuration"))
                if !resultSet.columnIsNull("CanCreateFromDevice")
                {
                    taskTemplate.CanCreateFromDevice = resultSet.bool(forColumn: "CanCreateFromDevice")
                }
                
                taskTemplateList.append(taskTemplate)
            }
        }
        sharedModelManager.database!.close()
        return taskTemplateList
    }
    
    func findTaskTemplateList(_ criteria: Dictionary<String, AnyObject>) -> [TaskTemplate] {
        var list: [TaskTemplate] = [TaskTemplate]()
        //var count: Int32 = 0
        (list, _) = findTaskTemplateList(criteria, pageSize: nil, pageNumber: nil)
        return list
    }
    
    func findTaskTemplateList(_ criteria: Dictionary<String, AnyObject>, pageSize: Int32?, pageNumber: Int32?) -> (List: [TaskTemplate], Count: Int32) {
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
        let countSet: FMResultSet! = sharedModelManager.database!.executeQuery("SELECT COUNT([RowId]) FROM [TaskTemplate] " + whereClause + orderByClause, withArgumentsIn: whereValues)
        if (countSet != nil) {
            while countSet.next() {
                count = countSet.int(forColumnIndex: 0)
            }
        }
        
        if (count > 0)
        {
            var pageClause: String = String()
            if (pageSize != nil && pageNumber != nil)
            {
                pageClause = " LIMIT " + String(pageSize!) + " OFFSET " + String((pageNumber! - 1) * pageSize!)
            }
            
            let resultSet: FMResultSet! = sharedModelManager.database!.executeQuery("SELECT [RowId], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [Deleted], [OrganisationId], [AssetType], [TaskName], [Priority], [EstimatedDuration], [CanCreateFromDevice] FROM [TaskTemplate] " + whereClause + orderByClause + pageClause, withArgumentsIn: whereValues)
            if (resultSet != nil) {
                while resultSet.next() {
                    let taskTemplate : TaskTemplate = TaskTemplate()
                    taskTemplate.RowId = resultSet.string(forColumn: "RowId")!
                    taskTemplate.CreatedBy = resultSet.string(forColumn: "CreatedBy")!
                    taskTemplate.CreatedOn = resultSet.date(forColumn: "CreatedOn")!
                    if !resultSet.columnIsNull("LastUpdatedBy")
                    {
                        taskTemplate.LastUpdatedBy = resultSet.string(forColumn: "LastUpdatedBy")
                    }
                    if !resultSet.columnIsNull("LastUpdatedOn")
                    {
                        taskTemplate.LastUpdatedOn = resultSet.date(forColumn: "LastUpdatedOn")
                    }
                    if !resultSet.columnIsNull("Deleted")
                    {
                        taskTemplate.Deleted = resultSet.date(forColumn: "Deleted")
                    }
                    taskTemplate.OrganisationId = resultSet.string(forColumn: "OrganisationId")!
                    taskTemplate.AssetType = resultSet.string(forColumn: "AssetType")!
                    taskTemplate.TaskName = resultSet.string(forColumn: "TaskName")!
                    taskTemplate.Priority = Int(resultSet.int(forColumn: "Priority"))
                    taskTemplate.EstimatedDuration = Int(resultSet.int(forColumn: "EstimatedDuration"))
                    if !resultSet.columnIsNull("CanCreateFromDevice")
                    {
                        taskTemplate.CanCreateFromDevice = resultSet.bool(forColumn: "CanCreateFromDevice")
                    }
                    
                    taskTemplateList.append(taskTemplate)
                }
            }
        }
        
        sharedModelManager.database!.close()
        return (taskTemplateList, count)
    }
    
    // MARK: - TaskTemplateParameter
    
    func addTaskTemplateParameter(_ taskTemplateParameter: TaskTemplateParameter) -> Bool {
        //build the sql statemnt
        var SQLStatement: String = String()
        var SQLParameterNames: String = String()
        var SQLParameterPlaceholders: String = String()
        var SQLParameterValues: [NSObject] = [NSObject]()
        
        SQLParameterNames = "[RowId], [CreatedBy], [CreatedOn]"
        SQLParameterPlaceholders = "?, ?, ?"
        SQLParameterValues.append(taskTemplateParameter.RowId as NSObject)
        SQLParameterValues.append(taskTemplateParameter.CreatedBy as NSObject)
        SQLParameterValues.append(taskTemplateParameter.CreatedOn as NSObject)
        
        if taskTemplateParameter.LastUpdatedBy != nil {
            SQLParameterNames += ", [LastUpdatedBy]"
            SQLParameterPlaceholders += ", ?"
            SQLParameterValues.append(taskTemplateParameter.LastUpdatedBy! as NSObject)
        }
        
        if taskTemplateParameter.LastUpdatedOn != nil {
            SQLParameterNames += ", [LastUpdatedOn]"
            SQLParameterPlaceholders += ", ?"
            SQLParameterValues.append(taskTemplateParameter.LastUpdatedOn! as NSObject)
        }
        
        if taskTemplateParameter.Deleted != nil {
            SQLParameterNames += ", [Deleted]"
            SQLParameterPlaceholders += ", ?"
            SQLParameterValues.append(taskTemplateParameter.Deleted! as NSObject)
        }
        
        SQLParameterNames += ", [TaskTemplateId]"
        SQLParameterPlaceholders += ", ?"
        SQLParameterValues.append(taskTemplateParameter.TaskTemplateId as NSObject)
        SQLParameterNames += ", [ParameterName]"
        SQLParameterPlaceholders += ", ?"
        SQLParameterValues.append(taskTemplateParameter.ParameterName as NSObject)
        SQLParameterNames += ", [ParameterType]"
        SQLParameterPlaceholders += ", ?"
        SQLParameterValues.append(taskTemplateParameter.ParameterType as NSObject)
        SQLParameterNames += ", [ParameterDisplay]"
        SQLParameterPlaceholders += ", ?"
        SQLParameterValues.append(taskTemplateParameter.ParameterDisplay as NSObject)
        SQLParameterNames += ", [Collect]"
        SQLParameterPlaceholders += ", ?"
        SQLParameterValues.append(taskTemplateParameter.Collect as NSObject)
        
        if taskTemplateParameter.ReferenceDataType != nil {
            SQLParameterNames += ", [ReferenceDataType]"
            SQLParameterPlaceholders += ", ?"
            SQLParameterValues.append(taskTemplateParameter.ReferenceDataType! as NSObject)
        }
        if taskTemplateParameter.ReferenceDataExtendedType != nil {
            SQLParameterNames += ", [ReferenceDataExtendedType]"
            SQLParameterPlaceholders += ", ?"
            SQLParameterValues.append(taskTemplateParameter.ReferenceDataExtendedType! as NSObject)
        }
        SQLParameterNames += ", [Ordinal]"
        SQLParameterPlaceholders += ", ?"
        SQLParameterValues.append(taskTemplateParameter.Ordinal as NSObject)
        
        if taskTemplateParameter.Predecessor != nil {
            SQLParameterNames += ", [Predecessor]"
            SQLParameterPlaceholders += ", ?"
            SQLParameterValues.append(taskTemplateParameter.Predecessor! as NSObject)
        }
        if taskTemplateParameter.PredecessorTrueValue != nil {
            SQLParameterNames += ", [PredecessorTrueValue]"
            SQLParameterPlaceholders += ", ?"
            SQLParameterValues.append(taskTemplateParameter.PredecessorTrueValue! as NSObject)
        }
        
        
        
        SQLStatement = "INSERT INTO [TaskTemplateParameter] (" + SQLParameterNames + ") VALUES (" + SQLParameterPlaceholders + ")"
        
        sharedModelManager.database!.open()
        let isInserted = sharedModelManager.database!.executeUpdate(SQLStatement, withArgumentsIn: SQLParameterValues)
        sharedModelManager.database!.close()
        return isInserted
    }
    
    func updateTaskTemplateParameter(_ taskTemplateParameter: TaskTemplateParameter) -> Bool {
        //build the sql statemnt
        var SQLStatement: String = String()
        var SQLParameterNames: String = String()
        var SQLParameterValues: [NSObject] = [NSObject]()
        
        SQLParameterNames = "[CreatedBy]=?, [CreatedOn]=?"
        SQLParameterValues.append(taskTemplateParameter.CreatedBy as NSObject)
        SQLParameterValues.append(taskTemplateParameter.CreatedOn as NSObject)
        
        if taskTemplateParameter.LastUpdatedBy != nil {
            SQLParameterNames += ", [LastUpdatedBy]=?"
            SQLParameterValues.append(taskTemplateParameter.LastUpdatedBy! as NSObject)
        }
        
        if taskTemplateParameter.LastUpdatedOn != nil {
            SQLParameterNames += ", [LastUpdatedOn]=?"
            SQLParameterValues.append(taskTemplateParameter.LastUpdatedOn! as NSObject)
        }
        
        if taskTemplateParameter.Deleted != nil {
            SQLParameterNames += ", [Deleted]=?"
            SQLParameterValues.append(taskTemplateParameter.Deleted! as NSObject)
        }
        
        SQLParameterNames += ", [TaskTemplateId]=?"
        SQLParameterValues.append(taskTemplateParameter.TaskTemplateId as NSObject)
        SQLParameterNames += ", [ParameterName]=?"
        SQLParameterValues.append(taskTemplateParameter.ParameterName as NSObject)
        SQLParameterNames += ", [ParameterType]=?"
        SQLParameterValues.append(taskTemplateParameter.ParameterType as NSObject)
        SQLParameterNames += ", [ParameterDisplay]=?"
        SQLParameterValues.append(taskTemplateParameter.ParameterDisplay as NSObject)
        SQLParameterNames += ", [Collect]=?"
        SQLParameterValues.append(taskTemplateParameter.Collect as NSObject)
        if taskTemplateParameter.ReferenceDataType != nil {
            SQLParameterNames += ", [ReferenceDataType]=?"
            SQLParameterValues.append(taskTemplateParameter.ReferenceDataType! as NSObject)
        }
        if taskTemplateParameter.ReferenceDataExtendedType != nil {
            SQLParameterNames += ", [ReferenceDataExtendedType]=?"
            SQLParameterValues.append(taskTemplateParameter.ReferenceDataExtendedType! as NSObject)
        }
        SQLParameterNames += ", [Ordinal]=?"
        SQLParameterValues.append(taskTemplateParameter.Ordinal as NSObject)
        
        if taskTemplateParameter.Predecessor != nil {
            SQLParameterNames += ", [Predecessor]=?"
            SQLParameterValues.append(taskTemplateParameter.Predecessor! as NSObject)
        }
        if taskTemplateParameter.PredecessorTrueValue != nil {
            SQLParameterNames += ", [PredecessorTrueValue]=?"
            SQLParameterValues.append(taskTemplateParameter.PredecessorTrueValue! as NSObject)
        }
        
        SQLParameterValues.append(taskTemplateParameter.RowId as NSObject)
        
        SQLStatement = "UPDATE [TaskTemplateParameter] SET " + SQLParameterNames + "WHERE [RowId]=?"
        
        sharedModelManager.database!.open()
        let isUpdated = sharedModelManager.database!.executeUpdate(SQLStatement, withArgumentsIn: SQLParameterValues)
        sharedModelManager.database!.close()
        return isUpdated
    }
    
    func deleteTaskTemplateParameter(_ taskTemplateParameter: TaskTemplateParameter) -> Bool {
        sharedModelManager.database!.open()
        let isDeleted = sharedModelManager.database!.executeUpdate("DELETE FROM [TaskTemplateParameter] WHERE [RowId]=?", withArgumentsIn: [taskTemplateParameter.RowId])
        sharedModelManager.database!.close()
        return isDeleted
    }
    
    func getTaskTemplateParameter(_ taskTemplateParameterId: String) -> TaskTemplateParameter? {
        sharedModelManager.database!.open()
        var taskTemplateParameter: TaskTemplateParameter? = nil
        
        let resultSet = sharedModelManager.database!.executeQuery("SELECT [RowId], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [Deleted], [TaskTemplateId], [ParameterName], [ParameterType], [ParameterDisplay], [Collect], [ReferenceDataType], [ReferenceDataExtendedType], [Ordinal], [Predecessor], [PredecessorTrueValue] FROM [TaskTemplateParameter] WHERE [RowId]=?", withArgumentsIn: [taskTemplateParameterId])
        if (resultSet != nil) {
            while (resultSet?.next())! {
                var resultTaskTemplateParameter: TaskTemplateParameter = TaskTemplateParameter()
                resultTaskTemplateParameter = TaskTemplateParameter()
                resultTaskTemplateParameter.RowId = (resultSet?.string(forColumn: "RowId"))!
                resultTaskTemplateParameter.CreatedBy = (resultSet?.string(forColumn: "CreatedBy"))!
                resultTaskTemplateParameter.CreatedOn = resultSet!.date(forColumn: "CreatedOn")!
                if !(resultSet?.columnIsNull("LastUpdatedBy"))!
                {
                    resultTaskTemplateParameter.LastUpdatedBy = resultSet?.string(forColumn: "LastUpdatedBy")
                }
                if !(resultSet?.columnIsNull("LastUpdatedOn"))!
                {
                    resultTaskTemplateParameter.LastUpdatedOn = resultSet?.date(forColumn: "LastUpdatedOn")
                }
                if !(resultSet?.columnIsNull("Deleted"))!
                {
                    resultTaskTemplateParameter.Deleted = resultSet?.date(forColumn: "Deleted")
                }
                resultTaskTemplateParameter.TaskTemplateId = (resultSet?.string(forColumn: "TaskTemplateId"))!
                resultTaskTemplateParameter.ParameterName = (resultSet?.string(forColumn: "ParameterName"))!
                resultTaskTemplateParameter.ParameterType = (resultSet?.string(forColumn: "ParameterType"))!
                resultTaskTemplateParameter.ParameterDisplay = (resultSet?.string(forColumn: "ParameterDisplay"))!
                resultTaskTemplateParameter.Collect = (resultSet?.bool(forColumn: "Collect"))!
                if !(resultSet?.columnIsNull("ReferenceDataType"))! {
                    resultTaskTemplateParameter.ReferenceDataType = resultSet?.string(forColumn: "ReferenceDataType")
                }
                if !(resultSet?.columnIsNull("ReferenceDataExtendedType"))! {
                    resultTaskTemplateParameter.ReferenceDataExtendedType = resultSet?.string(forColumn: "ReferenceDataExtendedType")
                }
                resultTaskTemplateParameter.Ordinal = Int((resultSet?.int(forColumn: "Ordinal"))!)
                if !(resultSet?.columnIsNull("Predecessor"))! {
                    resultTaskTemplateParameter.Predecessor = resultSet?.string(forColumn: "Predecessor")
                }
                if !(resultSet?.columnIsNull("PredecessorTrueValue"))! {
                    resultTaskTemplateParameter.PredecessorTrueValue = resultSet?.string(forColumn: "PredecessorTrueValue")
                }
                taskTemplateParameter = resultTaskTemplateParameter
            }
        }
        sharedModelManager.database!.close()
        return taskTemplateParameter
    }
    
    func getAllTaskTemplateParameter() -> [TaskTemplateParameter] {
        sharedModelManager.database!.open()
        let resultSet: FMResultSet! = sharedModelManager.database!.executeQuery("SELECT [RowId], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [Deleted], [TaskTemplateId], [ParameterName], [ParameterType], [ParameterDisplay], [Collect], [ReferenceDataType], [ReferenceDataExtendedType], [Ordinal], [Predecessor], [PredecessorTrueValue] FROM [TaskTemplateParameter]", withArgumentsIn: [])
        var taskTemplateParameterList: [TaskTemplateParameter] = [TaskTemplateParameter]()
        if (resultSet != nil) {
            while resultSet.next() {
                let taskTemplateParameter : TaskTemplateParameter = TaskTemplateParameter()
                taskTemplateParameter.RowId = resultSet.string(forColumn: "RowId")!
                taskTemplateParameter.CreatedBy = resultSet.string(forColumn: "CreatedBy")!
                taskTemplateParameter.CreatedOn = resultSet.date(forColumn: "CreatedOn")!
                if !resultSet.columnIsNull("LastUpdatedBy")
                {
                    taskTemplateParameter.LastUpdatedBy = resultSet.string(forColumn: "LastUpdatedBy")
                }
                if !resultSet.columnIsNull("LastUpdatedOn")
                {
                    taskTemplateParameter.LastUpdatedOn = resultSet.date(forColumn: "LastUpdatedOn")
                }
                if !resultSet.columnIsNull("Deleted")
                {
                    taskTemplateParameter.Deleted = resultSet.date(forColumn: "Deleted")
                }
                taskTemplateParameter.TaskTemplateId = resultSet.string(forColumn: "TaskTemplateId")!
                taskTemplateParameter.ParameterName = resultSet.string(forColumn: "ParameterName")!
                taskTemplateParameter.ParameterType = resultSet.string(forColumn: "ParameterType")!
                taskTemplateParameter.ParameterDisplay = resultSet.string(forColumn: "ParameterDisplay")!
                taskTemplateParameter.Collect = resultSet.bool(forColumn: "Collect")
                if !resultSet.columnIsNull("ReferenceDataType") {
                    taskTemplateParameter.ReferenceDataType = resultSet.string(forColumn: "ReferenceDataType")
                }
                if !resultSet.columnIsNull("ReferenceDataExtendedType") {
                    taskTemplateParameter.ReferenceDataExtendedType = resultSet.string(forColumn: "ReferenceDataExtendedType")
                }
                taskTemplateParameter.Ordinal = Int(resultSet.int(forColumn: "Ordinal"))
                if !resultSet.columnIsNull("Predecessor") {
                    taskTemplateParameter.Predecessor = resultSet.string(forColumn: "Predecessor")
                }
                if !resultSet.columnIsNull("PredecessorTrueValue") {
                    taskTemplateParameter.PredecessorTrueValue = resultSet.string(forColumn: "PredecessorTrueValue")
                }
                taskTemplateParameterList.append(taskTemplateParameter)
            }
        }
        sharedModelManager.database!.close()
        return taskTemplateParameterList
    }
    
    func findTaskTemplateParameterList(_ criteria: Dictionary<String, AnyObject>) -> [TaskTemplateParameter] {
        var list: [TaskTemplateParameter] = [TaskTemplateParameter]()
        //var count: Int32 = 0
        (list, _) = findTaskTemplateParameterList(criteria, pageSize: nil, pageNumber: nil)
        return list
    }
    
    func findTaskTemplateParameterList(_ criteria: Dictionary<String, AnyObject>, pageSize: Int32?, pageNumber: Int32?) -> (List: [TaskTemplateParameter], Count: Int32) {
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
        let countSet: FMResultSet! = sharedModelManager.database!.executeQuery("SELECT COUNT([RowId]) FROM [TaskTemplateParameter] " + whereClause + orderByClause, withArgumentsIn: whereValues)
        if (countSet != nil) {
            while countSet.next() {
                count = countSet.int(forColumnIndex: 0)
            }
        }
        
        if (count > 0)
        {
            var pageClause: String = String()
            if (pageSize != nil && pageNumber != nil)
            {
                pageClause = " LIMIT " + String(pageSize!) + " OFFSET " + String((pageNumber! - 1) * pageSize!)
            }
            
            let resultSet: FMResultSet! = sharedModelManager.database!.executeQuery("SELECT [RowId], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [Deleted], [TaskTemplateId], [ParameterName], [ParameterType], [ParameterDisplay], [Collect], [ReferenceDataType], [ReferenceDataExtendedType], [Ordinal], [Predecessor], [PredecessorTrueValue] FROM [TaskTemplateParameter] " + whereClause + orderByClause + pageClause, withArgumentsIn: whereValues)
            if (resultSet != nil) {
                while resultSet.next() {
                    let taskTemplateParameter : TaskTemplateParameter = TaskTemplateParameter()
                    taskTemplateParameter.RowId = resultSet.string(forColumn: "RowId")!
                    taskTemplateParameter.CreatedBy = resultSet.string(forColumn: "CreatedBy")!
                    taskTemplateParameter.CreatedOn = resultSet.date(forColumn: "CreatedOn")!
                    if !resultSet.columnIsNull("LastUpdatedBy")
                    {
                        taskTemplateParameter.LastUpdatedBy = resultSet.string(forColumn: "LastUpdatedBy")
                    }
                    if !resultSet.columnIsNull("LastUpdatedOn")
                    {
                        taskTemplateParameter.LastUpdatedOn = resultSet.date(forColumn: "LastUpdatedOn")
                    }
                    if !resultSet.columnIsNull("Deleted")
                    {
                        taskTemplateParameter.Deleted = resultSet.date(forColumn: "Deleted")
                    }
                    taskTemplateParameter.TaskTemplateId = resultSet.string(forColumn: "TaskTemplateId")!
                    taskTemplateParameter.ParameterName = resultSet.string(forColumn: "ParameterName")!
                    taskTemplateParameter.ParameterType = resultSet.string(forColumn: "ParameterType")!
                    taskTemplateParameter.ParameterDisplay = resultSet.string(forColumn: "ParameterDisplay")!
                    taskTemplateParameter.Collect = resultSet.bool(forColumn: "Collect")
                    if !resultSet.columnIsNull("ReferenceDataType") {
                        taskTemplateParameter.ReferenceDataType = resultSet.string(forColumn: "ReferenceDataType")
                    }
                    if !resultSet.columnIsNull("ReferenceDataExtendedType") {
                        taskTemplateParameter.ReferenceDataExtendedType = resultSet.string(forColumn: "ReferenceDataExtendedType")
                    }
                    taskTemplateParameter.Ordinal = Int(resultSet.int(forColumn: "Ordinal"))
                    
                    if !resultSet.columnIsNull("Predecessor") {
                        taskTemplateParameter.Predecessor = resultSet.string(forColumn: "Predecessor")
                    }
                    if !resultSet.columnIsNull("PredecessorTrueValue") {
                        taskTemplateParameter.PredecessorTrueValue = resultSet.string(forColumn: "PredecessorTrueValue")
                    }
                    
                    taskTemplateParameterList.append(taskTemplateParameter)
                }
            }
        }
        
        sharedModelManager.database!.close()
        return (taskTemplateParameterList, count)
    }
    
    // MARK: - Test Suite
    
    func addTestSuite(_ testSuite: TestSuite) -> Bool {
        //build the sql statemnt
        var SQLStatement: String = String()
        var SQLParameterNames: String = String()
        var SQLParameterPlaceholders: String = String()
        var SQLParameterValues: [NSObject] = [NSObject]()
        
        SQLParameterNames = "[RowId], [CreatedBy], [CreatedOn]"
        SQLParameterPlaceholders = "?, ?, ?"
        SQLParameterValues.append(testSuite.RowId as NSObject)
        SQLParameterValues.append(testSuite.CreatedBy as NSObject)
        SQLParameterValues.append(testSuite.CreatedOn as NSObject)
        
        if testSuite.LastUpdatedBy != nil {
            SQLParameterNames += ", [LastUpdatedBy]"
            SQLParameterPlaceholders += ", ?"
            SQLParameterValues.append(testSuite.LastUpdatedBy! as NSObject)
        }
        
        if testSuite.LastUpdatedOn != nil {
            SQLParameterNames += ", [LastUpdatedOn]"
            SQLParameterPlaceholders += ", ?"
            SQLParameterValues.append(testSuite.LastUpdatedOn! as NSObject)
        }
        
        if testSuite.Deleted != nil {
            SQLParameterNames += ", [Deleted]"
            SQLParameterPlaceholders += ", ?"
            SQLParameterValues.append(testSuite.Deleted! as NSObject)
        }
        SQLParameterNames += ", [OrganisationId]"
        SQLParameterPlaceholders += ", ?"
        SQLParameterValues.append(testSuite.OrganisationId as NSObject)
        SQLParameterNames += ", [Name]"
        SQLParameterPlaceholders += ", ?"
        SQLParameterValues.append(testSuite.Name as NSObject)
        SQLParameterNames += ", [Description]"
        SQLParameterPlaceholders += ", ?"
        SQLParameterValues.append(testSuite.Description as NSObject)
        SQLParameterNames += ", [TestSuiteType]"
        SQLParameterPlaceholders += ", ?"
        SQLParameterValues.append(testSuite.TestSuiteType as NSObject)
        if testSuite.FlushType != nil {
            SQLParameterNames += ", [FlushType]"
            SQLParameterPlaceholders += ", ?"
            SQLParameterValues.append(testSuite.FlushType! as NSObject)
        }
        
        SQLStatement = "INSERT INTO [TestSuite] (" + SQLParameterNames + ") VALUES (" + SQLParameterPlaceholders + ")"
        
        sharedModelManager.database!.open()
        let isInserted = sharedModelManager.database!.executeUpdate(SQLStatement, withArgumentsIn: SQLParameterValues)
        sharedModelManager.database!.close()
        return isInserted
    }
    
    func updateTestSuite(_ testSuite: TestSuite) -> Bool {
        //build the sql statemnt
        var SQLStatement: String = String()
        var SQLParameterNames: String = String()
        var SQLParameterValues: [NSObject] = [NSObject]()
        
        SQLParameterNames = "[CreatedBy]=?, [CreatedOn]=?"
        SQLParameterValues.append(testSuite.CreatedBy as NSObject)
        SQLParameterValues.append(testSuite.CreatedOn as NSObject)
        
        if testSuite.LastUpdatedBy != nil {
            SQLParameterNames += ", [LastUpdatedBy]=?"
            SQLParameterValues.append(testSuite.LastUpdatedBy! as NSObject)
        }
        
        if testSuite.LastUpdatedOn != nil {
            SQLParameterNames += ", [LastUpdatedOn]=?"
            SQLParameterValues.append(testSuite.LastUpdatedOn! as NSObject)
        }
        
        if testSuite.Deleted != nil {
            SQLParameterNames += ", [Deleted]=?"
            SQLParameterValues.append(testSuite.Deleted! as NSObject)
        }
        
        SQLParameterNames += ", [OrganisationId]=?"
        SQLParameterValues.append(testSuite.OrganisationId as NSObject)
        SQLParameterNames += ", [Name]=?"
        SQLParameterValues.append(testSuite.Name as NSObject)
        SQLParameterNames += ", [Description]=?"
        SQLParameterValues.append(testSuite.Description as NSObject)
        SQLParameterNames += ", [TestSuiteType]=?"
        SQLParameterValues.append(testSuite.TestSuiteType as NSObject)
        if testSuite.FlushType != nil {
            SQLParameterNames += ", [FlushType]=?"
            SQLParameterValues.append(testSuite.FlushType! as NSObject)
        }
        
        SQLParameterValues.append(testSuite.RowId as NSObject)
        
        SQLStatement = "UPDATE [TestSuite] SET " + SQLParameterNames + "WHERE [RowId]=?"
        
        sharedModelManager.database!.open()
        let isUpdated = sharedModelManager.database!.executeUpdate(SQLStatement, withArgumentsIn: SQLParameterValues)
        sharedModelManager.database!.close()
        return isUpdated
    }
    
    func deleteTestSuite(_ testSuite: TestSuite) -> Bool {
        sharedModelManager.database!.open()
        let isDeleted = sharedModelManager.database!.executeUpdate("DELETE FROM [TestSuite] WHERE [RowId]=?", withArgumentsIn: [testSuite.RowId])
        sharedModelManager.database!.close()
        return isDeleted
    }
    
    func getTestSuite(_ testSuiteId: String) -> TestSuite? {
        sharedModelManager.database!.open()
        var testSuite: TestSuite? = nil
        
        let resultSet = sharedModelManager.database!.executeQuery("SELECT [RowId], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [Deleted], [OrganisationId], [Name], [Description], [TestSuiteType], [FlushType] FROM [TestSuite] WHERE [RowId]=?", withArgumentsIn: [testSuiteId])
        if (resultSet != nil) {
            while (resultSet?.next())! {
                var resultTestSuite: TestSuite = TestSuite()
                resultTestSuite = TestSuite()
                resultTestSuite.RowId = (resultSet?.string(forColumn: "RowId"))!
                resultTestSuite.CreatedBy = (resultSet?.string(forColumn: "CreatedBy"))!
                resultTestSuite.CreatedOn = resultSet!.date(forColumn: "CreatedOn")!
                if !(resultSet?.columnIsNull("LastUpdatedBy"))!
                {
                    resultTestSuite.LastUpdatedBy = resultSet?.string(forColumn: "LastUpdatedBy")
                }
                if !(resultSet?.columnIsNull("LastUpdatedOn"))!
                {
                    resultTestSuite.LastUpdatedOn = resultSet?.date(forColumn: "LastUpdatedOn")
                }
                if !(resultSet?.columnIsNull("Deleted"))!
                {
                    resultTestSuite.Deleted = resultSet?.date(forColumn: "Deleted")
                }
                resultTestSuite.OrganisationId = (resultSet?.string(forColumn: "OrganisationId"))!
                resultTestSuite.Name = (resultSet?.string(forColumn: "Name"))!
                resultTestSuite.Description = (resultSet?.string(forColumn: "Description"))!
                resultTestSuite.TestSuiteType = (resultSet?.string(forColumn: "TestSuiteType"))!
                if !(resultSet?.columnIsNull("FlushType"))! {
                    resultTestSuite.FlushType = resultSet?.string(forColumn: "FlushType")
                }
                testSuite = resultTestSuite
            }
        }
        sharedModelManager.database!.close()
        return testSuite
    }
    
    func getAllTestSuite() -> [TestSuite] {
        sharedModelManager.database!.open()
        let resultSet: FMResultSet! = sharedModelManager.database!.executeQuery("SELECT [RowId], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [Deleted], [OrganisationId], [Name], [Description], [TestSuiteType], [FlushType] FROM [TestSuite]", withArgumentsIn: [])
        var testSuiteList: [TestSuite] = [TestSuite]()
        if (resultSet != nil) {
            while resultSet.next() {
                let testSuite : TestSuite = TestSuite()
                testSuite.RowId = resultSet.string(forColumn: "RowId")!
                testSuite.CreatedBy = resultSet.string(forColumn: "CreatedBy")!
                testSuite.CreatedOn = resultSet.date(forColumn: "CreatedOn")!
                if !resultSet.columnIsNull("LastUpdatedBy")
                {
                    testSuite.LastUpdatedBy = resultSet.string(forColumn: "LastUpdatedBy")
                }
                if !resultSet.columnIsNull("LastUpdatedOn")
                {
                    testSuite.LastUpdatedOn = resultSet.date(forColumn: "LastUpdatedOn")
                }
                if !resultSet.columnIsNull("Deleted")
                {
                    testSuite.Deleted = resultSet.date(forColumn: "Deleted")
                }
                testSuite.OrganisationId = (resultSet?.string(forColumn: "OrganisationId"))!
                testSuite.Name = (resultSet?.string(forColumn: "Name"))!
                testSuite.Description = (resultSet?.string(forColumn: "Description"))!
                testSuite.TestSuiteType = (resultSet?.string(forColumn: "TestSuiteType"))!
                if !(resultSet?.columnIsNull("FlushType"))! {
                    testSuite.FlushType = resultSet?.string(forColumn: "FlushType")
                }
               testSuiteList.append(testSuite)
            }
        }
        sharedModelManager.database!.close()
        return testSuiteList
    }
    
    func findTestSuiteList(_ criteria: Dictionary<String, AnyObject>) -> [TestSuite] {
        var list: [TestSuite] = [TestSuite]()
        //var count: Int32 = 0
        (list, _) = findTestSuiteList(criteria, pageSize: nil, pageNumber: nil)
        return list
    }
    
    func findTestSuiteList(_ criteria: Dictionary<String, AnyObject>, pageSize: Int32?, pageNumber: Int32?) -> (List: [TestSuite], Count: Int32) {
        
        //return variables
        var count: Int32 = 0
        var testSuiteList: [TestSuite] = [TestSuite]()
        
        //build the where clause
        var whereClause: String = String()
        var whereValues: [AnyObject] = [AnyObject]()
        
        (whereClause, whereValues) = buildWhereClause(criteria)
        
        if (whereClause != "")
        {
            whereClause = "WHERE " + whereClause
        }
        
        sharedModelManager.database!.open()
        let countSet: FMResultSet! = sharedModelManager.database!.executeQuery("SELECT COUNT([RowId]) FROM [TestSuite] " + whereClause, withArgumentsIn: whereValues)
        if (countSet != nil) {
            while countSet.next() {
                count = countSet.int(forColumnIndex: 0)
            }
        }
        
        if (count > 0)
        {
            var pageClause: String = String()
            if (pageSize != nil && pageNumber != nil)
            {
                pageClause = " LIMIT " + String(pageSize!) + " OFFSET " + String((pageNumber! - 1) * pageSize!)
            }
            
            let resultSet: FMResultSet! = sharedModelManager.database!.executeQuery("SELECT [RowId], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [Deleted], [OrganisationId], [Name], [Description], [TestSuiteType], [FlushType] FROM [TestSuite] " + whereClause + pageClause, withArgumentsIn: whereValues)
            if (resultSet != nil) {
                while resultSet.next() {
                    let testSuite : TestSuite = TestSuite()
                    testSuite.RowId = resultSet.string(forColumn: "RowId")!
                    testSuite.CreatedBy = resultSet.string(forColumn: "CreatedBy")!
                    testSuite.CreatedOn = resultSet.date(forColumn: "CreatedOn")!
                    if !resultSet.columnIsNull("LastUpdatedBy")
                    {
                        testSuite.LastUpdatedBy = resultSet.string(forColumn: "LastUpdatedBy")
                    }
                    if !resultSet.columnIsNull("LastUpdatedOn")
                    {
                        testSuite.LastUpdatedOn = resultSet.date(forColumn: "LastUpdatedOn")
                    }
                    if !resultSet.columnIsNull("Deleted")
                    {
                        testSuite.Deleted = resultSet.date(forColumn: "Deleted")
                    }
                    testSuite.OrganisationId = (resultSet?.string(forColumn: "OrganisationId"))!
                    testSuite.Name = (resultSet?.string(forColumn: "Name"))!
                    testSuite.Description = (resultSet?.string(forColumn: "Description"))!
                    testSuite.TestSuiteType = (resultSet?.string(forColumn: "TestSuiteType"))!
                    if !(resultSet?.columnIsNull("FlushType"))! {
                        testSuite.FlushType = resultSet?.string(forColumn: "FlushType")
                    }
                    
                    testSuiteList.append(testSuite)
                }
            }
        }
        
        sharedModelManager.database!.close()
        
        return (testSuiteList, count)
    }
    
    // MARK: - Test Suite Item
    
    func addTestSuiteItem(_ testSuiteItem: TestSuiteItem) -> Bool {
        //build the sql statemnt
        var SQLStatement: String = String()
        var SQLParameterNames: String = String()
        var SQLParameterPlaceholders: String = String()
        var SQLParameterValues: [NSObject] = [NSObject]()
        
        SQLParameterNames = "[RowId], [CreatedBy], [CreatedOn]"
        SQLParameterPlaceholders = "?, ?, ?"
        SQLParameterValues.append(testSuiteItem.RowId as NSObject)
        SQLParameterValues.append(testSuiteItem.CreatedBy as NSObject)
        SQLParameterValues.append(testSuiteItem.CreatedOn as NSObject)
        
        if testSuiteItem.LastUpdatedBy != nil {
            SQLParameterNames += ", [LastUpdatedBy]"
            SQLParameterPlaceholders += ", ?"
            SQLParameterValues.append(testSuiteItem.LastUpdatedBy! as NSObject)
        }
        
        if testSuiteItem.LastUpdatedOn != nil {
            SQLParameterNames += ", [LastUpdatedOn]"
            SQLParameterPlaceholders += ", ?"
            SQLParameterValues.append(testSuiteItem.LastUpdatedOn! as NSObject)
        }
        
        if testSuiteItem.Deleted != nil {
            SQLParameterNames += ", [Deleted]"
            SQLParameterPlaceholders += ", ?"
            SQLParameterValues.append(testSuiteItem.Deleted! as NSObject)
        }
        SQLParameterNames += ", [TestSuiteId]"
        SQLParameterPlaceholders += ", ?"
        SQLParameterValues.append(testSuiteItem.TestSuiteId as NSObject)
        SQLParameterNames += ", [Ordinal]"
        SQLParameterPlaceholders += ", ?"
        SQLParameterValues.append(testSuiteItem.Ordinal as NSObject)
        SQLParameterNames += ", [BacteriumType]"
        SQLParameterPlaceholders += ", ?"
        SQLParameterValues.append(testSuiteItem.BacteriumType as NSObject)
       
        SQLStatement = "INSERT INTO [TestSuiteItem] (" + SQLParameterNames + ") VALUES (" + SQLParameterPlaceholders + ")"
        
        sharedModelManager.database!.open()
        let isInserted = sharedModelManager.database!.executeUpdate(SQLStatement, withArgumentsIn: SQLParameterValues)
        sharedModelManager.database!.close()
        return isInserted
    }
    
    func updateTestSuiteItem(_ testSuiteItem: TestSuiteItem) -> Bool {
        //build the sql statemnt
        var SQLStatement: String = String()
        var SQLParameterNames: String = String()
        var SQLParameterValues: [NSObject] = [NSObject]()
        
        SQLParameterNames = "[CreatedBy]=?, [CreatedOn]=?"
        SQLParameterValues.append(testSuiteItem.CreatedBy as NSObject)
        SQLParameterValues.append(testSuiteItem.CreatedOn as NSObject)
        
        if testSuiteItem.LastUpdatedBy != nil {
            SQLParameterNames += ", [LastUpdatedBy]=?"
            SQLParameterValues.append(testSuiteItem.LastUpdatedBy! as NSObject)
        }
        
        if testSuiteItem.LastUpdatedOn != nil {
            SQLParameterNames += ", [LastUpdatedOn]=?"
            SQLParameterValues.append(testSuiteItem.LastUpdatedOn! as NSObject)
        }
        
        if testSuiteItem.Deleted != nil {
            SQLParameterNames += ", [Deleted]=?"
            SQLParameterValues.append(testSuiteItem.Deleted! as NSObject)
        }
        
        SQLParameterNames += ", [TestSuiteId]=?"
        SQLParameterValues.append(testSuiteItem.TestSuiteId as NSObject)
        SQLParameterNames += ", [Ordinal]=?"
        SQLParameterValues.append(testSuiteItem.Ordinal as NSObject)
        SQLParameterNames += ", [BacteriumType]=?"
        SQLParameterValues.append(testSuiteItem.BacteriumType as NSObject)
        
        SQLParameterValues.append(testSuiteItem.RowId as NSObject)
        
        SQLStatement = "UPDATE [TestSuiteItem] SET " + SQLParameterNames + "WHERE [RowId]=?"
        
        sharedModelManager.database!.open()
        let isUpdated = sharedModelManager.database!.executeUpdate(SQLStatement, withArgumentsIn: SQLParameterValues)
        sharedModelManager.database!.close()
        return isUpdated
    }
    
    func deleteTestSuiteItem(_ testSuiteItem: TestSuiteItem) -> Bool {
        sharedModelManager.database!.open()
        let isDeleted = sharedModelManager.database!.executeUpdate("DELETE FROM [TestSuiteItem] WHERE [RowId]=?", withArgumentsIn: [testSuiteItem.RowId])
        sharedModelManager.database!.close()
        return isDeleted
    }
    
    func getTestSuiteItem(_ testSuiteItemId: String) -> TestSuiteItem? {
        sharedModelManager.database!.open()
        var testSuiteItem: TestSuiteItem? = nil
        
        let resultSet = sharedModelManager.database!.executeQuery("SELECT [RowId], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [Deleted], [TestSuiteId], [Ordinal], [BacteriumType]  FROM [TestSuiteItem] WHERE [RowId]=?", withArgumentsIn: [testSuiteItemId])
        if (resultSet != nil) {
            while (resultSet?.next())! {
                var resultTestSuiteItem: TestSuiteItem = TestSuiteItem()
                resultTestSuiteItem = TestSuiteItem()
                resultTestSuiteItem.RowId = (resultSet?.string(forColumn: "RowId"))!
                resultTestSuiteItem.CreatedBy = (resultSet?.string(forColumn: "CreatedBy"))!
                resultTestSuiteItem.CreatedOn = resultSet!.date(forColumn: "CreatedOn")!
                if !(resultSet?.columnIsNull("LastUpdatedBy"))!
                {
                    resultTestSuiteItem.LastUpdatedBy = resultSet?.string(forColumn: "LastUpdatedBy")
                }
                if !(resultSet?.columnIsNull("LastUpdatedOn"))!
                {
                    resultTestSuiteItem.LastUpdatedOn = resultSet?.date(forColumn: "LastUpdatedOn")
                }
                if !(resultSet?.columnIsNull("Deleted"))!
                {
                    resultTestSuiteItem.Deleted = resultSet?.date(forColumn: "Deleted")
                }
                resultTestSuiteItem.TestSuiteId = (resultSet?.string(forColumn: "TestSuiteId"))!
                resultTestSuiteItem.Ordinal = Int((resultSet?.int(forColumn: "Ordinal"))!)
                resultTestSuiteItem.BacteriumType = (resultSet?.string(forColumn: "BacteriumType"))!
                testSuiteItem = resultTestSuiteItem
            }
        }
        sharedModelManager.database!.close()
        return testSuiteItem
    }
    
    func getAllTestSuiteItem() -> [TestSuiteItem] {
        sharedModelManager.database!.open()
        let resultSet: FMResultSet! = sharedModelManager.database!.executeQuery("SELECT [RowId], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [Deleted], [TestSuiteId], [Ordinal], [BacteriumType] FROM [TestSuiteItem]", withArgumentsIn: [])
        var testSuiteItemList: [TestSuiteItem] = [TestSuiteItem]()
        if (resultSet != nil) {
            while resultSet.next() {
                let testSuiteItem : TestSuiteItem = TestSuiteItem()
                testSuiteItem.RowId = resultSet.string(forColumn: "RowId")!
                testSuiteItem.CreatedBy = resultSet.string(forColumn: "CreatedBy")!
                testSuiteItem.CreatedOn = resultSet.date(forColumn: "CreatedOn")!
                if !resultSet.columnIsNull("LastUpdatedBy")
                {
                    testSuiteItem.LastUpdatedBy = resultSet.string(forColumn: "LastUpdatedBy")
                }
                if !resultSet.columnIsNull("LastUpdatedOn")
                {
                    testSuiteItem.LastUpdatedOn = resultSet.date(forColumn: "LastUpdatedOn")
                }
                if !resultSet.columnIsNull("Deleted")
                {
                    testSuiteItem.Deleted = resultSet.date(forColumn: "Deleted")
                }
                testSuiteItem.TestSuiteId = (resultSet?.string(forColumn: "TestSuiteId"))!
                testSuiteItem.Ordinal = Int((resultSet?.int(forColumn: "Ordinal"))!)
                testSuiteItem.BacteriumType = (resultSet?.string(forColumn: "BacteriumType"))!
               testSuiteItemList.append(testSuiteItem)
            }
        }
        sharedModelManager.database!.close()
        return testSuiteItemList
    }
    
    func findTestSuiteItemList(_ criteria: Dictionary<String, AnyObject>) -> [TestSuiteItem] {
        var list: [TestSuiteItem] = [TestSuiteItem]()
        //var count: Int32 = 0
        (list, _) = findTestSuiteItemList(criteria, pageSize: nil, pageNumber: nil)
        return list
    }
    
    func findTestSuiteItemList(_ criteria: Dictionary<String, AnyObject>, pageSize: Int32?, pageNumber: Int32?) -> (List: [TestSuiteItem], Count: Int32) {
        
        //return variables
        var count: Int32 = 0
        var testSuiteItemList: [TestSuiteItem] = [TestSuiteItem]()
        
        //build the where clause
        var whereClause: String = String()
        var whereValues: [AnyObject] = [AnyObject]()
        
        (whereClause, whereValues) = buildWhereClause(criteria)
        
        if (whereClause != "")
        {
            whereClause = "WHERE " + whereClause
        }
        
        sharedModelManager.database!.open()
        let countSet: FMResultSet! = sharedModelManager.database!.executeQuery("SELECT COUNT([RowId]) FROM [TestSuiteItem] " + whereClause, withArgumentsIn: whereValues)
        if (countSet != nil) {
            while countSet.next() {
                count = countSet.int(forColumnIndex: 0)
            }
        }
        
        if (count > 0)
        {
            var pageClause: String = String()
            if (pageSize != nil && pageNumber != nil)
            {
                pageClause = " LIMIT " + String(pageSize!) + " OFFSET " + String((pageNumber! - 1) * pageSize!)
            }
            
            let resultSet: FMResultSet! = sharedModelManager.database!.executeQuery("SELECT [RowId], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [Deleted], [TestSuiteId], [Ordinal], [BacteriumType] FROM [TestSuiteItem] " + whereClause + pageClause, withArgumentsIn: whereValues)
            if (resultSet != nil) {
                while resultSet.next() {
                    let testSuiteItem : TestSuiteItem = TestSuiteItem()
                    testSuiteItem.RowId = resultSet.string(forColumn: "RowId")!
                    testSuiteItem.CreatedBy = resultSet.string(forColumn: "CreatedBy")!
                    testSuiteItem.CreatedOn = resultSet.date(forColumn: "CreatedOn")!
                    if !resultSet.columnIsNull("LastUpdatedBy")
                    {
                        testSuiteItem.LastUpdatedBy = resultSet.string(forColumn: "LastUpdatedBy")
                    }
                    if !resultSet.columnIsNull("LastUpdatedOn")
                    {
                        testSuiteItem.LastUpdatedOn = resultSet.date(forColumn: "LastUpdatedOn")
                    }
                    if !resultSet.columnIsNull("Deleted")
                    {
                        testSuiteItem.Deleted = resultSet.date(forColumn: "Deleted")
                    }
                    testSuiteItem.TestSuiteId = (resultSet?.string(forColumn: "TestSuiteId"))!
                    testSuiteItem.Ordinal = Int((resultSet?.int(forColumn: "Ordinal"))!)
                    testSuiteItem.BacteriumType = (resultSet?.string(forColumn: "BacteriumType"))!
                    
                    testSuiteItemList.append(testSuiteItem)
                }
            }
        }
        
        sharedModelManager.database!.close()
        
        return (testSuiteItemList, count)
    }
    
}

