//
//  ViewInput.swift
//  Anyway
//
//  Created by Yigal Omer on 29/08/2019.
//  Copyright © 2019 Hasadna. All rights reserved.
//

import UIKit

protocol ViewInput: class {

    func setupView()

    func showAlert(_ alert: UIAlertController, animated: Bool)

}
