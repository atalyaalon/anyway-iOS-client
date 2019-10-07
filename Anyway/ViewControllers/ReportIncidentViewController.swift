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

    func didFinishReport()
    func didCancelReport()
    func didRequestToChangeLocation()
}


class ReportIncidentViewController: BaseViewController {

    private let contentRectHeight: CGFloat = 1000
    private let edgesPadding: CGFloat = 25
    private let topPadding: CGFloat = 7
    private let labelHeight: CGFloat = 30
    private let collectionViewInsets: CGFloat = 10
    private let reuseIdentifier = "cell"
    private let backgroundColor: UIColor = UIColor.white

    private var reportIncidentModel: ReportIncidentOutput! //ReportIncidentViewModel
    private var addImageModel: AddImageOutput! //AddImageViewModel

    private var scrollView: UIScrollView!
    private var contentView : UIView!
    private var imageOfTheIncidentLabel: UILabel!
    public var  incidentImageView: UIImageView?
    private var incidentTypesLabel: UILabel!
    private var incidentAddressLabel: UILabel!
    private var addressTextView :UITextView!
    private var mapButton: UIButton!
    private var collectionView: UICollectionView!
    private var otherLabel: UILabel!
    private var hazardDescTextView: UITextView!
    private var placeholderLabel : UILabel!
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
    
