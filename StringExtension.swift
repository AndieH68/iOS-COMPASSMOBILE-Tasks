//
//  StringExtension.swift
//  COMPASSMOBILE Tasks
//
//  Created by Andrew Harper on 29/04/2021.
//  Copyright © 2021 HYDOP E.C.S. All rights reserved.
//

import Foundation

extension String
{
    typealias SimpleToFromReplaceList = [(fromSubString:String,toSubString:String)]

    func simpleReplace( _ mapList:SimpleToFromReplaceList ) -> String
    {
        var string = self

        for (fromStr, toStr) in mapList
        {
            let separatedList = string.components(separatedBy: fromStr)
            if separatedList.count > 1
            {
                string = separatedList.joined(separator: toStr)
            }
        }
    
        return string
    }

    func xmlSimpleUnescape() -> String
    {
        let mapList : SimpleToFromReplaceList = [
        ("&amp;",  "&"),
        ("&quot;", "\""),
        ("&#x27;", "'"),
        ("&#x39;", "'"),
        ("&#x92;", "'"),
        ("&#x96;", "'"),
        ("&gt;",   ">"),
        ("&lt;",   "<")]

        return self.simpleReplace(mapList)
    }

    func GS1DataMatrixEscape() -> String
    {
        let mapList : SimpleToFromReplaceList = [
        ("\u{1d}",  "ZZ1DZZ"),
        ("\u{1c}", "ZZ1CZZ")]

        return self.simpleReplace(mapList)
    }
    
    func xmlSimpleEscape() -> String
    {
        let mapList : SimpleToFromReplaceList = [
        ("&",  "&amp;"),
        ("\"", "&quot;"),
        ("'",  "&#x27;"),
        (">",  "&gt;"),
        ("<",  "&lt;")]

        return self.simpleReplace(mapList)
    }
    
    /** Returning a substring of the current element */
    func substring(_ from: Int, length: Int)->String{
        let start = self.index(self.startIndex, offsetBy: from)
        let end = self.index(start, offsetBy: length)
        let range = start..<end
        return String(self[range])
    }
    /** Returning a substring of the current element */
    func substring(_ from: Int, to: Int)->String{
        return self.substring(from, length: to-from)
    }
    /** Returning a substring of the current element, cutting at the passed char */
    func substring(from: Int)->String{
        return self.substring(from, length: self.count - from)
    }
    
    /** Returning a substring of the current element, cutting at the passed char */
    func substring(to: Int)->String{
        return self.substring(0, length: to)
    }

    /** returns the index of a substring, if the string contains the parameter */
    func index(of string: String, options: CompareOptions = .literal) -> Index? {
        return range(of: string, options: options)?.lowerBound
    }
    
    /** checks if the string contains a certain substring */
    func startsWith(_ subString: String) -> Bool{
        return self.hasPrefix(subString)
    }
}
