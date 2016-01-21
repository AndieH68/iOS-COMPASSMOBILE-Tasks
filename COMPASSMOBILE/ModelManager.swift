//
//  ModelManager.swift
//  COMPASSMOBILE
//
//  Created by Andrew Harper on 20/01/2016.
//  Copyright © 2016 HYDOP E.C.S. All rights reserved.
//

import UIKit

let sharedInstance = ModelManager()

class ModelManager: NSObject {
    
    var database: FMDatabase? = nil
    
    class func getInstance() -> ModelManager
    {
        if(sharedInstance.database == nil)
        {
            sharedInstance.database = FMDatabase(path: Utility.getPath("COMPASSDB.sqlite"))
        }
        return sharedInstance
    }
    
    func buildWhereClause(criteria: NSDictionary) -> (whereClause: String, whereValues: [AnyObject]) {
        
        var whereClause: String = String()
        var loopCount: Int32 = 0
        var whereValues: [AnyObject] = [AnyObject]()
        for (itemKey, itemValue) in criteria
        {
            whereClause += (loopCount > 0 ? " AND " : " ")
            whereClause += (itemKey as! String) + "=?"
           
            whereValues.append(itemValue)
            
            loopCount += 1
        }
        return (whereClause, whereValues)
    }
    
    // MARK: - Operative
   
    func addOperative(operative: Operative) -> Bool {
        //build the sql statemnt
        var SQLStatement: String = String()
        var SQLParameterNames: String = String()
        var SQLParameterPlaceholders: String = String()
        var SQLParameterValues: [NSObject] = [NSObject]()
        
        SQLParameterNames = "[RowId], [CreatedBy], [CreatedOn], "
        SQLParameterPlaceholders = "?, ?, ?, "
        SQLParameterValues.append(operative.RowId)
        SQLParameterValues.append(operative.CreatedBy)
        SQLParameterValues.append(operative.CreatedOn)
        
        if operative.LastUpdatedBy != nil {
            SQLParameterNames += "[LastUpdatedBy], "
            SQLParameterPlaceholders += "?, "
            SQLParameterValues.append(operative.LastUpdatedBy!)
        }
        
        if operative.LastUpdatedOn != nil {
            SQLParameterNames += "[LastUpdatedOn], "
            SQLParameterPlaceholders += "?, "
            SQLParameterValues.append(operative.LastUpdatedOn!)
        }
        
        if operative.Deleted != nil {
            SQLParameterNames += "[Deleted], "
            SQLParameterPlaceholders += "?, "
            SQLParameterValues.append(operative.Deleted!)
        }
        
        SQLParameterNames += "[OrganisationId], [Username], [Password]"
        SQLParameterPlaceholders += "?, ?, ?"
        SQLParameterValues.append(operative.OrganisationId)
        SQLParameterValues.append(operative.Username)
        SQLParameterValues.append(operative.Password)
        
        SQLStatement = "INSERT INTO [OPERATIVE] (" + SQLParameterNames + ") VALUES (" + SQLParameterPlaceholders + ")"
        
        sharedInstance.database!.open()
        let isInserted = sharedInstance.database!.executeUpdate(SQLStatement, withArgumentsInArray: SQLParameterValues)
        sharedInstance.database!.close()
        return isInserted
    }
    
    func updateOperative(operative: Operative) -> Bool {
        //build the sql statemnt
        var SQLStatement: String = String()
        var SQLParameterNames: String = String()
        var SQLParameterValues: [NSObject] = [NSObject]()
        
        SQLParameterNames = "[CreatedBy]=?, [CreatedOn]=?, "
        SQLParameterValues.append(operative.CreatedBy)
        SQLParameterValues.append(operative.CreatedOn)
        
        if operative.LastUpdatedBy != nil {
            SQLParameterNames += "[LastUpdatedBy]=?, "
            SQLParameterValues.append(operative.LastUpdatedBy!)
        }
        
        if operative.LastUpdatedOn != nil {
            SQLParameterNames += "[LastUpdatedOn]=?, "
            SQLParameterValues.append(operative.LastUpdatedOn!)
        }
        
        if operative.Deleted != nil {
            SQLParameterNames += "[Deleted]=?, "
            SQLParameterValues.append(operative.Deleted!)
        }
        
        SQLParameterNames += "[OrganisationId]=?, [Username]=?, [Password]=?"
        SQLParameterValues.append(operative.OrganisationId)
        SQLParameterValues.append(operative.Username)
        SQLParameterValues.append(operative.Password)
        
        SQLParameterValues.append(operative.RowId)
        
        SQLStatement = "UPDATE [OPERATIVE] SET " + SQLParameterNames + "WHERE [RowId]=?"
        
        sharedInstance.database!.open()
        let isUpdated = sharedInstance.database!.executeUpdate(SQLStatement, withArgumentsInArray: SQLParameterValues)
        sharedInstance.database!.close()
        return isUpdated
    }
    
    func deleteOperative(operative: Operative) -> Bool {
        sharedInstance.database!.open()
        let isDeleted = sharedInstance.database!.executeUpdate("DELETE FROM [OPERATIVE] WHERE [RowId]=?", withArgumentsInArray: [operative.RowId])
        sharedInstance.database!.close()
        return isDeleted
    }
    
