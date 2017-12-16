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

class LocationFeedViewController: UIViewController {

    var cannotavailable_msg = EdgeInsetLabel()
    var scrollView = UIScrollView()
    var cardViews: [UIView] = [UIView()]
    var base_margin = 0.0 as CGFloat
    var attr_frame = CGRect()
    var distance_frame = CGRect()
    var name_frame = CGRect()
    
    var user_id = 0
    
    //MARK: DEBUG
    let DEGUG = true
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if CLLocationManager.locationServicesEnabled() {
            cannotavailable_msg.isHidden = true
            scrollView.isScrollEnabled = true
            
            guard let user_id = GetAppDelegate().user_id else {
                return
            }
            
            self.user_id = user_id
            
            CallLocationFeedAPI()

            scrollView.contentSize = CGSize(width: self.view.bounds.width, height: cardViews.last!.frame.height+cardViews.last!.frame.origin.y+base_margin*1.5)
            
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
        cannotavailable_msg.font = UIFont(name: FontName.J_W3.rawValue, size: 15)
        cannotavailable_msg.numberOfLines = 0
        cannotavailable_msg.textAlignment = .center
        cannotavailable_msg.textColor = UIColor.gray
        cannotavailable_msg.attributedText = GetAttributedTextLineHeight(height: 20, text: "位置情報サービスが無効のため、\n情報を表示することができません")
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

        base_margin = self.view.bounds.width * 0.025
        var card_start_y = base_margin
        
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
                }else {
                    cardViews.last!.addSubview(view as! UIImageView)
                }
            }
            
            
            //TODO: プロフィール画像の設置
            let profileImageView = CreateProfileImageView(url: avatar_url)
            cardViews.last!.addSubview(profileImageView)
            
            card_start_y = cardViews.last!.frame.height + cardViews.last!.frame.origin.y + self.base_margin*1.5
        }
    }
    
    func CreateCard(start_y: CGFloat) -> UIView {
        let card_width = self.view.bounds.width * 0.95
        let card_height = self.view.bounds.height * 0.27
        
        let card_view = UIView(frame: CGRect(x: base_margin, y: start_y, width: card_width, height: card_height))
        card_view.backgroundColor = UIColor.white
        card_view.layer.cornerRadius = 5
        card_view.layer.shadowOpacity = 0.2
        card_view.layer.shadowColor = UIColor.black.cgColor
        card_view.layer.shadowOffset = CGSize(width: 2, height: 2)
        card_view.layer.shadowRadius = 5
        card_view.layer.masksToBounds = false
        
        return card_view
    }
    
    func CreateAttributeLabel(attribute: String) -> UILabel {
        let x = base_margin * 1.5
        let y = base_margin * 1
        let w = cardViews.last!.frame.width
        let f_size = 13 as CGFloat
        
        let label = EdgeInsetLabel(frame: CGRect(x: x, y: y, width: w, height: f_size))
        label.attributedText = GetAttributeColor(attr: attribute)
        label.textAlignment = .left
        label.font = UIFont(name: "DINAlternate-Bold", size: f_size)
        
        return label
    }
    
    func CreateDistanceLabel(distance: Int) -> EdgeInsetLabel {
        let f_size = 15 as CGFloat
        let label = EdgeInsetLabel()
        label.text = GenerateDistanceString(distance: distance)
        label.font = UIFont(name: FontName.J_W6.rawValue, size: f_size)
        label.frame = CGRect(x: 0, y: 0, width: 0, height: f_size+15)
        label.backgroundColor = UIColor.black
        label.textColor = UIColor.white
        label.topTextInset = 7.5
        label.rightTextInset = 12.5
        label.bottomTextInset = 7.5
        label.leftTextInset = 12.5
        label.sizeToFit()
        
        let x = cardViews.last!.frame.width - label.frame.width
        
        let maskPath = UIBezierPath(roundedRect: label.frame,
                                    byRoundingCorners: [.topRight],
                                    cornerRadii: CGSize(width: 5, height: 5))
        let maskLayer = CAShapeLayer()
        maskLayer.path = maskPath.cgPath
        label.layer.mask = maskLayer

        
        label.frame = CGRect(x: x, y: 0, width: label.frame.width, height: f_size+15)
        return label
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
        
        let x = base_margin * 2.5
        let y = attr_frame.origin.y + attr_frame.height + base_margin * 2.85
        let w = cardViews.last!.frame.width
        
        let name_label = EdgeInsetLabel(frame: CGRect(x: x, y: y, width: w, height: font_size))
        name_label.text = text
        name_label.textAlignment = .left
        name_label.font = UIFont(name: font_name, size: font_size)
        
        return name_label
    }
    
    func CreateMainSkillsLabels(skills: Array<String>) -> Array<Any> {
        var views:[Any] = []
        let y = name_frame.height+name_frame.origin.y+base_margin * 2
        var x = base_margin * 2.5
        
        for skill in skills {
            //skillラベル追加
            let label = UILabel(frame: CGRect(x: x, y: y, width: 0, height: 0))
            label.text = skill
            label.font = UIFont(name: FontName.E.rawValue, size: 12)
            label.sizeToFit()
            views.append(label)
            
            x = label.frame.origin.x + label.frame.width + base_margin * 1
            
            //スラッシュ画像追加
            let slash = UIImageView(image: UIImage(named: "icon_slash"))
            slash.frame = CGRect(x: x, y: y, width: 5, height: 15)
            views.append(slash)
            
            x = slash.frame.origin.x + slash.frame.width + base_margin * 1
        }
        
        _ = views.popLast()
        
        return views
    }
    
    func CreateProfileImageView(url: String) -> UIImageView {
        let escapedAddress = url.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
        let url = URL(string: escapedAddress!)!
        
        do {
            let imageData: NSData = try NSData(contentsOf: url)
            let wh = base_margin * 7
            let x = cardViews.last!.frame.origin.x + cardViews.last!.frame.width - wh*1.4
            let y = distance_frame.origin.y + distance_frame.height + base_margin*2
            
            let resizedAndMaskedImage = Toucan(image: UIImage(data: imageData as Data)!).resize(CGSize(width: wh, height: wh), fitMode: Toucan.Resize.FitMode.clip).maskWithEllipse().image
            let imageview = UIImageView(image: resizedAndMaskedImage)
            imageview.frame = CGRect(x: x, y: y, width: wh, height: wh)
            
            return imageview
        }catch{
            print(error)
        }
        
        return UIImageView()
    }
    
    func GenerateDistanceString(distance: Int) -> String {
        let km: Double = Double(distance) / 1000.0
        
        if km < 1.0 {
            return String(distance) + "m"
        }
        
        return String(km) + "km"
    }
    
    func CallLocationFeedAPI(){
        if DEGUG {
            let dummy = LocationFeedDummyData().users_data
            self.AddCard(json: JSON(dummy))
        }else {
            let urlString: String = API.host.rawValue + API.v1.rawValue + API.users.rawValue + "?user_id=" + String(user_id)
            
            Alamofire.request(urlString, method: .get).responseJSON { (response) in
                guard let object = response.result.value else{return}
                let json = JSON(object)
                print("Location Feed results: ", json.count)
                
                self.AddCard(json: json)
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
