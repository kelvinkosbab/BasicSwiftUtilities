//
//  File.swift
//  
//  Copyright © 2021 Kozinga. All rights reserved.
//

import Foundation

public extension Date {
    
    var daysSince1970: Int {
        return Int(self.timeIntervalSince1970 / 60 / 60 / 24)
    }
    
    var year: Int {
        return Calendar.current.component(.year, from: self)
    }
    
    var month: Int {
        return Calendar.current.component(.month, from: self)
    }
    
    var day: Int {
        return Calendar.current.component(.day, from: self)
    }
    
    var hour: Int {
        return Calendar.current.component(.hour, from: self)
    }
    
    var minute: Int {
        return Calendar.current.component(.minute, from: self)
    }
    
    var second: Int {
        return Calendar.current.component(.second, from: self)
    }
    
    var uniqueId: Int {
        return Int(self.timeIntervalSince1970)
    }
    
    var isToday: Bool {
        return Calendar.current.isDateInToday(self)
    }
    
    var isYesterday: Bool {
        return Calendar.current.isDateInYesterday(self)
    }
    
    var isTomorrow: Bool {
        return Calendar.current.isDateInTomorrow(self)
    }
    
    var isWeekend: Bool {
        return Calendar.current.isDateInWeekend(self)
    }
    
    var noon: Date? {
        return self.set(hour: 12, minute: 0, second: 0)
    }
    
    func set(hour: Int, minute: Int, second: Int) -> Date? {
        return Calendar.current.date(bySettingHour: hour, minute: minute, second: second, of: self)
    }
    
    // MARK: - Comparison
    
    func compareIsGreater(thanDate date: Date) -> Bool {
        return self.compare(date) == .orderedDescending
    }
    
    func compareIsLess(thanDate date: Date) -> Bool {
        return self.compare(date) == .orderedAscending
    }
    
    func compareIsEqual(toDate date: Date) -> Bool {
        return self.compare(date) == .orderedSame
    }
    
    // MARK: - Adding Intervals
    
    func add(years value: Int) -> Date? {
        return Calendar.current.date(byAdding: .year, value: value, to: self)
    }
    
    func add(months value: Int) -> Date? {
        return Calendar.current.date(byAdding: .month, value: value, to: self)
    }
    
    func add(weeks value: Int) -> Date? {
        return Calendar.current.date(byAdding: .weekOfYear, value: value, to: self)
    }
    
    func add(days value: Int) -> Date? {
        return Calendar.current.date(byAdding: .day, value: value, to: self)
    }
    
    func add(hours value: Int) -> Date? {
        return Calendar.current.date(byAdding: .hour, value: value, to: self)
    }
    
    func add(minutes value: Int) -> Date? {
        return Calendar.current.date(byAdding: .minute, value: value, to: self)
    }
    
    func add(seconds value: Int) -> Date? {
        return Calendar.current.date(byAdding: .second, value: value, to: self)
    }
    
    func add(nanoseconds value: Int) -> Date? {
        return Calendar.current.date(byAdding: .nanosecond, value: value, to: self)
    }
    
    func add(timeInterval: Double) -> Date {
        return self.addingTimeInterval(timeInterval)
    }
    
    // MARK: - Duration
    
    func years(fromDate date: Date) -> Int {
        return Calendar.current.dateComponents([ .year ], from: date, to: self).year!
    }
    
    func months(fromDate date: Date) -> Int {
        return Calendar.current.dateComponents([ .month ], from: date, to: self).month!
    }
    
    func weeks(fromDate date: Date) -> Int {
        return Calendar.current.dateComponents([ .weekOfYear ], from: date, to: self).weekOfYear!
    }
    
    func days(fromDate date: Date) -> Int {
        return Calendar.current.dateComponents([ .day ], from: date, to: self).day!
    }
    
    func hours(fromDate date: Date) -> Int {
        return Calendar.current.dateComponents([ .hour ], from: date, to: self).hour!
    }
    
    func minutes(fromDate date: Date) -> Int {
        return Calendar.current.dateComponents([ .minute ], from: date, to: self).minute!
    }
    
    func seconds(fromDate date: Date) -> Double {
        return self.timeIntervalSince(date)
    }
    
