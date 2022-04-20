//
//  SampleTaskViewController.swift
//  COMPASSMOBILE Tasks
//
//  Created by Andrew Harper on 09/11/2021.
//  Copyright © 2021 HYDOP E.C.S. All rights reserved.
//

import Foundation
import UIKit
import MBProgressHUD

class SampleTaskViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate, MBProgressHUDDelegate {
    
    var task: Task = Task()
    var taskParameters: [TaskParameter] = [TaskParameter]()
}
