//
//  DetailCells.swift
//  Anyway
//
//  Created by Aviel Gross on 23/11/2015.
//  Copyright © 2015 Hasadna. All rights reserved.
//

import Foundation

protocol MarkerPresenter {
    var marker: Marker? { get set }
    func setInfo(_ marker: Marker?)
}

class DetailCell: UITableViewCell, MarkerPresenter {
    
    var marker: Marker?
    var vehicles = [Vehicle]()
    var persons = [Person]()
    
    var indexPath: IndexPath?
    
    func setInfo(_ marker: Marker?) {
        assertionFailure("Should be implemented by subclass!")
    }
}


//MARK: Specific

protocol WebPresentationDelegate: class {
    func shouldPresent(_ address: String)
}

class DetailCellTop: DetailCell {
    static let dequeueId = "DetailCellTop"
    
    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var labelSource: UILabel!
    
    @IBOutlet weak var buttonSource: UIButton!
    
    /// Presents accident's date
    @IBOutlet weak var labelFooter: UILabel!
    
    weak var webDelegate: WebPresentationDelegate?
    
    override func setInfo(_ marker: Marker?) {
        guard let _ = indexPath else {return}
        // If marker is nil all labels will be nil -> clears any former label from cell dequeue...
        
        // Provider init can fail > button title will simply be nil...
        buttonSource.setTitle(Provider(marker?.provider_code ?? -1)?.name, for: UIControl.State())
        
        labelFooter.text = marker.map{"\($0.created.longDate), \($0.created.shortTime)"} ?? ""
        
        //TODO: Change to the same nice title as in website.... (take algorithm from the website??)
        labelTitle.text = marker?.title
    }
    
    @IBAction func actionSource() {
        guard let m = marker, let p = Provider(m.provider_code) else {return}
        webDelegate?.shouldPresent(p.url)
    }
    
}

class DetailCellHeader: DetailCell {
    static let dequeueId = "DetailCellHeader"
    
    @IBOutlet weak var imageIcon: UIImageView!
    @IBOutlet weak var labelTitle: UILabel!
    
    override func setInfo(_ marker: Marker?) {
        guard let path = indexPath else {return}
        
        let header = StaticData.header(forSection: path.section)
        
        imageIcon.image = header?.image
        labelTitle.text = header?.name
    }
}

class DetailCellInfo: DetailCell {
    static let dequeueId = "DetailCellInfo"
    
    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var labelInfo: UILabel!
    
    override func setInfo(_ marker: Marker?) {
        guard let path = indexPath else {return}
        
        // get title and row type for this marker at this index path
        let (title, rowType) = StaticData.title(marker, atIndex: path, persons: persons, vehicles: vehicles)
        
        // set the title
        labelTitle.text = title
        
        // make inter-titles a stand out a bit
        switch rowType {
        case .intermediateTitle: self.contentView.alpha = 1
        case .info: self.contentView.alpha = 0.6
        }
        
        // set the info itself
        labelInfo.text = StaticData.info(marker, atIndex: path, persons: persons, vehicles: vehicles)
    }
    
}


private struct StaticData {
    
    struct Header {
        let name: String
        let image: UIImage
    }
    
    static func header(forSection section: Int) -> Header? {
        let name: String, imageName: String
        switch section {
        case 1: name = local("DETAILS_HEADER_details");         imageName = "detail_warning"
        case 2: name = local("DETAILS_HEADER_road");            imageName = "detail_road"
        case 3: name = local("DETAILS_HEADER_time_location");   imageName = "detail_marker"
        case 4: name = local("DETAILS_HEADER_people");          imageName = "detail_pessanger"
        case 5: name = local("DETAILS_HEADER_cars");            imageName = "detail_car"
        case 6: name = local("DETAILS_HEADER_more_info");       imageName = "detail_plus"
        default: return nil
        }
        return Header(name: name, image: UIImage(named: imageName)!)
    }
    
    enum InfoRowType {
        case info, intermediateTitle
    }
    
    static func title(_ marker: Marker?, atIndex indexPath: IndexPath, persons: [Person], vehicles: [Vehicle]) -> (String, InfoRowType) {
        switch (indexPath.section, indexPath.row) {
            case (1, 1): return (local("ACC_ID"), .info)
            case (1, 2): return (local("PROVIDER_CODE"), .info)
            case (1, 3): return (local("HUMRAT_TEUNA"), .info)
            case (1, 4): return (local("SUG_TEUNA"), .info)
            
            case (2, let i): return (marker?.roadConditionData.safeRetrieveElement(i)?.0 ?? "", .info)
            
            case (3, 1): return (local("TAARICH"), .info)
            case (3, 2): return (local("SUG_YOM"), .info)
            case (3, 3): return ("", .info) // address (no title on website design)
            
            case (4, let i): return fieldName(i, rawInfos: persons)
            case (5, let i): return fieldName(i, rawInfos: vehicles)
            
            case (6, 1): return (local("STATUS_IGUN"), .info)
            case (6, 2): return (local("YEHIDA"), .info)

            default: return ("", .info)
        }
    }
    
    static func fieldName<T: RawInfo>(_ row: Int, rawInfos: [T]) -> (String, InfoRowType) {
        guard let
            info = infoData(row, rawInfos: rawInfos),
            let titleKey = rawInfos.first?.innerTitleKey
            else { return ("UNKNOWN FIELD", .info) }
        
        
        if info.0 == local(titleKey) {
            return (info.0, .intermediateTitle)
        }
        return (info.0, .info)
    }
    
    static func fieldValue<T: RawInfo>(_ row: Int, rawInfos: [T]) -> String {
        guard let
            info = infoData(row, rawInfos: rawInfos)
        else { return "UNKNOWN FIELD" }
        
        return info.1
    }
    
    static func infoData<T: RawInfo>(_ row: Int, rawInfos: [T]) -> (String, String)? {
        
        // row 0 is the "header" cell, so we begin from 1 instead 0...
        assert(row-1 >= 0, "row must never be less than zero here")
        
        let infos = rawInfos.flatMap{ $0.info }
        return infos.safeRetrieveElement(row-1)
        
    }
    
    static func info(_ marker: Marker?, atIndex indexPath: IndexPath, persons: [Person], vehicles: [Vehicle]) -> String {
        guard let data = marker else {return ""}
        
        switch (indexPath.section, indexPath.row) {
            
        case (1, 1): return "\(data.id)"
        case (1, 2): return "\(data.provider_code)"
        case (1, 3): return data.localizedSeverity
        case (1, 4): return data.localizedSubtype
            
        case (2, let i): return marker?.roadConditionData.safeRetrieveElement(i)?.1 ?? ""
            
        case (3, 1): return "\(data.created.longDate), \(data.created.shortTime)"
        case (3, 2): return Localization.sug_YOM[data.dayType] ?? ""
        case (3, 3): return data.address
            
        case (4, let i): return fieldValue(i, rawInfos: persons)
        case (5, let i): return fieldValue(i, rawInfos: vehicles)
            
        case (6, 1): return Localization.status_IGUN[data.intactness] ?? "" //TODO: is right param?
        case (6, 2): return Localization.yehida[data.unit] ?? ""

        default: return ""
        }
    }
    
}
