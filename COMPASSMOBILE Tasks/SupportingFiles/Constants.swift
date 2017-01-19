//
//  Constants.swift
//  COMPASSMOBILE
//
//  Created by Andrew Harper on 22/01/2016.
//  Copyright © 2016 HYDOP E.C.S. All rights reserved.
//

import UIKit

enum EntityType: Int32 {
    case ReferenceData = 1, Organisation = 2, Site = 3, Property = 4, Location = 5, LocationGroup = 6, LocationGroupMembership = 7, Asset = 8, Operative = 9, TaskTemplate = 10, TaskTemplateParameter = 11, Task = 12, TaskParameter = 13
}

enum ReferenceDataSortOrder: Int32 {
    case Display = 1, Ordinal = 2
}

enum TaskSortOrder: Int32 {
    case Date = 1, Location = 2, AssetType = 3, Task = 4 //, Route = 5
}

enum TaskPeriod: Int32 {
    case All = 0, DueToday = 1, DueNext7Days = 2, DueNext30Days = 3, DueThisMonth = 4
}

let formatString: NSString = NSDateFormatter.dateFormatFromTemplate("j", options: 0, locale: NSLocale.currentLocale())!
let hasAMPM = formatString.containsString("a")

let DateFormat24: String = "yyyy-MM-dd'T'HH:mm:ss.SSS"
let DateFormat24NoNano: String = "yyyy-MM-dd'T'HH:mm:ss"
let DateFormat24StartOfDay: String = "yyyy-MM-dd'T'00:00:00.000"
let DateFormat24StartOfMonth: String = "yyyy-MM-01'T'00:00:00.000"

let DateFormat12: String = "yyyy-MM-dd'T'hh:mm:ss a"
let DateFormat12NoNano: String = "yyyy-MM-dd'T'hh:mm:ss a"
let DateFormat12StartOfDay: String = "yyyy-MM-dd'T'12:00:00 a"
let DateFormat12StartOfMonth: String = "yyyy-MM-01'T'12:00:00 a"

let DateFormatNoTime: String = "yyyy-MM-dd"
let DateFormatForView: String = "dd/MM/yyyy"
let DateFormatForTaskName: String = "yyMMddhhmm"

let BaseDate: NSDate = NSDate(dateString: hasAMPM ? "2000-01-01T12:00:00 PM" : "2000-01-01T00:00:00.000")

let EmptyGuid: String = "00000000-0000-0000-0000-000000000000"

let RemedialTask: String = "Remedial Task"
let Accessible: String = "Accessible"
let NotApplicable: String = "Not applicable"
let PleaseSelect: String = "Please select"
