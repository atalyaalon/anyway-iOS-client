//
//  SelectHazardViewController.swift
//  Anyway
//
//  Created by Yigal Omer on 22/08/2019.
//  Copyright © 2019 Hasadna. All rights reserved.
//

import UIKit
import SnapKit
import Spring

public protocol SelectHazardViewControllerDelegate: class {

    func didSelectHazard(selectedItems: Array<Any>?, hazardDescription: String?)
    func didCancelHazard() 
}


class SelectHazardViewController: UIViewController {

    private let edgesPadding: CGFloat = 25
    private let topPadding: CGFloat = 7
    private let labelHeight: CGFloat = 30
    private let collectionViewInsets: CGFloat = 10

    private var scrollView: UIScrollView!
    private var contentView: UIView!
    private var customStackView : UIView!
    private var imageOfTheIncidentLabel: UILabel!
    public var  incidentImageView: UIImageView?
    public var  incidentTypesLabel: UILabel!
    private var collectionView: UICollectionView!
    private var otherLabel: UILabel!
    private var hazardDescTextView: PlaceHolderTextView!
    private var switchLabel: UILabel!
    private var switchControl: UISwitch!
    private var addUserDetailsView: SpringView!
    private var sendButton: UIButton!

    private var rightBarButtonItem: UIBarButtonItem?
    private let reuseIdentifier = "cell"
    private var items: [HazardData] = HazardsStorage.hazards
    private var selectedItems = Set<IndexPath>()
    private var currentResponder: UIResponder?

