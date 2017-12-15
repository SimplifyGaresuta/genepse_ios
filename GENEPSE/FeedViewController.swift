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
import FaceCropper

class FeedViewController: UIViewController, UIScrollViewDelegate, UITabBarControllerDelegate {
    var scrollView = UIScrollView()
    var cardViews: [UIView] = [UIView()]
    var profileImageView = UIImageView()
    var nameLabel = UILabel()
    var base_margin = 0.0 as CGFloat
    var card_start_y = 0.0 as CGFloat
    
    var isUpdating = false
    var preViewName = StoryboardID.Feed.rawValue
    var limit = 20
    var offset = 0
    var has_next = true
    
    var user_id = 0
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.navigationItem.title = StoryboardID.Feed.rawValue
        
        preViewName = StoryboardID.Feed.rawValue
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
        
        scrollView.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height)
        self.view.addSubview(scrollView)
        scrollView.delegate = self
        
//        self.tabBarController?.delegate = self
        
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
        
        let image = UIImage(named: "sample3.jpg")
        image?.face.crop { result in
            switch result {
            case .success(let faces):
                for (i, face) in faces.enumerated() {
                    let hoge = UIImageView(image: face)
                    hoge.frame = CGRect(x: 0, y: i*100+100, width: 100, height: 100)
                    self.view.addSubview(hoge)
                    self.view.bringSubview(toFront: hoge)
                }
                
                break
                // When the `Vision` successfully find faces, and `FaceCropper` cropped it.
            // `faces` argument is a collection of cropped images.
            case .notFound: break
            // When the image doesn't contain any face, `result` will be `.notFound`.
            case .failure(let error): break
                // When the any error occured, `result` will be `failure`.
            }
        }

    }
    
    func refresh(sender: UIRefreshControl) {
        for cardView in cardViews {
            cardView.removeFromSuperview()
        }
        
        cardViews.removeAll()
        
        //初期化
        card_start_y = base_margin
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
            
            // カードを追加
            cardViews.append(self.CreateCard(card_start_y: self.card_start_y))
            self.self.scrollView.addSubview(cardViews.last!)
            cardViews.last!.tag = id
            
            // プロフィール画像を追加
            self.profileImageView = self.CreateProfileImageView(url: avatar_url)
            cardViews.last!.addSubview(self.profileImageView)
            
            // 属性を追加
            let attributeImageView = self.CreateAttributeImageView(attribute: attribute)
            cardViews.last!.addSubview(attributeImageView)

            
            // メインスキルを追加
            let mainskillsLabels = self.CreateMainSkillsLabels(skills: skills)
            for (shadowView, skillLabel) in zip(mainskillsLabels.0, mainskillsLabels.1) {
                cardViews.last!.addSubview(shadowView)
                cardViews.last!.addSubview(skillLabel)
            }
            
            // 名前のラベルを追加
            self.nameLabel = self.CreateNameLabel(text: name)
            cardViews.last!.addSubview(self.nameLabel)
            
            // 経歴のラベルを追加
            let careerLabel = self.CreateCareerLabel(text: overview)
            cardViews.last!.addSubview(careerLabel)
            
            // 次に描画するカードのyを保存
            self.card_start_y = cardViews.last!.frame.height + cardViews.last!.frame.origin.y + self.base_margin*0.5
        }
        
        self.scrollView.contentSize = CGSize(width: self.view.bounds.width, height: cardViews.last!.frame.height+cardViews.last!.frame.origin.y+self.base_margin)
    }
    
    func CreateCard(card_start_y: CGFloat) -> UIView {
        let card_width = self.view.bounds.width * 0.8
        let card_height = self.view.bounds.height * 0.65
        
        let card_view = UIView(frame: CGRect(x: base_margin, y: card_start_y, width: card_width, height: card_height))
        card_view.backgroundColor = UIColor.white
        card_view.layer.cornerRadius = 20
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
        let je_num = SearchJapaneseEnglish(text: text)
        let font_name = GetFontName(je_num: je_num, font_w: 6)
        var font_size = 0 as CGFloat
        if je_num == JapaneseEnglish.Japanese.rawValue {
            font_size = 32
        }else {
            font_size = 34
        }
        
        let name_label = UILabel(frame: CGRect(x: base_margin*0.5, y: profileImageView.frame.height+base_margin*0.25, width: cardViews.last!.frame.width, height: base_margin))
        name_label.text = text
        name_label.font = UIFont(name: font_name, size: font_size)
        name_label.sizeToFit()
        
        return name_label
    }
    
    func CreateCareerLabel(text: String) -> UILabel {
        let label_start_y = nameLabel.frame.origin.y+nameLabel.frame.height
        
        let career_label = UILabel(frame: CGRect(x: base_margin*0.5, y: label_start_y, width: cardViews.last!.frame.width-base_margin, height: base_margin*2))
        career_label.font = UIFont(name: FontName.J_W6.rawValue, size: 15)
        career_label.backgroundColor = UIColor.clear
        career_label.numberOfLines = 0
        
        let lineHeight:CGFloat = 21.0
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.minimumLineHeight = lineHeight
        paragraphStyle.maximumLineHeight = lineHeight
        paragraphStyle.lineBreakMode = .byTruncatingTail
        let attributedText = NSMutableAttributedString(string: text)
        attributedText.addAttribute(NSParagraphStyleAttributeName, value: paragraphStyle, range: NSMakeRange(0, attributedText.length))
        career_label.attributedText = attributedText
        
        return career_label
    }
    
    func CreateAttributeImageView(attribute: String) -> UIImageView {
        let y = profileImageView.frame.origin.y + base_margin*0.5
        
        let attributeImageView = UIImageView(image: UIImage(named: "attr_"+attribute))
        attributeImageView.frame = CGRect(x: base_margin*0.33, y: y, width: profileImageView.frame.width*0.45, height: profileImageView.frame.height*0.2)
        attributeImageView.contentMode = .scaleAspectFill
        
        return attributeImageView
    }
    
    func CreateMainSkillsLabels(skills: Array<String>) -> (Array<UIView>, Array<UILabel>) {
        var labels = [UILabel]()
        var views = [UIView]()
        let bg_color = UIColor.white
        
        var labelstart_x = base_margin * 0.25
        let label_y = profileImageView.frame.origin.y + profileImageView.frame.height
        
        for skill in skills {
            let je_num = SearchJapaneseEnglish(text: skill)
            let font_name = GetFontName(je_num: je_num, font_w: 6)
            var font_size = 0 as CGFloat
            if je_num == JapaneseEnglish.Japanese.rawValue {
                font_size = 20
            }else {
                font_size = 21
            }
            
            // skillラベルの生成
            let label = UILabel(frame: CGRect(x: labelstart_x, y: label_y, width: 0, height: 0))
            label.text = "  " + skill + "  "
            label.font = UIFont(name: font_name, size: font_size)
            label.backgroundColor = bg_color
            label.sizeToFit()
            label.layer.cornerRadius = 10
            label.layer.masksToBounds = true
            label.frame = CGRect(x: labelstart_x, y: label.frame.origin.y-label.frame.height - base_margin*0.25, width: 0, height: 0)   //プロフ画像のbottomからマージン分だけ上に
            label.sizeToFit()   //w, hの再調整
            
            //TODO: はみ出したラベルがある場合は調整
            if (label.frame.origin.x+label.frame.width) > (profileImageView.frame.origin.x+profileImageView.frame.width-base_margin*0.25) {
            }
            
            
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
        let urlString: String = API.host.rawValue + API.v1.rawValue + API.users.rawValue + "?limit=" + String(limit) + "&offset=" + String(offset)
        
        Alamofire.request(urlString, method: .get).responseJSON { (response) in
            guard let object = response.result.value else{return}
            let json = JSON(object)
            print("Feed results: ", json.count)
            
            let dummy = FeedViewDummyData().users_data
//            self.AddCard(json: JSON(dummy))
            self.AddCard(json: json)
            
            self.isUpdating = false
        }
    }
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        print("FEED")
        print(viewController.restorationIdentifier!, preViewName)
        
        if viewController.restorationIdentifier! == StoryboardID.Feed.rawValue && preViewName == StoryboardID.Feed.rawValue {
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

