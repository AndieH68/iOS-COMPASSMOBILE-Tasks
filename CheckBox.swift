//
//  CheckBox.swift
//  COMPASSMOBILE Tasks
//
//  Created by Andrew Harper on 28/04/2023.
//  Copyright © 2023 HYDOP E.C.S. All rights reserved.
//

import UIKit

protocol CheckBoxDelegate: AnyObject {
    func CheckBoxClicked(sender: CheckBox)
}

class CheckBox: UIButton {
    //Images
    let checkedImage = UIImage(named: "ic_check_box")! as UIImage
    let uncheckedImage = UIImage(named: "ic_check_box_outline_blank")! as UIImage
    var Name: String = ""
    
    weak var delegate: CheckBoxDelegate?
    
    //Bool property
    var isChecked: Bool = false {
        didSet {
            if isChecked == true {
                self.setImage(checkedImage, for: UIControl.State.normal)
            } else {
                self.setImage(uncheckedImage, for: UIControl.State.normal)
            }
        }
    }
    
    override func awakeFromNib(){
        self.addTarget(self, action:#selector(buttonClicked(sender:)), for: UIControl.Event.touchUpInside)
        self.isChecked = false
    }
    
    @IBAction func buttonClicked(sender: UIButton) {
        if sender == self {
            isChecked = !isChecked
            self.delegate?.CheckBoxClicked(sender: sender as! CheckBox)
        }
     }
}
