//
//  TaskTemplateParameterCellScanCode.swift
//  COMPASSMOBILE Tasks
//
//  Created by Andrew Harper on 04/05/2021.
//  Copyright © 2021 HYDOP E.C.S. All rights reserved.
//

import Foundation

class TaskTemplateParameterCellScanCode: UITableViewCell {
    @IBOutlet var Question: UILabel!
    @IBOutlet var Answer: UITextField!
    @IBOutlet var ScanCodeButton: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        // super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }

    func value() -> String? {
        return Answer.text
    }
}
