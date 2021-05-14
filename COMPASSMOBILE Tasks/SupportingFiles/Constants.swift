//
//  Constants.swift
//  COMPASSMOBILE
//
//  Created by Andrew Harper on 22/01/2016.
//  Copyright © 2016 HYDOP E.C.S. All rights reserved.
//

import UIKit

enum EntityType: Int32 {
    case referenceData = 1, organisation = 2, site = 3, property = 4, location = 5, locationGroup = 6, locationGroupMembership = 7, asset = 8, operative = 9, taskTemplate = 10, taskTemplateParameter = 11, task = 12, taskParameter = 13, operativeGroup = 14, operativeGroupMembership = 15, operativeGroupTaskTemplateMembership = 16
}

enum ReferenceDataSortOrder: Int32 {
    case display = 1, ordinal = 2
}

enum TaskSortOrder: Int32 {
    case date = 1, location = 2, assetType = 3, task = 4 //, Route = 5
}

enum TaskPeriod: Int32 {
    case all = 0, dueToday = 1, dueNext7Days = 2, dueCalendarMonth = 3, dueThisMonth = 4
}

let All: String = "All"
let DueTodayText: String = "Due Today"
let DueNext7DaysText: String = "Due This Week"
let DueCalendarMonthText: String = "Due This Month"
let DueThisMonthText: String = "Due by the End of Next Month"

let formatString: NSString = DateFormatter.dateFormat(fromTemplate: "j", options: 0, locale: Locale.current)! as NSString
let hasAMPM = formatString.contains("a")

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

let BaseDate: Date = Date(dateString: hasAMPM ? "2000-01-01T12:00:00 PM" : "2000-01-01T00:00:00.000")

let EmptyGuid: String = "00000000-0000-0000-0000-000000000000"

let RemedialTask: String = "Remedial Task"
let Accessible: String = "Accessible"
let NotApplicable: String = "Not applicable"
let PleaseSelect: String = "Please select"
let TaskOpenMessage: String = "A different task is already open"

let TemperatureCell: Int = 1
let TemperatureProfileCellHot: Int = 2
let TemperatureProfileCellCold: Int = 3

let ScanCodeCell: Int = 1

let DataMatrixCell: Int = 1

let NoNetwork: String = "Not connected to network"
