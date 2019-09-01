//
//  Utilities.swift
//  SpeakApp
//
//  Created by Aviel Gross on 10/22/14.
//  Copyright (c) 2014 Aviel Gross. All rights reserved.
//

import UIKit

// MARK: Operators/Typealiases

/**
*  Set lhs to be rhs only if lhs is nil
*  Example: imageView.image ?= placeholderImage
*           Will set placeholderImage only if imageView.image is nil
*/
infix operator ?=
func ?=<T>(lhs: inout T!, rhs: T) {
    if lhs == nil {
        lhs = rhs
    }
}
//func ?=<T>(lhs: inout T?, rhs: T) {
//    if lhs == nil {
//        lhs = rhs
//    }
//}
func ?=<T>(lhs: inout T?, rhs: T?) {
    if lhs == nil {
        lhs = rhs
    }
}

typealias Seconds = TimeInterval

//MARK: Tick/Tock
private var tickD = Date()
func TICK() {
    tickD = Date()
}
func TOCK(_ sender: Any = #function) {
    print("⏰ TICK/TOCK for: \(sender) :: \(-tickD.timeIntervalSinceNow) ⏰")
}

// MARK: Common/Generic

func local(_ key: String, comment: String = "") -> String {
    return NSLocalizedString(key, comment: comment)
}

var brString: String { return "_________________________________________________________________" }
func printbr() {
    print(brString)
}
func printFunc(_ val: Any = #function) {
    print("🚩 \(val)")
}

