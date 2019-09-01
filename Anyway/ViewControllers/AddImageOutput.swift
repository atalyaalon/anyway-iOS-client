//
//  AddImageOutput.swift
//  Anyway
//
//  Created by Yigal Omer on 01/09/2019.
//  Copyright © 2019 Hasadna. All rights reserved.
//

import UIKit

protocol AddImageOutput: ViewOutput {

    func closeImagePicker()

    func showSelectImageAlert(_ withSkip: Bool)

}
