//
//  FilterCellTableViewCell.swift
//  Anyway
//
//  Created by Aviel Gross on 3/30/15.
//  Copyright (c) 2015 Hasadna. All rights reserved.
//

import UIKit

protocol FilterCellDelegate {
    func filterSwitchChanged(_ to: Bool, filterType: FilterCellTableViewCell.FilterType)
}

class FilterCellTableViewCell: UITableViewCell {

    enum FilterType: Int {
        case startDate = 0, endDate // Date pickers
        case showFatal, showSevere, showLight, showInaccurate, showAccurate // Switches
    }
    
    var filterType: FilterType?
    weak var filter: Filter? { didSet{ updateCellUI() } }
    
    @IBOutlet weak var btnSwitch: UISwitch! { didSet{ updateCellUI() } }
    @IBOutlet weak var titleLabel: UILabel! { didSet{ updateCellUI() } }
    @IBOutlet weak var detailLabel: UILabel! { didSet{ updateCellUI() } }
    
    var filterCellLabel: String? {
        if let type = filterType {
            switch type {
            case .startDate: return "תאריך התחלה"
            case .endDate: return "תאריך סיום"
            case .showFatal: return "הצג תאונות קטלניות"
            case .showSevere: return "הצג פגיעות בינוניות"
            case .showLight: return "הצג פגיעות קלות"
            case .showInaccurate: return "הצג עיגון מרחבי"
            case .showAccurate: return "הצג עיגון מדויק"
            }
        }
        return nil
    }
    
    @IBAction func switchValueChanged(_ sender: UISwitch) {
        if let type = filterType {
            switch type {
            case .showFatal: filter?.showFatal = btnSwitch.isOn
            case .showSevere: filter?.showSevere = btnSwitch.isOn
            case .showLight: filter?.showLight = btnSwitch.isOn
            case .showInaccurate: filter?.showInaccurate = btnSwitch.isOn
            case .showAccurate: filter?.showAccurate = btnSwitch.isOn
            default: break
            }
        }
    }
    
    
    func updateCellUI() {
        //Labels
        titleLabel?.text = filterCellLabel
        
        //Filter
        if let type = filterType, let fil = filter {
            switch type {
            case .startDate: detailLabel?.text = dateLabel(fil.startDate as Date)
            case .endDate: detailLabel?.text = dateLabel(fil.endDate as Date)
            case .showFatal: btnSwitch?.isOn = fil.showFatal
            case .showSevere: btnSwitch?.isOn = fil.showSevere
            case .showLight: btnSwitch?.isOn = fil.showLight
            case .showInaccurate: btnSwitch?.isOn = fil.showInaccurate
            case .showAccurate: btnSwitch?.isOn = fil.showAccurate
            }
        }
    }
    
    func dateLabel(_ fromDate: Date?) -> String {
        if let date = fromDate {
            let formatter = DateFormatter()
            formatter.locale = Locale.current
            formatter.timeStyle = DateFormatter.Style.none
            formatter.dateStyle = DateFormatter.Style.medium
            return formatter.string(from: date)
        }
        return "בחר תאריך"
    }
    
}
