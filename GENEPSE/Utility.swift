//
//  Utility.swift
//  GENEPSE
//
//  Created by 岩見建汰 on 2017/12/09.
//  Copyright © 2017年 Kenta. All rights reserved.
//

import UIKit
import SwiftyJSON

func GetAttributeString(attr: String) -> NSMutableAttributedString {
    let text = AttributeStr_L.Business.rawValue + "　" + AttributeStr_L.Engineer.rawValue + "　" + AttributeStr_L.Designer.rawValue
    let attributedText = NSMutableAttributedString(string: text)
    let gray = UIColor.hexStr(hexStr: "#BCBCBC", alpha: 1.0)
    
    switch attr {
    case AttributeStr.Designer.rawValue:
        attributedText.addAttribute(NSForegroundColorAttributeName, value: gray, range: NSRange(location: 0, length: 17))
        return attributedText
        
    case AttributeStr.Engineer.rawValue:
        attributedText.addAttribute(NSForegroundColorAttributeName, value: gray, range: NSRange(location: 0, length: 8))
        attributedText.addAttribute(NSForegroundColorAttributeName, value: gray, range: NSRange(location: 18, length: 8))
        return attributedText
        
    case AttributeStr.Business.rawValue:
        attributedText.addAttribute(NSForegroundColorAttributeName, value: gray, range: NSRange(location: 8, length: 18))
        return attributedText
        
    default:
        attributedText.addAttribute(NSForegroundColorAttributeName, value: gray, range: NSRange(location: 0, length: 26))
        return attributedText
    }
}

func GetDetailData(json: JSON) -> DetailData {
    let activity_base = json[Key.activity_base.rawValue].stringValue
    let name = json[Key.name.rawValue].stringValue
    let overview = json[Key.overview.rawValue].stringValue
    let avatar_url = json[Key.avatar_url.rawValue].stringValue
    let cover_url = json[Key.cover_url.rawValue].stringValue
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
    data.SetCoverUrl(cover_url: cover_url)
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
    
    return EscapeSpace(data: data)
}

func EscapeSpace(data: DetailData) -> DetailData {
    let escaped = data

    if data.GetActivityBase() == " " {
        escaped.SetActivityBase(activity_base: "")
    }
    
    if data.GetOverview() == " " {
        escaped.SetOverview(overview: "")
    }
    
    if data.GetAddress() == " " {
        escaped.SetAddress(address: "")
    }
    
    if data.GetSchoolCareer() == " " {
        escaped.SetSchoolCareer(school_career: "")
    }
    return escaped
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
        return FontName.E_M.rawValue
        
    default:
        return FontName.J_W3.rawValue
    }
}

func AddAttributedTextLineHeight(height: Int, text: NSMutableAttributedString) -> NSMutableAttributedString {
    let lineHeight = CGFloat(height)
    let paragraphStyle = NSMutableParagraphStyle()
    paragraphStyle.minimumLineHeight = lineHeight
    paragraphStyle.maximumLineHeight = lineHeight
    paragraphStyle.lineBreakMode = .byTruncatingTail
    text.addAttribute(NSParagraphStyleAttributeName, value: paragraphStyle, range: NSMakeRange(0, text.length))
    
    return text
}

func AddAttributedTextLetterSpacing(space: Double, text: NSMutableAttributedString) -> NSMutableAttributedString {
    text.addAttribute(NSKernAttributeName, value: space, range: NSMakeRange(0, text.length))
    
    return text
}

func AddAttributedTextColor(color: UIColor, text: NSMutableAttributedString) -> NSMutableAttributedString {
    text.addAttribute(NSForegroundColorAttributeName, value: color, range: NSRange(location:0,length:text.length))
    
    return text
}

func GetAppDelegate() -> AppDelegate {
    return UIApplication.shared.delegate as! AppDelegate
}

func GetSectionName(id: Int) -> String {
    switch id {
    case SectionID.name.rawValue:
        return Key.name.rawValue
    case SectionID.awards.rawValue:
        return Key.awards.rawValue
    case SectionID.skills.rawValue:
        return Key.skills.rawValue
    case SectionID.products.rawValue:
        return Key.products.rawValue
    case SectionID.sns.rawValue:
        return Key.sns.rawValue
    case SectionID.license.rawValue:
        return Key.licenses.rawValue
    case SectionID.info.rawValue:
        return "info"
    default:
        return ""
    }
}

func InsertIntervalString(array: [String], insert_str: String) -> Array<String> {
    var new:[String] = []
    
    for element in array {
        new.append(element)
        new.append(insert_str)
    }
    _ = new.popLast()
    
    return new
}

func GetAllSkills() -> Array<String> {
    return ["Ruby", "Java", "Python", "Go", "MySQL", "PHP", "AE", "営業", "NLP"]
}

func CheckHTTPStatus(statusCode: Int?, VC: UIViewController) {
    // 200系以外ならエラー
    let code = String(statusCode!)
    var results:[String] = []
    
    if code.pregMatche(pattern: "2..", matches: &results) {
        VC.dismiss(animated: true, completion: nil)
    }else {
        VC.present(GetStandardAlert(title: "通信エラー", message: "通信中にエラーが発生しました。もう一度やり直してください。", b_title: "OK"), animated: true, completion: nil)
    }
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

