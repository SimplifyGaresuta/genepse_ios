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
    case avatar_url = "avatar_url"
    case attribute = "attribute"
    case awards = "awards"
    case skills = "skills"
    case products = "products"
    case sns = "sns"
    case licenses = "licenses"
    case gender = "gender"
    case age = "age"
    case address = "address"
    case school_career = "school_career"
    
    //プロダクト登録
    case product_id = "product_id"
    
    //プロダクト詳細
    case title = "title"
    case url = "url"
    case image = "image"
    
    //SNS
    case provider = "provider"
    
    // 位置情報
    case latitude = "latitude"
    case longitude = "longitude"
    case distance = "distance"
    
    // ログイン
    case login_url = "login_url"
    case user_id = "user_id"
}

enum AttributeStr: String {
    case Designer = "Designer"
    case Engineer = "Engineer"
    case Business = "Business"
}

enum AttributeStr_L: String {
    case Designer = "DESIGNER"
    case Engineer = "ENGINEER"
    case Business = "BUSINESS"
}

enum API: String {
    case host = "https://genepse-186713.appspot.com"
    case v1 = "/v1"
    case users = "/users/"
    case products = "/products/"
    case login_url = "/login_url/"
    case provider = "facebook"
    case locations = "/locations/"
}

enum JapaneseEnglish: Int {
    case Japanese = 0
    case English = 1
    case Both = 2
}

enum StoryboardID: String {
    case Home = "Home"
    case MyProfile = "MyProfile"
    case Location = "Location"
}
