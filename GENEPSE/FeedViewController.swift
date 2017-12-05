//
//  FeedViewController.swift
//  GENEPSE
//
//  Created by 岩見建汰 on 2017/12/02.
//  Copyright © 2017年 Kenta. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class FeedViewController: UIViewController, UIScrollViewDelegate, UITabBarControllerDelegate {
    var scrollView = UIScrollView()
    var cardViews: [UIView] = [UIView()]
    var profileImageView = UIImageView()
    var nameLabel = UILabel()
    var base_margin = 0.0 as CGFloat
    var card_width = 0.0 as CGFloat
    var card_height = 0.0 as CGFloat
    var card_start_y = 0.0 as CGFloat
    
    var isUpdating = false
    var preViewName = "Feed"
    
    var dummy_names: [String] = []
    var dummy_careers: [String] = []
    var dummy_images: [String] = []
    var dummy_attributes: [String] = []
    var dummy_main_skills = [[String]]()
    var dummy_count = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.layoutIfNeeded()
        
        GetFeedData()
        
        base_margin = self.view.bounds.width * 0.1
        card_width = self.view.bounds.width * 0.8
        card_height = self.view.bounds.height * 0.65
        
        scrollView.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height)
        self.view.addSubview(scrollView)
        scrollView.delegate = self
        
        self.tabBarController?.delegate = self
        
        card_start_y = base_margin
        
        CallFeedAPI()
        
        let refresh_controll = UIRefreshControl()
        scrollView.refreshControl = refresh_controll
        refresh_controll.addTarget(self, action: #selector(self.refresh(sender:)), for: .valueChanged)
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.topAnchor.constraint(equalTo:self.view.topAnchor).isActive = true
        scrollView.trailingAnchor.constraint(equalTo:self.view.trailingAnchor).isActive = true
        scrollView.bottomAnchor.constraint(equalTo:self.view.bottomAnchor).isActive = true
        scrollView.leadingAnchor.constraint(equalTo:self.view.leadingAnchor).isActive = true
    }
    
    func refresh(sender: UIRefreshControl) {
        for cardView in cardViews {
            cardView.removeFromSuperview()
        }
        
        cardViews.removeAll()
        
        //初期化
        card_start_y = base_margin
        dummy_count = 0
        
        AddCard()
        
        sender.endRefreshing()
    }
    
    func AddCard() {
        for i in 0..<self.dummy_names.count {
            // カードを追加
            cardViews.append(self.CreateCard(card_start_y: self.card_start_y))
            self.self.scrollView.addSubview(cardViews.last!)
            
            // プロフィール画像を追加
            self.profileImageView = self.CreateProfileImageView(url: self.dummy_images[i])
            cardViews.last!.addSubview(self.profileImageView)
            
            // 属性ラベルを追加
            let attributeLabels = self.CreateAttributeLabel(attribute: self.dummy_attributes[i])
            cardViews.last!.addSubview(attributeLabels.0)
            cardViews.last!.addSubview(attributeLabels.1)
            
            // メインスキルを追加
            let mainskillsLabels = self.CreateMainSkillsLabels(skills: self.dummy_main_skills[i])
            for (shadowView, skillLabel) in zip(mainskillsLabels.0, mainskillsLabels.1) {
                cardViews.last!.addSubview(shadowView)
                cardViews.last!.addSubview(skillLabel)
            }
            
            // 名前のラベルを追加
            self.nameLabel = self.CreateNameLabel(text: self.dummy_names[i])
            cardViews.last!.addSubview(self.nameLabel)
            
            // 経歴のラベルを追加
            let careerLabel = self.CreateCareerLabel(text: self.dummy_careers[i])
            cardViews.last!.addSubview(careerLabel)
            
            // 次に描画するカードのyを保存
            self.card_start_y = cardViews.last!.frame.height + cardViews.last!.frame.origin.y + self.base_margin*0.5
        }
        
        self.scrollView.contentSize = CGSize(width: self.view.bounds.width, height: cardViews.last!.frame.height+cardViews.last!.frame.origin.y+self.base_margin)
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
        card_view.tag = dummy_count
        
        dummy_count += 1
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.TapCard(sender:)))
        card_view.addGestureRecognizer(tap)
        
        return card_view
    }
    
    func TapCard(sender: UITapGestureRecognizer){
        let user_detail_VC = UserDetailViewController()
        user_detail_VC.SetUserID(id: (sender.view?.tag)!)
        self.navigationController!.pushViewController(user_detail_VC, animated: true)
    }
    
    func CreateProfileImageView(url: String) -> UIImageView {
        let imageView = AsyncUIImageView(frame: CGRect(x: 0, y: 0, width: cardViews.last!.frame.width, height: cardViews.last!.frame.height*0.7))
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
        let name_label = UILabel(frame: CGRect(x: base_margin*0.5, y: profileImageView.frame.height+base_margin*0.25, width: cardViews.last!.frame.width, height: base_margin))
        name_label.text = text
        name_label.font = UIFont(name: "AmericanTypewriter-Bold", size: 30)
        name_label.sizeToFit()
        
        return name_label
    }
    
    func CreateCareerLabel(text: String) -> UILabel {
        let label_start_y = nameLabel.frame.origin.y+nameLabel.frame.height
        
        let career_label = UILabel(frame: CGRect(x: base_margin*0.5, y: label_start_y, width: cardViews.last!.frame.width-base_margin, height: base_margin*2))
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
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y + scrollView.frame.size.height > scrollView.contentSize.height && scrollView.isDragging && !isUpdating {
            isUpdating = true
            CallFeedAPI()
        }
    }
    
    func CallFeedAPI(){
        let urlString: String = "https://kentaiwami.jp/FiNote/django.cgi/api/v1/get_recently_movie/"
        Alamofire.request(urlString, method: .get).responseJSON { (response) in
            guard let object = response.result.value else{return}
            let json = JSON(object)
            print(json.count)
            
            self.AddCard()
            
            self.isUpdating = false
        }
    }
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        
        if viewController.restorationIdentifier! == "Feed" && preViewName == "Feed" {
            scrollView.scroll(to: .top, animated: true)
        }
        
        preViewName = viewController.restorationIdentifier!
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

