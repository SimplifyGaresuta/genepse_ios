//
//  Utility.swift
//  GENEPSE
//
//  Created by 岩見建汰 on 2017/12/09.
//  Copyright © 2017年 Kenta. All rights reserved.
//

import UIKit

func GetAttributeColor(attr: String) -> UIColor {
    var bg_color: UIColor
    
    switch attr {
    case AttributeStr.Designer.rawValue:
        bg_color = UIColor.hexStr(hexStr: AttributeColor.red.rawValue as NSString, alpha: 1.0)
        break
    case AttributeStr.Engineer.rawValue:
        bg_color = UIColor.hexStr(hexStr: AttributeColor.blue.rawValue as NSString, alpha: 1.0)
        break
    default:
        bg_color = UIColor.hexStr(hexStr: AttributeColor.green.rawValue as NSString, alpha: 1.0)
        break
    }
    
    return bg_color
}
