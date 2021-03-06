//
//  SelectHazardCollectionCellCollectionViewCell.swift
//  Anyway
//
//  Created by Yigal Omer on 22/08/2019.
//  Copyright © 2019 Hasadna. All rights reserved.
//

import UIKit

class HazardCollectionViewCell: UICollectionViewCell {

    public var desc: UILabel!
    public var image: UIImageView!


    override init(frame: CGRect) {
        super.init(frame: frame)

        self.setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        self.setup()
    }

    var otherLabelTitle: String = "" {
        didSet {
            self.desc.text = self.otherLabelTitle
        }
    }

    // MARK: - Public

    //    public func setSelected(isSelected: Bool) {
    //        UIView.animate(withDuration: 0.2) {
    //            self.selectionView.alpha = isSelected ? 1 : 0
    //        }
    //    }

    // MARK: - Private

    private func setup() {
        self.setupLabel()
        self.setupImage()
    }

    private func setupImage() {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        view.contentMode = .scaleAspectFit
        view.clipsToBounds = true

        self.contentView.addSubview(view)
        self.image = view

        //view.f8.pinEdgesToSuperviewEdges(insets: UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5))
    }

    private func setupLabel() {
        let view = UILabel()
        view.backgroundColor = #colorLiteral(red: 0.9467939734, green: 0.9468161464, blue: 0.9468042254, alpha: 1)
        view.layer.borderColor = #colorLiteral(red: 0.06666666667, green: 0.5647058824, blue: 0.9803921569, alpha: 1).cgColor
        view.layer.borderWidth = 1
        //view.alpha = 0

        self.desc = view
    }

    override func updateConstraints() {

        image.snp.remakeConstraints { (make) in
            make.top.lessThanOrEqualToSuperview().offset(15)
            make.bottom.greaterThanOrEqualToSuperview().offset(-15)
            make.leading.equalToSuperview().offset(5)
            make.trailing.equalToSuperview().offset(-5)
        }

        desc.snp.remakeConstraints { (make) in
            make.leading.equalToSuperview().offset(5)
            make.trailing.equalToSuperview().offset(-5)
            make.bottom.equalTo(self.image)
            //make.height.equalTo(self.separatorHeight)
        }

        super.updateConstraints()
    }

    // MARK: - BindableView
//    typealias BindableType = ChugCategory
//    func bind(object: BindableType) {
//        self.categoryIcon.image = UIImage(named: object.iconName)
//    }
}
