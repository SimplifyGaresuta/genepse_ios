//
//  OriginUInavigationController.swift
//  GENEPSE
//
//  Created by 岩見建汰 on 2017/11/19.
//  Copyright © 2017年 Kenta. All rights reserved.
//

import UIKit

class OriginUInavigationController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()

        //ナビゲーションバーの色を設定
        navigationBar.barTintColor = UIColor.hexStr(hexStr: "#000000", alpha: 1.0)
//        navigationBar.alpha = 0.1
        navigationBar.isTranslucent = false
        
        navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        self.navigationBar.tintColor = UIColor.white
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
