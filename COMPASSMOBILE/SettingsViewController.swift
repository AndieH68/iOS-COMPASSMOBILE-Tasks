//
//  SettingsViewController.swift
//  COMPASSMOBILE
//
//  Created by Andrew Harper on 25/02/2016.
//  Copyright © 2016 HYDOP E.C.S. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {

    @IBAction func Cancel(sender: UIBarButtonItem) {
                self.navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func Done(sender: UIBarButtonItem) {
                self.navigationController?.popViewControllerAnimated(true)
    }
    @IBAction func Logout(sender: UIButton) {
        Session.OperativeId = nil
        Session.OrganisationId = "00000000-0000-0000-0000-000000000000"
        self.navigationController?.popViewControllerAnimated(true)
    }
}