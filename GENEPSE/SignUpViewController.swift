//
//  SignUpViewController.swift
//  GENEPSE
//
//  Created by 岩見建汰 on 2017/12/10.
//  Copyright © 2017年 Kenta. All rights reserved.
//

import UIKit

class SignUpViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        InitView()
    }
    
    func InitView() {
        let full_w = self.view.frame.width
        let full_h = self.view.frame.height
        
        let bgImageView = UIImageView(image: UIImage(named: "sample2.jpg"))
        bgImageView.frame = CGRect(x: 0, y: 0, width: full_w, height: full_h)
        bgImageView.contentMode = .scaleAspectFill
        self.view.addSubview(bgImageView)
        
        //TODO: frameを要検討
        let genepse_tokyoImageView = UIImageView(image: UIImage(named: "genepse_tokyo.png"))
        genepse_tokyoImageView.frame = CGRect(x: 100, y: 100, width: full_w*0.5, height: 10)
        genepse_tokyoImageView.contentMode = .scaleAspectFill
        self.view.addSubview(genepse_tokyoImageView)
        
        //TODO: frameを要検討
        let start_facebookButton = UIButton(frame: CGRect(x: 100, y: 500, width: full_w*0.5, height: 50))
        start_facebookButton.contentMode = .scaleAspectFill
        start_facebookButton.setImage(UIImage(named: "start_facebook.png"), for: .normal)
        start_facebookButton.addTarget(self, action: #selector(self.TapStartButton(sender:)), for: .touchUpInside)
        self.view.addSubview(start_facebookButton)
    }
    
    func TapStartButton(sender: UIButton) {
        print("tap")
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
