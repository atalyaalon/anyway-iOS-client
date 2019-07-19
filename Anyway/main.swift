//
//  main.swift
//  Anyway
//
//  Created by Aviel Gross on 1/25/16.
//  Copyright © 2016 Hasadna. All rights reserved.
//

import Foundation

autoreleasepool {
    
    ManualLocalizationWorker.overrideCurrentLocal()
    
    
    UIApplicationMain(
        CommandLine.argc,
        UnsafeMutableRawPointer(CommandLine.unsafeArgv)
            .bindMemory(
                to: UnsafeMutablePointer<Int8>.self,
                capacity: Int(CommandLine.argc)),
        nil,
        NSStringFromClass(AppDelegate.self)
    )
}