    private let backgroundColor: UIColor = UIColor.white//.withAlphaComponent(0.525) //UIColor.purple
    private var placeholderLabel : UILabel!
    private var tapGesture: UITapGestureRecognizer!
    private var activeField: UITextView?
    public weak var delegate: SelectHazardViewControllerDelegate?


    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        addKeyboardObservers()
        addTapGesture()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        removeKeyboardObservers()
        removeTapGesture()
    }

    //
    // MARK: Private
    //
    private func setupView() {

        self.navigationController?.isNavigationBarHidden = false
        setupScrollView()
        setupContentView()
        setupStackView()
        setupImageOfTheIncidentLabel()
        setupImage()
        setupIncidentTypesLabel()
        setupCollectionView()
        setupOtherLabel()
        setupTextView()
        setupSwitchLabel()
        setupSwitchControlView()
        setupAddUserDetailsView()
        setupSendButton()
        setupNavigationBar()

        //scrollView.updateContentView()

        self.view.setNeedsUpdateConstraints()
        self.view.updateConstraintsIfNeeded()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        var contentRect = CGRect.zero
        for view: UIView in scrollView.subviews {
            contentRect = contentRect.union(view.frame)
        }
        contentRect.size.height = contentRect.size.height + 400
        scrollView.contentSize = contentRect.size
    }

    private func addKeyboardObservers() {

        NotificationCenter.default.addObserver(self, selector: #selector(SelectHazardViewController.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(SelectHazardViewController.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    private func removeKeyboardObservers() {
        NotificationCenter.default.removeObserver(self)
    }

    private func addTapGesture() {
        tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        view.addGestureRecognizer(tapGesture)
        disableKeyboardDissmissingByTap()
    }

    private func removeTapGesture() {
        customStackView.removeGestureRecognizer(tapGesture)
    }

    private func enableKeyboardDissmissingByTap() {
        self.tapGesture.isEnabled = true
    }

    private func disableKeyboardDissmissingByTap() {
        self.tapGesture.isEnabled = false
    }

    @objc func keyboardWillHide(_ aNotification: NSNotification) {

        let contentInsets: UIEdgeInsets = .zero
        self.scrollView.contentInset = contentInsets
        self.scrollView.scrollIndicatorInsets = contentInsets
        disableKeyboardDissmissingByTap()
    }

    @objc func keyboardWillShow(_ aNotification: NSNotification) {

        if let kbSize = (aNotification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {

            print("keyboard = \(kbSize)")

            let contentInsets: UIEdgeInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: kbSize.height, right: 0.0)

            scrollView.contentInset = contentInsets
            scrollView.scrollIndicatorInsets = contentInsets

            var aRect: CGRect = self.view.frame

            aRect.size.height -= kbSize.height
            enableKeyboardDissmissingByTap()
            //if !aRect.contains(hazardDescTextView.frame.origin) {
            //if let activeField = activeField {
                self.scrollView.scrollRectToVisible(hazardDescTextView.frame, animated: true)
            //}
            //}
        }
    }

    @objc func hideKeyboard() {
        view.endEditing(true)
        self.hazardDescTextView.endEditing(true)
    }

    private func setupScrollView() {
        let view = UIScrollView()
        view.backgroundColor = UIColor.clear

        //view.contentSize = CGSize(width: self.view.frame.width, height: 2000)
        self.view.addSubview(view)
        self.scrollView = view
    }

    private func setupContentView() {
        let view = UIView()
        view.backgroundColor = UIColor.clear
        view.clipsToBounds = true
        self.scrollView.addSubview(view)
        self.contentView = view
    }



    private func setupStackView() {

        customStackView = UIView()
        customStackView.backgroundColor = self.backgroundColor
        self.contentView.addSubview(customStackView)
    }

    private func setupImageOfTheIncidentLabel() {
        let view: UILabel = UILabel()
        view.textColor = UIColor.f8BlackText
        view.font = UIFont.systemFont(ofSize: 17)
        view.textAlignment = .center
        view.text = "IMAGE_OF_THE_INCIDENGT".localized
        //self.view.addSubview(view)
        self.customStackView.addSubview(view)
        self.imageOfTheIncidentLabel = view
    }

    private func setupImage() {
        if let view = self.incidentImageView {
            self.customStackView.addSubview(view)
            view.contentMode = .center
            view.translatesAutoresizingMaskIntoConstraints = false
            view.backgroundColor = .clear
            view.clipsToBounds = false
            view.contentMode = .scaleAspectFit
            self.incidentImageView = view
        }
    }

    private func setupIncidentTypesLabel() {
        let view: UILabel = UILabel()
        view.textColor = UIColor.f8BlackText
        view.font = UIFont.systemFont(ofSize: 17)
        view.textAlignment = .center
        view.text = "INCIDENGT_TYPE".localized
        self.customStackView.addSubview(view)
        self.incidentTypesLabel = view
    }
    private func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 1
        layout.minimumInteritemSpacing = 1

        let view = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        view.backgroundColor = self.backgroundColor
        customStackView.addSubview(view)
        let contentInsets: UIEdgeInsets = UIEdgeInsets(top: collectionViewInsets, left: collectionViewInsets, bottom: collectionViewInsets, right: collectionViewInsets)
        view.contentInset = contentInsets
        view.contentMode = .center
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
        view.text = "ELSE".localized
        //self.view.addSubview(view)
        self.customStackView.addSubview(view)
        self.otherLabel = view
    }

    private func setupTextView() {
        let view = PlaceHolderTextView()
        view.backgroundColor = .clear
        view.isEditable = true
        view.showsVerticalScrollIndicator = true
        view.font = UIFont.systemFont(ofSize: 14)
        //view.place = ""
        view.layer.cornerRadius = 4.0
        view.layer.borderWidth = 1.0
        view.layer.borderColor = UIColor.black.cgColor
        view.returnKeyType = UIReturnKeyType.done
        view.placeholder = "describe bla bla"
        view.placeholderColor = UIColor.lightGray

        self.customStackView.addSubview(view)
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

    private func setupSwitchLabel() {
        let view: UILabel = UILabel()
        view.textColor = UIColor.f8BlackText
        view.font = UIFont.systemFont(ofSize: 17)
        view.textAlignment = .center
        view.text = "REPORT_TO_MUNICIPALITY".localized
        self.customStackView.addSubview(view)
        self.switchLabel = view
    }
    private func setupSwitchControlView() {
        let view = UISwitch()
        view.addTarget(self, action: #selector(valueChanged), for: .valueChanged)
        self.customStackView.addSubview(view)
        self.switchControl = view

    }
    @objc func valueChanged() {
        let isOn:Bool = self.switchControl.isOn
        print("\(isOn)")
        if isOn {
            if isAllAddUserDetailsViewSubviewsNotEmpty()  && (selectedItems.count > 0 || !self.hazardDescTextView.text.isEmpty) {
                self.sendButton.backgroundColor = UIColor.init(hexString: "3764BC")
            }
            else{
                self.sendButton.backgroundColor = UIColor.lightGray
            }
            self.addUserDetailsView.isHidden = false
            self.addUserDetailsView.duration = 1.0
            self.addUserDetailsView.animation = "pop"
            self.addUserDetailsView.animate()
        }
        else{
            if  selectedItems.count > 0 || !self.hazardDescTextView.text.isEmpty {
                self.sendButton.backgroundColor = UIColor.init(hexString: "3764BC")
            }
            else{
                self.sendButton.backgroundColor = UIColor.lightGray
            }
            self.addUserDetailsView.animation = "fadeOut"
            self.addUserDetailsView.duration = 2.0
            self.addUserDetailsView.animate()
        }
    }


    private func setupAddUserDetailsView(){
        let view = SpringView()
        //view.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width-40, height: 200)
        view.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width-40, height: 210)
        //view.backgroundColor = UIColor.f8LightGray
        view.layer.cornerRadius = 5.0
        view.layer.borderWidth = 1.0
        view.layer.borderColor = UIColor.black.cgColor

        view.isHidden = false
        view.duration = 1.0
        view.damping = 0.8
        view.animation = "pop"

        func addTextView(_ textView:PlaceHolderTextView, _ index:CGFloat, _ placeHolder: String ){
            //let testView = UITextView()
            textView.backgroundColor = .white
            textView.isEditable = true
            textView.font = UIFont.systemFont(ofSize: 14)
            textView.layer.cornerRadius = 4.0
            textView.layer.borderWidth = 1.0
            textView.layer.borderColor = UIColor.black.cgColor
            textView.placeholder = placeHolder
            textView.placeholderColor = UIColor.lightGray
            textView.textColor = UIColor.lightGray
            textView.delegate = self
            textView.text = placeHolder

            let y: CGFloat = 10 + index*10.0 + index * 30.0

            textView.frame = CGRect(x: 10, y: y, width: UIScreen.main.bounds.size.width-70, height: 30)
            view.addSubview(textView)
        }

        let firstNameTextView = PlaceHolderTextView()
        addTextView(firstNameTextView, 0, "שם פרטי")

        let lastNameTextView = PlaceHolderTextView()
        addTextView(lastNameTextView, 1, "שם משפחה")

        let idTextView = PlaceHolderTextView()
        addTextView(idTextView, 2, "תעודת זהות")

        let emailTextView = PlaceHolderTextView()
        addTextView(emailTextView, 3, "דואר אלקטרוני")

        let phoneTextView = PlaceHolderTextView()
        addTextView(phoneTextView, 4, "מספר טלפון")

        view.isHidden = true

        self.customStackView.addSubview(view)
        self.addUserDetailsView = view
    }

    private func setupSendButton() {
        let view: UIButton = UIButton()

        view.clipsToBounds = true
        view.setTitleColor(UIColor.white, for: UIControl.State.normal)
        view.backgroundColor = UIColor.lightGray
        view.layer.cornerRadius = 4
        view.tintColor = UIColor.black
        view.setTitle("שלח", for: UIControl.State.normal)

        view.addTarget(self, action: #selector(sendButtonTapped), for: .touchUpInside)
        self.customStackView.addSubview(view)
        self.sendButton = view
    }

    @objc private func sendButtonTapped(_ sender: UIButton) {
        //mainViewModel?.handleHelpTap()
    }
    private func setupNavigationBar() {
        self.rightBarButtonItem = UIBarButtonItem(title: "DONE".localized,
                                                  style: .done,
                                                  target: self,
                                                  action: #selector(doneBarButtonItemAction))
        rightBarButtonItem?.tintColor = UIColor.white
        self.navigationItem.setRightBarButton(self.rightBarButtonItem, animated: false)


        let leftBarButtonItem: UIBarButtonItem = UIBarButtonItem(title: "BACK".localized,
                                                  style: .plain,
                                                  target: self,
                                                  action: #selector(onBackButtonClick))
        leftBarButtonItem.tintColor = UIColor.white
        self.navigationItem.setLeftBarButton(leftBarButtonItem, animated: false)


        self.navigationItem.title = "REPORT_AN_INCIDENT".localized
        self.navigationItem.rightBarButtonItem?.isEnabled = false

        let nav = self.navigationController?.navigationBar
        nav?.isTranslucent = false;
        nav?.barTintColor = UIColor.init(hexString: "3764BC")//backgroundColor
        nav?.barStyle = UIBarStyle.black
        nav?.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
    }


    @objc func onBackButtonClick() {
        print("On back button click called. Am I on main thread? \(Thread.isMainThread)")
        if Thread.callStackSymbols.count > 2 {
            print("Who called me: \(Thread.callStackSymbols[2])")
        }
        delegate?.didCancelHazard()
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
        delegate?.didCancelHazard()
    }
    //
    // MARK: Layout
    //
    override func updateViewConstraints() {

        scrollView.snp.remakeConstraints { (make) in
            make.top.equalToSuperview()
            //make.bottom.equalToSuperview()
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.height.equalTo(2000.0)
        }

        contentView.snp.remakeConstraints { (make) in
            make.edges.equalToSuperview()
            make.width.equalToSuperview()
            make.height.equalToSuperview().priority(250)
        }
        self.customStackView.snp.remakeConstraints({ (make: ConstraintMaker) in
            make.leading.equalToSuperview().offset(0)
            make.trailing.equalToSuperview().offset(0)
            make.top.equalToSuperview().offset(0)
            make.height.equalToSuperview().offset(0)//equalTo(400)
         })

        self.imageOfTheIncidentLabel.snp.remakeConstraints({ (make: ConstraintMaker) in
            make.top.equalToSuperview().offset(topPadding)
            make.leading.equalToSuperview().offset(edgesPadding)
            make.height.equalTo(labelHeight)
        })

        self.incidentImageView?.snp.remakeConstraints({ (make: ConstraintMaker) in
            make.leading.equalToSuperview().offset(edgesPadding)
            make.height.equalTo(100)
            make.width.equalTo(100)
            make.top.equalTo(imageOfTheIncidentLabel.snp.bottom).offset(topPadding)
        })

        self.incidentTypesLabel.snp.remakeConstraints({ (make: ConstraintMaker) in
            make.leading.equalToSuperview().offset(edgesPadding)
            if let incidentImageView = self.incidentImageView{
                make.top.equalTo(incidentImageView.snp.bottom).offset(edgesPadding)
            }else{
                make.top.equalTo(imageOfTheIncidentLabel.snp.bottom).offset(edgesPadding)
            }
            make.height.equalTo(labelHeight)
        })

        self.collectionView.snp.remakeConstraints({ (make: ConstraintMaker) in
            make.leading.equalToSuperview().offset(edgesPadding - collectionViewInsets)
            make.top.equalTo(incidentTypesLabel.snp.bottom).offset(topPadding)
            make.left.equalTo(edgesPadding - collectionViewInsets)
            make.height.equalTo(370)
        })

        self.otherLabel.snp.remakeConstraints({ (make: ConstraintMaker) in
            make.leading.equalToSuperview().offset(edgesPadding)
            make.height.equalTo(labelHeight)
            make.top.equalTo(self.collectionView.snp.bottom).offset(edgesPadding)
        })

        self.hazardDescTextView.snp.remakeConstraints({ (make: ConstraintMaker) in
            make.leading.equalToSuperview().offset(edgesPadding)
            make.trailing.equalToSuperview().offset(-edgesPadding)
            make.top.equalTo(self.otherLabel.snp.bottom).offset(topPadding)
            make.height.equalTo(60)
        })

        self.placeholderLabel.snp.remakeConstraints({ (make: ConstraintMaker) in
            make.top.equalToSuperview().offset(9)
            make.trailing.equalToSuperview().offset(-225)
        })

        self.switchLabel.snp.remakeConstraints({ (make: ConstraintMaker) in
            make.leading.equalToSuperview().offset(edgesPadding)
            make.height.equalTo(labelHeight)
            make.top.equalTo(self.hazardDescTextView.snp.bottom).offset(edgesPadding)
        })

        self.switchControl.snp.remakeConstraints({ (make: ConstraintMaker) in
            make.centerY.equalTo(self.switchLabel)
            make.top.equalTo(self.hazardDescTextView.snp.bottom).offset(edgesPadding)
            make.height.equalTo(labelHeight)
            make.trailing.equalToSuperview().offset(-edgesPadding)
        })

        self.addUserDetailsView.snp.remakeConstraints({ (make: ConstraintMaker) in
            make.centerX.equalToSuperview()
            make.top.equalTo(self.switchControl.snp.bottom).offset(edgesPadding)
            make.trailing.equalToSuperview().offset(-edgesPadding)
            make.leading.equalToSuperview().offset(edgesPadding)
            make.height.equalTo(210)

        })

        self.sendButton.snp.remakeConstraints({ (make: ConstraintMaker) in
            make.centerX.equalToSuperview()
            make.top.equalTo(self.addUserDetailsView.snp.bottom).offset(edgesPadding)
            make.trailing.equalToSuperview().offset(-edgesPadding)
            make.leading.equalToSuperview().offset(edgesPadding)
            make.height.equalTo(40)

        })


        super.updateViewConstraints()
    }
}

// MARK: - UITextViewDelegate
extension SelectHazardViewController: UITextViewDelegate {

     func textViewDidBeginEditing(_ textView: UITextView) {
        self.currentResponder = textView
        activeField = textView
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }

    private func isAllAddUserDetailsViewSubviewsNotEmpty() -> Bool {

        for subView in self.addUserDetailsView.subviews {
            if let subView = subView as? UITextView {
                if subView.text.isEmpty  || subView.textColor == UIColor.lightGray {
                    return false
                }
            }else{
                print("addUserDetailsView has unidentified subviews")
                return false
            }
        }
        return true
    }

    func textViewDidChange(_ textView: UITextView) {
        placeholderLabel.isHidden = !hazardDescTextView.text.isEmpty
        //self.navigationItem.rightBarButtonItem?.isEnabled = !textView.text.isEmpty

        if self.switchControl.isOn && isAllAddUserDetailsViewSubviewsNotEmpty() && (!hazardDescTextView.text.isEmpty || selectedItems.count > 0){
            self.sendButton.backgroundColor = UIColor.init(hexString: "3764BC")
        }
        else if !self.switchControl.isOn && (!hazardDescTextView.text.isEmpty || selectedItems.count > 0) {
            self.sendButton.backgroundColor = UIColor.init(hexString: "3764BC")
        }
        else{
            self.sendButton.backgroundColor = UIColor.lightGray
        }

    }

    private func textFieldDidEndEditing(_ textView: UITextView) {
        activeField = nil
    }

    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
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

    // change background color and shadow when user selects cell
    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath){
        let cell = collectionView.cellForItem(at: indexPath)
        //hideKeyboard()

        if selectedItems.contains(indexPath) {
            selectedItems.remove(indexPath)
            cell?.backgroundColor = UIColor.white
            cell?.layer.shadowColor = UIColor.black.cgColor
        }
        else{
            selectedItems.insert(indexPath)
            cell?.backgroundColor = UIColor.init(hexString: "7FA9C6")
            cell?.layer.shadowColor = UIColor.white.cgColor
        }

        if isAllAddUserDetailsViewSubviewsNotEmpty() && (self.switchControl.isOn || selectedItems.count > 0) {
            self.sendButton.backgroundColor = UIColor.init(hexString: "3764BC")
        }
        else if !self.switchControl.isOn && (!hazardDescTextView.text.isEmpty || selectedItems.count > 0)  {
            self.sendButton.backgroundColor = UIColor.init(hexString: "3764BC")
        }
        else{
            self.sendButton.backgroundColor = UIColor.lightGray
        }


        //self.navigationItem.rightBarButtonItem?.isEnabled = selectedItems.count > 0
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
        return edgesPadding
    }
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
}
