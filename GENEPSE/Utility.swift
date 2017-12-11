//
//  Utility.swift
//  GENEPSE
//
//  Created by 岩見建汰 on 2017/12/09.
//  Copyright © 2017年 Kenta. All rights reserved.
//

import UIKit
import SwiftyJSON

func GetAttributeColor(attr: String) -> UIColor {
    var bg_color: UIColor
    
    switch attr {
    case AttributeStr.Designer.rawValue:
        bg_color = UIColor.hexStr(hexStr: AttributeColor.red.rawValue as NSString, alpha: 1.0)
        break
    case AttributeStr.Engineer.rawValue:
        bg_color = UIColor.hexStr(hexStr: AttributeColor.blue.rawValue as NSString, alpha: 1.0)
        break
    case AttributeStr.Business.rawValue:
        bg_color = UIColor.hexStr(hexStr: AttributeColor.green.rawValue as NSString, alpha: 1.0)
        break
    default:
        bg_color = UIColor.clear
        break
    }
    
    return bg_color
}

func GetDetailData(json: JSON) -> DetailData {
    let activity_base = json[Key.activity_base.rawValue].stringValue
    let name = json[Key.name.rawValue].stringValue
    let overview = json[Key.overview.rawValue].stringValue
    let avatar_url = json[Key.avatar_url.rawValue].stringValue
    let attribute = json[Key.attribute.rawValue].stringValue
    let skills:[String] = json[Key.skills.rawValue].arrayValue.map({$0.stringValue})
    let main_skills:[String] = Array(skills.prefix(3))
    let awards:[String] = json[Key.awards.rawValue].arrayValue.map({$0.stringValue})
    let products = json[Key.products.rawValue].arrayValue
    let sns = json[Key.sns.rawValue].arrayValue
    let licenses:[String] = json[Key.licenses.rawValue].arrayValue.map({$0.stringValue})
    let gender = json[Key.gender.rawValue].stringValue
    let age = json[Key.age.rawValue].intValue
    let address = json[Key.address.rawValue].stringValue
    let school_career = json[Key.school_career.rawValue].stringValue
    
    let data = DetailData()
    data.SetActivityBase(activity_base: activity_base)
    data.SetName(name: name)
    data.SetOverview(overview: overview)
    data.SetAvatarUrl(avatar_url: avatar_url)
    data.SetAttr(attr: attribute)
    data.SetMainSkills(main_skills: main_skills)
    data.SetAwards(awards: awards)
    data.SetSkills(skills: skills)
    data.SetProducts(products: products)
    data.SetSNS(sns: sns)
    data.SetLicenses(licenses: licenses)
    data.SetGender(gender: gender)
    data.SetAge(age: age)
    data.SetAddress(address: address)
    data.SetSchoolCareer(school_career: school_career)
    
    return data
}

func GetStandardAlert(title: String, message: String, b_title: String) -> UIAlertController {
    let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
    let ok = UIAlertAction(title: b_title, style:UIAlertActionStyle.default)
    
    alertController.addAction(ok)
    
    return alertController
}

func SearchJapaneseEnglish(text: String) -> Int {
    let text_count = text.count
    
    //スペースの文字数をカウント
    var regex = try! NSRegularExpression(pattern: "[ |　]", options: [.caseInsensitive])
    var targetStringRange = NSRange(location: 0, length: (text as NSString).length)
    let space_count = regex.numberOfMatches(in: text, options: [], range: targetStringRange)
    
    //英数文字の文字数をカウント
    regex = try! NSRegularExpression(pattern: "[a-z|A-Z|0-9]", options: [.caseInsensitive])
    targetStringRange = NSRange(location: 0, length: (text as NSString).length)
    let e_count = regex.numberOfMatches(in: text, options: [], range: targetStringRange)
    
    if text_count - space_count == e_count {
        return JapaneseEnglish.English.rawValue
    }
    
    //日本語文字の文字数をカウント
    regex = try! NSRegularExpression(pattern: "[\\p{Han}\\p{Hiragana}\\p{Katakana}]", options: [.caseInsensitive])
    targetStringRange = NSRange(location: 0, length: (text as NSString).length)
    let j_count = regex.numberOfMatches(in: text, options: [], range: targetStringRange)
    
    if text_count - space_count == j_count {
        return JapaneseEnglish.Japanese.rawValue
    }
    
    return JapaneseEnglish.Both.rawValue
}

func GetFontName(je_num: Int, font_w: Int) -> String {
    switch je_num {
    //日本語のみ
    case 0:
        if font_w == 3 {
            return FontName.J_W3.rawValue
        }
        return FontName.J_W6.rawValue
        
    //英語のみ
    case 1:
        return FontName.E.rawValue
    default:
        return FontName.J_W3.rawValue
    }
}

func GetAttributedTextLineHeight(height: Int, text: String) -> NSMutableAttributedString {
    let lineHeight = CGFloat(height)
    let paragraphStyle = NSMutableParagraphStyle()
    paragraphStyle.minimumLineHeight = lineHeight
    paragraphStyle.maximumLineHeight = lineHeight
    paragraphStyle.lineBreakMode = .byTruncatingTail
    let attributedText = NSMutableAttributedString(string: text)
    attributedText.addAttribute(NSParagraphStyleAttributeName, value: paragraphStyle, range: NSMakeRange(0, attributedText.length))
    
    return attributedText
}

func GetAppDelegate() -> AppDelegate {
    return UIApplication.shared.delegate as! AppDelegate
}

class Indicator {
    let indicator = UIActivityIndicatorView()
    
    func showIndicator(view: UIView) {
        indicator.activityIndicatorViewStyle = .whiteLarge
        indicator.center = view.center
        indicator.color = UIColor.gray
        indicator.hidesWhenStopped = true
        view.addSubview(indicator)
        view.bringSubview(toFront: indicator)
        indicator.startAnimating()
    }
    
    func stopIndicator() {
        self.indicator.stopAnimating()
    }
}

