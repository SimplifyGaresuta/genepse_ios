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
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        
        let newController = viewControllers![1]
        
        if viewController == newController {
            let storyboard = UIStoryboard(name: "Chat", bundle: nil)
            let vc = storyboard.instantiateInitialViewController()
            present(vc!, animated: true, completion: nil)
            
            return false
        }
        
        
        return true
    }
}
