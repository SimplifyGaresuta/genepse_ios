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
    let users_data =  [
        "has_next": true,
        "users": [
            [
                "id": 1,
                "name": "Kenta Iwami",
                "avatar_url": "https://res.cloudinary.com/demo/image/upload/w_500/sample.jpg",
                "attribute": "Business",
                "skills": ["経営", "会計", "起業"],
                "overview": "これまでに複数インターンで頑張りましたこれまでに複数インターンで頑張りましたこれまでに複数インターンで頑張りましたこれまでに複数インターンで頑張りましたこれまでに複数インターンで頑張りましたこれまでに複数インターンで頑張りましたこれまでに複数インターンで頑張りましたこれまでに複数インターンで頑張りましたこれまでに複数インターンで頑張りましたこれまでに複数インターンで頑張りましたこれまでに複数インターンで頑張りましたこれまでに複数インターンで頑張りましたこれまでに複数インターンで頑張りました",
            ],
            [
                "id": 2,
                "name": "岩見建汰",
                "avatar_url": "https://bomanite.com/wp-content/uploads/2015/03/HTC-One-Photo-Sample-Marbles.jpeg",
                "attribute": "Engineer",
                "skills": ["python","自然言語処理","swift"],
                "overview": "研究では自然言語処理を行っています。インターンでは研究では自然言語処理を行っています。インターンでは研究では自然言語処理を行っています。インターンでは研究では自然言語処理を行っています。インターンでは研究では自然言語処理を行っています。インターンでは研究では自然言語処理を行っています。インターンでは研究では自然言語処理を行っています。インターンでは研究では自然言語処理を行っています。インターンでは研究では自然言語処理を行っています。インターンでは研究では自然言語処理を行っています。インターンでは研究では自然言語処理を行っています。インターンでは研究では自然言語処理を行っています。インターンでは",
            ],
            [
                "id": 3,
                "name": "いわみけんた",
                "avatar_url": "https://www.visioncritical.com/wp-content/uploads/2014/12/BLG_Andrew-G.-River-Sample_09.13.12.png",
                "attribute": "Designer",
                "skills": ["Illustrator", "Protopie", "sketch"],
                "overview": "UI/UXデザインを専門としています。これまで株式会社XYZのUIデザインのインターンで優勝経験があります。他には株式会社AAAを立ち上げ、月間PV数が1000万にもなるサイトを運営していたりします。UI/UXデザインを専門としています。これまで株式会社XYZのUIデザインのインターンで優勝経験があります。他には株式会社AAAを立ち上げ、月間PV数が1000万にもなるサイトを運営していたりします。UI/UXデザインを専門としています。これまで株式会社XYZのUIデザインのインターンで優勝経験があります。他には株式会社AAAを立ち上げ、月間PV数が1000万にもなるサイトを運営していたりします。UI/UXデザインを専門としています。これまで株式会社XYZのUIデザインのインターンで優勝経験があります。他には株式会社AAAを立ち上げ、月間PV数が1000万にもなるサイトを運営していたりします。",
                ]
        ]
    ] as [String : Any]
}


class UserDetailDummyData {
    let user_data = [
        "name": "岩見建汰",
        "overview": "UI/UXデザインを専門としています。これまで株式会社XYZのUIデザインのインターンで優勝経験があります。他には株式会社AAAを立ち上げ、月間PV数が1000万にもなるサイトを運営していたりします。ここにとても素晴らしい自己紹介の文章が入る。ここにとても素晴らしい自己紹介の文章が入る。ここにとても素晴らしい自己紹介の文章が入る。",
        "profile_img": "https://res.cloudinary.com/demo/image/upload/w_500/sample.jpg",
        "attr": "DESIGNER",
        "main_skills": ["Illustrator", "Protopie", "sketch"],
        "awards": ["AdTech Charenge 優勝", "CrossOverGameJam 優勝", "ジロッカソン terateil賞"],
        "skills": ["Illustrator", "Protopie", "sketch", "ruby", "go", "unity"],
        "products": [
            ["title": "リア充無双", "url": "https://appsto.re/jp/26J0gb.i","image":"https://res.cloudinary.com/demo/image/upload/w_500/sample.jpg"
            ],
            ["title": "Webクローラー", "url": "https://github.com/ryonakao/netsurfer","image":"https://res.cloudinary.com/demo/image/upload/w_500/sample.jpg"
            ]
        ],
        "sns": [
            ["provider": "facebook", "url": "https://www.facebook.com/nakao.boy"
            ],
            ["provider": "twitter", "url": "https://www.facebook.com/nakao.boy"
            ]
        ],
        "license": ["TOEIC 820点", "FP2級"],
        "gender": "男",
        "age": 20,
        "address": "埼玉県さいたま市",
        "school_career": "中央大学商学部"
        ] as [String : Any]
}

