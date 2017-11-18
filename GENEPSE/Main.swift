//
//  Main.swift
//  GENEPSE
//
//  Created by 岩見建汰 on 2017/11/18.
//  Copyright © 2017年 Kenta. All rights reserved.
//

import UIKit

class Main: UIViewController {

    @IBOutlet weak var Tab: Tab!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // TODO: とりあえず決め打ち(iPhone6)
        Tab.bottomAnchor.constraint(equalTo:self.view.bottomAnchor, constant: -10.0).isActive = true
        Tab.topAnchor.constraint(equalTo:self.view.topAnchor, constant: 600.0).isActive = true

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
