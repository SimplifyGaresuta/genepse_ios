//
//  Extension.swift
//  GENEPSE
//
//  Created by 岩見建汰 on 2017/12/04.
//  Copyright © 2017年 Kenta. All rights reserved.
//

import UIKit

extension UIScrollView {
    public enum ScrollDirection {
        case top
//        case bottom
//        case left
//        case right
    }
    
    public func scroll(to direction: ScrollDirection, animated: Bool) {
        let offset: CGPoint
        switch direction {
        case .top:
            offset = CGPoint(x: contentOffset.x, y: -adjustedContentInset.top)
//        case .bottom:
//            offset = CGPoint(x: contentOffset.x, y: max(-contentInset.top, contentSize.height - frame.height + contentInset.bottom))
//        case .left:
//            offset = CGPoint(x: -contentInset.left, y: contentOffset.y)
//        case .right:
//            offset = CGPoint(x: max(-contentInset.left, contentSize.width - frame.width + contentInset.right), y: contentOffset.y)
        }
        setContentOffset(offset, animated: animated)
    }
}

extension UIColor {
    class func hexStr ( hexStr : NSString, alpha : CGFloat) -> UIColor {
        let alpha = alpha
        var hexStr = hexStr
        hexStr = hexStr.replacingOccurrences(of: "#", with: "") as NSString
        let scanner = Scanner(string: hexStr as String)
        var color: UInt32 = 0
        if scanner.scanHexInt32(&color) {
            let r = CGFloat((color & 0xFF0000) >> 16) / 255.0
            let g = CGFloat((color & 0x00FF00) >> 8) / 255.0
            let b = CGFloat(color & 0x0000FF) / 255.0
            return UIColor(red:r,green:g,blue:b,alpha:alpha)
        } else {
            print("invalid hex string")
            return UIColor.white;
        }
    }
}

