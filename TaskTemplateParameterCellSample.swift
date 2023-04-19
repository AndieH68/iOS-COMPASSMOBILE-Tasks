//
//  TaskTemplateParameterCellSample.swift
//  COMPASSMOBILE Tasks
//
//  Created by Andrew Harper on 23/06/2022.
//  Copyright © 2022 HYDOP E.C.S. All rights reserved.
//

import UIKit

class TaskTemplateParameterCellSample: UITableViewCell {
    
    @IBOutlet var Delete: UIButton!
    @IBOutlet var SampleReference: UILabel!
    @IBOutlet var BacteriumType: UILabel!
    
    @IBOutlet var OutletType: KFPopupSelector!
    @IBOutlet var SampleType: KFPopupSelector!
    @IBOutlet var NumberOfBottles: UITextField!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func outletType() -> String?
    {
        return OutletType.selectedValue
    }
    
    func sampleType() -> String?
    {
        return SampleType.selectedValue
    }
    
    func numberOfBottles() -> String?
    {
        return NumberOfBottles.text
    }
}
