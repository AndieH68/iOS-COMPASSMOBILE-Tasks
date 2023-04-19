//
//  GS1Barcode.swift
//  COMPASSMOBILE Tasks
//
//  Created by Andrew Harper on 29/04/2021.
//  Copyright © 2021 HYDOP E.C.S. All rights reserved.
//

import Foundation

public class GS1Barcode: NSObject, Barcode {
    public var raw: String?
    private var
lastParseSuccessfull: Bool = false
    private var hasUnrecognisedElement: Bool = false

    /* Just the common Application Identifiers for now */
    private var applicationIdentifiers = [
        "SerialShippingContainerCode": GS1ApplicationIdentifier("00", length: 18, type: .AlphaNumeric),
        "GlobalTradeItemNumber": GS1ApplicationIdentifier("01", length: 14, type: .AlphaNumeric),
        "GlobalTradeItemNumberOfContainedTradeItems": GS1ApplicationIdentifier("02", length: 14, type: .AlphaNumeric),
        "BatchNumber": GS1ApplicationIdentifier("10", length: 20, type: .AlphaNumeric, dynamicLength: true),
        "ProductionDate": GS1ApplicationIdentifier(dateIdentifier: "11"),
        "DueDate": GS1ApplicationIdentifier(dateIdentifier: "12"),
        "PackagingDate": GS1ApplicationIdentifier(dateIdentifier: "13"),
        "BestBeforeDate": GS1ApplicationIdentifier(dateIdentifier: "15"),
        "SellByDate": GS1ApplicationIdentifier(dateIdentifier: "16"),
        "ExpirationDate": GS1ApplicationIdentifier(dateIdentifier: "17"),
        "ProductVariant": GS1ApplicationIdentifier("20", length: 2, type: .AlphaNumeric),
        "SerialNumber": GS1ApplicationIdentifier("21", length: 20, type: .AlphaNumeric, dynamicLength: true),
    ]

    /* Public properties */
    public var SerialShippingContainerCode: String? { return applicationIdentifiers["SerialShippingContainerCode"]!.stringValue }
    public var GlobalTradeItemNumber: String? { return applicationIdentifiers["GlobalTradeItemNumber"]!.stringValue }
    public var GlobalTradeItemNumberOfContainedTradeItems: String? { return applicationIdentifiers["GlobalTradeItemNumberOfContainedTradeItems"]!.stringValue }
    public var BatchNumber: String? { return applicationIdentifiers["BatchNumber"]!.stringValue }
    public var ProductionDate: Date? { return applicationIdentifiers["ProductionDate"]!.dateValue }
    public var DueDate: Date? { return applicationIdentifiers["DueDate"]!.dateValue }
    public var PackagingDate: Date? { return applicationIdentifiers["PackagingDate"]!.dateValue }
    public var BestBeforeDate: Date? { return applicationIdentifiers["BestBeforeDate"]!.dateValue }
    public var SellByDate: Date? { return applicationIdentifiers["SellByDate"]!.dateValue }
    public var ExpirationDate: Date? { return applicationIdentifiers["ExpirationDate"]!.dateValue }
    public var ProductVariant: String? { return applicationIdentifiers["ProductVariant"]!.stringValue }
    public var SerialNumber: String? { return applicationIdentifiers["SerialNumber"]!.stringValue }

    /* Empty constructor */
    override public required init() {
        super.init()
    }

    /* Constructor from string */
    public required init(raw: String) {
        super.init()
        self.raw = raw
        print(raw)
        try? parse()
    }

    /* Constructor from exiting ApplicationIdentifers */
    public required init(raw: String, customApplicationIdentifiers: [String: GS1ApplicationIdentifier]) {
        super.init()
        self.raw = raw
        print(raw)

        for applicationIdentifer in customApplicationIdentifiers {
            applicationIdentifiers[applicationIdentifer.key] = applicationIdentifer.value
        }

        try? parse()
    }
    
    public var LastParseSuccessfull: Bool
    {
        get { return lastParseSuccessfull}
    }

    public var HasUnrecognisedElement: Bool
    {
        get { return hasUnrecognisedElement}
    }

    public func validate() throws -> Bool {
        // check for no unparsed value
        if raw == nil {
            throw GS1BarcodeErrors.ValidationError.barcodeNil
        }

        if raw == "" {
            throw GS1BarcodeErrors.ValidationError.barcodeNil
        }

        if raw!.replacingOccurrences(of: "\u{1d}", with: "").range(of: #"^\d+[a-zA-Z0-9äöüÄÖU@#\-]*$"#, options: .regularExpression) == nil {
            throw GS1BarcodeErrors.ValidationError.unallowedCharacter
        }
        if !lastParseSuccessfull {
            throw GS1BarcodeErrors.ValidationError.parseUnsucessfull
        }
        return true
    }

    private func parseApplicationIdentifier(_ applicationIdentifier: GS1ApplicationIdentifier, data: inout String) throws {
        if data.hasPrefix(applicationIdentifier.identifier) {
            do {
                try GS1BarcodeParser.parseGS1ApplicationIdentifier(applicationIdentifier, data: data)
                data = GS1BarcodeParser.reduce(data: data, by: applicationIdentifier)!
            }
            catch let error {
                throw error
            }
        }
        else {
            print("The data didn't start with the expected Application Identifier \(applicationIdentifier.identifier)")
        }
    }

    public func parse() throws {
        lastParseSuccessfull = false
        hasUnrecognisedElement = false
        var data = raw
        print("Parsing: " + data!)

        if data != nil {
            while data!.count > 0 {
                // Removing Group Seperator from the beginning of the string
                if data!.startsWith("\u{1D}") {
                    data = data!.substring(from: 1)
                }
                if data!.startsWith("\u{1C}") {
                    data = data!.substring(from: 1)
                }
                
                // Checking the AIs by it's identifier and passing it to the Barcode Parser to get the value and cut the data
                var foundOne = false
                for (_, applicationIdentifier) in applicationIdentifiers {
                    // Exclude the gtinIndicatorDigit, because it get's added later for the gtin identifier
                    // If could parse ai, continue and do the loop once again
                    // Keep syntax like that! foundOne should and continue should only be set if no error was thrown
                    do {
                        if data!.startsWith(applicationIdentifier.identifier) {
                            try parseApplicationIdentifier(applicationIdentifier, data: &data!)
                            foundOne = true
                            continue
                        }
                    }
                    catch {
                        foundOne = false
                    }
                }
                // If no ai was found return false and keep the lastParseSuccessfull to false -> This will make validate() fail as well
                if !foundOne {
                    hasUnrecognisedElement = true
                    throw GS1BarcodeErrors.ParseError.didNotFoundApplicationIdentifier
                }
            }
        }
        lastParseSuccessfull = true
    }
}
