//
//  GS1ApplicationIdentifier.swift
//  COMPASSMOBILE Tasks
//
//  Created by Andrew Harper on 29/04/2021.
//  Copyright © 2021 HYDOP E.C.S. All rights reserved.
//

import Foundation

public enum GS1ApplicationIdentifierType: String {
    case AlphaNumeric
    case Numeric
    case NumericDouble
    case Date
    var description: String {
        return rawValue
    }
}

public class GS1ApplicationIdentifier: NSObject {
    public var identifier: String
    public var maxLength: Int
    public var dynamicLength: Bool = false

    public var type: GS1ApplicationIdentifierType?

    public var rawValue: String?
    public var dateValue: Date?
    public var intValue: Int?
    public var doubleValue: Double?
    public var stringValue: String?

    public var significance: Int?

    /* Identifier with length**/
    public init(_ identifier: String, length: Int) {
        self.identifier = identifier
        maxLength = length
    }

    /* Identifier with length and type */
    public convenience init(_ identifier: String, length: Int, type: GS1ApplicationIdentifierType) {
        self.init(identifier, length: length)
        self.type = type
    }

    /* Identifier with dynamic length and type */
    public convenience init(_ identifier: String, length: Int, type: GS1ApplicationIdentifierType, dynamicLength: Bool) {
        self.init(identifier, length: length, type: type)
        self.dynamicLength = dynamicLength
    }

    /* Date Identifier */
    public convenience init(dateIdentifier identifier: String) {
        self.init(identifier, length: 6, type: .Date)
    }
}
