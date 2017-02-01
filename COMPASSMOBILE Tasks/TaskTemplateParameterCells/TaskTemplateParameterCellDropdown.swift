//
//  TaskTemplateParameterCellDropdown.swift
//  COMPASSMOBILE
//
//  Created by Andrew Harper on 23/05/2016.
//  Copyright © 2016 HYDOP E.C.S. All rights reserved.
//

import UIKit

class TaskTemplateParameterCellDropdown: UITableViewCell {
    
    @IBOutlet var Question: UILabel!
    @IBOutlet var AnswerSelector: KFPopupSelector!
    
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
        return AnswerSelector.selectedValue
    }
}
