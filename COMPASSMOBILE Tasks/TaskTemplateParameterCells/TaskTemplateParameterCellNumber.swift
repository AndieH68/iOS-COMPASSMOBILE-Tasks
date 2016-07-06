//
//  TaskTemplateParameterCellNumber.swift
//  COMPASSMOBILE
//
//  Created by Andrew Harper on 23/05/2016.
//  Copyright © 2016 HYDOP E.C.S. All rights reserved.
//

import UIKit

class TaskTemplateParameterCellNumber: UITableViewCell {
   
    @IBOutlet var Question: UILabel!
    @IBOutlet var Answer: UITextField!
        
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        //super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    func value() -> String?
    {
        return Answer.text
    }
}