    func nanoseconds(fromDate date: Date) -> Int {
        return Calendar.current.dateComponents([ .nanosecond ], from: date, to: self).nanosecond!
    }
    
    // MARK: - Static Helpers
    
    func yearsBetween(fromDate: Date, toDate: Date) -> Int {
        return toDate.years(fromDate: fromDate)
    }
    
    func monthsBetween(fromDate: Date, toDate: Date) -> Int {
        return toDate.months(fromDate: fromDate)
    }
    
    func weeksBetween(fromDate: Date, toDate: Date) -> Int {
        return toDate.weeks(fromDate: fromDate)
    }
    
    func daysBetween(fromDate: Date, toDate: Date) -> Int {
        return toDate.days(fromDate: fromDate)
    }
    
    func hoursBetweenDates(_ fromDate: Date, toDate: Date) -> Int {
        return toDate.hours(fromDate: fromDate)
    }
    
    func minutesBetweenDates(_ fromDate: Date, toDate: Date) -> Int {
        return toDate.minutes(fromDate: fromDate)
    }
    
    func secondsBetweenDates(_ fromDate: Date, toDate: Date) -> Double {
        return toDate.seconds(fromDate: fromDate)
    }
    
    func nanosecondsBetweenDates(_ fromDate: Date, toDate: Date) -> Int {
        return toDate.nanoseconds(fromDate: fromDate)
    }
    
    // MARK: - Date String Formats
    
    var simpleTimeString: String {
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = .short
        dateFormatter.dateStyle = .none
        return dateFormatter.string(from: self)
    }
    
    var complexDateTimeString: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        return dateFormatter.string(from: self)
    }
    
    // MARK: - String Formats
    
    var shortTimeString: String {
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = .short
        dateFormatter.dateStyle = .none
        return dateFormatter.string(from: self)
    }

    var mediumTimeString: String {
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = .medium
        dateFormatter.dateStyle = .none
        return dateFormatter.string(from: self)
    }
    
    var mediumDateString: String {
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = .none
        dateFormatter.dateStyle = .medium
        return dateFormatter.string(from: self)
    }
    
    var mediumDateTimeString: String {
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = .medium
        dateFormatter.dateStyle = .medium
        return dateFormatter.string(from: self)
    }
    
    var shortDateTimeString: String {
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = .short
        dateFormatter.dateStyle = .short
        return dateFormatter.string(from: self)
    }
    
    var upcomingMatchDateTimeString: String {
        // Day of week, month, day
        let dateMonthFormatter = DateFormatter()
        dateMonthFormatter.dateFormat = "E, MMM d"
        let dateMonthString = dateMonthFormatter.string(from: self)
        
        // Hour:minute am/pm
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "h:mm a"
        let timeString = timeFormatter.string(from: self)
        return String(format: NSLocalizedString("%@ at %@", comment: "{Thu, Jan 17} at {8:40 AM}"), dateMonthString, timeString)
    }
    
    var serverDateTimeString: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        return dateFormatter.string(from: self)
    }
    
    // MARK: - Parsing
    
    static func parse(dateString: String, in timeZone: TimeZone? = nil) -> Date? {
        // Time interval dates
        if let timeInterval = TimeInterval(dateString) {
            return Date(timeIntervalSinceReferenceDate: timeInterval)
        }
        
        // Formatted dates
        let formatter = DateFormatter()
        if let timeZone = timeZone {
            formatter.timeZone = timeZone
        }
        
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSSS"
        if let date = formatter.date(from: dateString) {
            return date
        }

        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSxxxxx"
        if let date = formatter.date(from: dateString) {
            return date
        }
        
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssxxxxx"
        if let date = formatter.date(from: dateString) {
            return date
        }
        
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        if let date = formatter.date(from: dateString) {
            return date
        }
        
        formatter.dateFormat = "EEE MMM dd yyyy HH:mm:ss zzzz"
        if let date = formatter.date(from: dateString) {
            return date
        } else if let date = formatter.date(from: dateString.replacingOccurrences(of: "GMT", with: "").replacingOccurrences(of: "(UTC)", with: "").trim) {
            return date
        }
        return nil
    }
}
