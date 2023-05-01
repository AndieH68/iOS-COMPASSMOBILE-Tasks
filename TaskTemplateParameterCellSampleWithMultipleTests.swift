//
//  TaskTemplateParameterCellSampleWithMultipleTests.swift
//  COMPASSMOBILE Tasks
//
//  Created by Andrew Harper on 28/04/2023.
//  Copyright © 2023 HYDOP E.C.S. All rights reserved.
//

import Foundation

class TaskTemplateParameterCellSampleWithMultipleTests: UITableViewCell {
    
    @IBOutlet var Sample: UILabel!
    @IBOutlet var Delete: UIButton!
    @IBOutlet var SampleReference: UILabel!
    @IBOutlet var BacteriumType: UILabel!
    
    @IBOutlet var OutletType: KFPopupSelector!
    @IBOutlet var SampleType: KFPopupSelector!
    @IBOutlet var NumberOfBottles: UITextField!
   
    @IBOutlet var TVC: CheckBox!
    @IBOutlet var EColi: CheckBox!
    @IBOutlet var Coliforms: CheckBox!
    @IBOutlet var PseudomonasSpp: CheckBox!
    @IBOutlet var PseudomonasAeruginosa: CheckBox!
    @IBOutlet var Cryptosporidium: CheckBox!
    
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
    
    func tVC() -> Bool
    {
        return TVC.isChecked;
    }

    func eColi() -> Bool
    {
        return EColi.isChecked;
    }
    func coliforms() -> Bool
    {
        return Coliforms.isChecked;
    }
    func pseudomonasSpp() -> Bool
    {
        return PseudomonasSpp.isChecked;
    }
    func pseudomonasAeruginosa() -> Bool
    {
        return PseudomonasAeruginosa.isChecked;
    }
    func cryptosporidium() -> Bool
    {
        return Cryptosporidium.isChecked;
    }
    
}
