//
//  UserDetailViewController.swift
//  GENEPSE
//
//  Created by 岩見建汰 on 2017/12/04.
//  Copyright © 2017年 Kenta. All rights reserved.
//

import UIKit

class UserDetailViewController: UIViewController {
    private var user_id = 0
    var base_margin = 0.0 as CGFloat
    var navigation_bar_end_position = 0.0 as CGFloat
    
    var cardScrollView = UIScrollView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        base_margin = self.view.bounds.width * 0.05
        navigation_bar_end_position = (self.navigationController?.navigationBar.frame.size.height)! + (self.navigationController?.navigationBar.frame.origin.y)!
        
        self.view.backgroundColor = UIColor.white
        print(user_id)
        
        InitCardScrollView()
    }
    
    func InitCardScrollView () {
        cardScrollView.frame = CGRect(x: base_margin, y: navigation_bar_end_position+base_margin, width: self.view.bounds.width - base_margin * 2, height: self.view.bounds.height)
        cardScrollView.backgroundColor = UIColor.white
        
        cardScrollView.layer.cornerRadius = 20
        cardScrollView.layer.shadowOpacity = 1.0
        cardScrollView.layer.shadowColor = UIColor.black.cgColor
        cardScrollView.layer.shadowOffset = CGSize(width: 2, height: 2)
        cardScrollView.layer.shadowRadius = 10
        cardScrollView.layer.masksToBounds = false
        
        self.view.addSubview(cardScrollView)
    }
    
    func SetUserID(id: Int) {
        user_id = id
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
