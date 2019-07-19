//
//  PairsDataProtocol.swift
//  Anyway
//
//  Created by Aviel Gross on 1/18/16.
//  Copyright © 2016 Hasadna. All rights reserved.
//

import Foundation

typealias Title = String
typealias Detail = String

protocol PairsData {}
extension PairsData {
    
    static func pair(forType type: Localization, value: Int) -> (Title, Detail)? {
        
        let rawType = "\(type)"
        let title = local(rawType)
        
        // if there is no localized value we get
        // the key - so we check we got a value
        // that is different from the key...
        guard title != rawType else { return nil }
        
        // trying to get the specific value for
        // the number of 'value'.
        guard let
            result = type[value], result.isEmpty == false
            else { return nil }
        
        // tuple of the field title and it's value
        return (title, result)
    }
}
