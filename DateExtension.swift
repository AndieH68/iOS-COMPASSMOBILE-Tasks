//
//  DateExtension.swift
//  COMPASSMOBILE Tasks
//
//  Created by Andrew Harper on 29/04/2021.
//  Copyright © 2021 HYDOP E.C.S. All rights reserved.
//

import Foundation

extension Date
{
    
    init(dateString:String) {
        let dateStringFormatter = DateFormatter()
        dateStringFormatter.timeZone = TimeZone(abbreviation: "UTC")
        dateStringFormatter.dateFormat = hasAMPM ? DateFormat12 : DateFormat24
        if let d = dateStringFormatter.date(from: dateString)
        {
            self = Date(timeInterval: 0, since: d)
            return
        }
        
        dateStringFormatter.dateFormat = hasAMPM ? DateFormat12NoNano : DateFormat24NoNano
        if let d = dateStringFormatter.date(from: dateString)
        {
            self = Date(timeInterval: 0, since: d)
            return
        }
        
        dateStringFormatter.dateFormat = DateFormatNoTime
        if let d = dateStringFormatter.date(from: dateString)
        {
            self = Date(timeInterval: 0, since: d)
            return
        }
        
        dateStringFormatter.locale = Locale.init(identifier: "en_US_POSIX")
        dateStringFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"
        dateStringFormatter.timeZone = TimeZone(abbreviation: "UTC")
        if let d = dateStringFormatter.date(from: dateString)
        {
            self = Date(timeInterval: 0, since: d)
            return
        }

        dateStringFormatter.locale = Locale.init(identifier: "en_US_POSIX")
        dateStringFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        dateStringFormatter.timeZone = TimeZone(abbreviation: "UTC")
        if let d = dateStringFormatter.date(from: dateString)
        {
            self = Date(timeInterval: 0, since: d)
            return
        }
        
        let d = dateStringFormatter.date(from: dateString)
        self = Date(timeInterval: 0, since: d!)
    }
   
    func startOfDay() -> Date {
        let dateStringFormatter = DateFormatter()
        dateStringFormatter.dateFormat = hasAMPM ? DateFormat12StartOfDay : DateFormat24StartOfDay
        dateStringFormatter.timeZone = TimeZone(abbreviation: "UTC")
        let startOfDay: Date =  Date(dateString: dateStringFormatter.string(from: self))
        return startOfDay
    }
 
    func endOfDay() -> Date {
        let startOfDay: Date = self.startOfDay()
        let calendar = Calendar.current
        let startOfTomorrow = (calendar as NSCalendar).date(byAdding: .day, value: 1, to: startOfDay, options: NSCalendar.Options(rawValue: 0))!
        let endOfDay = (calendar as NSCalendar).date(byAdding: .second, value: -1, to: startOfTomorrow, options: NSCalendar.Options(rawValue: 0))!
        return endOfDay
    }
    
    func startOfWeek() -> Date {
        var calendar = Calendar.current
        calendar.firstWeekday = 2
        var startOfWeek : NSDate?
        (calendar as NSCalendar).range(of: .weekOfYear, start: &startOfWeek, interval: nil, for: self)
        return startOfWeek! as Date
    }
   
    func endOfWeek() -> Date {
        var calendar = Calendar.current
        calendar.firstWeekday = 2
        var startOfWeek : NSDate?
        (calendar as NSCalendar).range(of: .weekOfYear, start: &startOfWeek, interval: nil, for: self)
        let startOfNextWeek = (calendar as NSCalendar).date(byAdding: .day, value: 7, to: startOfWeek! as Date, options: NSCalendar.Options(rawValue: 0))!
        let endOfWeek = (calendar as NSCalendar).date(byAdding: .second, value: -1, to: startOfNextWeek, options: NSCalendar.Options(rawValue: 0))!
        return endOfWeek as Date
    }
    
    func startOfMonth() -> Date {
        let dateStringFormatter = DateFormatter()
        dateStringFormatter.dateFormat = hasAMPM ? DateFormat12StartOfMonth : DateFormat24StartOfMonth
        dateStringFormatter.timeZone = TimeZone(abbreviation: "UTC")
        return Date(dateString: dateStringFormatter.string(from: self))
    }
 
    func endOfMonth() -> Date {
        let dateStringFormatter = DateFormatter()
        dateStringFormatter.dateFormat = hasAMPM ? DateFormat12StartOfMonth : DateFormat24StartOfMonth
        dateStringFormatter.timeZone = TimeZone(abbreviation: "UTC")
        var startOfMonth : Date?
        startOfMonth =  Date(dateString: dateStringFormatter.string(from: self))

        let calendar = Calendar.current
 
        let startOfNextMonth = (calendar as NSCalendar).date(byAdding: .month, value: 1, to: startOfMonth!, options: NSCalendar.Options(rawValue: 0))!
        let endOfMonth = (calendar as NSCalendar).date(byAdding: .second, value: -1, to: startOfNextMonth, options: NSCalendar.Options(rawValue: 0))!
        return endOfMonth
    }
    
    func startOfNextMonth() -> Date {
        let dateStringFormatter = DateFormatter()
        dateStringFormatter.dateFormat = hasAMPM ? DateFormat12StartOfMonth : DateFormat24StartOfMonth
        dateStringFormatter.timeZone = TimeZone(abbreviation: "UTC")
        var startOfMonth : Date?
        startOfMonth =  Date(dateString: dateStringFormatter.string(from: self))
        
        let calendar = Calendar.current
        let startOfNextMonth = (calendar as NSCalendar).date(byAdding: .month, value: 1, to: startOfMonth!, options: NSCalendar.Options(rawValue: 0))!
        return startOfNextMonth
    }
    
    func endOfNextMonth() -> Date {
        let dateStringFormatter = DateFormatter()
        dateStringFormatter.dateFormat = hasAMPM ? DateFormat12StartOfMonth : DateFormat24StartOfMonth
        dateStringFormatter.timeZone = TimeZone(abbreviation: "UTC")
        var startOfMonth : Date?
        startOfMonth =  Date(dateString: dateStringFormatter.string(from: self))
        
        let calendar = Calendar.current
        
        let startOfOverMonth = (calendar as NSCalendar).date(byAdding: .month, value: 2, to: startOfMonth!, options: NSCalendar.Options(rawValue: 0))!
        let endOfNextMonth = (calendar as NSCalendar).date(byAdding: .second, value: -1, to: startOfOverMonth, options: NSCalendar.Options(rawValue: 0))!
        return endOfNextMonth
    }
    
    /** Wrapper function to create a date based on a year, month and day */
    static func from(year: Int?, month: Int?, day: Int?)->Date{
        // Setting paramters to component
        var dateComponents = DateComponents()
        dateComponents.year = year
        dateComponents.month = month
        dateComponents.day = day
        
        // Create date from components
        let userCalendar = NSCalendar.current
        let someDateTime = userCalendar.date(from: dateComponents)
        // Return Date
        return someDateTime! as Date
    }
}
