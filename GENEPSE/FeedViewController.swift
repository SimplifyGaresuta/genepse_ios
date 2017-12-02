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
        
        let imageView = AsyncUIImageView(frame: CGRect(x: 0, y: 0, width: card_view.frame.width, height: card_view.frame.height*0.7))
        imageView.loadImage(urlString: "https://res.cloudinary.com/demo/image/upload/w_500/sample.jpg")
        imageView.contentMode = .scaleAspectFill
        
        let maskPath = UIBezierPath(roundedRect: imageView.frame,
                                    byRoundingCorners: [.topLeft, .topRight],
                                    cornerRadii: CGSize(width: 20, height: 20))
        let maskLayer = CAShapeLayer()
        maskLayer.path = maskPath.cgPath
        imageView.layer.mask = maskLayer
        
        card_view.addSubview(imageView)
        
        let name_label = UILabel()
        name_label.text = "岩見 建汰"
        name_label.font = UIFont(name: "AmericanTypewriter-Bold", size: 30)
        name_label.frame = CGRect(x: lr_margin*0.5, y: imageView.frame.height+lr_margin*0.5, width: card_view.frame.width, height: 50)
        name_label.sizeToFit()
        
        card_view.addSubview(name_label)
        
        let hoge = NSMutableParagraphStyle()
        hoge.paragraphSpacing = 50.0
        hoge.lineBreakMode = .byTruncatingTail
        let hoge2 = [NSParagraphStyleAttributeName: hoge]
        
        let label_height = card_view.frame.origin.y + card_view.frame.height - (imageView.frame.height+name_label.frame.height+lr_margin)
        
        print("***************")
        print(card_view.frame.origin.y)
        print(card_view.frame.height)
        print(imageView.frame.height)
        print(name_label.frame.height)
        let career_label = UILabel()
//        career_label.text = "UI/UXデザインを専門としています。これまで株式会社XYZのUIデザインのインターンで優勝経験があります。"
        career_label.font = UIFont(name: "AmericanTypewriter-Bold", size: UIFont.systemFontSize)
        career_label.frame = CGRect(x: lr_margin*0.5, y: imageView.frame.height+name_label.frame.height+lr_margin*0.5, width: card_view.frame.width-(lr_margin), height: label_height)
        career_label.backgroundColor = UIColor.blue
        career_label.numberOfLines = 0
        career_label.attributedText = NSMutableAttributedString(string: "UI/UXデザインを専門としています。これまで株式会社XYZのUIデザインのインターンで優勝経験があります。", attributes: hoge2)
//        career_label.sizeToFit()
        
        card_view.addSubview(career_label)

        

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

