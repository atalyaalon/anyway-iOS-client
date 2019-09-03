//
//  ReportIncidentViewController.swift
//  Anyway
//
//  Created by Yigal Omer on 22/08/2019.
//  Copyright © 2019 Hasadna. All rights reserved.
//

import UIKit
import SnapKit
import Spring
import RSKImageCropper

protocol ReportIncidentViewControllerDelegate: class {

    func didSelectHazard(incidentData: Incident?)
    func didCancelHazard() 
}


class ReportIncidentViewController: BaseViewController {

    private let edgesPadding: CGFloat = 25
    private let topPadding: CGFloat = 7
    private let labelHeight: CGFloat = 30
    private let collectionViewInsets: CGFloat = 10
    private let reuseIdentifier = "cell"
    private let backgroundColor: UIColor = UIColor.white//.withAlphaComponent(0.525)

    private var reportIncidentModel: ReportIncidentOutput! //ReportIncidentViewModel
    private var addImageModel: AddImageOutput! //AddImageViewModel

    private var scrollView: UIScrollView!
    private var contentView : UIView!
    private var imageOfTheIncidentLabel: UILabel!
    public var  incidentImageView: UIImageView?
    public var  incidentTypesLabel: UILabel!
    private var collectionView: UICollectionView!
    private var otherLabel: UILabel!
    private var hazardDescTextView: UITextView!
    private var placeholderLabel : UILabel!
    private var switchLabel: UILabel!
    private var switchControl: UISwitch!
    private var addUserDetailsView: SpringView!
    private var sendButton: UIButton!

    private var items: [HazardData] = HazardsStorage.hazards
    private var selectedItems = Set<Int>()
    private var currentResponder: UIResponder?

    private var tapGesture: UITapGestureRecognizer!
    private var imageTapGesture: UITapGestureRecognizer!

    private var activeField: UITextView?
    public weak var delegate: ReportIncidentViewControllerDelegate?
    private weak var cropDelegate: RSKImageCropViewControllerDelegate?
    private weak var imagePickerController: UIImagePickerController?

    override func viewDidLoad() {
        super.viewDidLoad()
        reportIncidentModel = ReportIncidentViewModel(viewController: self)
        addImageModel = AddImageViewModel(viewController: self)
        //setupView()
        reportIncidentModel.viewDidLoad()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        addKeyboardObservers()
        addTapGesture()
        addImageTapGesture()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        removeKeyboardObservers()
        removeTapGesture()
        removeImagepGesture()
    }

    //
    // MARK: Private
    //
    internal override func setupView() {

        self.navigationController?.isNavigationBarHidden = false
        setupScrollView()
        setupContentView()
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
        activeField = self.hazardDescTextView

        self.view.setNeedsUpdateConstraints()
        self.view.updateConstraintsIfNeeded()
    }

    fileprivate func setScrollViewHeight() {

        var contentRect = CGRect.zero
        for view: UIView in scrollView.subviews {
            contentRect = contentRect.union(view.frame)
        }
        contentRect.size.height = contentRect.size.height
        scrollView.contentSize = contentRect.size
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setScrollViewHeight()
    }

    private func addKeyboardObservers() {

        NotificationCenter.default.addObserver(self, selector: #selector(ReportIncidentViewController.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(ReportIncidentViewController.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    private func removeKeyboardObservers() {
        NotificationCenter.default.removeObserver(self)
    }

    private func addTapGesture() {
        tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        contentView.addGestureRecognizer(tapGesture)
    }

    private func removeTapGesture() {
        contentView.removeGestureRecognizer(tapGesture)
    }

    private func addImageTapGesture() {
        imageTapGesture = UITapGestureRecognizer(target: self, action: #selector(imageTapped))
        self.incidentImageView?.addGestureRecognizer(imageTapGesture)
    }

    private func removeImagepGesture() {
        self.incidentImageView?.removeGestureRecognizer(imageTapGesture)
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
            print("keyboard rect = \(kbSize)")
            let contentInsets: UIEdgeInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: kbSize.height, right: 0.0)
            scrollView.contentInset = contentInsets
            scrollView.scrollIndicatorInsets = contentInsets
            enableKeyboardDissmissingByTap()
        }
    }

