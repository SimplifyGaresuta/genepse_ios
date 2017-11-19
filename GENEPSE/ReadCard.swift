//
//  Card.swift
//  GENEPSE
//
//  Created by 岩見建汰 on 2017/11/18.
//  Copyright © 2017年 Kenta. All rights reserved.
//

import UIKit

class ReadCard: UIView {
    
    override init(frame: CGRect){
        super.init(frame: frame)
        loadNib()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        loadNib()
    }
    
    func loadNib(){
        let view = Bundle.main.loadNibNamed("Card", owner: self, options: nil)?.first as! UIView
        view.frame = self.bounds
        self.addSubview(view)
    }
}

