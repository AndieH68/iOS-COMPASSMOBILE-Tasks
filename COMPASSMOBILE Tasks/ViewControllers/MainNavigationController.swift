//
//  MainNavigationController.swift
//  COMPASSMOBILE
//
//  Created by Andrew Harper on 26/05/2016.
//  Copyright © 2016 HYDOP E.C.S. All rights reserved.
//

import UIKit

class MainNavigationController: UINavigationController
{
    override var shouldAutorotate : Bool {
        return (self.topViewController?.shouldAutorotate)!
    }
}

