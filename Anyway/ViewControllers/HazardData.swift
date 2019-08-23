//
//  HazardData.swift
//  Anyway
//
//  Created by Yigal Omer on 22/08/2019.
//  Copyright © 2019 Hasadna. All rights reserved.
//

//import SwiftUI



struct HazardData : Codable { //}, Identifiable {
  var id: Int
  var hazardDescription: String
  //var lastName: String
  var imageName: String
}

struct Storage {
  static var hazards: [HazardData] = load("hazards.json")

  static func load<T: Decodable>(_ file: String) -> T {
    guard let url = Bundle.main.url(forResource: file, withExtension: nil),
          let data = try? Data(contentsOf: url),
          let typedData = try? JSONDecoder().decode(T.self, from: data) else {
      fatalError("Error while loading data from file: \(file)")
    }
    return typedData;
  }
}
