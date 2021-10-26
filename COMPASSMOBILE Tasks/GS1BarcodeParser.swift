//
//  GS1BarcodeParser.swift
//  COMPASSMOBILE Tasks
//
//  Created by Andrew Harper on 29/04/2021.
//  Copyright © 2021 HYDOP E.C.S. All rights reserved.
//

import Foundation

public class GS1BarcodeParser: NSObject {
    /** Set to true to prints debug information to console */
    static var printDebugOutput = false

    /**
     Takes a data String,removed the GS1 Value and AI and returns the modified String
     - returns:
     Modified String without the AI and it's value
     */
    static func reduce(data: String?, by applicationIndentifier: GS1ApplicationIdentifier) -> String? {
        if data == nil {
            return data
        }

        var length = (applicationIndentifier.rawValue?.count ?? 0) + applicationIndentifier.identifier.count
        if applicationIndentifier.dynamicLength && data!.count > length {
            length += 1
        }
        if applicationIndentifier.type == .NumericDouble {
            length += 1
        }
        return data!.substring(from: length)
    }

    /** Parses and sets the data of the AI, based on it's  identifier */
    static func parseGS1ApplicationIdentifier(_ applicationIndentifier: GS1ApplicationIdentifier, data: String) throws {
        if printDebugOutput {
            print("Parsing application identifier with identifier \(applicationIndentifier.identifier) of type \(String(describing: applicationIndentifier.type?.description))")
        }
        if data.count == 0 {
            throw GS1BarcodeErrors.ParseError.emptyData
        }
        if !data.startsWith(applicationIndentifier.identifier) {
            throw GS1BarcodeErrors.ParseError.dataDoesNotStartWithAIIdentifier(data: data)
        }

        // Get Pure Data by removing the identifier
        var applicationIndentifierData = data
        applicationIndentifierData = applicationIndentifierData.substring(from: applicationIndentifier.identifier.count)

        if applicationIndentifier.type == .NumericDouble {
            applicationIndentifier.significance = Int(applicationIndentifierData.substring(to: 1))
            applicationIndentifierData = applicationIndentifierData.substring(from: 1)
        }

        // Cut data by Group Seperator, if dynamic length item and has a GS.
        if applicationIndentifier.dynamicLength && applicationIndentifierData.index(of: "\u{1D}") != nil {
            let toi = applicationIndentifierData.index(of: "\u{1D}")
            let to = applicationIndentifierData.distance(from: applicationIndentifierData.startIndex, to: toi ?? applicationIndentifierData.`startIndex`)

            applicationIndentifierData = applicationIndentifierData.substring(to: to)
        }
        else
        {
            if applicationIndentifier.dynamicLength && applicationIndentifierData.index(of: "\u{1C}") != nil {
                let toi = applicationIndentifierData.index(of: "\u{1C}")
                let to = applicationIndentifierData.distance(from: applicationIndentifierData.startIndex, to: toi ?? applicationIndentifierData.`startIndex`)

                applicationIndentifierData = applicationIndentifierData.substring(to: to)
            }
        }
        // Cut to Max Length, if applicationIndentifierData still longer after the previous cutting.
        if applicationIndentifierData.count > applicationIndentifier.maxLength {
            applicationIndentifierData = applicationIndentifierData.substring(to: applicationIndentifier.maxLength)
        }

        // Set original value to the value of the content
        applicationIndentifier.rawValue = applicationIndentifierData

        // Parsing applicationIndentifierData, based on the applicationIndentifier Type
        if applicationIndentifier.type == GS1ApplicationIdentifierType.Date { // Check if type is a date type and if there are 6 more chars available
            // Parsing the next 6 chars to a Date
            if applicationIndentifierData.count >= 6 {
                applicationIndentifier.dateValue = Date.from(
                    year: Int("20" + applicationIndentifierData.substring(to: 2)),
                    month: Int(applicationIndentifierData.substring(2, length: 2)),
                    day: Int(applicationIndentifierData.substring(4, length: 2))
                )
            }
        }
        else if applicationIndentifier.type == GS1ApplicationIdentifierType.Numeric { // Parsing value to Integer
            applicationIndentifier.intValue = Int(applicationIndentifierData)
        }
        else if applicationIndentifier.type == GS1ApplicationIdentifierType.NumericDouble {
            applicationIndentifier.rawValue = applicationIndentifierData

            applicationIndentifier.doubleValue = Double(applicationIndentifierData)

            if applicationIndentifier.doubleValue != nil {
                applicationIndentifier.doubleValue = applicationIndentifier.doubleValue! / pow(10, Double(applicationIndentifier.significance ?? 0))
            }
        }
        else { // Taking the data left and just putting it into the string value. Expecting that type is not Date and no Numeric. If it is date but not enough chars there, it would still put the content into the string
            applicationIndentifier.stringValue = applicationIndentifierData
        }
    }
}
