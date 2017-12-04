//
//  TestData.swift
//  GENEPSE
//
//  Created by 岩見建汰 on 2017/12/03.
//  Copyright © 2017年 Kenta. All rights reserved.
//

import Foundation
import UIKit

class FeedViewDummyData {
    let test_names = ["岩見建汰", "Kenta Iwami", "いわみけんた"]
    let test_careers = ["UI/UXデザインを専門としています。これまで株式会社XYZのUIデザインのインターンで優勝経験があります。他には株式会社AAAを立ち上げ、月間PV数が1000万にもなるサイトを運営していたりします。", "UI/UXデザインを専門としています。これまで株式会社XYZのUIデザインのインターンで優勝経験があります。他には株式会社AAAを立ち上げ、月間PV数が1000万にもなるサイトを運営していたりします。", "UI/UXデザインを専門としています。これまで株式会社XYZのUIデザインのインターンで優勝経験があります。他には株式会社AAAを立ち上げ、月間PV数が1000万にもなるサイトを運営していたりします。"]
    let test_images = ["https://bomanite.com/wp-content/uploads/2015/03/HTC-One-Photo-Sample-Marbles.jpeg", "https://res.cloudinary.com/demo/image/upload/w_500/sample.jpg","https://www.visioncritical.com/wp-content/uploads/2014/12/BLG_Andrew-G.-River-Sample_09.13.12.png"]
    let test_attributes = ["DESIGNER", "ENGINEER", "BUSINESS"]
    let test_main_skills = [
        ["Illustrator", "Protopie", "sketch"],
        ["Python", "Swift", "Java"],
        ["経営", "会計", "起業"]
    ]
    
    func GetNames() -> Array<String> {
        return test_names
    }
    
    func GetCareers() -> Array<String> {
        return test_careers
    }
    
    func GetImages() -> Array<String> {
        return test_images
    }
    
    func GetAttributes() -> Array<String> {
        return test_attributes
    }
    
    func GetMainSkills() -> Array<Array<String>> {
        return test_main_skills
    }
}


class UserDetailDummyData {
    let user_data = [
        "name": "岩見建汰",
        "overview": "UI/UXデザインを専門としています。これまで株式会社XYZのUIデザインのインターンで優勝経験があります。他には株式会社AAAを立ち上げ、月間PV数が1000万にもなるサイトを運営していたりします。",
        "profile_img": "https://bomanite.com/wp-content/uploads/2015/03/HTC-One-Photo-Sample-Marbles.jpeg",
        "attr": "DESIGNER",
        "main_skills": ["Illustrator", "Protopie", "sketch"]
        ] as [String : Any]
}

