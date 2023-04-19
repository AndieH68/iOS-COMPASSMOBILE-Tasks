//
//  TaskTemplateParameterCellSampleWithBiocide.swift
//  COMPASSMOBILE Tasks
//
//  Created by Andrew Harper on 23/06/2022.
//  Copyright © 2022 HYDOP E.C.S. All rights reserved.
//

import UIKit

class TaskTemplateParameterCellSampleWithBiocide: UITableViewCell {
    
    @IBOutlet var Delete: UIButton!
    @IBOutlet var SampleReference: UILabel!
    @IBOutlet var BacteriumType: UILabel!
    
    @IBOutlet var OutletType: KFPopupSelector!
    @IBOutlet var SampleType: KFPopupSelector!
    @IBOutlet var NumberOfBottles: UITextField!
    
    @IBOutlet var BiocideType: KFPopupSelector!
    @IBOutlet var Reading1Label: UILabel!
    @IBOutlet var Reading1: UITextField!
    @IBOutlet var Reading2Label: UILabel!
    @IBOutlet var Reading2: UITextField!
    @IBOutlet var Temperature: UITextField!
    
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
    
    func biocideType() -> String?
    {
        return BiocideType.selectedValue
    }
    
    func reading1() -> String?
    {
        return Reading1.text
    }
    
    func reading2() -> String?
    {
        return Reading2.text
    }
    
    func temperature() -> String?
    {
        return Temperature.text
    }
    
}
