//
//  TaskTemplateParameterCellScanUniversal.swift
//  COMPASSMOBILE Tasks
//
//  Created by Andrew Harper on 08/06/2021.
//  Copyright © 2021 HYDOP E.C.S. All rights reserved.
//

import Foundation

class TaskTemplateParameterCellScanUniversal: UITableViewCell {
    @IBOutlet var Question: UILabel!
    @IBOutlet var Answer: UITextField!

    @IBOutlet var ScanUniversalTextButton: UIButton!
    @IBOutlet var ScanUniversalButton: UIButton!

    @IBOutlet var SerialNumber: UILabel!
    @IBOutlet var PartNumber: UILabel!
    @IBOutlet var BatchNumber: UILabel!
    @IBOutlet var ExpiryDate: UILabel!
   
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.setupLabelTap()
    }

    @objc func labelTapped(_ sender: UITapGestureRecognizer) {
        setupManual()
    }
        
    @IBAction func ScanUniversalTextButton_TouchDown(_ sender: Any) {
        setupManual()
    }
    
    func setupManual()
    {
        if (self.Answer.text != NotApplicable)
        {
            self.SerialNumber.isHidden = true
            self.Answer.isHidden = false
            self.Answer.becomeFirstResponder()
        }
    }
    
    func setupLabelTap() {
        let labelTap = UITapGestureRecognizer(target: self, action: #selector(self.labelTapped(_:)))
        self.SerialNumber.isUserInteractionEnabled = true
        self.SerialNumber.addGestureRecognizer(labelTap)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        // super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
   
    func value() -> String? {
        return Answer.text
    }

    func updateFromAnswer(){
        if(Answer.text != nil)
        {
            if Session.MatrixScanned != nil
            {
                let GS1DataMatrix = GS1Barcode(raw: Answer.text!)
                if GS1DataMatrix.LastParseSuccessfull {
                    SerialNumber.text = GS1DataMatrix.SerialNumber!
                    PartNumber.text = GS1DataMatrix.GlobalTradeItemNumber!
                    BatchNumber.text = GS1DataMatrix.BatchNumber!
                    ExpiryDate.text = Utility.DateToStringForView(GS1DataMatrix.ExpirationDate!)
                } else {
                    if GS1DataMatrix.HasUnrecognisedElement == true {
                        if GS1DataMatrix.SerialNumber != nil
                        {
                            SerialNumber.text = GS1DataMatrix.SerialNumber!
                        }
                        if GS1DataMatrix.GlobalTradeItemNumber != nil
                        {
                            PartNumber.text = GS1DataMatrix.GlobalTradeItemNumber!
                        }
                        if GS1DataMatrix.BatchNumber != nil
                        {
                            BatchNumber.text = GS1DataMatrix.BatchNumber!
                        }
                        if GS1DataMatrix.ExpirationDate != nil
                        {
                            ExpiryDate.text = Utility.DateToStringForView(GS1DataMatrix.ExpirationDate!)
                        }
                        
                    }
                }
                SerialNumber.isHidden = false;
                Answer.isHidden = true;
            }
            else if Session.CodeScanned != nil
            {
                SerialNumber.text = Answer.text
                PartNumber.text = ""
                BatchNumber.text = ""
                ExpiryDate.text = ""
                SerialNumber.isHidden = false;
                Answer.isHidden = true;
            }
            else
            {
                SerialNumber.text = Answer.text
                PartNumber.text = ""
                BatchNumber.text = ""
                ExpiryDate.text = ""
                SerialNumber.isHidden = false;
                Answer.isHidden = true;
            }
        }
    }
}