func prettyPrint<T>(_ val: T, filename: NSString = #file, line: Int = #line, funcname: String = #function)
{
    print("\(Date()) [\(filename.lastPathComponent):\(line)] - \(funcname):\r\(val)\n")
}

public func resizeImage(_ image : UIImage, size : CGSize) -> UIImage {
    UIGraphicsBeginImageContextWithOptions(size, false, 0);
    image.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
    let out = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return out!;
}

func delay(_ delay:Double, closure:@escaping ()->()) {
    DispatchQueue.main.asyncAfter(
        deadline: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: closure)
}

func async<T>(_ back:@escaping ()->(T), then main:@escaping (T)->()) {
    DispatchQueue.global(qos: .default).async {
        let some = back()
        DispatchQueue.main.async {
            main(some)
        }
    }
}

func async(_ back:@escaping ()->(), then main:@escaping ()->()) {
    DispatchQueue.global(qos: .default).async {
        back()
        DispatchQueue.main.async {
            main()
        }
    }
}

func sync(_ main:@escaping ()->()) {
    DispatchQueue.main.async {
        main()
    }
}

func async(_ back:@escaping ()->()) {
    DispatchQueue.global(qos: .default).async {
        back()
    }
}

extension Data {
    var unarchived: AnyObject? { return NSKeyedUnarchiver.unarchiveObject(with: self) as AnyObject? }
}

extension Array {
    func safeRetrieveElement(_ index: Int) -> Element? {
        if count > index { return self[index] }
        return nil
    }
    
    mutating func removeFirst(_ element: Element, equality: (Element, Element) -> Bool) -> Bool {
        for (index, item) in enumerated() {
            if equality(item, element) {
                self.remove(at: index)
                return true
            }
        }
        return false
    }
    
    mutating func removeFirst(_ compareTo: (Element) -> Bool) -> Bool {
        for (index, item) in enumerated() {
            if compareTo(item) {
                self.remove(at: index)
                return true
            }
        }
        return false
    }
}


extension UIStoryboardSegue {
    func destinationController<T>(_ type: T.Type) -> T? {
        if let destNav = destination as? UINavigationController,
            let dest = destNav.topViewController as? T {
                return dest
        }
        
        if let dest = destination as? T {
            return dest
        }
        
        return nil
    }
}

extension UIViewController {
    func parentViewController<T: UIViewController>(ofType type:T.Type) -> T? {
        if  let parentVC = presentingViewController as? UINavigationController,
            let topParent = parentVC.topViewController as? T {
                return topParent
        } else
            if let parentVC = presentingViewController as? T {
                return parentVC
        }
        return nil
    }
}

extension UIAlertController {
    
    func show() {
        present(animated: true, completion: nil)
    }
    
    func present(animated: Bool, completion: (() -> Void)?) {
        if let rootVC = UIApplication.shared.keyWindow?.rootViewController {
            presentFromController(rootVC, animated: animated, completion: completion)
        }
    }
    
    fileprivate func presentFromController(_ controller: UIViewController, animated: Bool, completion: (() -> Void)?) {
        if  let navVC = controller as? UINavigationController,
            let visibleVC = navVC.visibleViewController {
                presentFromController(visibleVC, animated: animated, completion: completion)
        } else
        if  let tabVC = controller as? UITabBarController,
            let selectedVC = tabVC.selectedViewController {
                presentFromController(selectedVC, animated: animated, completion: completion)
        } else {
            controller.present(self, animated: animated, completion: completion)
        }
    }
}

extension UIAlertView {
    class func show(_ title: String?, message: String?, closeTitle: String?) {
        UIAlertView(title: title, message: message, delegate: nil, cancelButtonTitle: closeTitle).show()
    }
}

extension UIImageView {
    func setImage(_ url: String, placeHolder: UIImage? = nil, animated: Bool = true) {
        if let placeHolderImage = placeHolder {
            self.image = placeHolderImage
        }

        UIImage.image(url, image: { (image) in
            if animated {
                UIView.transition(with: self, duration: 0.25, options: .transitionCrossDissolve, animations: {
                    self.image = image
                }) { done in }
            } else {
                self.image = image
            }
        })
    }
}

extension UIImage {
    
    func resizeToSquare() -> UIImage? {
        let originalWidth  = self.size.width
        let originalHeight = self.size.height
        
        var edge: CGFloat
        if originalWidth > originalHeight {
            edge = originalHeight
        } else {
            edge = originalWidth
        }
        
        let posX = (originalWidth  - edge) / 2.0
        let posY = (originalHeight - edge) / 2.0
        
        let cropSquare = CGRect(x: posX, y: posY, width: edge, height: edge)
        
        if let imageRef = self.cgImage?.cropping(to: cropSquare)
        {
            return UIImage(cgImage: imageRef, scale: UIScreen.main.scale, orientation: self.imageOrientation)
        }
        return nil
        
    }
    
    /// Returns an image in the given size (in pixels)
    func resized(_ size: CGSize) -> UIImage? {
        let image = self.cgImage
        
        let bitsPerComponent = image?.bitsPerComponent
        let bytesPerRow = image?.bytesPerRow
        let colorSpace = image?.colorSpace
        let bitmapInfo = image?.bitmapInfo
        
        let context = CGContext(data: nil, width: Int(size.width), height: Int(size.height), bitsPerComponent: bitsPerComponent!, bytesPerRow: bytesPerRow!, space: colorSpace!, bitmapInfo: (bitmapInfo?.rawValue)!)
        context!.interpolationQuality = CGInterpolationQuality.medium
        context?.draw(image!, in: CGRect(origin: CGPoint.zero, size: size))
        
        if let aCGImage = context?.makeImage()
        {
            return UIImage(cgImage: aCGImage)
        }
        
        return nil
        
    }
    
    func scaled(_ scale: CGFloat) -> UIImage? {
        return resized(CGSize(width: self.size.width * scale, height: self.size.height * scale))
    }
    
    func resizedToFullHD() -> UIImage? { return resize(maxLongEdge: 1920) }
    func resizedToMediumHD() -> UIImage? { return resize(maxLongEdge: 1080) }
    func resizeToThumbnail() -> UIImage? { return resize(maxLongEdge: 50) }
    
    func resize(maxLongEdge: CGFloat) -> UIImage? {
        let longEdge = max(size.width, size.height)
        let shortEdge = min(size.width, size.height)
        
        if longEdge <= maxLongEdge {
            return self
        }
        
        let scale = maxLongEdge/longEdge
        if longEdge == size.width {
            return resized(CGSize(width: maxLongEdge, height: shortEdge * scale))
        } else {
            return resized(CGSize(width: shortEdge * scale, height: maxLongEdge))
        }
    }
    
    class func image(_ link: String, session: URLSession = URLSession.shared, image: @escaping (UIImage)->()) {
        let url = URL(string: link)!
        let downloadPhotoTask = session.downloadTask(with: url, completionHandler: { (location, response, err) in
            if  let location = location,
                let data = try? Data(contentsOf: location),
                let img = UIImage(data: data) {
                    DispatchQueue.main.async {
                        image(img)
                    }
            }
        }) 
        downloadPhotoTask.resume()
    }
    
    class func imageWithInitials(_ initials: String, diameter: CGFloat, textColor: UIColor = UIColor.darkGray, backColor: UIColor = UIColor.lightGray, font: UIFont = UIFont.systemFont(ofSize: 14)) -> UIImage {
        let size = CGSize(width: diameter, height: diameter)
        let r = size.width / 2
        
        UIGraphicsBeginImageContextWithOptions(size, false, UIScreen.main.scale)
        let context = UIGraphicsGetCurrentContext()
        context?.setStrokeColor(backColor.cgColor)
        context?.setFillColor(backColor.cgColor)
        
        let path = UIBezierPath(ovalIn: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        path.addClip()
        path.lineWidth = 1.0
        path.stroke()
        
        context?.setFillColor(backColor.cgColor)
        context?.fill(CGRect(x: 0, y: 0, width: size.width, height: size.height))
        
        let dict = [NSAttributedString.Key.font: font, NSAttributedString.Key.foregroundColor: textColor]
        let nsInitials = initials as NSString
        let textSize = nsInitials.size(withAttributes: dict)
        nsInitials.draw(in: CGRect(x: r - textSize.width / 2, y: r - font.lineHeight / 2, width: size.width, height: size.height), withAttributes: dict)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image!
    }

}

extension UITextField {
    
    func passRegex(_ expression: Regex) -> Bool {
        if let text = self.text, text.empty
        {
            return false
        }
        return (self.text ?? "").passRegex(expression)
    }
}

extension UITableView {
    func reloadData(_ completion: @escaping ()->()) {
        UIView.animate(withDuration: 0, animations: { self.reloadData() }, completion: { _ in completion() })
            
    }
    
    func calculateHeightForConfiguredSizingCell(_ cell: UITableViewCell) -> CGFloat {
        cell.bounds.size = CGSize(width: frame.width, height: cell.bounds.height)
        cell.setNeedsLayout()
        cell.layoutIfNeeded()
        let size = cell.contentView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
        return size.height + 1
    }
    
    func deselectRowIfNeeded(animated animate: Bool = true) {
        if let selected = indexPathForSelectedRow {
            deselectRow(at: selected, animated: animate)
        }
    }
    
    /**
    !!WILL OVERRIDE ANY EXISTING TABLE FOOTER THAT MIGHT EXIST!!
    */
    func hideEmptySeperators() {
        tableFooterView = UIView(frame: CGRect.zero)
    }
}


enum Regex: String {
    case FullName = ".*\\s.*." // two words with a space
    case Email = "^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\\.[a-zA-Z0-9-.]+$"
    case Password = "^[\\d\\w]{6,255}$"
    case LetterOrDigit = "[a-zA-Z0-9]"
    case Digit = "[0-9]"
}

extension String {
    
    func passRegex(_ expression: Regex) -> Bool {
        var error: NSError?
        let regex: NSRegularExpression?
        do {
            regex = try NSRegularExpression(pattern: expression.rawValue, options: NSRegularExpression.Options.caseInsensitive)
        } catch let error1 as NSError {
            error = error1
            regex = nil
        }
        
        if let err = error { print(err) }
        
        if self.empty {
            return false
        }
        
        let str: NSString = self as NSString
        let options: NSRegularExpression.MatchingOptions = NSRegularExpression.MatchingOptions()
        let numOfMatches = regex!.numberOfMatches(in: str as String, options: options, range: str.range(of: str as String))
        
        return numOfMatches > 0
    }
    
   /* func attributedStringFromHTMLString(_ overrideFont: Bool = false, color: UIColor = UIColor.white) -> NSAttributedString {
        let options = [
            NSAttributedString.DocumentAttributeKey.documentType.rawValue: NSAttributedString.DocumentType.html,
            NSAttributedString.DocumentAttributeKey.characterEncoding: String.Encoding.utf8
            ] as! [String : Any]
        
        var atStr: NSMutableAttributedString?
        do {

            atStr = try NSMutableAttributedString(data: self.data(using: String.Encoding.utf8)!, options: options as [String : AnyObject], documentAttributes: nil)
            if let str = atStr
            {
                let range = NSMakeRange(0, NSString(string: str.string).length)
                
                str.addAttribute(NSAttributedString.Key.foregroundColor, value: color, range: range)
                
                if overrideFont {
                    str.addAttribute(NSAttributedString.Key.font, value: UIFont.preferredFont(forTextStyle: UIFont.TextStyle.body), range:range)
                }
                
                atStr = str
            }
            
        }
        catch let error as NSError
        {
            prettyPrint(error)
        }
        
        if let s = atStr
        {
            return s
        }
        
        return NSMutableAttributedString(string: "")
    }*/
    
    func stringByTrimmingHTMLTags() -> String {
        return self.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil)
    }
       
    func firstWord() -> String? {
        return self.components(separatedBy: " ").first
    }
    
    func lastWord() -> String? {
        return self.components(separatedBy: " ").last
    }
    
    var firstChar: String? { return empty ? nil : String(self[0]) }
    var lastChar:  String? { return String(self[index(before: endIndex)]) }

    func firstCharAsLetterOrDigit() -> String? {
        if let f = firstChar, f.passRegex(.LetterOrDigit) { return f }
        return nil
    }
    
    var empty: Bool {
        return self.count == 0
    }
    
    /// Either empty or only whitespace and/or new lines
    var emptyDeduced: Bool {
        return empty || trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).empty
    }
        
    // discussion: http://stackoverflow.com/a/2933145/2242359
    func stringByForcingWritingDirectionLTR() -> String {
        return "\u{200E}" + self
    }
    
    func stringByForcingWritingDirectionRTL() -> String {
        return "\u{200F}" + self
    }
    /**
    Returns the caller string with apostrophes.
    e.g.,
    "Hello" will return "\"Hello\""
    */
    func forceApostrophes() -> String {
        return "\"\(self)\""
    }
    
    func contains(_ substring: String, ignoreCase: Bool = false, ignoreDiacritic: Bool = false) -> Bool {
        var options = NSString.CompareOptions()
        if ignoreCase { options.insert(NSString.CompareOptions.caseInsensitive) }
        if ignoreDiacritic { options.insert(NSString.CompareOptions.diacriticInsensitive) }
        return range(of: substring, options: options) != nil
    }
    
    subscript (i: Int) -> Character {
        return self[self.index(self.startIndex, offsetBy: i)]
    }
    
    subscript (i: Int) -> String {
        return String(self[i] as Character)
    }
    
    subscript (r: Range<Int>) -> String {
        return substring(with: index(startIndex, offsetBy: r.lowerBound)..<index(startIndex, offsetBy: r.upperBound))
    }

}

