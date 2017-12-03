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
    
    var dummy_names: [String] = []
    var dummy_careers: [String] = []
    var dummy_images: [String] = []
    var dummy_attributes: [String] = []
    var dummy_main_skills = [[String]]()
    
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
        
        for i in 0..<dummy_names.count {
            // カードを追加
            cardView = self.CreateCard(card_start_y: card_start_y)
            scroll_view.addSubview(cardView)
            
            // プロフィール画像を追加
            profileImageView = self.CreateProfileImageView(url: dummy_images[i])
            cardView.addSubview(profileImageView)
            
            // 属性ラベルを追加
            let attributeLabels = self.CreateAttributeLabel(attribute: dummy_attributes[i])
            cardView.addSubview(attributeLabels.0)
            cardView.addSubview(attributeLabels.1)
            
            // メインスキルを追加
            let mainskillsLabels = self.CreateMainSkillsLabels(skills: dummy_main_skills[i])
            for (shadowView, skillLabel) in zip(mainskillsLabels.0, mainskillsLabels.1) {
                cardView.addSubview(shadowView)
                cardView.addSubview(skillLabel)
            }
            
            // 名前のラベルを追加
            nameLabel = self.CreateNameLabel(text: dummy_names[i])
            cardView.addSubview(nameLabel)
            
            // 経歴のラベルを追加
            let careerLabel = self.CreateCareerLabel(text: dummy_careers[i])
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
        let card_view = UIView(frame: CGRect(x: base_margin, y: card_start_y, width: card_width, height: card_height))
        card_view.backgroundColor = UIColor.white
        card_view.layer.cornerRadius = 20
        card_view.layer.shadowOpacity = 0.5
        card_view.layer.shadowColor = UIColor.black.cgColor
        card_view.layer.shadowOffset = CGSize(width: 0.5, height: 0.5)
        card_view.layer.shadowRadius = 20
        card_view.layer.masksToBounds = false
        
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
        let name_label = UILabel(frame: CGRect(x: base_margin*0.5, y: profileImageView.frame.height+base_margin*0.25, width: cardView.frame.width, height: base_margin))
        name_label.text = text
        name_label.font = UIFont(name: "AmericanTypewriter-Bold", size: 30)
        name_label.sizeToFit()
        
        return name_label
    }
    
    func CreateCareerLabel(text: String) -> UILabel {
        let label_start_y = nameLabel.frame.origin.y+nameLabel.frame.height
        
        let career_label = UILabel(frame: CGRect(x: base_margin*0.5, y: label_start_y, width: cardView.frame.width-base_margin, height: base_margin*2))
        career_label.font = UIFont(name: "AmericanTypewriter-Bold", size: UIFont.systemFontSize)
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
    
    func CreateAttributeLabel(attribute: String) -> (UIView, UILabel) {
        var bg_color: UIColor
        switch attribute {
        case "DESIGNER":
            bg_color = UIColor.red
            break
        case "ENGINEER":
            bg_color = UIColor.blue
            break
        default:
            bg_color = UIColor.green
            break
        }
        
        let label_start_y = profileImageView.frame.origin.y + base_margin*0.5
        
        // 属性ラベル
        let attribute_label = UILabel(frame: CGRect(x: 0, y: label_start_y, width: 0, height: 0))
        attribute_label.text = "   " + attribute + "   "
        attribute_label.font = UIFont(name: "AmericanTypewriter-Bold", size: 20)
        attribute_label.backgroundColor = bg_color
        attribute_label.textColor = UIColor.white
        attribute_label.sizeToFit()
        
        // 右上，右下を角丸に
        let maskPath = UIBezierPath(roundedRect: attribute_label.bounds, byRoundingCorners: [.topRight, .bottomRight], cornerRadii: CGSize(width: 20, height: 20)).cgPath
        let maskLayer = CAShapeLayer()
        maskLayer.frame = attribute_label.bounds
        maskLayer.path = maskPath
        attribute_label.layer.mask = maskLayer
        
        // 影をつけるためのViewを作成
        let shadow_view = UIView(frame: attribute_label.frame)
        shadow_view.backgroundColor = bg_color
        shadow_view.layer.shadowColor = UIColor.black.cgColor
        shadow_view.layer.shadowOpacity = 1.0
        shadow_view.layer.shadowOffset = CGSize(width: 1, height: 1)
        shadow_view.layer.shadowRadius = 2
        shadow_view.layer.cornerRadius = 10
        
        return (shadow_view, attribute_label)
    }
    
    func CreateMainSkillsLabels(skills: Array<String>) -> (Array<UIView>, Array<UILabel>) {
        var labels = [UILabel]()
        var views = [UIView]()
        let bg_color = UIColor.white
        
        var labelstart_x = base_margin * 0.25
        let label_y = profileImageView.frame.origin.y + profileImageView.frame.height
        
        for skill in skills {
            // skillラベルの生成
            let label = UILabel(frame: CGRect(x: labelstart_x, y: label_y, width: 0, height: 0))
            label.text = "  " + skill + "  "
            label.backgroundColor = bg_color
            label.sizeToFit()
            label.layer.cornerRadius = 10
            label.layer.masksToBounds = true
            label.frame = CGRect(x: labelstart_x, y: label.frame.origin.y-label.frame.height - base_margin*0.25, width: 0, height: 0)   //プロフ画像のbottomからマージン分だけ上に
            label.sizeToFit()   //w, hの再調整
            
            labelstart_x = label.frame.origin.x + label.frame.width + base_margin*0.25
            
            // 影Viewの生成
            let offset = 1.5
            let shadow = UIView(frame: CGRect(x: label.frame.origin.x, y: label.frame.origin.y, width: label.frame.width, height: label.frame.height))
            shadow.layer.shadowColor = UIColor.black.cgColor
            shadow.backgroundColor = bg_color
            shadow.layer.shadowOpacity = 1.0
            shadow.layer.shadowOffset = CGSize(width: offset, height: offset)
            shadow.layer.shadowRadius = CGFloat(offset)
            shadow.layer.cornerRadius = 10
            
            labels.append(label)
            views.append(shadow)
        }
        return (views, labels)
    }
    
    func GetFeedData() {
        let dummy_data = FeedViewDummyData()
        dummy_names = dummy_data.GetNames()
        dummy_images = dummy_data.GetImages()
        dummy_careers = dummy_data.GetCareers()
        dummy_attributes = dummy_data.GetAttributes()
        dummy_main_skills = dummy_data.GetMainSkills()
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

