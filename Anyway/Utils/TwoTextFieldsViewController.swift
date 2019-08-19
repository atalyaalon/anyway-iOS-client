import UIKit

extension UIAlertController {
    
    /// Add two textField
    ///
    /// - Parameters:
    ///   - height: textField height
    ///   - hInset: right and left margins to AlertController border
    ///   - vInset: bottom margin to button
    ///   - textFieldOne: first textField
    ///   - textFieldTwo: second textField
    
    func addTwoTextFields(height: CGFloat = 58, hInset: CGFloat = 0, vInset: CGFloat = 0, textFieldOne: TextField.Config?, textFieldTwo: TextField.Config?) {
        let textField = TwoTextFieldsViewController(height: height, hInset: hInset, vInset: vInset, textFieldOne: textFieldOne, textFieldTwo: textFieldTwo)
        set(vc: textField, height: height * 2 + 2 * vInset)
    }
    func addFiveTextFields(height: CGFloat = 145,
                           hInset: CGFloat = 0,
                           vInset: CGFloat = 0,
                           textFieldOne: TextField.Config?,
                           textFieldTwo: TextField.Config?,
                           textFieldThree: TextField.Config?,
                           textFieldFour: TextField.Config?,
                           textFieldFive: TextField.Config?) {
        let textField = TwoTextFieldsViewController(height: height,
                                                    hInset: hInset,
                                                    vInset: vInset,
                                                    textFieldOne: textFieldOne,
                                                    textFieldTwo: textFieldTwo,
                                                    textFieldThree: textFieldThree,
                                                    textFieldFour: textFieldFour,
                                                    textFieldFive: textFieldFive)
        set(vc: textField, height: height * 5 + 5 * vInset)
    }
}

final class TwoTextFieldsViewController: UIViewController {
    
    fileprivate lazy var textFieldView: UIView = UIView()
    fileprivate lazy var textFieldOne: TextField = TextField()
    fileprivate lazy var textFieldTwo: TextField = TextField()
    fileprivate lazy var textFieldThree: TextField = TextField()
    fileprivate lazy var textFieldFour: TextField = TextField()
    fileprivate lazy var textFieldFive: TextField = TextField()

    fileprivate var height: CGFloat
    fileprivate var hInset: CGFloat
    fileprivate var vInset: CGFloat
    
    init(height: CGFloat, hInset: CGFloat, vInset: CGFloat, textFieldOne configurationOneFor: TextField.Config?, textFieldTwo configurationTwoFor: TextField.Config?) {
        self.height = height
        self.hInset = hInset
        self.vInset = vInset
        super.init(nibName: nil, bundle: nil)
        view.addSubview(textFieldView)
        
        textFieldView.addSubview(textFieldOne)
        textFieldView.addSubview(textFieldTwo)
        
        textFieldView.width = view.width
        textFieldView.height = height * 2
        textFieldView.maskToBounds = true
        textFieldView.borderWidth = 1
        textFieldView.borderColor = UIColor.lightGray
        textFieldView.cornerRadius = 8
        
        configurationOneFor?(textFieldOne)
        configurationTwoFor?(textFieldTwo)
        
        //preferredContentSize.height = height * 2 + vInset
    }

    init(height: CGFloat,
         hInset: CGFloat,
         vInset: CGFloat,
         textFieldOne configurationOneFor: TextField.Config?,
         textFieldTwo configurationTwoFor: TextField.Config?,
         textFieldThree configurationThreeFor: TextField.Config?,
         textFieldFour  configurationFourFor: TextField.Config?,
         textFieldFive  configurationFiveFor: TextField.Config?) {

        self.height = height
        self.hInset = hInset
        self.vInset = vInset
        super.init(nibName: nil, bundle: nil)
        view.addSubview(textFieldView)

        textFieldView.addSubview(textFieldOne)
        textFieldView.addSubview(textFieldTwo)
        textFieldView.addSubview(textFieldThree)
        textFieldView.addSubview(textFieldFour)
        textFieldView.addSubview(textFieldFive)

        textFieldView.width = view.width
        textFieldView.height = height * 5
        textFieldView.maskToBounds = true
        textFieldView.borderWidth = 1
        textFieldView.borderColor = UIColor.lightGray
        textFieldView.cornerRadius = 8

        configurationOneFor?(textFieldOne)
        configurationTwoFor?(textFieldTwo)
        configurationThreeFor?(textFieldThree)
        configurationFourFor?(textFieldFour)
        configurationFiveFor?(textFieldFive)

        //preferredContentSize.height = height * 2 + vInset
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        print("has deinitialized")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }

     func viewDidLayoutSubviews1() {
        super.viewDidLayoutSubviews()

        textFieldView.width = view.width - hInset * 2
        textFieldView.height = height * 2
        textFieldView.center.x = view.center.x
        textFieldView.center.y = view.center.y

//        textFieldOne.width = textFieldView.width
//        textFieldOne.height = textFieldView.height / 2
//        textFieldOne.center.x = textFieldView.width / 2
//        textFieldOne.center.y = textFieldView.height / 4
//
//        textFieldTwo.width = textFieldView.width
//        textFieldTwo.height = textFieldView.height / 2
//        textFieldTwo.center.x = textFieldView.width / 2
//        textFieldTwo.center.y = textFieldView.height - textFieldView.height / 4


        textFieldOne.width = textFieldView.width
        textFieldOne.height = height
        textFieldOne.center.x = textFieldView.width / 2
        textFieldOne.center.y = height / 2

        textFieldTwo.width = textFieldView.width
        textFieldTwo.height = textFieldView.height / 2
        textFieldTwo.center.x = textFieldView.width / 2
        textFieldTwo.center.y = textFieldOne.height + height / 2

    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        textFieldView.width = view.width - hInset * 2
        textFieldView.height = height * 5
        textFieldView.center.x = view.center.x
        textFieldView.center.y = view.center.y

        textFieldOne.width = textFieldView.width
        textFieldOne.height = height
        textFieldOne.center.x = textFieldView.width / 2
        textFieldOne.center.y = height / 2

        textFieldTwo.width = textFieldView.width
        textFieldTwo.height = height
        textFieldTwo.center.x = textFieldView.width / 2
        textFieldTwo.center.y = height + height / 2


        textFieldThree.width = textFieldView.width
        textFieldThree.height = height
        textFieldThree.center.x = textFieldView.width / 2
        textFieldThree.center.y = height * 2 + height / 2

        textFieldFour.width = textFieldView.width
        textFieldFour.height = height
        textFieldFour.center.x = textFieldView.width / 2
        textFieldFour.center.y = height * 3  + height / 2

        textFieldFive.width = textFieldView.width
        textFieldFive.height = height
        textFieldFive.center.x = textFieldView.width / 2
        textFieldFive.center.y = height * 4  + height / 2
    }

}