extension NSMutableAttributedString {
    public func addAttribute(_ name: String, value: AnyObject, ranges: [NSRange]) {
        for r in ranges {
            addAttribute(NSAttributedString.Key(rawValue: name), value: value, range: r)
        }
    }
}


extension Int {
    var ordinal: String {
        get {
            var suffix: String = ""
            let ones: Int = self % 10;
            let tens: Int = (self/10) % 10;
            
            if (tens == 1) {
                suffix = "th";
            } else if (ones == 1){
                suffix = "st";
            } else if (ones == 2){
                suffix = "nd";
            } else if (ones == 3){
                suffix = "rd";
            } else {
                suffix = "th";
            }
            
            return suffix
        }
    }
    
    var string: String {
        get{
            return "\(self)"
        }
    }
}

extension UIView {
//    @IBInspectable var cornerRadius: CGFloat {
//        get {
//            return layer.cornerRadius
//        }
//        set {
//            layer.cornerRadius = newValue
//            layer.masksToBounds = newValue > 0
//        }
//    }
    
    func shakeView() {
        let shake:CABasicAnimation = CABasicAnimation(keyPath: "position")
        shake.duration = 0.1
        shake.repeatCount = 2
        shake.autoreverses = true
        
        let from_point:CGPoint = CGPoint(x: self.center.x - 5, y: self.center.y)
        let from_value:NSValue = NSValue(cgPoint: from_point)
        
        let to_point:CGPoint = CGPoint(x: self.center.x + 5, y: self.center.y)
        let to_value:NSValue = NSValue(cgPoint: to_point)
        
        shake.fromValue = from_value
        shake.toValue = to_value
        self.layer.add(shake, forKey: "position")
    }
    
