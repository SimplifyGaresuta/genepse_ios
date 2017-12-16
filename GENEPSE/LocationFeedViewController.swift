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

class LocationFeedViewController: UIViewController {

    var cannotavailable_msg = EdgeInsetLabel()
    var scrollView = UIScrollView()
    var cardViews: [UIView] = [UIView()]
    var base_margin = 0.0 as CGFloat
    
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
            
            //TODO: カードを追加
            cardViews.append(CreateCard(start_y: card_start_y))
            scrollView.addSubview(cardViews.last!)
            
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
