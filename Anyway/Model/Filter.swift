//
//  Filter.swift
//  Anyway
//
//  Created by Aviel Gross on 14/12/2015.
//  Copyright © 2015 Hasadna. All rights reserved.
//

import Foundation

struct IntersectionType {
    var showIn: Bool
    var showNot: Bool
    
    fileprivate var showInCurrentVal: Int { return showIn ? 2 : 0 }
    fileprivate var showNotCurrentVal: Int { return showNot ? 1 : 0 }
    var value: Int { return showInCurrentVal + showNotCurrentVal }
}

struct LaneType {
    var oneWay: Bool
    var bothWays: Bool
    
    fileprivate var bothWaysCurrentVal: Int { return bothWays ? 2 : 0 }
    fileprivate var oneWayCurrentVal: Int { return oneWay ? 1 : 0 }
    var value: Int { return bothWaysCurrentVal + oneWayCurrentVal }
}

struct UrbanType {
    var urban: Bool
    var nonUrban: Bool
    
    fileprivate var urbanCurrentVal: Int { return urban ? 2 : 0 }
    fileprivate var nonUrbanCurrentVal: Int { return nonUrban ? 1 : 0 }
    var value: Int { return urbanCurrentVal + nonUrbanCurrentVal }
}

enum WeekdayType: Int {
    case sun, mon, tue, wed, thu, fri, sat, all
    var localized: String {
        return ["sun", "mon", "tue", "wed", "thu", "fri", "sat"]
            .map{ local("FILTER_weekday_\($0)") }[rawValue]
    }
}

enum HolidayType: Int {
    case all, holiday, holiEve, holiWeekday, weekday
    var localized: String {
        return ["0", "1", "2", "3", "4"]
            .map{ local("SUG_YOM_\($0)") }[rawValue]
    }
}

enum DayTimeType: Int {
    case all = 24, light = 25, dark = 26, morning = 6, noon = 12, evening = 18, night = 0
    var localized: String {
        return local("FILTER_time_\("\(self)".lowercased())")
    }
}

enum WeatherType: Int {
    case all, clear, rainy, torrid, cloudy, other
    var localized: String {
        return local("FILTER_weather_\(rawValue)")
    }
    var symbol: String {
        return [WeatherType.all.localized, "☀️", "☔️", "🔥🌡", "☁️", WeatherType.other.localized][rawValue]
    }
}

public struct Filter {
    var startDate = Date(timeIntervalSince1970: 1356991200) { didSet{ valueChanged() } } // Default: Jan 1st 2013
    var endDate = Date() { didSet{ valueChanged() } }  // Default: Now
   
    var showFatal = true { didSet{ valueChanged() } }
    var showSevere = true { didSet{ valueChanged() } }
    var showLight = true { didSet{ valueChanged() } }
    var showInaccurate = false { didSet{ valueChanged() } }
    var showAccurate = true { didSet{ valueChanged() } }
    
    var showUrban = UrbanType(urban: true, nonUrban: true) { didSet { valueChanged() } }
    var showIntersection = IntersectionType(showIn: true, showNot: true) { didSet { valueChanged() } }
    var showLane = LaneType(oneWay: true, bothWays: true) { didSet { valueChanged() } }
    var weekday = WeekdayType.all { didSet{ valueChanged() } }
    var holiday = HolidayType.all { didSet{ valueChanged() } }
    var dayTime = DayTimeType.all { didSet{ valueChanged() } }
    var weather = WeatherType.all { didSet{ valueChanged() } }
    
    var description: String {
        let valsAndNames = [
            "Fatal": showFatal,
            "Severe": showSevere,
            "Light": showLight,
            "Inaccurate": showInaccurate,
            "Accurate": showAccurate,
            "Urban" : showUrban.value,
            "Intersection" : showIntersection.value,
            "Lane" : showLane.value,
            "Weekday" : weekday.rawValue,
            "Holiday" : holiday.rawValue,
            "Day Time" : dayTime.rawValue,
            "Weather" : weather.rawValue
        ] as [String : Any]
        let pref = "_______[ Filter Details ]_______\n"
        let suff = "\n________________________________\n"
        let time = "\(startDate.shortDate) ... \(endDate.shortDate)"
        return valsAndNames.reduce(pref + time) { return "\($0) | \($1.0): \($1.1)" } + suff
    }
    
    var onChange: ()->() = {}
    func valueChanged() { print("filter changed"); onChange() }
}
