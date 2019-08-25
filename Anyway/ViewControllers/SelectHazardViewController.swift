//
//  SelectHazardViewController.swift
//  Anyway
//
//  Created by Yigal Omer on 22/08/2019.
//  Copyright © 2019 Hasadna. All rights reserved.
//

import UIKit
import SnapKit


public protocol SelectHazardViewControllerDelegate: class {

    func didSelectHazard(selectedItems: Array<Any>?, hazardDescription: String?)
    func didCancel() 
}



class SelectHazardViewController: UIViewController  {

    private var collectionView: UICollectionView!
    private var rightBarButtonItem: UIBarButtonItem?
    private let reuseIdentifier = "cell"
    private var items: [HazardData] = HazardsStorage.hazards
    private var selectedItems = Set<IndexPath>()
    private var currentResponder: UIResponder?
    private var otherLabel: UILabel!
    private var hazardDescTextView: UITextView!
    private var customStackView : UIView!
    private let padding: CGFloat = 15
    private let backgroundColor: UIColor = UIColor.purple
    private var placeholderLabel : UILabel!
    public weak var delegate: SelectHazardViewControllerDelegate?


    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = false
        setupView()
    }

    //
    // MARK: Private
    //
    private func setupView() {
        customStackView = UIView()
        customStackView.backgroundColor = backgroundColor
        view.addSubview(customStackView)
        setupNavigationBar()
        setupCollectionView()
        setupOtherLabel()
        setupTextView()

        self.view.setNeedsUpdateConstraints()
        self.view.updateConstraintsIfNeeded()
    }
    private func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 1
        layout.minimumInteritemSpacing = 1

        let view = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        view.backgroundColor = backgroundColor
        customStackView.addSubview(view)
        self.collectionView = view
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        self.collectionView.register(HazardCollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        self.collectionView.reloadData()
    }

    private func setupOtherLabel() {
        let view: UILabel = UILabel()
        view.textColor = UIColor.f8BlackText
        view.font = UIFont.systemFont(ofSize: 19)
        view.textAlignment = .center
        view.text = "אחר"
        self.view.addSubview(view)
        self.otherLabel = view
    }

    private func setupTextView() {
        let view = UITextView()
        view.backgroundColor = .clear
        view.isEditable = true
        view.showsVerticalScrollIndicator = true
        view.font = UIFont.systemFont(ofSize: 14)
        //view.place = ""
        view.layer.cornerRadius = 4.0
        view.layer.borderWidth = 2.0
        view.layer.borderColor = UIColor.black.cgColor
        self.view.addSubview(view)
        self.hazardDescTextView = view
        self.hazardDescTextView.delegate = self

        placeholderLabel = UILabel()
        placeholderLabel.text = "תאר את פרטי המפגע"
        placeholderLabel.font = UIFont.italicSystemFont(ofSize: 14)
        placeholderLabel.sizeToFit()
        hazardDescTextView.addSubview(placeholderLabel)
        //placeholderLabel.frame.origin = CGPoint(x: 10, y: 10)
        placeholderLabel.textColor = UIColor.lightGray
        placeholderLabel.isHidden = !hazardDescTextView.text.isEmpty
    }

    private func setupNavigationBar() {
        self.rightBarButtonItem = UIBarButtonItem(title: "DONE".localized,
                                                  style: .done,
                                                  target: self,
                                                  action: #selector(doneBarButtonItemAction))
        self.navigationItem.setRightBarButton(self.rightBarButtonItem, animated: false)


        let leftBarButtonItem: UIBarButtonItem = UIBarButtonItem(title: "BACK".localized,
                                                  style: .done,
                                                  target: self,
                                                  action: #selector(onBackButtonClick))
        self.navigationItem.setLeftBarButton(leftBarButtonItem, animated: false)


        self.navigationItem.title = "פרטי המפגע"
        self.navigationItem.rightBarButtonItem?.isEnabled = false
        self.navigationController?.navigationBar.isTranslucent = false;
        self.navigationController?.navigationBar.barTintColor = backgroundColor
    }


    @objc func onBackButtonClick() {
        print("On back button click called. Am I on main thread? \(Thread.isMainThread)")
        if Thread.callStackSymbols.count > 2 {
            print("Who called me: \(Thread.callStackSymbols[2])")
        }
        delegate?.didCancel()
        //self.navigationController?.popViewController(animated: true)
    }

    // MARK: - Actions
    @objc func doneBarButtonItemAction() {
        self.currentResponder?.resignFirstResponder()

        var array: Array<HazardData>? = nil
        if self.selectedItems.count > 0 {
            array = Array<HazardData>()
            for indexPath in self.selectedItems {
                array?.append(self.items[indexPath.item])
            }
        }
        self.delegate?.didSelectHazard(selectedItems: array, hazardDescription: hazardDescTextView.text)
    }

    // MARK: - Actions
    @objc func backBarButtonItemAction(sender: UIButton) {
        self.currentResponder?.resignFirstResponder()
        delegate?.didCancel()
    }
    //
    // MARK: Layout
    //
    override func updateViewConstraints() {

        self.customStackView.snp.remakeConstraints({ (make: ConstraintMaker) in
            make.leading.equalToSuperview().offset(0)
            make.trailing.equalToSuperview().offset(0)
            make.top.equalToSuperview().offset(0)
            make.height.equalTo(400)
         })

        self.collectionView.snp.remakeConstraints({ (make: ConstraintMaker) in
            make.leading.equalToSuperview().offset(padding)
            //make.trailing.equalToSuperview().offset(padding)
            //make.top.equalToSuperview().offset(0)
            make.top.equalTo(padding)
            make.left.equalTo(padding)
            make.bottom.equalToSuperview()
            //make.bottom.equalTo(self.otherLabel.snp.top).offset(2)
        })

        self.otherLabel.snp.remakeConstraints({ (make: ConstraintMaker) in
            make.leading.equalToSuperview().offset(15)
            //make.trailing.equalToSuperview().offset(-15)
            //make.height.equalTo(100)
            make.top.equalTo(self.collectionView.snp.bottom).offset(10)
            make.bottom.equalTo(self.hazardDescTextView.snp.top).offset(-12)
        })

        self.hazardDescTextView.snp.remakeConstraints({ (make: ConstraintMaker) in
            make.leading.equalToSuperview().offset(15)
            make.trailing.equalToSuperview().offset(-15)
            //make.top.equalTo(self.otherLabel.snp.bottom).offset(30)
            make.bottom.equalToSuperview().offset(-170)
        })

        self.placeholderLabel.snp.remakeConstraints({ (make: ConstraintMaker) in
            //make.leading.equalToSuperview().offset(9)
            make.top.equalToSuperview().offset(9)
            make.trailing.equalToSuperview().offset(-220)
            //make.right.equalTo(9)
            //make.bottom.equalToSuperview().offset(0)
            //make.bottom.equalTo(self.textView.snp.top).offset(-12)
        })
        super.updateViewConstraints()
    }
}

// MARK: - UITextViewDelegate
extension SelectHazardViewController: UITextViewDelegate {

    private func textFieldDidBeginEditing(_ textField: UITextField) {
        self.currentResponder = textField
    }

    func textViewDidChange(_ textView: UITextView) {
        placeholderLabel.isHidden = !textView.text.isEmpty
        self.navigationItem.rightBarButtonItem?.isEnabled = !textView.text.isEmpty
    }
}

// MARK: - UICollectionViewDataSource
extension SelectHazardViewController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.items.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        // get a reference to our storyboard cell
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath as IndexPath) as! HazardCollectionViewCell

        // Use the outlet in our custom class to get a reference to the UILabel in the cell
        cell.descriptionText = self.items[indexPath.item].hazardDescription
        cell.backgroundColor = UIColor.white // make cell more visible in our example project
        cell.layer.borderColor = UIColor.black.cgColor
        cell.layer.borderWidth = 1
        cell.layer.cornerRadius = 5

        cell.layer.shadowColor = UIColor.black.cgColor
        cell.layer.shadowOffset = CGSize(width: 4.0, height: 2.0)
        cell.layer.shadowRadius = 5.0
        cell.layer.shadowOpacity = 0.5
        cell.layer.masksToBounds = false
        cell.layer.shadowPath = UIBezierPath(roundedRect: cell.bounds, cornerRadius: cell.contentView.layer.cornerRadius).cgPath

        let image = UIImage(named: self.items[indexPath.item].imageName)!
        //let image = #imageLiteral(resourceName: self.items[indexPath.item].imageName)
        //helpButton.setImage(#imageLiteral(resourceName: "information"), for: .normal)
        cell.imageView.image = image

        return cell
    }

}

// MARK: - UICollectionViewDelegate
extension SelectHazardViewController: UICollectionViewDelegate {

    // change background color when user touches cell
    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath){
        let cell = collectionView.cellForItem(at: indexPath)

        if selectedItems.contains(indexPath) {
            selectedItems.remove(indexPath)
            cell?.backgroundColor = UIColor.white
        }
        else{
            selectedItems.insert(indexPath)
            cell?.backgroundColor = UIColor.f8Blue
        }
        self.navigationItem.rightBarButtonItem?.isEnabled = selectedItems.count > 0
    }

    // change background color back when user releases touch
    func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        // let cell = collectionView.cellForItem(at: indexPath)
        // cell?.backgroundColor = UIColor.cyan
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension SelectHazardViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize{
        return CGSize(width: 100.0, height: 100.0)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 15
    }
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
}
