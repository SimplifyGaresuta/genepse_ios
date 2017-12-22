//
//  LocationFeedViewController.swift
//  GENEPSE
//
//  Created by 岩見建汰 on 2017/12/13.
//  Copyright © 2017年 Kenta. All rights reserved.
//

import UIKit
import CoreLocation
import SwiftyJSON
import Alamofire
import Toucan

class LocationFeedViewController: UIViewController, UITabBarControllerDelegate {

    var preViewName = StoryboardID.CLOSEUSER.rawValue
    var cannotavailable_msg = EdgeInsetLabel()
    var scrollView = UIScrollView()
    var cardViews: [UIView] = [UIView()]
    var base_margin = 0.0 as CGFloat
    var attr_frame = CGRect()
    var distance_frame = CGRect()
    var name_frame = CGRect()
    var skill_frame = CGRect()
    var indicator = Indicator()
    
    var tag_count = 1
    var users_tag:[Int:Array<Int>] = [:]
    var users_count = 0
    
    var users = [JSON()]
    var user_id = 0
    
    //MARK: DEBUG
    let DEGUG = false
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // タイトルを装飾
        self.tabBarController?.navigationItem.titleView = ViewUtility().CreateTitleLabelView(title: StoryboardID.CLOSEUSER.rawValue, font_name: FontName.DIN.rawValue, font_size: 20)
        
        self.tabBarController?.delegate = self
        preViewName = StoryboardID.CLOSEUSER.rawValue
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        /*初期化処理*/
        for cardView in cardViews {
            cardView.removeFromSuperview()
        }
        tag_count = 1
        users_tag = [:]
        users_count = 0
        /*初期化処理*/
        
        
        if CLLocationManager.locationServicesEnabled() {
            cannotavailable_msg.isHidden = true
            scrollView.isScrollEnabled = true
            
            guard let user_id = GetAppDelegate().user_id else {
                return
            }
            
            self.user_id = user_id
            
            indicator.showIndicator(view: self.view)
            CallLocationFeedAPI()

            switch CLLocationManager.authorizationStatus() {
            case .notDetermined, .restricted, .denied:
                cannotavailable_msg.isHidden = false
                scrollView.isScrollEnabled = false
            case .authorizedAlways, .authorizedWhenInUse:
                break
            }
        }else {
            cannotavailable_msg.isHidden = false
            scrollView.isScrollEnabled = false
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollView.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height)
        self.view.addSubview(scrollView)
        
