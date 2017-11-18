//
//  SampleTabBarController.swift
//  GENEPSE
//
//  Created by 岩見建汰 on 2017/11/18.
//  Copyright © 2017年 Kenta. All rights reserved.
//

import UIKit

class SampleTabBarController: UITabBarController,UITabBarControllerDelegate {

    
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        let storyboard = UIStoryboard(name: "Chat", bundle: nil)
        let ChatViewController = storyboard.instantiateInitialViewController()
        let CV_ID = viewController.restorationIdentifier
        let hoge = ChatViewController?.restorationIdentifier
        
        if let currentVC = self.selectedViewController {
            if CV_ID! == hoge! {
                let modalViewController: UIViewController = UIViewController()
                modalViewController.view.backgroundColor = UIColor.red
                currentVC.present(ChatViewController!, animated: true, completion: nil)
            }
        }
        
//        if CV_ID! == hoge! {
//            self.selectedViewController?.present(ChatViewController, animated: true, completion: nil)
//        }
    }
    
//    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
//        print(tabBarController.selectedIndex)
//
//        let storyboard = UIStoryboard(name: "Chat", bundle: nil)
//        let DummyViewController = storyboard.instantiateInitialViewController()
        
//        let hoge = DummyViewController?.restorationIdentifier
//        print(hoge!)
//        let hoge2 = self.selectedViewController
        
//        print("shoudselect: ", hoge2?.restorationIdentifier)
        
//        if viewController === viewController2 {
////        if viewController is DummyViewController {
//            // DummyViewControllerはモーダルを出したい特定のタブに紐付けたViewController
//            if let currentVC = self.selectedViewController{
//                //表示させるモーダル
////                let modalViewController: UIViewController = UIViewController()
//                //わかりやすく背景を赤色に
////                modalViewController.view.backgroundColor = UIColor.red
////                currentVC.present(modalViewController, animated: true, completion: nil)
//
//                let storyboard = UIStoryboard(name: "Chat", bundle: nil)
//                let DummyViewController = storyboard.instantiateInitialViewController()
//                currentVC.present(DummyViewController!, animated: true, completion: nil)
//            }
//            return false
//        }
//
//        return true
//    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}
