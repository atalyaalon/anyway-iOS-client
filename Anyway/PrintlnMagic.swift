//
//  PrintlnMagic.swift
//
//  Created by Arthur Sabintsev on 1/28/15.
//  Copyright (c) 2015 Arthur Ariel Sabintsev. All rights reserved.
//

import Foundation

/**
    Overrides Swift's default println() implementation.

    As with the original println() function, this function writes the textual representation of `object` into the standard output.
    It augments the original function with the filename, function name, and line number of the object that is being logged.
*/
public func println<T>(_ object: T, _ file: String = #file, function: String = #function, _ line: Int = #line)
{
    let filename = (file as NSString).lastPathComponent.replacingOccurrences(of: ".swift", with: "")
    print("\(filename).\(function)[\(line)]: \(object)\n", terminator: "")
}
