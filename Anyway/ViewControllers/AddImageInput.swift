//
//  AddImageInput.swift
//  Anyway
//
//  Created by Yigal Omer on 01/09/2019.
//  Copyright © 2019 Hasadna. All rights reserved.
//

import UIKit

protocol AddImageInput: ViewInput {
    
    func showImagPickerScreen(_ pickerController: UIImagePickerController, animated: Bool)

    func setSelectedImage(image: UIImage)
}
