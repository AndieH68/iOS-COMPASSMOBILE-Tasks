//
//  GS1BarcodeErrors.swift
//  COMPASSMOBILE Tasks
//
//  Created by Andrew Harper on 29/04/2021.
//  Copyright © 2021 HYDOP E.C.S. All rights reserved.
//

import Foundation

class GS1BarcodeErrors: NSObject {
    /** Error cases for Barcode Parser */
    public enum ParseError: Error {
        case dataDoesNotStartWithAIIdentifier(data: String)
        case emptyData
        // GS1 Barcode
        case didNotFoundApplicationIdentifier
    }

    public enum ValidationError: Error {
        case parseUnsucessfull
        case barcodeNil
        case barcodeEmpty
        case unallowedCharacter
    }
}
