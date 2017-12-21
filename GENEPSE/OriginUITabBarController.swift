//
//  OriginUITabBarController.swift
//  GENEPSE
//
//  Created by 岩見建汰 on 2017/11/19.
//  Copyright © 2017年 Kenta. All rights reserved.
//

import UIKit

class OriginUITabBarController: UITabBarController, UITabBarControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        
        self.tabBar.barTintColor = UIColor.black
        self.tabBar.isTranslucent = false
        
        let selectedAttributes = [
            NSFontAttributeName: UIFont.systemFont(ofSize: 10),
            NSForegroundColorAttributeName: UIColor.white
        ]
        
        self.tabBarItem.setTitleTextAttributes(selectedAttributes, for: UIControlState.selected)
        
        UITabBar.appearance().tintColor = UIColor.white
        
//        let selected_name = ["tabbar_feed_selected", "tabbar_locationfeed_selected", "tabbar_myprofile_selected"]
//        let unselected_name = ["tabbar_feed_unselected", "tabbar_locationfeed_unselected", "tabbar_myprofile_unselected"]
//
//        for (i, (selected, unselected)) in zip(selected_name, unselected_name).enumerated() {
//            let item = self.tabBar.items![i]
//            item.selectedImage = UIImage(named: selected)
//            item.image = UIImage(named: unselected)
//
//            item.imageInsets = UIEdgeInsets(top: 0, left: 2, bottom: -14, right: 2)
//        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
