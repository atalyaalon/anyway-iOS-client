//
//  Localization.swift
//  Anyway
//
//  Created by Aviel Gross on 16/11/2015.
//  Copyright © 2015 Hasadna. All rights reserved.
//

import Foundation

/**
 Builds and gets a localized string for an enum
 type using the enum's name and the raw value.
 
 Format is:
 ENUM_NAME + "_" + RAW_VALUE
 
 e.g.,:
 SUG_YOM_1
 HUMRAT_TEUNA_9
 etc.

 For this to work any string using this
 enum must follow the above format...
 */
enum Localization {
    
    // Road Conditions
    case sug_DERECH, yehida, sug_YOM, humrat_TEUNA, sug_TEUNA,
         zurat_DEREH, had_MASLUL, rav_MASLUL, mehirut_MUTERET,
         tkinut, rohav, simun_TIMRUR, teura, bakara, mezeg_AVIR,
         pne_KVISH, sug_EZEM, merhak_EZEM, lo_HAZA, ofen_HAZIYA,
         mekom_HAZIYA, kivun_HAZIYA, status_IGUN
    
    // Vehicle Description
    case matzav_REHEV, shiyuh_REHEV_LMS, sug_REHEV_LMS
    
    // Involved Person Description
    case sug_MEORAV, min, emzae_BETIHUT,
         humrat_PGIA, sug_NIFGA_LMS, peulat_NIFGA_LMS,
         pazua_USHPAZ, madad_RAFUI, yaad_SHIHRUR,
         shimush_BE_AVIZAREY_BETIHOT, ptira_MEUHERET
    
    
    subscript(val: Int) -> String? {
        let localKey = "\(self)_\(val)"
        let result = local(localKey)
        
        // when no localized string found, we get
        // back the code we sent to 'local()'.
        // When this happens - pass an empty string
        // to the caller.
        return result.hasPrefix("\(self)") ? "" : result
    }
    
}


/**
 The supported app locals
 'rawValue' is the code used to
 set the local key in user defaults.
 */
enum AppLocal: String {
    case English = "en_US", Hebrew = "he_IL"
}

/**
 *  The app's language (i.e., local) is determined on
 *  launch (specifically in when initializing UIKit for
 *  the app) from the string in Apple's set user defaults
 *  key ("AppleLanguages").
 *  The workaround is to set that key before the app launces
 *  (i.e., in the 'main.swift' of the app). There is a bug
 *  where sometimes the local is determined after launch, so
 *  we override it in AppDelegate as well, just in case.
 */
struct ManualLocalizationWorker {
    
    
    /// Default for fresh install, or when there isn't any value
    fileprivate static var defaultLocal: AppLocal {
        let phoneVar = (defaults.object(forKey: "AppleLanguages") as? [String])?
                        .flatMap{ AppLocal(rawValue: $0) }.first
        return phoneVar ?? AppLocal.English
    }
    
    /// The user preferenced local (saved in NSUserDefaults)
    fileprivate static let defaultsKey = "com.hasadna.anyway.AppLocal"
    static var defaults: UserDefaults { return UserDefaults.standard }
    static var currentLocal: AppLocal {
        get{
            guard let
                rawVal = defaults.string(forKey: defaultsKey),
                let local = AppLocal(rawValue: rawVal)
            else { return defaultLocal }
            return local
        }
        set{
            defaults.set(newValue.rawValue, forKey: defaultsKey)
            defaults.synchronize()
        }
    }
    
    /**
     Overrides the key for retreiving app local
     */
    static func overrideCurrentLocal() {
        let local = [currentLocal.rawValue]
        defaults.set(local, forKey: "AppleLanguages")
        defaults.synchronize()
    }
    
}



