//
//  TestData.swift
//  GENEPSE
//
//  Created by 岩見建汰 on 2017/12/03.
//  Copyright © 2017年 Kenta. All rights reserved.
//

import Foundation
import UIKit

class FeedViewTestData {
    let test_names = ["岩見建汰", "Kenta Iwami"]
    let test_careers = ["UI/UXデザインを専門としています。これまで株式会社XYZのUIデザインのインターンで優勝経験があります。他には株式会社AAAを立ち上げ、月間PV数が1000万にもなるサイトを運営していたりします。", "UI/UXデザインを専門としています。これまで株式会社XYZのUIデザインのインターンで優勝経験があります。他には株式会社AAAを立ち上げ、月間PV数が1000万にもなるサイトを運営していたりします。"]
    let test_images = ["https://bomanite.com/wp-content/uploads/2015/03/HTC-One-Photo-Sample-Marbles.jpeg", "https://res.cloudinary.com/demo/image/upload/w_500/sample.jpg"]
    
    func GetNames() -> Array<String> {
        return test_names
    }
    
    func GetCareers() -> Array<String> {
        return test_careers
    }
    
    func GetImages() -> Array<String> {
        return test_images
    }
}