    var incidentLocation: CLLocationCoordinate2D?
    var incidentAddress: String?
    

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
        addDoneButtonOnKeyboard()
    }
    
    
    func addDoneButtonOnKeyboard() {
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 320, height: 40))
        doneToolbar.barStyle       = UIBarStyle.default
        let flexSpace              = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem  = UIBarButtonItem(title: "סיום", style: UIBarButtonItem.Style.done, target: self, action: #selector(ReportIncidentViewController.doneButtonAction))
        
        var items = [UIBarButtonItem]()
        items.append(flexSpace)
        items.append(done)
        
        doneToolbar.items = items
        doneToolbar.sizeToFit()
        
        self.hazardDescTextView.inputAccessoryView = doneToolbar
    }

    @objc func doneButtonAction() {
        self.hazardDescTextView.resignFirstResponder()
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
        setupAddressLabel()
        setupAddressTextView()
        setupMapButton()
        setupIncidentTypesLabel()
        setupCollectionView()
        setupCommentLabel()
        setupTextView()
        //setupSwitchLabel()
        //setupSwitchControlView()
        //setupAddUserDetailsView()
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
       // contentRect.size.height = contentRect.size.height
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
        tapGesture.cancelsTouchesInView = false
        tapGesture.delaysTouchesBegan = false
        tapGesture.delaysTouchesEnded = false
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

    private func setupAddressLabel() {
        let view: UILabel = UILabel()
        view.textColor = UIColor.f8BlackText
        view.font = UIFont.systemFont(ofSize: 17)
        view.textAlignment = .center
        view.text = "INCIDENT_ADDRESS".localized
        self.contentView.addSubview(view)
        self.incidentAddressLabel = view
    }
    
    private func setupAddressTextView() {

        let view = PlaceHolderTextView()
        view.backgroundColor = .clear
        view.isEditable = true
        view.showsVerticalScrollIndicator = true
        view.font = UIFont.systemFont(ofSize: 14)
        //view.place = ""
        view.layer.cornerRadius = 4.0
        view.layer.borderWidth = 1.0
        view.layer.borderColor = UIColor.black.cgColor
        //view.returnKeyType = UIReturnKeyType.done
        view.text = self.incidentAddress
        
        self.contentView.addSubview(view)
        self.addressTextView = view
    }
    
    private func setupMapButton() {
        let view: UIButton = UIButton()
        
        view.clipsToBounds = true
        view.setTitleColor(UIColor.white, for: UIControl.State.normal)
        view.backgroundColor = UIColor.anywayBlue
        view.tintColor = UIColor.black
        view.setTitle("מפה (לחץ לשינוי מקום המפגע)", for: UIControl.State.normal)
        
        view.layer.borderColor = UIColor.black.cgColor
        view.layer.borderWidth = 1
        view.layer.cornerRadius = 5
        
        view.addTarget(self, action: #selector(mapButtonTapped), for: .touchUpInside)
        self.contentView.addSubview(view)
        self.mapButton = view
    }
    
    @objc private func mapButtonTapped(_ sender: UIButton) {
        self.delegate?.didRequestToChangeLocation()
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

    private func setupCommentLabel() {
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
        //view.returnKeyType = UIReturnKeyType.done
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
        self.contentView.addSubview(placeholderLabel)
        //placeholderLabel.frame.origin = CGPoint(x: 10, y: 10)
        placeholderLabel.textColor = UIColor.lightGray
        placeholderLabel.isHidden = !hazardDescTextView.text.isEmpty
    }

    private func setupSendButton() {
        let view: UIButton = UIButton()

        view.clipsToBounds = true
        view.setTitleColor(UIColor.white, for: UIControl.State.normal)
        view.backgroundColor = UIColor.lightGray
        //view.layer.cornerRadius = 4
        view.tintColor = UIColor.black
        view.setTitle("המשך", for: UIControl.State.normal)

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

        view.addTarget(self, action: #selector(continewButtonTapped), for: .touchUpInside)
        self.contentView.addSubview(view)
        self.sendButton = view
    }

    @objc private func continewButtonTapped(_ sender: UIButton) {
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

        incidentData.imageData = incidentImageView?.image?.jpegData(compressionQuality: 0.8)
         
        if let incidentLocation = self.incidentLocation {
            incidentData.latitude = incidentLocation.latitude
            incidentData.longitude = incidentLocation.longitude
            
        }
        incidentData.problem_descripion = hazardDescTextView.text
        
        print ("incident data 1 = \(incidentData)")
        
        
      //   let imageData = selectedImageView?.image?.jpegData(compressionQuality: 0.8)
        
        startReportIncidentUserInfoVC(incidentData: incidentData)

        //self.delegate?.didFinishReport(incidentData: incidentData)
    }

    private func setupNavigationBar() {

        let leftBarButtonItem: UIBarButtonItem = UIBarButtonItem(title: "CANCEL".localized,
                                                  style: .plain,
                                                  target: self,
                                                  action: #selector(onBackButtonClick))
        leftBarButtonItem.tintColor = UIColor.white
        self.navigationItem.setLeftBarButton(leftBarButtonItem, animated: false)
        self.navigationItem.title = "REPORT_AN_INCIDENT1".localized

        let nav = self.navigationController?.navigationBar
        nav?.isTranslucent = false;
        nav?.barTintColor = UIColor.anywayBlue//backgroundColor
        nav?.barStyle = UIBarStyle.black
        nav?.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
    }

    @objc override func onBackButtonClick() {

        if let delegate = self.delegate {
            delegate.didCancelReport()
        }
        else{
            self.navigationController?.popViewController(animated: true)
            self.navigationController?.isNavigationBarHidden = true
        }
    }

    // MARK: - Actions
//    @objc func backBarButtonItemAction(sender: UIButton) {
//        self.currentResponder?.resignFirstResponder()
//        delegate?.didCancelReport()
//    }
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
            make.height.equalTo(contentRectHeight)
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
        
        
        self.incidentAddressLabel.snp.remakeConstraints({ (make: ConstraintMaker) in
            make.leading.equalToSuperview().offset(edgesPadding)
            if let incidentImageView = self.incidentImageView{
                make.top.equalTo(incidentImageView.snp.bottom).offset(edgesPadding)
            }else{
                make.top.equalTo(imageOfTheIncidentLabel.snp.bottom).offset(edgesPadding)
            }
            make.height.equalTo(labelHeight)
        })
        
        self.addressTextView.snp.remakeConstraints({ (make: ConstraintMaker) in
            make.leading.equalToSuperview().offset(edgesPadding)
            make.trailing.equalToSuperview().offset(-edgesPadding)
            make.height.equalTo(labelHeight)
            make.top.equalTo(self.incidentAddressLabel.snp.bottom).offset(topPadding)
        })
        

        self.mapButton.snp.remakeConstraints({ (make: ConstraintMaker) in
            make.centerX.equalToSuperview()
            make.top.equalTo(self.addressTextView.snp.bottom).offset(topPadding)
            make.trailing.equalToSuperview().offset(-edgesPadding)
            make.leading.equalToSuperview().offset(edgesPadding)
            make.height.equalTo(40)

        })
        self.incidentTypesLabel.snp.remakeConstraints({ (make: ConstraintMaker) in
            make.leading.equalToSuperview().offset(edgesPadding)
            make.height.equalTo(labelHeight)
            make.top.equalTo(self.mapButton.snp.bottom).offset(edgesPadding)
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
            
            make.leading.equalToSuperview().offset(edgesPadding + 4)
            
            //make.leading.equalToSuperview().offset(10) // TODO YIGAL not working???
            //make.top.equalTo(self.hazardDescTextView.center).offset(labelHeight/2 )
            make.top.equalTo(self.hazardDescTextView).offset(5)
            make.height.equalTo(labelHeight)
            //make.trailing.equalToSuperview().offset(-UIScreen.main.bounds.size.width/1.75 )
            make.trailing.equalToSuperview().offset(-edgesPadding)
        })

        self.sendButton.snp.remakeConstraints({ (make: ConstraintMaker) in
            make.centerX.equalToSuperview()
            make.top.equalTo(self.hazardDescTextView.snp.bottom).offset(edgesPadding)
            make.trailing.equalToSuperview().offset(-edgesPadding)
            make.leading.equalToSuperview().offset(edgesPadding)
            make.height.equalTo(40)

        })
        super.updateViewConstraints()
    }
    
    
    
    
    private func startReportIncidentUserInfoVC(incidentData: Incident) {
        let reportIncidentUserInfoViewController:ReportIncidentUserInfoViewController = UIStoryboard.main.instantiateViewController(withIdentifier: "ReportIncidentUserInfoViewController") as UIViewController as! ReportIncidentUserInfoViewController
        
        reportIncidentUserInfoViewController.incidentData = incidentData
        reportIncidentUserInfoViewController.delegate = self
        
        //print ("incident data 2 = \(incidentData)")
        
        self.navigationController?.pushViewController(reportIncidentUserInfoViewController, animated: true)
    }
}

// MARK: - UITextViewDelegate
extension ReportIncidentViewController: UITextViewDelegate {

     func textViewDidBeginEditing(_ textView: UITextView) {
        self.currentResponder = textView
        activeField = textView

        let frameToScrollTo: CGRect = self.hazardDescTextView.frame

        self.scrollView.scrollRectToVisible(frameToScrollTo, animated: true)

        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }

    func textViewDidChange(_ textView: UITextView) {
        placeholderLabel.isHidden = !hazardDescTextView.text.isEmpty

        if !hazardDescTextView.text.isEmpty || selectedItems.count > 0{
            self.sendButton.backgroundColor = UIColor.anywayBlue
        }
        else if selectedItems.count > 0 {
            self.sendButton.backgroundColor = UIColor.anywayBlue
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

        if  selectedItems.count > 0 {
            self.sendButton.backgroundColor = UIColor.anywayBlue
        }
        else if !hazardDescTextView.text.isEmpty || selectedItems.count > 0  {
            self.sendButton.backgroundColor = UIColor.anywayBlue
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

// MARK: - ReportIncidentViewControllerDelegate
extension ReportIncidentViewController: ReportIncidentUserInfoViewControllerDelegate {

    func didFinishUserInfo() {
                
        self.delegate?.didFinishReport()
    }

    func didCancelUserInfo() {
        self.navigationController?.popViewController(animated: true)
    }
}