    func blowView() {
        UIView.animate(withDuration: 0.1, delay: 0, options: UIView.AnimationOptions.curveEaseIn, animations: { () -> Void in
            self.transform = CGAffineTransform(scaleX: 1.06, y: 1.05)
        }) { _ in
                
            UIView.animate(withDuration: 0.06, delay: 0, options: UIView.AnimationOptions.curveEaseOut, animations: { () -> Void in
                    self.transform = CGAffineTransform.identity
                }) { _ in }
            
        }
    }
    
    func snapShotImage(afterScreenUpdates after: Bool) -> UIImage? {
        UIGraphicsBeginImageContext(self.bounds.size)
        self.drawHierarchy(in: self.bounds, afterScreenUpdates: after)
        let snap = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return snap
    }
}

extension NotificationCenter {
    
    class func post(_ name: String) {
        `default`.post(name: Notification.Name(rawValue: name), object: nil)
    }
    
    class func observe(_ name: String, usingBlock block: @escaping (Notification?) -> Void) -> NSObjectProtocol {
        return `default`.addObserver(forName: NSNotification.Name(rawValue: name), object: nil, queue: nil, using:block)
    }
    
    class func observe<T: AnyObject>(_ target: T, name: String, usingBlock block: @escaping (_ note: Notification?, _ targetRef: T) -> Void) -> NSObjectProtocol {
        weak var weakTarget = target
        return `default`.addObserver(forName: NSNotification.Name(rawValue: name), object: nil, queue: nil) {
            if let strTarget = weakTarget {
                block($0, strTarget)
            }
        }
    }
    
}

