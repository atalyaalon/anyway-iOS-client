//
//  SelectHazardCollectionCellCollectionViewCell.swift
//  Anyway
//
//  Created by Yigal Omer on 22/08/2019.
//  Copyright © 2019 Hasadna. All rights reserved.
//

import UIKit

class HazardCollectionViewCell: UICollectionViewCell {

    private var descriptionLabel: UILabel!
    public var imageView: UIImageView!

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setup()
    }

    var descriptionText: String = "" {
        didSet {
            self.descriptionLabel.text = self.descriptionText
        }
    }

    // MARK: - Private
    private func setup() {
        self.setupLabel()
        self.setupImage()
        self.setNeedsUpdateConstraints()
    }

    private func setupImage() {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        view.contentMode = .scaleAspectFit
        view.clipsToBounds = true
        self.contentView.addSubview(view)
        self.imageView = view

        //view.f8.pinEdgesToSuperviewEdges(insets: UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5))
    }

    private func setupLabel() {
        let view = UILabel()
        //view.backgroundColor = #colorLiteral(red: 0.9467939734, green: 0.9468161464, blue: 0.9468042254, alpha: 1)
        view.layer.borderColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1).cgColor
        view.layer.borderWidth = 1
        //view.alpha = 0
        view.layer.cornerRadius = 3.0
        view.layer.borderWidth = 1.0
        view.layer.borderColor = UIColor.black.cgColor
        view.font = UIFont.systemFont(ofSize: 10)
        view.textAlignment = .center
        self.contentView.addSubview(view)
        self.descriptionLabel = view
    }

    override func updateConstraints() {

        imageView.snp.remakeConstraints { (make) in
            //make.top.lessThanOrEqualToSuperview().offset(15)
            //make.bottom.greaterThanOrEqualToSuperview().offset(-15)
            make.top.equalToSuperview().offset(2)
            make.leading.equalToSuperview().offset(5)
            //make.height.equalTo(60)
            //make.width.equalTo(60)
            make.trailing.equalToSuperview().offset(-5)
        }

        descriptionLabel.snp.remakeConstraints { (make) in
            make.leading.equalToSuperview().offset(5)
            make.trailing.equalToSuperview().offset(-5)
            make.top.equalTo(self.imageView.snp.bottom).offset(5)
            make.bottom.equalToSuperview().offset(-5)
            make.height.equalTo(20)
        }

        super.updateConstraints()
    }
}
