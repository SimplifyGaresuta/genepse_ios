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
    var profileImageView = UIImageView()
    var nameLabel = UILabel()
    var base_margin = 0.0 as CGFloat
    var card_width = 0.0 as CGFloat
    var card_height = 0.0 as CGFloat
    
    var test_names: [String] = []
    var test_careers: [String] = []
    var test_images: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.layoutIfNeeded()
        
        GetFeedData()
        
        base_margin = self.view.bounds.width * 0.1
        card_width = self.view.bounds.width * 0.8
        card_height = self.view.bounds.height * 0.65
        
        let scroll_view = UIScrollView()
        scroll_view.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height)
        self.view.addSubview(scroll_view)
        
        var card_start_y = base_margin
        
        for i in 0..<test_names.count {
            // カードを追加
            cardView = self.CreateCard(card_start_y: card_start_y)
            scroll_view.addSubview(cardView)
            
            // プロフィール画像を追加
            profileImageView = self.CreateProfileImageView(url: test_images[i])
            cardView.addSubview(profileImageView)
            
            // 名前のラベルを追加
            nameLabel = self.CreateNameLabel(text: test_names[i])
            cardView.addSubview(nameLabel)
            
            // 経歴のラベルを追加
            let careerLabel = self.CreateCareerLabel(text: test_careers[i])
            cardView.addSubview(careerLabel)
            
            // 次に描画するカードのyを保存
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
    
    func CreateProfileImageView(url: String) -> UIImageView {
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
        name_label.frame = CGRect(x: base_margin*0.5, y: profileImageView.frame.height+base_margin*0.25, width: cardView.frame.width, height: base_margin)
        name_label.sizeToFit()
        
        return name_label
    }
    
    func CreateCareerLabel(text: String) -> UILabel {
        let label_start_y = nameLabel.frame.origin.y+nameLabel.frame.height
        
        let career_label = UILabel()
        career_label.font = UIFont(name: "AmericanTypewriter-Bold", size: UIFont.systemFontSize)
        career_label.frame = CGRect(x: base_margin*0.5, y: label_start_y, width: cardView.frame.width-base_margin, height: base_margin*2)
        career_label.backgroundColor = UIColor.clear
        career_label.numberOfLines = 0
        
        let lineHeight:CGFloat = 23.0
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.minimumLineHeight = lineHeight
        paragraphStyle.maximumLineHeight = lineHeight
        paragraphStyle.lineBreakMode = .byTruncatingTail
        let attributedText = NSMutableAttributedString(string: text)
        attributedText.addAttribute(NSParagraphStyleAttributeName, value: paragraphStyle, range: NSMakeRange(0, attributedText.length))
        career_label.attributedText = attributedText
        
        return career_label
    }
    
    func GetFeedData() {
        let test_data = FeedViewTestData()
        test_names = test_data.GetNames()
        test_images = test_data.GetImages()
        test_careers = test_data.GetCareers()
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

