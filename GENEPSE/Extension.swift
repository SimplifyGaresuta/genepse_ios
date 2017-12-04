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
