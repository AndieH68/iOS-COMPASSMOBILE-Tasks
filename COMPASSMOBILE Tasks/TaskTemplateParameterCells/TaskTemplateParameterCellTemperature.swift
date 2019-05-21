//
//  TaskTemplateParameterCellTemperature.swift
//  COMPASSMOBILE
//
//  Created by Andrew Harper on 01/06/2016.
//  Copyright © 2016 HYDOP E.C.S. All rights reserved.
//

import UIKit

class TaskTemplateParameterCellTemperature: UITableViewCell {
    
    @IBOutlet var Question: UILabel!
    @IBOutlet var Answer: UITextField!
    @IBOutlet var ProfileButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        //super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    func value() -> String?
    {
        return Answer.text
    }
 }