extension Date {
    static func todayComponents() -> (day: Int, month: Int, year: Int) {
        let calendar = Calendar(identifier: Calendar.Identifier.gregorian)
        let units: NSCalendar.Unit = [NSCalendar.Unit.day, NSCalendar.Unit.month, NSCalendar.Unit.year]
        let comps = (calendar as NSCalendar).components(units, from: Date())
        return (comps.day!, comps.month!, comps.year!)
    }
    
    var shortDescription: String { return self.customDescription(.short, date: .short) }
    var shortTime: String { return self.customDescription(.short) }
    var shortDate: String { return self.customDescription(date: .short) }
    var mediumDescription: String { return self.customDescription(.medium, date: .medium) }
    var mediumTime: String { return self.customDescription(.medium) }
    var mediumDate: String { return self.customDescription(date: .medium) }
    var longDescription: String { return self.customDescription(.long, date: .long) }
    var longTime: String { return self.customDescription(.long) }
    var longDate: String { return self.customDescription(date: .long) }
    
    func customDescription(_ time: DateFormatter.Style = .none, date: DateFormatter.Style = .none) -> String {
        let form = DateFormatter()
        form.timeStyle = time
        form.dateStyle = date
        return form.string(from: self)
    }
    
    func formattedFromCompenents(_ styleAttitude: DateFormatter.Style, year: Bool = true, month: Bool = true, day: Bool = true, hour: Bool = true, minute: Bool = true, second: Bool = true) -> String {
        let long = styleAttitude == .long || styleAttitude == .full ? true : false
        var comps = ""
        
        if year { comps += long ? "yyyy" : "yy" }
        if month { comps += long ? "MMMM" : "MMM" }
        if day { comps += long ? "dd" : "d" }
        
        if hour { comps += long ? "HH" : "H" }
        if minute { comps += long ? "mm" : "m" }
        if second { comps += long ? "ss" : "s" }
        
        let format = DateFormatter.dateFormat(fromTemplate: comps, options: 0, locale: Locale.current)
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: self)
    }
    
    func formatted(_ format: String) -> String {
        let form = DateFormatter()
        form.dateFormat = format
        return form.string(from: self)
    }
    
    /**
    Init an NSDate with string and format. eg. (W3C format: "YYYY-MM-DDThh:mm:ss")
    
    - parameter val:      the value with the date info
    - parameter format:   the format of the value string
    - parameter timeZone: optional, default is GMT time (not current locale!)
    
    - returns: returns the created date, if succeeded
    */
    init?(val: String, format: String, timeZone: String = "") {
        let form = DateFormatter()
        form.dateFormat = format
        if timeZone.emptyDeduced {
            form.timeZone = TimeZone(secondsFromGMT: 0)
        } else {
            form.timeZone = TimeZone(identifier: timeZone)
        }
        if let date = form.date(from: val) {
            self.init(timeIntervalSince1970: date.timeIntervalSince1970)
        } else {
            self.init()
            return nil
        }
    }
}