    @objc func hideKeyboard() {
        view.endEditing(true)
        self.hazardDescTextView.endEditing(true)
    }

    private func setupScrollView() {
        let view = UIScrollView()
        view.backgroundColor = UIColor.clear
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

    private func setupImageOfTheIncidentLabel() {
        let view: UILabel = UILabel()
        view.textColor = UIColor.f8BlackText
        view.font = UIFont.systemFont(ofSize: 17)
        view.textAlignment = .center
        view.text = "IMAGE_OF_THE_INCIDENGT".localized
        self.contentView.addSubview(view)
        self.imageOfTheIncidentLabel = view
    }

    private func setupImage() {

        // If image was received from mainVC use it. else create one and set the place holder image
        if let view = self.incidentImageView {
            self.contentView.addSubview(view)
        }
        else {
            self.incidentImageView = UIImageView()
            self.incidentImageView?.image = #imageLiteral(resourceName: "plus2")
            self.incidentImageView?.maskWith(color: UIColor.lightGray)
//            imageTapGesture = UITapGestureRecognizer(target: self, action: #selector(imageTapped))
//            self.incidentImageView?.addGestureRecognizer(imageTapGesture)
            self.incidentImageView?.isUserInteractionEnabled = true
            self.contentView.addSubview(self.incidentImageView!)
        }

        self.incidentImageView?.contentMode = .center
        self.incidentImageView?.translatesAutoresizingMaskIntoConstraints = false
        self.incidentImageView?.backgroundColor = .clear
        self.incidentImageView?.clipsToBounds = false
        self.incidentImageView?.contentMode = .scaleToFill
        self.incidentImageView?.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        self.incidentImageView?.layer.cornerRadius = 50
        self.incidentImageView?.layer.masksToBounds = true
        self.incidentImageView?.clipsToBounds = true
    }

    @objc func imageTapped() {
        print("image tapped")
        addImageModel.showSelectImageAlert(false)
    }

    private func setupIncidentTypesLabel() {
        let view: UILabel = UILabel()
        view.textColor = UIColor.f8BlackText
        view.font = UIFont.systemFont(ofSize: 17)
        view.textAlignment = .center
        view.text = "INCIDENGT_TYPE".localized
        self.contentView.addSubview(view)
        self.incidentTypesLabel = view
    }
    private func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 1
        layout.minimumInteritemSpacing = 1

        let view = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        view.backgroundColor = self.backgroundColor
        contentView.addSubview(view)
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
        self.contentView.addSubview(view)
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
        //view.placeholder = "describe bla bla"
        //view.placeholderColor = UIColor.lightGray

        self.contentView.addSubview(view)
        self.hazardDescTextView = view
        self.hazardDescTextView.delegate = self


        placeholderLabel = UILabel()
        placeholderLabel.text = "תאר את פרטי המפגע"
        placeholderLabel.font = UIFont.italicSystemFont(ofSize: 14)
        placeholderLabel.sizeToFit()
        //placeholderLabel.textAlignment = .right
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
        self.contentView.addSubview(view)
        self.switchLabel = view
    }
    private func setupSwitchControlView() {
        let view = UISwitch()
        view.addTarget(self, action: #selector(valueChanged), for: .valueChanged)
        self.contentView.addSubview(view)
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
        view.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width-40, height: 210)
        view.layer.cornerRadius = 5.0
        view.layer.borderWidth = 1.0
        view.layer.borderColor = UIColor.black.cgColor

        view.isHidden = false
        view.duration = 1.0
        view.damping = 0.8
        view.animation = "pop"


        func addTextView2(factory: (() -> UITextView),  index:CGFloat,  placeHolder: String, config: ((UITextView, CGFloat, String) -> Void)  ) {

            let textView: UITextView  = factory()
            config(textView,index,placeHolder)
        }


        addTextView2(factory:{ () in
                return  UITextView()
            },index: 0 , placeHolder: "FIRST_NAME".localized , config: { (textView,index,placeHolder) in

                textView.backgroundColor = .white
                textView.isEditable = true
                textView.font = UIFont.systemFont(ofSize: 14)
                textView.layer.cornerRadius = 4.0
                textView.layer.borderWidth = 1.0
                textView.layer.borderColor = UIColor.black.cgColor
                textView.textColor = UIColor.lightGray
                textView.delegate = self
                textView.text = placeHolder

                let y: CGFloat = 10 + index*10.0 + index * 30.0

                textView.frame = CGRect(x: 10, y: y, width: UIScreen.main.bounds.size.width-70, height: 30)
                view.addSubview(textView)
            }
        )

        func addTextView(_ index:CGFloat, _ placeHolder: String ) {

            let textView = UITextView()
            textView.backgroundColor = .white
            textView.isEditable = true
            textView.font = UIFont.systemFont(ofSize: 14)
            textView.layer.cornerRadius = 4.0
            textView.layer.borderWidth = 1.0
            textView.layer.borderColor = UIColor.black.cgColor
            textView.textColor = UIColor.lightGray
            textView.delegate = self
            textView.text = placeHolder

            let y: CGFloat = 10 + index*10.0 + index * 30.0

            textView.frame = CGRect(x: 10, y: y, width: UIScreen.main.bounds.size.width-70, height: 30)
            view.addSubview(textView)
        }
        //addTextView(0, "FIRST_NAME".localized)
        addTextView(1, "LAST_NAME".localized)
        addTextView(2, "ID_NUMBER".localized)
        addTextView(3, "EMAIL".localized)
        addTextView(4, "PHONE_NUMBER".localized)

        view.isHidden = true

        self.contentView.addSubview(view)
        self.addUserDetailsView = view
    }

