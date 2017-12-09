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
    default:
        bg_color = UIColor.hexStr(hexStr: AttributeColor.green.rawValue as NSString, alpha: 1.0)
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
