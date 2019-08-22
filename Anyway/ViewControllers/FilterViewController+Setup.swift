//
//  FilterViewController+Setup.swift
//  Anyway
//
//  Created by Aviel Gross on 2/1/16.
//  Copyright © 2016 Hasadna. All rights reserved.
//

import Foundation
import Eureka


/**
 We build the filter screen using the open source
 library "Eureka!". It uses some Domain-Specific Language
 to setup to filter. The setup flow basically build a "form"
 that is presented in a UITableView.
 
 Read more here: https://github.com/xmartlabs/Eureka
*/
extension FilterViewController {
    
    /**
     Should be called from 'viewDidLoad()'
     to build the form.
     */
    internal func setupForm(_ filter: Filter) {

        form += [datesSection(), weekdaySection(), conditionsSection(),
            severitySection(), accuracySection(), roadTypeSection()]
    }
    
    
    
    fileprivate func datesSection() -> Section {
            
        return Section(local("FILTER_SECTION_date_range"))
        
        <<< DateInlineRow() {
            $0.title = local("FILTER_ROW_date_start")
            $0.value = filter.startDate
        }.onChange{ [weak self] row in
            guard let d = row.value else {return}
            self?.filter.startDate = d
        }
        
        <<< DateInlineRow() {
            $0.title = local("FILTER_ROW_date_end")
            $0.value = filter.endDate
        }.onChange{ [weak self] row in
            guard let d = row.value else {return}
            self?.filter.endDate = d
        }
    }
    
    fileprivate func severitySection() -> Section {
        
        return Section(local("FILTER_SECTION_severity"))
            
        <<< CheckRow() {
            $0.title = local("FILTER_ROW_fatal")
            $0.value = filter.showFatal
        }.cellUpdate { cell, row in
                cell.textLabel?.textColor = AnywayColor.red
        }.onChange{ [weak self] row in
                guard let v = row.value else {return}
                self?.filter.showFatal = v
        }
        
        <<< CheckRow() {
            $0.title = local("FILTER_ROW_severe")
            $0.value = filter.showSevere
        }.cellUpdate { cell, row in
                cell.textLabel?.textColor = AnywayColor.orange
        }.onChange{ [weak self] row in
                guard let v = row.value else {return}
                self?.filter.showSevere = v
        }
            
        <<< CheckRow() {
            $0.title = local("FILTER_ROW_light")
            $0.value = filter.showLight
        }.cellUpdate { cell, row in
                cell.textLabel?.textColor = AnywayColor.yellow
        }.onChange{ [weak self] row in
                guard let v = row.value else {return}
                self?.filter.showLight = v
        }
    }
    
    fileprivate func accuracySection() -> Section {
        
        return Section(local("FILTER_SECTION_anchoring"))
            
        <<< CheckRow() {
            $0.title = local("FILTER_ROW_accurate")
            $0.value = filter.showAccurate
        }.onChange{ [weak self] row in
            guard let v = row.value else {return}
            self?.filter.showAccurate = v
        }
        
        <<< CheckRow() {
            $0.title = local("FILTER_ROW_inaccurate")
            $0.value = filter.showInaccurate
        }.onChange{ [weak self] row in
            guard let v = row.value else {return}
            self?.filter.showInaccurate = v
        }
        
    }
    
    fileprivate func roadTypeSection() -> Section {
        
        return Section(local("FILTER_SECTION_road_type"))
            
        <<< CheckRow() {
            $0.title = local("FILTER_ROW_road_junction")
            $0.value = filter.showIntersection.showIn
        }.onChange{ [weak self] row in
            guard let v = row.value else {return}
            self?.filter.showIntersection.showIn = v
        }
        
        <<< CheckRow() {
            $0.title = local("FILTER_ROW_road_not_junction")
            $0.value = filter.showIntersection.showNot
        }.onChange{ [weak self] row in
            guard let v = row.value else {return}
            self?.filter.showIntersection.showNot = v
        }
        
        <<< CheckRow() {
            $0.title = local("FILTER_ROW_road_one_way")
            $0.value = filter.showLane.oneWay
        }.onChange{ [weak self] row in
            guard let v = row.value else {return}
            self?.filter.showLane.oneWay = v
        }
        
        <<< CheckRow() {
            $0.title = local("FILTER_ROW_road_both_ways")
            $0.value = filter.showLane.bothWays
        }.onChange{ [weak self] row in
            guard let v = row.value else {return}
            self?.filter.showLane.bothWays = v
        }
        
        <<< CheckRow() {
            $0.title = local("FILTER_ROW_road_urban")
            $0.value = filter.showUrban.urban
        }.onChange{ [weak self] row in
            guard let v = row.value else {return}
            self?.filter.showUrban.urban = v
        }
        
        <<< CheckRow() {
            $0.title = local("FILTER_ROW_road_not_urban")
            $0.value = filter.showUrban.nonUrban
        }.onChange{ [weak self] row in
            guard let v = row.value else {return}
            self?.filter.showUrban.nonUrban = v
        }
        
    }
    
    fileprivate func weekdaySection() -> Section {
        
        return Section(local("FILTER_SECTION_day"))
        
        <<< SwitchRow("weekday_all") {
            $0.title = local("FILTER_weekday_all")
            $0.value = filter.weekday == .all
        }.onChange{ [weak self] row in
            guard let v = row.value else {return}
            self?.filter.weekday = v == true ? .all : WeekdayType.sun
        }
            
        <<< SegmentedRow<WeekdayType>() {
            $0.options = [.sun, .mon, .tue, .wed, .thu, .fri, .sat]
            $0.value = filter.weekday == .all ? .sun : filter.weekday
            $0.hidden = "$weekday_all == true"
            $0.displayValueFor = { v in return (v ?? WeekdayType.sun).localized }
        }.onChange{ [weak self] row in
            guard let v = row.value else {return}
            self?.filter.weekday = v
        }
        
        
        <<< ActionSheetRow<HolidayType>() {
            $0.title = local("SUG_YOM")
            $0.options = [.all, .holiday, .holiEve, .holiWeekday, .weekday]
            $0.value = filter.holiday
            $0.displayValueFor = { v in return (v ?? HolidayType.all).localized }
        }.onChange{ [weak self] row in
            guard let v = row.value else {return}
            self?.filter.holiday = v
        }
        
        
        <<< ActionSheetRow<DayTimeType>() {
            $0.title = local("FILTER_ROW_day_time")
            $0.options = [.all, .light, .dark, .morning, .noon, .evening, .night]
            $0.value = filter.dayTime
            $0.displayValueFor = { v in return (v ?? DayTimeType.all).localized }
        }.onChange{ [weak self] row in
            guard let v = row.value else {return}
            self?.filter.dayTime = v
        }
        
    }
    
    fileprivate func conditionsSection() -> Section {
        
        return Section(local("FILTER_SECTION_conditions"))
        
        <<< SegmentedRow<WeatherType>() {
            $0.options = [.all, .clear, .rainy, .torrid, .cloudy, .other]
            $0.value = filter.weather
            $0.displayValueFor = { v in return (v ?? WeatherType.all).symbol }
        }.onChange{ [weak self] row in
            guard let v = row.value else {return}
            self?.filter.weather = v
        }

    }
    
    
}