extension UIApplication {
    
//    static var isAppInForeground: Bool {
//        
//        return shared.applicationState == UIApplication.State.active
//
//    }
    
    func registerForPushNotifications() {

        let types: UIUserNotificationType = ([.alert, .badge, .sound])
        let settings: UIUserNotificationSettings = UIUserNotificationSettings(types: types, categories: nil)
        
        registerUserNotificationSettings(settings)
        registerForRemoteNotifications()
    }
    
}

extension FileManager
{
    class func documentsDir() -> String
    {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true) 
        return paths[0]
    }
    
    class func cachesDir() -> String
    {
        let paths = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true) 
        return paths[0]
    }
    
    class func tempBaseDir() -> String!
    {
        print("temp - \(NSTemporaryDirectory())")
        return NSTemporaryDirectory()        
    }

}


func + <K,V>(left: Dictionary<K,V>, right: Dictionary<K,V>) -> Dictionary<K,V> {
    var map = Dictionary<K,V>()
    for (k, v) in left {
        map[k] = v
    }
    for (k, v) in right {
        map[k] = v
    }
    return map
}


extension UIImage {

    func maskWithColor(color: UIColor) -> UIImage? {
        let maskImage = cgImage!

        let width = size.width
        let height = size.height
        let bounds = CGRect(x: 0, y: 0, width: width, height: height)

        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
        let context = CGContext(data: nil, width: Int(width), height: Int(height), bitsPerComponent: 8, bytesPerRow: 0, space: colorSpace, bitmapInfo: bitmapInfo.rawValue)!

        context.clip(to: bounds, mask: maskImage)
        context.setFillColor(color.cgColor)
        context.fill(bounds)

        if let cgImage = context.makeImage() {
            let coloredImage = UIImage(cgImage: cgImage)
            return coloredImage
        } else {
            return nil
        }
    }

}

extension UIImageView {

    func maskWith(color: UIColor) {
        guard let tempImage = image?.withRenderingMode(.alwaysTemplate) else { return }
        image = tempImage
        tintColor = color
    }

}
