//
//  FeedViewController.swift
//  GENEPSE
//
//  Created by 岩見建汰 on 2017/12/02.
//  Copyright © 2017年 Kenta. All rights reserved.
//

import UIKit

class FeedViewController: UIViewController {
    
    var cardView = UIView()
    var profileimageView = UIImageView()
    var name_label = UILabel()
    var base_margin = 0.0 as CGFloat
    var card_width = 0.0 as CGFloat
    var card_height = 0.0 as CGFloat
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.layoutIfNeeded()
        
        base_margin = self.view.bounds.width * 0.1
        card_width = self.view.bounds.width * 0.8
        card_height = self.view.bounds.height * 0.65
        
        let scroll_view = UIScrollView()
        scroll_view.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height)
        self.view.addSubview(scroll_view)
        
        var card_start_y = base_margin
        
        for i in 0...1 {
            // カードを追加
            cardView = self.CreateCard(card_start_y: card_start_y)
            scroll_view.addSubview(cardView)
            
            // プロフィール画像を追加
            profileimageView = self.CreateProfileImage(url: "https://res.cloudinary.com/demo/image/upload/w_500/sample.jpg")
            cardView.addSubview(profileimageView)
            
            name_label = self.CreateNameLabel(text: String(i))
            cardView.addSubview(name_label)
            
            let career_label = self.hoge4()
            cardView.addSubview(career_label)
            
            card_start_y = cardView.frame.height + cardView.frame.origin.y + base_margin*0.5
        }
        
        let refresh_controll = UIRefreshControl()
        
        scroll_view.contentSize = CGSize(width: self.view.bounds.width, height: cardView.frame.height+cardView.frame.origin.y+base_margin)
        scroll_view.refreshControl = refresh_controll
        refresh_controll.addTarget(self, action: #selector(self.refresh(sender:)), for: .valueChanged)
        
        scroll_view.translatesAutoresizingMaskIntoConstraints = false
        scroll_view.topAnchor.constraint(equalTo:self.view.topAnchor).isActive = true
        scroll_view.trailingAnchor.constraint(equalTo:self.view.trailingAnchor).isActive = true
        scroll_view.bottomAnchor.constraint(equalTo:self.view.bottomAnchor).isActive = true
        scroll_view.leadingAnchor.constraint(equalTo:self.view.leadingAnchor).isActive = true
        
        
//        let AAA = UIView()
//        AAA.frame = CGRect(x: 0, y: card_view.frame.height+card_view.frame.origin.y, width: self.view.frame.width, height: 10)
//        AAA.backgroundColor = UIColor.red
//        scroll_view.addSubview(AAA)
    }
    
    func refresh(sender: UIRefreshControl) {
        print("hoge!!")
        sender.endRefreshing()
    }
    
    func CreateCard(card_start_y: CGFloat) -> UIView {
        let card_view = UIView()
        card_view.backgroundColor = UIColor.white
        card_view.layer.cornerRadius = 20
        card_view.layer.shadowOpacity = 0.5
        card_view.layer.shadowColor = UIColor.black.cgColor
        card_view.layer.shadowOffset = CGSize(width: 0.5, height: 0.5)
        card_view.layer.shadowRadius = 20
        card_view.layer.masksToBounds = false
        
        card_view.frame = CGRect(x: base_margin, y: card_start_y, width: card_width, height: card_height)
        
        return card_view
    }
    
    func CreateProfileImage(url: String) -> UIImageView {
        let imageView = AsyncUIImageView(frame: CGRect(x: 0, y: 0, width: cardView.frame.width, height: cardView.frame.height*0.7))
        imageView.loadImage(urlString: url)
        imageView.contentMode = .scaleAspectFill
        
        let maskPath = UIBezierPath(roundedRect: imageView.frame,
                                    byRoundingCorners: [.topLeft, .topRight],
                                    cornerRadii: CGSize(width: 20, height: 20))
        let maskLayer = CAShapeLayer()
        maskLayer.path = maskPath.cgPath
        imageView.layer.mask = maskLayer
        
        return imageView
    }
    
    func CreateNameLabel(text: String) -> UILabel {
        let name_label = UILabel()
        name_label.text = text
        name_label.font = UIFont(name: "AmericanTypewriter-Bold", size: 30)
        name_label.frame = CGRect(x: base_margin*0.5, y: profileimageView.frame.height+base_margin*0.5, width: cardView.frame.width, height: 50)
        name_label.sizeToFit()
        
        return name_label
    }
    
    func hoge4() -> UILabel {
        let hoge = NSMutableParagraphStyle()
        hoge.paragraphSpacing = 50.0
        hoge.lineBreakMode = .byTruncatingTail
        let hoge2 = [NSParagraphStyleAttributeName: hoge]
        
        let label_height = cardView.frame.origin.y + cardView.frame.height - (profileimageView.frame.height+name_label.frame.height+base_margin)
        
        let career_label = UILabel()
        //        career_label.text = "UI/UXデザインを専門としています。これまで株式会社XYZのUIデザインのインターンで優勝経験があります。"
        career_label.font = UIFont(name: "AmericanTypewriter-Bold", size: UIFont.systemFontSize)
        career_label.frame = CGRect(x: base_margin*0.5, y: profileimageView.frame.height+name_label.frame.height+base_margin*0.5, width: cardView.frame.width-(base_margin), height: label_height)
        career_label.backgroundColor = UIColor.blue
        career_label.numberOfLines = 0
        career_label.attributedText = NSMutableAttributedString(string: "UI/UXデザインを専門としています。これまで株式会社XYZのUIデザインのインターンで優勝経験があります。", attributes: hoge2)
        //        career_label.sizeToFit()
        
        return career_label
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

