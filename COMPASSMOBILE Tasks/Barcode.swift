//
//  Barcode.swift
//  COMPASSMOBILE Tasks
//
//  Created by Andrew Harper on 29/04/2021.
//  Copyright © 2021 HYDOP E.C.S. All rights reserved.
//

import Foundation

protocol Barcode {
    var raw: String? { get set }

    init()
    init(raw: String)

    func validate() throws -> Bool
    func parse() throws
}
