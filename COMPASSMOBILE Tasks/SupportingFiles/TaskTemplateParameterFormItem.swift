//
//  TaskTemplateParameterFormItem.swift
//  COMPASSMOBILE
//
//  Created by Andrew Harper on 07/06/2016.
//  Copyright © 2016 HYDOP E.C.S. All rights reserved.
//

import UIKit

class TaskTemplateParameterFormItem
{
    var TemplateParameter: TaskTemplateParameter
    var Enabled: Bool = false
    var Dependencies: [TaskTemplateParameterFormItem] = []
    var SelectedItem: String? = nil
    var LabelColour: UIColor = UIColor.whiteColor()
    var ControlBackgroundColor: UIColor = UIColor.whiteColor()
    
    init (taskTemplateParameter: TaskTemplateParameter)
    {
        TemplateParameter = taskTemplateParameter
    }
}
