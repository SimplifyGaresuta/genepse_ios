//
//  FeedViewController.swift
//  GENEPSE
//
//  Created by 岩見建汰 on 2017/12/02.
//  Copyright © 2017年 Kenta. All rights reserved.
//

import UIKit

class FeedViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.layoutIfNeeded()
        
        let lr_margin = self.view.bounds.width * 0.1
        let card_width = self.view.bounds.width * 0.8
        let card_height = self.view.bounds.height * 0.65
        
        let scroll_view = UIScrollView()
        scroll_view.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height)
        self.view.addSubview(scroll_view)
        
        let card_view = UIView()
        card_view.backgroundColor = UIColor.white
        card_view.layer.cornerRadius = 20
        card_view.layer.shadowOpacity = 0.5
        card_view.layer.shadowColor = UIColor.black.cgColor
        card_view.layer.shadowOffset = CGSize(width: 0.5, height: 0.5)
        card_view.layer.shadowRadius = 20
        view.layer.masksToBounds = false
        
        card_view.frame = CGRect(x: lr_margin, y: lr_margin, width: card_width, height: card_height)
        
        print(card_view.frame)
        print(card_view.frame.height)
        
        let y_position = card_view.frame.height + card_view.frame.origin.y
        print(y_position)
        scroll_view.addSubview(card_view)

        let image = UIImage(named: "sample1")
        
        let hoge_image = UIImageView()
        hoge_image.frame = CGRect(x: 0, y: 0, width: card_view.frame.width, height: card_view.frame.height/2)
        hoge_image.backgroundColor = UIColor.black
        hoge_image.image = image
        hoge_image.contentMode = .scaleAspectFill
        
        let maskPath = UIBezierPath(roundedRect: hoge_image.frame,
                                    byRoundingCorners: [.topLeft, .topRight],
                                    cornerRadii: CGSize(width: 20, height: 20))
        let maskLayer = CAShapeLayer()
        maskLayer.path = maskPath.cgPath
        hoge_image.layer.mask = maskLayer
        
        card_view.addSubview(hoge_image)
        
        let card_view2 = UIView()
        card_view2.frame = CGRect(x: lr_margin, y: y_position, width: card_width, height: card_height)
        
        scroll_view.addSubview(card_view2)
        
        let refresh_controll = UIRefreshControl()
        
        scroll_view.contentSize = CGSize(width: self.view.bounds.width, height: card_view2.frame.height+card_view2.frame.origin.y+50)
        scroll_view.refreshControl = refresh_controll
        refresh_controll.addTarget(self, action: #selector(self.refresh(sender:)), for: .valueChanged)
        
        scroll_view.translatesAutoresizingMaskIntoConstraints = false
        scroll_view.topAnchor.constraint(equalTo:self.view.topAnchor).isActive = true
        scroll_view.trailingAnchor.constraint(equalTo:self.view.trailingAnchor).isActive = true
        scroll_view.bottomAnchor.constraint(equalTo:self.view.bottomAnchor).isActive = true
        scroll_view.leadingAnchor.constraint(equalTo:self.view.leadingAnchor).isActive = true
    }
    
    func refresh(sender: UIRefreshControl) {
        print("hoge!!")
        sender.endRefreshing()
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