    private func setupSendButton() {
        let view: UIButton = UIButton()

        view.clipsToBounds = true
        view.setTitleColor(UIColor.white, for: UIControl.State.normal)
        view.backgroundColor = UIColor.lightGray
        //view.layer.cornerRadius = 4
        view.tintColor = UIColor.black
        view.setTitle("שלח", for: UIControl.State.normal)

        view.layer.borderColor = UIColor.black.cgColor
        view.layer.borderWidth = 1
        view.layer.cornerRadius = 5
        // Shadow is not working TODO YIGAL
//        view.layer.shadowColor = UIColor.black.cgColor
//        view.layer.shadowOffset = CGSize(width: 4.0, height: 2.0)
//        view.layer.shadowRadius = 5.0
//        view.layer.shadowOpacity = 0.5
        //view.layer.masksToBounds = false
        //view.layer.shadowPath = UIBezierPath(roundedRect: view.bounds, cornerRadius: view.layer.cornerRadius).cgPath

        view.addTarget(self, action: #selector(sendButtonTapped), for: .touchUpInside)
        self.contentView.addSubview(view)
        self.sendButton = view
    }

    @objc private func sendButtonTapped(_ sender: UIButton) {
        sender.layer.shadowColor = UIColor.white.cgColor

        var array: Array<HazardData>? = nil
        if self.selectedItems.count > 0 {
            array = Array<HazardData>()
            for item in self.selectedItems {
                array?.append(self.items[item])
            }
        }
        var incidentData: Incident = Incident()
        incidentData.signs_on_the_road_not_clear = self.selectedItems.contains(0)
        incidentData.sidewalk_is_blocked = self.selectedItems.contains(1)
        incidentData.pothole = self.selectedItems.contains(2)
        incidentData.no_sign = self.selectedItems.contains(3)
        incidentData.road_hazard = self.selectedItems.contains(4)
        incidentData.no_light = self.selectedItems.contains(5)
        incidentData.crossing_missing = self.selectedItems.contains(6)
        incidentData.signs_problem = self.selectedItems.contains(7)
        incidentData.street_light_issue = self.selectedItems.contains(8)

        incidentData.send_to_monicipality = self.switchControl.isOn
        var userDetailArray:Array<String> = Array<String>()
        if self.switchControl.isOn {

            for  (index, subView)  in self.addUserDetailsView.subviews.enumerated() {
                if let subView = subView as? UITextView {
                    if !subView.text.isEmpty  && subView.textColor != UIColor.lightGray {
                        print("index = \(index) subView text = \(String(describing: subView.text))")
                        print("userDetailArray  = \(userDetailArray)")
                        userDetailArray.insert( subView.text, at: index)
                    }
                }else{
                    print("ERROR addUserDetailsView has unidentified subviews")
                }
            }
            incidentData.fist_name = userDetailArray[0]
            incidentData.last_name = userDetailArray[1]
            incidentData.id = userDetailArray[2]
            incidentData.email = userDetailArray[3]
            incidentData.phone_number = userDetailArray[4]
        }

        self.delegate?.didSelectHazard(incidentData: incidentData)
    }

    private func setupNavigationBar() {

        let leftBarButtonItem: UIBarButtonItem = UIBarButtonItem(title: "BACK".localized,
                                                  style: .plain,
                                                  target: self,
                                                  action: #selector(onBackButtonClick))
        leftBarButtonItem.tintColor = UIColor.white
        self.navigationItem.setLeftBarButton(leftBarButtonItem, animated: false)
        self.navigationItem.title = "REPORT_AN_INCIDENT".localized

        let nav = self.navigationController?.navigationBar
        nav?.isTranslucent = false;
        nav?.barTintColor = UIColor.init(hexString: "3764BC")//backgroundColor
        nav?.barStyle = UIBarStyle.black
        nav?.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
    }

    @objc override func onBackButtonClick() {
        print("On back button click called. Am I on main thread? \(Thread.isMainThread)")
        if Thread.callStackSymbols.count > 2 {
            print("Who called me: \(Thread.callStackSymbols[2])")
        }
        delegate?.didCancelHazard()
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
            make.bottom.equalToSuperview()
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            //make.height.equalTo(1500.0)
        }

        self.contentView.snp.remakeConstraints({ (make: ConstraintMaker) in
            make.edges.equalToSuperview()
            make.width.equalToSuperview()
            make.height.equalTo(1100)
            //make.height.equalToSuperview().priority(250)
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
            //make.leading.equalToSuperview().offset(10) // TODO YIGAL not working???
            make.top.equalToSuperview().offset(2)
            make.height.equalTo(labelHeight)
            make.trailing.equalToSuperview().offset(-UIScreen.main.bounds.size.width/1.75 )
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
extension ReportIncidentViewController: UITextViewDelegate {

     func textViewDidBeginEditing(_ textView: UITextView) {
        self.currentResponder = textView
        activeField = textView

        var frameToScrollTo: CGRect = self.hazardDescTextView.frame
        if (activeField != self.hazardDescTextView ) {
            print("activeField is not hazardDescTextView")
            frameToScrollTo = addUserDetailsView.frame
        }
        //if let activeField = activeField {
            self.scrollView.scrollRectToVisible(frameToScrollTo, animated: true)
        //}

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
            } else {
                print("addUserDetailsView has unidentified subviews")
                return false
            }
        }
        return true
    }

    func textViewDidChange(_ textView: UITextView) {
        placeholderLabel.isHidden = !hazardDescTextView.text.isEmpty

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

    func textViewDidEndEditing(_ textView: UITextView) {
        activeField = nil
        textView.resignFirstResponder()
    }
}

// MARK: - UICollectionViewDataSource
extension ReportIncidentViewController: UICollectionViewDataSource {

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
        cell.imageView.image = image
        return cell
    }
}

// MARK: - UICollectionViewDelegate
extension ReportIncidentViewController: UICollectionViewDelegate {

    // change background color and shadow when user selects cell
    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath){
        let cell = collectionView.cellForItem(at: indexPath)

        let itemNumber : Int = indexPath.item
        print ("itemNumber = \(itemNumber) selected")
        
        if selectedItems.contains(itemNumber) {
            selectedItems.remove(itemNumber)
            cell?.backgroundColor = UIColor.white
            cell?.layer.shadowColor = UIColor.black.cgColor
        }
        else{
            selectedItems.insert(itemNumber)
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
    }
    // change background color back when user releases touch
    func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        // let cell = collectionView.cellForItem(at: indexPath)
        // cell?.backgroundColor = UIColor.cyan
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension ReportIncidentViewController: UICollectionViewDelegateFlowLayout {

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

// MARK: - AddImageInput
extension ReportIncidentViewController: AddImageInput {

    func skipSelectedWhenAddingImage() {
    }

    func showImagPickerScreen(_ pickerController: UIImagePickerController, animated: Bool) {
        self.present(pickerController, animated: animated)
    }

    func setSelectedImage(image: UIImage) {
        self.incidentImageView?.image = image
    }
}

// MARK: - ReportIncidentInput
extension ReportIncidentViewController: ReportIncidentInput {


}


