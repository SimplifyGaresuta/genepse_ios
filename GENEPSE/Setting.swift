//
//  Setting.swift
//  GENEPSE
//
//  Created by 岩見建汰 on 2017/12/06.
//  Copyright © 2017年 Kenta. All rights reserved.
//

import UIKit

enum SectionID: Int {
    case name = 1
    case awards = 2
    case skills = 3
    case products = 4
    case sns = 5
    case license = 6
    case info = 7
}

enum Key: String {
    // ユーザデータ
    case activity_base = "activity_base"
    case name = "name"
    case overview = "overview"
    case profile_img = "profile_img"
    case attr = "attr"
    case main_skills = "main_skills"
    case awards = "awards"
    case skills = "skills"
    case products = "products"
    case sns = "sns"
    case license = "license"
    case gender = "gender"
    case age = "age"
    case address = "address"
    case school_career = "school_career"
    
    //プロダクト登録
    case product_id = "product_id"
    
    // 位置情報
    case latitude = "latitude"
    case longitude = "longitude"
    
    // ログイン
    case login_url = "login_url"
    case user_id = "user_id"
}