    func getOperative(operativeId: String) -> Operative? {
        sharedInstance.database!.open()
        var operative: Operative? = nil
        
        let resultSet = sharedInstance.database!.executeQuery("SELECT [RowId], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [Deleted], [OrganisationId], [Username], [Password] FROM [Operative] WHERE [RowId]=?", withArgumentsInArray: [operativeId])
        if (resultSet != nil) {
            while resultSet.next() {
                var resultOperative: Operative = Operative()
                resultOperative = Operative()
                resultOperative.RowId = resultSet.stringForColumn("RowId")
                resultOperative.CreatedBy = resultSet.stringForColumn("CreatedBy")
                resultOperative.CreatedOn = NSDate(dateString: resultSet.stringForColumn("CreatedOn"))
                if(resultSet.stringForColumn("LastUpdatedBy") != "")
                {
                    resultOperative.LastUpdatedBy = resultSet.stringForColumn("LastUpdatedBy")
                }
                if(resultSet.stringForColumn("LastUpdatedOn") != "")
                {
                    resultOperative.LastUpdatedOn = NSDate(dateString: resultSet.stringForColumn("LastUpdatedOn"))
                }
                if(resultSet.stringForColumn("Deeted") != "")
                {
                    resultOperative.Deleted = NSDate(dateString: resultSet.stringForColumn("Deleted"))
                }
                resultOperative.OrganisationId = resultSet.stringForColumn("OrganisationId")
                resultOperative.Username = resultSet.stringForColumn("Username")
                resultOperative.Password = resultSet.stringForColumn("Password")
                
                operative = resultOperative
            }
        }
        sharedInstance.database!.close()
        return operative
    }
    
    func getAllOperative() -> NSMutableArray {
        sharedInstance.database!.open()
        let resultSet: FMResultSet! = sharedInstance.database!.executeQuery("SELECT [RowId], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [Deleted], [OrganisationId], [Username], [Password] FROM [Operative]", withArgumentsInArray: nil)
        let operatives : NSMutableArray = NSMutableArray()
        if (resultSet != nil) {
            while resultSet.next() {
                let operative : Operative = Operative()
                operative.RowId = resultSet.stringForColumn("RowId")
                operative.CreatedBy = resultSet.stringForColumn("CreatedBy")
                operative.CreatedOn = NSDate(dateString: resultSet.stringForColumn("CreatedOn"))
                if(resultSet.stringForColumn("LastUpdatedBy") != "")
                {
                    operative.LastUpdatedBy = resultSet.stringForColumn("LastUpdatedBy")
                }
                if(resultSet.stringForColumn("LastUpdatedOn") != "")
                {
                    operative.LastUpdatedOn = NSDate(dateString: resultSet.stringForColumn("LastUpdatedOn"))
                }
                if(resultSet.stringForColumn("Deeted") != "")
                {
                    operative.Deleted = NSDate(dateString: resultSet.stringForColumn("Deleted"))
                }
                operative.OrganisationId = resultSet.stringForColumn("OrganisationId")
                operative.Username = resultSet.stringForColumn("Username")
                operative.Password = resultSet.stringForColumn("Password")
                
                operatives.addObject(operative)
            }
        }
        sharedInstance.database!.close()
        return operatives
    }
    
    func findOperatives(criteria: NSDictionary) -> NSMutableArray {
        var whereClause: String = String()
        var whereValues: [AnyObject] = [AnyObject]()
        
        (whereClause, whereValues) = buildWhereClause(criteria)
        
        sharedInstance.database!.open()
        let resultSet: FMResultSet! = sharedInstance.database!.executeQuery("SELECT [RowId], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [Deleted], [OrganisationId], [Username], [Password] FROM [Operative] WHERE " + whereClause, withArgumentsInArray: whereValues)
        let operatives : NSMutableArray = NSMutableArray()
        if (resultSet != nil) {
            while resultSet.next() {
                let operative : Operative = Operative()
                operative.RowId = resultSet.stringForColumn("RowId")
                operative.CreatedBy = resultSet.stringForColumn("CreatedBy")
                operative.CreatedOn = NSDate(dateString: resultSet.stringForColumn("CreatedOn"))
                if(resultSet.stringForColumn("LastUpdatedBy") != "")
                {
                    operative.LastUpdatedBy = resultSet.stringForColumn("LastUpdatedBy")
                }
                if(resultSet.stringForColumn("LastUpdatedOn") != "")
                {
                    operative.LastUpdatedOn = NSDate(dateString: resultSet.stringForColumn("LastUpdatedOn"))
                }
                if(resultSet.stringForColumn("Deeted") != "")
                {
                    operative.Deleted = NSDate(dateString: resultSet.stringForColumn("Deleted"))
                }
                operative.OrganisationId = resultSet.stringForColumn("OrganisationId")
                operative.Username = resultSet.stringForColumn("Username")
                operative.Password = resultSet.stringForColumn("Password")
                
                operatives.addObject(operative)
            }
        }
        sharedInstance.database!.close()
        return operatives
        
    }

}
