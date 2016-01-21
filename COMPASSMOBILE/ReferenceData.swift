//
//  ReferenceData.swift
//  COMPASSMOBILE
//
//  Created by Andrew Harper on 19/01/2016.
//  Copyright © 2016 HYDOP E.C.S. All rights reserved.
//

import UIKit

class ReferenceData: NSObject{
    
    var RowId: String = String()
    var CreatedBy: String = String()
    var CreatedOn: NSDate = NSDate()
    var LastUpdatedBy: String? = nil
    var LastUpdatedOn: NSDate? = nil
    var Deleted: NSDate? = nil
    var StartDate: NSDate = NSDate()
    var EndDate: NSDate? = nil
    var Type: String = String()
    var Value: String = String()
    var Ordinal: Int64 = Int64()
    var Display: String = String()
    var System: Bool = Bool()
    var ParentType: String? = nil
    var ParentValue: String? = nil
}