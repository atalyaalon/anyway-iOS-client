//
//  UIColor+Anyway.swift
//  Anyway
//
//  Created by Yigal Omer on 04/08/2019.
//  Copyright © 2019 Hasadna. All rights reserved.
//
import Foundation

extension UIColor {

    open class var f8Greyish: UIColor {
        return #colorLiteral(red: 0.6392156863, green: 0.6392156863, blue: 0.6392156863, alpha: 1)
    }

    open class var f8Blue: UIColor {
        return UIColor(hexString: "#009edb")
    }

    open class var f8WarmGray: UIColor {
        return UIColor(hexString: "#888888")
    }

    open class var f8BlackText: UIColor {
        return UIColor(hexString: "#222222")
    }

    open class var f8Cerulean: UIColor {
        return UIColor(hexString: "#00A0DE")
    }

    open class var f8CeruleanTwo: UIColor {
        return UIColor(hexString: "#009ED8")
    }

    open class var f8CeruleanThree: UIColor {
        return UIColor(hexString: "#00ADEE")
    }

    open class var f8LightGray: UIColor {
        return UIColor(hexString: "#DADADA")
    }

    open class var f8RedText: UIColor {
        return UIColor(hexString: "#EE333F")
    }

    open class var f8PinkishGray: UIColor {
        return UIColor(hexString: "#CCCCCC")
    }

    open class var f8WarmGrayThree: UIColor {
        return UIColor(hexString: "#777777")
    }

    open class var f8WhiteTwo: UIColor {
        return UIColor(hexString: "#E5E5E5")
    }

    open class var f8WhiteBackground: UIColor {
        return UIColor(hexString: "#F7F7F9")
    }

    open class var f8Silver: UIColor {
        return UIColor(hexString: "#D6D8DA")
    }

    open class var f8Strawberry: UIColor {
        return UIColor(hexString: "#EE333F")
    }

    open class var f8MiddleGrey: UIColor {
        return UIColor(hexString: "#AAAAAA")
    }

    open class var f8PaleGrey: UIColor {
        return UIColor(hexString: "#f5f5f7")
    }

    open class var f8DarkGrey: UIColor {
        return UIColor(hexString: "#555555")
    }
    open class var pink: UIColor {
        return UIColor(hexString: "#F7E6F8")
    }
    

    open class var purple1: UIColor {
        return UIColor(hexString: "#DFDDFA")
    }
    open class var purple: UIColor {
        return #colorLiteral(red: 0.8301323758, green: 0.8245005649, blue: 0.8977235597, alpha: 0.9284567637)
    }

    open class var f8PastDayBackground: UIColor {
        return #colorLiteral(red: 0.9568627451, green: 0.9568627451, blue: 0.9568627451, alpha: 1)
    }

    open class var f8PastDayDevider: UIColor {
        return #colorLiteral(red: 0.9411764706, green: 0.9411764706, blue: 0.9411764706, alpha: 1)
    }

    open class var f8RideViewBackground: UIColor {
        return #colorLiteral(red: 0.6, green: 0.6, blue: 0.6, alpha: 0.1)
    }

    open class var f8RideViewDirection: UIColor {
        return #colorLiteral(red: 0.6117647059, green: 0.6117647059, blue: 0.6117647059, alpha: 1)
    }

    open class var f8SkippedKidColor: UIColor {
        return #colorLiteral(red: 0.937254902, green: 0.2705882353, blue: 0.3137254902, alpha: 1)
    }

    open class var f8SchoolMessageColor: UIColor {
        return #colorLiteral(red: 0.1490196078, green: 0.7450980392, blue: 0.4549019608, alpha: 1)
    }

    open class var initialsColors: [UIColor] {
        return [#colorLiteral(red: 0.937254902, green: 0.6039215686, blue: 0.6039215686, alpha: 1), #colorLiteral(red: 0.9568627451, green: 0.5607843137, blue: 0.6941176471, alpha: 1), #colorLiteral(red: 0.8078431373, green: 0.5764705882, blue: 0.8470588235, alpha: 1), #colorLiteral(red: 0.7019607843, green: 0.6156862745, blue: 0.8588235294, alpha: 1), #colorLiteral(red: 0.6235294118, green: 0.6588235294, blue: 0.8549019608, alpha: 1), #colorLiteral(red: 0.5058823529, green: 0.831372549, blue: 0.9803921569, alpha: 1), #colorLiteral(red: 0.5019607843, green: 0.8705882353, blue: 0.9176470588, alpha: 1), #colorLiteral(red: 0.5019607843, green: 0.7960784314, blue: 0.768627451, alpha: 1), #colorLiteral(red: 0.6470588235, green: 0.8392156863, blue: 0.6549019608, alpha: 1), #colorLiteral(red: 0.7725490196, green: 0.8823529412, blue: 0.6470588235, alpha: 1)]
    }
    public convenience init(intRed red: Int, green: Int, blue: Int, alpha: Float = 1.0) {
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: CGFloat(alpha))
    }

    public convenience init(hexString: String) {
        let hex = hexString.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int = UInt32()
        Scanner(string: hex).scanHexInt32(&int)
        let alpha, red, green, blue: UInt32
        switch hex.count {
        case 3: // RGB (12-bit)
            (alpha, red, green, blue) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (alpha, red, green, blue) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (alpha, red, green, blue) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (alpha, red, green, blue) = (255, 0, 0, 0)
        }
        self.init(red: CGFloat(red) / 255, green: CGFloat(green) / 255, blue: CGFloat(blue) / 255, alpha: CGFloat(alpha) / 255)
    }

    convenience init(hex: Int) {
        self.init(hex: hex, alpha: 1.0)
    }
    convenience init(hex: Int, alpha: CGFloat) {
        let r = CGFloat((hex & 0xFF0000) >> 16)/255
        let g = CGFloat((hex & 0xFF00) >> 8)/255
        let b = CGFloat(hex & 0xFF)/255
        self.init(red: r, green: g, blue: b, alpha: alpha)
    }
}
