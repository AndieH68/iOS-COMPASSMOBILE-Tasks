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

let DateFormat: String = "yyyy-MM-dd'T'HH:mm:ss.SSS"
let DateFormatNoNano: String = "yyyy-MM-dd'T'HH:mm:ss"
let DateFormatNoTime: String = "yyyy-MM-dd"

let BaseDate: NSDate = NSDate(dateString: "2000-01-01T00:00:00.000")

let EmptyGuid: String = "00000000-0000-0000-0000-000000000000"