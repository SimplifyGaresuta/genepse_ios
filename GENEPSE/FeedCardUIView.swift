//
//  FeedCardUIView.swift
//  GENEPSE
//
//  Created by 岩見建汰 on 2017/12/02.
//  Copyright © 2017年 Kenta. All rights reserved.
//

import UIKit

class FeedCardUIView: UIView {
    
    @IBOutlet weak var imageview: UIImageView!
    
    
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
        imageview.layer.cornerRadius = 20
        imageview.layer.masksToBounds = true
    }
 

}
