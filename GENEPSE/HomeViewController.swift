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
import Toucan

class HomeViewController: UIViewController, UIScrollViewDelegate, UITabBarControllerDelegate {
    var scrollView = UIScrollView()
    var cardViews: [UIView] = [UIView()]
    var last_frame = CGRect()
    
    var base_margin = 0.0 as CGFloat
    var card_start_y = 0.0 as CGFloat
    var view_w = 0.0 as CGFloat
    var view_h = 0.0 as CGFloat
    
    var isUpdating = false
    var preViewName = StoryboardID.Home.rawValue
    var limit = 20
    var offset = 0
    var has_next = true
    
    var user_id = 0
    
    //MARK: DEBUG
    let DEGUG = true
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.navigationItem.title = StoryboardID.Home.rawValue
        
        preViewName = StoryboardID.Home.rawValue
        self.tabBarController?.delegate = self
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let user_id = GetAppDelegate().user_id else {
            return
        }
        
        self.user_id = user_id

        self.view.layoutIfNeeded()
        
        base_margin = self.view.bounds.width * 0.1
        view_w = self.view.bounds.width
        view_h = self.view.bounds.height
        
        scrollView.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height)
        self.view.addSubview(scrollView)
        scrollView.delegate = self
        
        card_start_y = base_margin * 0.5
        
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
        sender.beginRefreshing()

        for cardView in cardViews {
            cardView.removeFromSuperview()
        }
        
        cardViews.removeAll()
        
        //初期化
        card_start_y = base_margin * 0.5
        ResetOffset()
        
        CallFeedAPI()
        
        sender.endRefreshing()
    }
    
    func AddCard(json: JSON) {
        let has_next = json["has_next"].boolValue
        self.has_next = has_next
        
        let users = json["users"].arrayValue
        
        for obj in users {
            let id = obj["id"].intValue
            
            //表示しようとしているカードが自分と同じ場合はスキップ
            if id == user_id {
                continue
            }
            
            let name = obj[Key.name.rawValue].stringValue
            let avatar_url = obj[Key.avatar_url.rawValue].stringValue
            let attribute = obj[Key.attribute.rawValue].stringValue
            let skills = obj[Key.skills.rawValue].arrayValue.map({$0.stringValue})
            let overview = obj[Key.overview.rawValue].stringValue
            let activity_base = obj[Key.activity_base.rawValue].stringValue

            // カードを追加
            cardViews.append(self.CreateCard(card_start_y: self.card_start_y))
            scrollView.addSubview(cardViews.last!)
            cardViews.last!.tag = id
            
            // 属性を追加
            let attributeLabel = self.CreateAttributeLabel(attribute: attribute)
            cardViews.last!.addSubview(attributeLabel)
            last_frame = attributeLabel.frame
            
            // プロフィール画像を追加
            let profileImageView = self.CreateProfileImageView(url: avatar_url)
            cardViews.last!.addSubview(profileImageView)
            last_frame = profileImageView.frame
            
            // 名前のラベルを追加
            let nameLabel = self.CreateNameLabel(text: name)
            cardViews.last!.addSubview(nameLabel)
            last_frame = nameLabel.frame
            
            
            // 活動拠点の追加
            let activity_baseView = self.CreateActivityBase(name: activity_base)
            cardViews.last!.addSubview(activity_baseView.0)
            cardViews.last!.addSubview(activity_baseView.1)
            last_frame = activity_baseView.1.frame

            
            // メインスキルを追加
            let mainskillsViews = self.CreateMainSkillsLabels(skills: skills)
            for view in mainskillsViews {
                if let label = view as? UILabel {
                    cardViews.last!.addSubview(label)
                }else {
                    cardViews.last!.addSubview(view as! UIImageView)
                }
            }
            
            if mainskillsViews.count != 0 {
                let lastview = mainskillsViews.last! as! UILabel
                last_frame = lastview.frame
            }
            
            // 経歴のラベルを追加
            let careerLabel = self.CreateCareerLabel(text: overview)
            cardViews.last!.addSubview(careerLabel)
            
            // 次に描画するカードのyを保存
            self.card_start_y = cardViews.last!.frame.height + cardViews.last!.frame.origin.y + self.base_margin*0.5
        }
        
        self.scrollView.contentSize = CGSize(width: self.view.bounds.width, height: cardViews.last!.frame.height+cardViews.last!.frame.origin.y+self.base_margin)
    }
    
    func CreateCard(card_start_y: CGFloat) -> UIView {
        let card_width = view_w * 0.8
        let card_height = view_h * 0.53
        
        let card_view = UIView(frame: CGRect(x: base_margin, y: card_start_y, width: card_width, height: card_height))
        card_view.backgroundColor = UIColor.white
        card_view.layer.cornerRadius = 10
        card_view.layer.shadowOpacity = 0.2
        card_view.layer.shadowColor = UIColor.black.cgColor
        card_view.layer.shadowOffset = CGSize(width: 2, height: 2)
        card_view.layer.shadowRadius = 5
        card_view.layer.masksToBounds = false
        
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
        let escapedAddress = url.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
        let url = URL(string: escapedAddress!)!
        
        do {
            let imageData: NSData = try NSData(contentsOf: url)
            let wh = base_margin * 3
            let x = cardViews.last!.frame.width / 2 - wh/2
            let y = last_frame.origin.y + last_frame.height + base_margin * 0.45
            
            let resizedAndMaskedImage = Toucan(image: UIImage(data: imageData as Data)!).resize(CGSize(width: wh, height: wh), fitMode: Toucan.Resize.FitMode.clip).maskWithEllipse().image
            let imageview = UIImageView(image: resizedAndMaskedImage)
            imageview.frame = CGRect(x: x, y: y, width: wh, height: wh)
            
            return imageview
        }catch{
            print(error)
        }
        
        return UIImageView()
    }
    
    func CreateNameLabel(text: String) -> UILabel {
        let je_num = SearchJapaneseEnglish(text: text)
        let font_name = GetFontName(je_num: je_num, font_w: 6)
        var font_size = 0 as CGFloat
        if je_num == JapaneseEnglish.Japanese.rawValue {
            font_size = 22
        }else {
            font_size = 23
        }
        
        let x = 0 as CGFloat
        let y = last_frame.origin.y+last_frame.height+base_margin * 0.4
        let w = cardViews.last!.frame.width
        
        let name_label = UILabel(frame: CGRect(x: x, y: y, width: w, height: font_size))
        name_label.text = text
        name_label.textAlignment = .center
        name_label.font = UIFont(name: font_name, size: font_size)
        
        return name_label
    }
    
    //TODO: 活動拠点の中心がずれているので調整
    func CreateActivityBase(name: String) -> (UIImageView, UILabel) {
        let homeImageView = UIImageView(image: UIImage(named: "icon_home"))
        let start_y = last_frame.origin.y+last_frame.height+base_margin*0.35
        let homeImageView_wh = 13 as CGFloat
        homeImageView.frame = CGRect(x: 0, y: start_y, width: homeImageView_wh, height: homeImageView_wh)
        
        let label = UILabel(frame: CGRect(x: 0, y: start_y, width: 0, height: 0))
        label.font = UIFont(name: FontName.J_W6.rawValue, size: 13)
        label.text = name
        label.sizeToFit()
        
        let label_start_x = (cardViews.last!.frame.width - (homeImageView.frame.width + label.frame.width)) / 2
        homeImageView.frame = CGRect(x: label_start_x, y: start_y, width: homeImageView_wh, height: homeImageView_wh)
        label.frame = CGRect(x: homeImageView.frame.origin.x+homeImageView.frame.width+base_margin*0.25, y: start_y, width: 0, height: 0)
        label.sizeToFit()

        return (homeImageView, label)
    }
    
    func CreateCareerLabel(text: String) -> UILabel {
        let label_start_y = last_frame.origin.y+last_frame.height + base_margin*0.2
        
        let x = cardViews.last!.frame.width * 0.1
        let w = cardViews.last!.frame.width * 0.8
        
        let career_label = UILabel(frame: CGRect(x: x, y: label_start_y, width: w, height: base_margin*2))
        career_label.font = UIFont(name: FontName.J_W6.rawValue, size: 12)
        career_label.backgroundColor = UIColor.clear
        career_label.numberOfLines = 0
        
        var attributedText = NSMutableAttributedString(string: text)
        attributedText = AddAttributedTextLineHeight(height: 21, text: attributedText)
        attributedText = AddAttributedTextLetterSpacing(space: -0.05, text: attributedText)
        
        career_label.attributedText = attributedText

        return career_label
    }
    
    func CreateAttributeLabel(attribute: String) -> UILabel {
        let x = 0 as CGFloat
        let y = base_margin * 0.5
        let w = cardViews.last!.frame.width
        let f_size = 13 as CGFloat
        
        let label = EdgeInsetLabel(frame: CGRect(x: x, y: y, width: w, height: f_size))
        label.attributedText = GetAttributeString(attr: attribute)
        label.textAlignment = .center
        label.font = UIFont(name: "DINAlternate-Bold", size: f_size)
        label.topTextInset = 30
        label.rightTextInset = 20
        label.bottomTextInset = 30
        label.leftTextInset = 20
        
        return label
    }
    
    //TODO: スキルの中心がずれているので調整
    func CreateMainSkillsLabels(skills: Array<String>) -> Array<Any> {
        var views:[Any] = []
        let y = last_frame.height+last_frame.origin.y+base_margin*0.5
        var x = 0 as CGFloat
        var sum_w = 0 as CGFloat
        
        //初期配置をしてサイズを求めるためのループ
        for skill in skills {
            //skillラベル追加
            let label = UILabel(frame: CGRect(x: x, y: y, width: 0, height: 0))
            label.text = skill
            label.font = UIFont(name: FontName.E_M.rawValue, size: 12)
            label.sizeToFit()
            views.append(label)
            
            x = label.frame.origin.x + label.frame.width + base_margin*0.25
            sum_w += label.frame.width+base_margin*0.25
            
            //スラッシュ画像追加
            let slash = UIImageView(image: UIImage(named: "icon_slash"))
            slash.frame = CGRect(x: x, y: y, width: 5, height: 15)
            views.append(slash)
            
            x = slash.frame.origin.x + slash.frame.width + base_margin*0.25
            sum_w += slash.frame.width+base_margin*0.25
        }
        
        if views.count != 0 {
            let last_view = views.last! as! UIImageView
            sum_w -= last_view.frame.width+base_margin*0.25
            _ = views.popLast()
        }
        
        var start_x = (cardViews.last!.frame.width - sum_w) / 2
        
        for view in views {
            if let label = view as? UILabel {
                label.frame = CGRect(x: start_x, y: y, width: 0, height: 0)
                label.sizeToFit()
                start_x = label.frame.origin.x + label.frame.width + base_margin*0.25
            }else {
                let slash = view as! UIImageView
                slash.frame = CGRect(x: start_x, y: y, width: 5, height: 15)
                start_x = slash.frame.origin.x + slash.frame.width + base_margin*0.25
            }
        }
        
        return views
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y + scrollView.frame.size.height > scrollView.contentSize.height && scrollView.isDragging && !isUpdating {
            if has_next {
                isUpdating = true
                UpOffset()
                CallFeedAPI()
            }
        }
    }
    
    func CallFeedAPI(){
        if DEGUG {
            let dummy = FeedViewDummyData().users_data
            self.AddCard(json: JSON(dummy))
        }else {
            let urlString: String = API.host.rawValue + API.v1.rawValue + API.users.rawValue + "?limit=" + String(limit) + "&offset=" + String(offset)
            
            Alamofire.request(urlString, method: .get).responseJSON { (response) in
                guard let object = response.result.value else{return}
                let json = JSON(object)
                print("Feed results: ", json.count)
                print(json)
                
                self.AddCard(json: json)
                self.isUpdating = false
            }
        }
    }
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        print("FEED")
        print(viewController.restorationIdentifier!, preViewName)
        
        if viewController.restorationIdentifier! == StoryboardID.Home.rawValue && preViewName == StoryboardID.Home.rawValue {
            scrollView.scroll(to: .top, animated: true)
        }
        
        preViewName = viewController.restorationIdentifier!
    }
    
    func UpOffset() {
        offset += limit
    }
    
    func ResetOffset() {
        offset = 0
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