        SetUpCanNotAvailableLocationFeedMSG()
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.topAnchor.constraint(equalTo:self.view.topAnchor).isActive = true
        scrollView.trailingAnchor.constraint(equalTo:self.view.trailingAnchor).isActive = true
        scrollView.bottomAnchor.constraint(equalTo:self.view.bottomAnchor).isActive = true
        scrollView.leadingAnchor.constraint(equalTo:self.view.leadingAnchor).isActive = true
    }
    
    func SetUpCanNotAvailableLocationFeedMSG() {
        let attred_str = NSMutableAttributedString(string: "位置情報サービスが無効のため、\n情報を表示することができません")
        
        cannotavailable_msg.font = UIFont(name: FontName.J_W3.rawValue, size: 15)
        cannotavailable_msg.numberOfLines = 0
        cannotavailable_msg.textAlignment = .center
        cannotavailable_msg.textColor = UIColor.gray
        cannotavailable_msg.attributedText = AddAttributedTextLineHeight(height: 20, text: attred_str)
        cannotavailable_msg.topTextInset = 20
        cannotavailable_msg.leftTextInset = 20
        cannotavailable_msg.bottomTextInset = 20
        cannotavailable_msg.rightTextInset = 20
        cannotavailable_msg.sizeToFit()
        
        cannotavailable_msg.center = self.view.center
        
        self.view.addSubview(cannotavailable_msg)
    }
    
    func AddCard(json: JSON) {
        let users = json["users"].arrayValue
        let sorted_users = users.sorted { $0["distance"].intValue < $1["distance"].intValue }
        self.users = sorted_users

        base_margin = self.view.bounds.width * 0.035
        var card_start_y = base_margin * 1.5
        
        for user in sorted_users {
            //表示しようとしているカードが自分と同じ場合はスキップ
            if user["id"].intValue == user_id {
                continue
            }
            
            let name = user[Key.name.rawValue].stringValue
            let avatar_url = user[Key.avatar_url.rawValue].stringValue
            let attribute = user[Key.attribute.rawValue].stringValue
            let skills = user[Key.skills.rawValue].arrayValue.map({$0.stringValue})
            let sns = user[Key.sns.rawValue].arrayValue
            let distance = user[Key.distance.rawValue].intValue
            
            
            // カードを追加
            cardViews.append(CreateCard(start_y: card_start_y))
            scrollView.addSubview(cardViews.last!)
            
            
            // 属性を追加
            let attributeLabel = CreateAttributeLabel(attribute: attribute)
            cardViews.last!.addSubview(attributeLabel)
            attr_frame = attributeLabel.frame
            
            
            // 距離の設置
            let distanceLabel = CreateDistanceLabel(distance: distance)
            cardViews.last!.addSubview(distanceLabel)
            distance_frame = distanceLabel.frame
            
            
            // 名前の設置
            let nameLabel = CreateNameLabel(text: name)
            cardViews.last!.addSubview(nameLabel)
            name_frame = nameLabel.frame
            
            
            // メインスキルの設置
            let mainskillsViews = CreateMainSkillsLabels(skills: skills)
            for view in mainskillsViews {
                if let label = view as? UILabel {
                    cardViews.last!.addSubview(label)
                    skill_frame = label.frame
                }else {
                    cardViews.last!.addSubview(view as! UIImageView)
                }
            }
            
            
            // プロフィール画像の設置
            let profileImageView = CreateProfileImageView(url: avatar_url)
            cardViews.last!.addSubview(profileImageView)
            
            
            // SNSの設置
            let snsButtons = CreateSNSButton(json: sns)
            for snsButton in snsButtons {
                cardViews.last!.addSubview(snsButton)
            }
            
            card_start_y = cardViews.last!.frame.height + cardViews.last!.frame.origin.y + base_margin * 2
        }
        
        scrollView.contentSize = CGSize(width: self.view.bounds.width, height: cardViews.last!.frame.height+cardViews.last!.frame.origin.y+base_margin*1.5)
    }
    
    func CreateCard(start_y: CGFloat) -> UIView {
        let card_width = self.view.bounds.width * 0.93
        let card_height = self.view.bounds.height * 0.27
        
        let card_view = UIView(frame: CGRect(x: base_margin, y: start_y, width: card_width, height: card_height))
        card_view.backgroundColor = UIColor.white
        card_view.layer.cornerRadius = 2
        card_view.layer.shadowOpacity = 0.2
        card_view.layer.shadowColor = UIColor.black.cgColor
        card_view.layer.shadowOffset = CGSize(width: 2, height: 2)
        card_view.layer.shadowRadius = 5
        card_view.layer.masksToBounds = false
        
        return card_view
    }
    
    func CreateAttributeLabel(attribute: String) -> UILabel {
        //TODO: 各属性同士の間隔をもう少し狭める
        let x = base_margin * 1
        let y = base_margin * 1
        let w = cardViews.last!.frame.width
        let f_size = 13 as CGFloat
        
        let label = EdgeInsetLabel(frame: CGRect(x: x, y: y, width: w, height: f_size))
        var attr_str = GetAttributeString(attr: attribute)
        attr_str = AddAttributedTextLetterSpacing(space: 1, text: attr_str)
        
        label.attributedText = attr_str
        label.textAlignment = .left
        label.font = UIFont(name: FontName.DIN.rawValue, size: f_size)
        
        return label
    }
    
    func CreateDistanceLabel(distance: Int) -> EdgeInsetLabel {
        var attr_text = NSMutableAttributedString(string: GenerateDistanceString(distance: distance))
        print(attr_text, distance)
        attr_text = AddAttributedTextLetterSpacing(space: 0.9, text: attr_text)
        
        let f_size = 16 as CGFloat
        let label = EdgeInsetLabel()
        label.attributedText = attr_text
        label.font = UIFont(name: FontName.E_B.rawValue, size: f_size)
        label.frame = CGRect(x: 0, y: 0, width: 0, height: f_size+16)
        label.backgroundColor = UIColor.black
        label.textColor = UIColor.white
        label.topTextInset = f_size/3
        label.rightTextInset = 8
        label.bottomTextInset = f_size/3
        label.leftTextInset = 8
        label.sizeToFit()
        
        let x = cardViews.last!.frame.width - label.frame.width
        
        let maskPath = UIBezierPath(roundedRect: label.frame,
                                    byRoundingCorners: [.topRight],
                                    cornerRadii: CGSize(width: 2, height: 2))
        let maskLayer = CAShapeLayer()
        maskLayer.path = maskPath.cgPath
        label.layer.mask = maskLayer

        
        label.frame = CGRect(x: x, y: 0, width: label.frame.width, height: f_size+15)
        return label
    }
    
    func CreateNameLabel(text: String) -> UILabel {
        let je_num = SearchJapaneseEnglish(text: text)
        let font_name = GetFontName(je_num: je_num, font_w: 6)
        let font_size = 22 as CGFloat
        
        let x = base_margin * 2.5
        let y = attr_frame.origin.y + attr_frame.height + base_margin * 1.5
        let w = cardViews.last!.frame.width
        
        let name_label = EdgeInsetLabel(frame: CGRect(x: x, y: y, width: w, height: font_size))
        name_label.text = text
        name_label.textAlignment = .left
        name_label.font = UIFont(name: font_name, size: font_size)
        
        return name_label
    }
    
    func CreateMainSkillsLabels(skills: Array<String>) -> Array<Any> {
        var views:[Any] = []
        let y = name_frame.height+name_frame.origin.y+base_margin * 1.0
        var x = base_margin * 2.5

        for skill in skills {
            var font_name = ""
            var font_size = 0 as CGFloat
            var attr_str = NSMutableAttributedString(string: skill)
            
            if SearchJapaneseEnglish(text: skill) == JapaneseEnglish.Japanese.rawValue {
                font_name = FontName.J_W6.rawValue
                font_size = 10
            }else {
                font_name = FontName.E_M.rawValue
                font_size = 11
                attr_str = AddAttributedTextLetterSpacing(space: 0.4, text: attr_str)
            }
            
            //skillラベル追加
            let label = UILabel(frame: CGRect(x: x, y: y, width: 0, height: 0))
            label.attributedText = attr_str
            label.font = UIFont(name: font_name, size: font_size)
            label.sizeToFit()
            views.append(label)
            
            x = label.frame.origin.x + label.frame.width + base_margin * 0.5
            
            //スラッシュ画像追加
            let slash = UIImageView(image: UIImage(named: "icon_slash"))
            slash.frame = CGRect(x: x, y: y, width: 5, height: 15)
            views.append(slash)
            
            x = slash.frame.origin.x + slash.frame.width + base_margin * 0.5
        }
        
        _ = views.popLast()
        
        return views
    }
    
    func CreateProfileImageView(url: String) -> UIImageView {
        //TODO: 非同期処理にする
        let escapedAddress = url.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
        let url = URL(string: escapedAddress!)!
        
        do {
            let imageData: NSData = try NSData(contentsOf: url)
            let wh = base_margin * 4.5
            let x = cardViews.last!.frame.origin.x + cardViews.last!.frame.width - wh*1.5
            let y = distance_frame.origin.y + distance_frame.height + base_margin*1
            
            let resizedAndMaskedImage = Toucan(image: UIImage(data: imageData as Data)!).resize(CGSize(width: wh, height: wh), fitMode: Toucan.Resize.FitMode.clip).maskWithEllipse().image
            let imageview = UIImageView(image: resizedAndMaskedImage)
            imageview.frame = CGRect(x: x, y: y, width: wh, height: wh)
            
            return imageview
        }catch{
            print(error)
        }
        
        return UIImageView()
    }
    
    func CreateSNSButton(json: [JSON]) -> [UIButton] {
        var buttons:[UIButton] = []
        
        let icon_name = ["icon_facebook", "icon_twitter"]
        let title = ["Facebook", "Twitter"]
        let color:[NSString] = ["#385495", "#1DA1F2"]
        let s_x = [0, cardViews.last!.frame.width/2]
        let y = skill_frame.origin.y+skill_frame.height+base_margin*1.7
        let h = cardViews.last!.bounds.height-y
        let w = cardViews.last!.frame.width/2
        var tag_array:[Int] = []
        
        for (i, sns) in json.enumerated() {
            let button = UIButton(type: UIButtonType.custom)
            var icon = icon_name[i]
            var isEnabled = true
            var font_color = color[i]
            
            button.tag = tag_count
            
            if sns[Key.url.rawValue].stringValue.count == 0 {
                icon += "_dis"
                isEnabled = false
                button.adjustsImageWhenDisabled = false
                font_color = "#BCBCBC"
                button.tag = 0
            }else {
                tag_count += 1
                tag_array.append(button.tag)
            }
            
            var attr_str = NSMutableAttributedString(string: title[i])
            attr_str = AddAttributedTextLetterSpacing(space: 0.5, text: attr_str)
            attr_str = AddAttributedTextColor(color: UIColor.hexStr(hexStr: font_color, alpha: 1.0), text: attr_str)
            
            let buttonImageDefault :UIImage? = UIImage(named: icon)
            button.frame = CGRect(x: s_x[i],
                                      y: y,
                                      width: w,
                                      height: h)
            button.setImage(buttonImageDefault!, for: .normal)
            button.titleLabel?.font = UIFont(name: FontName.E_B.rawValue, size: 13)
            button.setAttributedTitle(attr_str, for: .normal)
            button.addTarget(self, action: #selector(TapSNSButton(sender:)), for: .touchUpInside)
            button.isEnabled = isEnabled
            
            //image、titleの表示サイズ・位置の調整
            let offset_image = 15 as CGFloat
            let offset_title = 5 as CGFloat
            button.imageEdgeInsets = UIEdgeInsetsMake(offset_image, 0, offset_image, 0)
            button.imageView?.contentMode = .scaleAspectFit
            
            button.titleEdgeInsets = UIEdgeInsetsMake(0, offset_title, 0, 0)
            
            //Top_borderの描画
            let border_w = 1 as CGFloat
            let top_border = CALayer()
            top_border.backgroundColor = UIColor.hexStr(hexStr: "#EEEEEE", alpha: 1.0).cgColor
            top_border.frame = CGRect(x:0,y: 0, width:button.frame.size.width, height:border_w)
            button.layer.addSublayer(top_border)
            
            //片方のボタンのみRight_borderを描画
            if i == 0 {
                let right_border = CALayer()
                right_border.backgroundColor = UIColor.hexStr(hexStr: "#EEEEEE", alpha: 1.0).cgColor
                right_border.frame = CGRect(x: button.frame.size.width - border_w,y: 0, width:border_w, height:button.frame.size.height)
                button.layer.addSublayer(right_border)
            }

            buttons.append(button)
        }
        
        users_tag[users_count] = tag_array
        users_count += 1
        
        print(users_tag)
        
        return buttons
    }
    
    func TapSNSButton(sender: UIButton) {
        var user_count = 0
        for hoge in users_tag.keys {
            for hoge2 in users_tag[hoge]! {
                if sender.tag == hoge2 {
                    user_count = hoge
                    break
                }
            }
        }
        
        let index = users_tag[user_count]!.index(of: sender.tag)!

        let url = URL(string: users[user_count][Key.sns.rawValue][index][Key.url.rawValue].stringValue)!
        if (UIApplication.shared.canOpenURL(url)) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }else {
            self.present(GetStandardAlert(title: "URLエラー", message: "設定されているURLが間違っているため、開けませんでした", b_title: "OK"), animated: true, completion: nil)
        }
    }
    
    func GenerateDistanceString(distance: Int) -> String {
        let km: Double = Double(distance) / 1000.0
        
        if km < 1.0 {
            return String(distance) + "m"
        }

        if km < 10 {
            return String(format: "%.1fkm", km)
        }else {
            return String(format: "%.0fkm", km)
        }
    }
    
    func CallLocationFeedAPI(){
        if DEGUG {
            let dummy = LocationFeedDummyData().users_data
            self.AddCard(json: JSON(dummy))
        }else {
            let urlString: String = API.host.rawValue + API.v1.rawValue + API.near_users.rawValue + "?user_id=" + String(user_id)
            
            Alamofire.request(urlString, method: .get).responseJSON { (response) in
                guard let object = response.result.value else{return}
                let json = JSON(object)
                print("Location Feed results: ", json.count)
                print(json)
                
                self.indicator.stopIndicator()
                self.AddCard(json: json)
            }
        }
    }
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        if viewController.restorationIdentifier! == StoryboardID.CLOSEUSER.rawValue && preViewName == StoryboardID.CLOSEUSER.rawValue {
            scrollView.scroll(to: .top, animated: true)
        }
        
        preViewName = viewController.restorationIdentifier!
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
