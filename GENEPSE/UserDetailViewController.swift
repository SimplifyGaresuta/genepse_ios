//
//  UserDetailViewController.swift
//  GENEPSE
//
//  Created by 岩見建汰 on 2017/12/04.
//  Copyright © 2017年 Kenta. All rights reserved.
//

import UIKit

class UserDetailViewController: UIViewController {

    let appDelegate:AppDelegate = UIApplication.shared.delegate as! AppDelegate
    var user_id = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.blue
        user_id = appDelegate.current_user!
        print(user_id)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func SetUserID(id: Int) {
        user_id = id
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
