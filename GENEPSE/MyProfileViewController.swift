//
//  MyProfileViewController.swift
//  GENEPSE
//
//  Created by 岩見建汰 on 2017/12/06.
//  Copyright © 2017年 Kenta. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import Toucan

class MyProfileViewController: UIViewController, UITabBarControllerDelegate, UIScrollViewDelegate {

    var preViewName = StoryboardID.MyProfile.rawValue
    
    private var user_id = 0
    let appdelegate = GetAppDelegate()
    var base_margin = 0.0 as CGFloat
    
    var scrollView = UIScrollView()
    var cardView = UIView()
//    var profileImageView = UIImageView()
    var cover_img = UIImageView()
//    var latest_section_frame = CGRect()
    var latest_frame = CGRect()
    
//    var product_link:[Int:String] = [:]
//    var sns_link:[Int:String] = [:]
    
    //MARK: DEBUG
    let debug = true
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.navigationItem.title = StoryboardID.MyProfile.rawValue
        
        preViewName = StoryboardID.MyProfile.rawValue
        self.tabBarController?.delegate = self
        self.navigationController?.navigationBar.isHidden = true
        UIApplication.shared.statusBarStyle = .default
        
        cardView.removeFromSuperview()
        cover_img.removeFromSuperview()
        scrollView.removeFromSuperview()
        
        InitScrollView()
        CallUserDetailAPI()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBar.isHidden = false
        UIApplication.shared.statusBarStyle = .lightContent
    }
    
    override func viewDidLoad() {
        user_id = GetMyID()
        
        super.viewDidLoad()
        
        base_margin = self.view.bounds.width * 0.05
        self.view.backgroundColor = UIColor.white
        
        scrollView.delegate = self
    }
    
    func GetMyID() -> Int {
        guard let user_id = GetAppDelegate().user_id else {
            return 0
        }
        
        //MARK: テストのため1を設定
        return user_id
    }
    
    func InitScrollView() {
        scrollView.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height+1000)
        self.view.addSubview(scrollView)
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.topAnchor.constraint(equalTo:self.view.topAnchor).isActive = true
        scrollView.trailingAnchor.constraint(equalTo:self.view.trailingAnchor).isActive = true
        scrollView.bottomAnchor.constraint(equalTo:self.view.bottomAnchor).isActive = true
        scrollView.leadingAnchor.constraint(equalTo:self.view.leadingAnchor).isActive = true
    }
    
    func InitCardView() {
        cardView = UIView()
        
        let y = cover_img.frame.height * 0.8
        cardView.frame = CGRect(x: base_margin, y: y, width: self.view.bounds.width - base_margin * 2, height: self.view.bounds.height+1000)
        cardView.backgroundColor = UIColor.white
        
        cardView.layer.cornerRadius = 3
        cardView.layer.shadowOpacity = 0.2
        cardView.layer.shadowColor = UIColor.black.cgColor
        cardView.layer.shadowOffset = CGSize(width: 1, height: 1)
        cardView.layer.shadowRadius = 3
        cardView.layer.masksToBounds = false
        
        scrollView.addSubview(cardView)
    }
    
    func AddViews(json: JSON) {
        //MARK: delegateに保存
        appdelegate.data = GetDetailData(json: json)
        
        
        // 背景画像の追加
        let cover_img = CreateCoverImageView(url: (appdelegate.data?.GetCoverUrl())!)
        scrollView.addSubview(cover_img)
        self.cover_img = cover_img
        
        // カードの追加
        InitCardView()
        
        // プロフ画像の追加
        let profileImageView = CreateProfileImageView(url: (appdelegate.data?.GetAvatarURL())!)
        cardView.addSubview(profileImageView)
        latest_frame = profileImageView.frame
        
        
        // SNSの追加
        let snsButtons = CreateSNSLabel(json: (appdelegate.data?.GetSNS())!)
        for s_button in snsButtons {
            cardView.addSubview(s_button)
        }
        
        
        // 名前の追加
        let nameLabel = CreateNameLabel(text: (appdelegate.data?.GetName())!)
        cardView.addSubview(nameLabel)
        latest_frame = nameLabel.frame
        UpdateCardViewFrame(last_add_cgrect: nameLabel.frame)
        cardView.addSubview(CreateEditButton(cgrect: nameLabel.frame))
        
        scrollView.contentSize = CGSize(width: self.view.bounds.width, height: cardView.frame.height+cover_img.frame.height*0.8+base_margin)
    }
    
    func CreateCoverImageView(url: String) -> AsyncUIImageView {
        let h = self.view.frame.height * 0.3
        let cover_img = AsyncUIImageView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: h))
        cover_img.loadImage(urlString: url)
        cover_img.contentMode = .scaleAspectFill
        
        return cover_img
    }
    
    func CreateProfileImageView(url: String) -> UIImageView {
        let escapedAddress = url.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
        let url = URL(string: escapedAddress!)!
        
        do {
            let imageData: NSData = try NSData(contentsOf: url)
            let wh = base_margin * 6
            let x = cardView.frame.width / 2 - wh/2
            let y = cardView.bounds.origin.y - wh/2
            
            let resizedAndMaskedImage = Toucan(image: UIImage(data: imageData as Data)!).resize(CGSize(width: wh, height: wh), fitMode: Toucan.Resize.FitMode.clip).maskWithEllipse().image
            let imageview = UIImageView(image: resizedAndMaskedImage)
            imageview.frame = CGRect(x: x, y: y, width: wh, height: wh)
            
            return imageview
        }catch{
            print("profile img NSData: ", error)
        }
        
        return UIImageView()
    }
    
    func CreateSNSLabel(json: [JSON]) -> [UIButton] {
        let wh = base_margin * 2
        let y = cardView.bounds.origin.y - wh/2
        let x = [cardView.bounds.origin.x + base_margin * 2.5, cardView.bounds.width-base_margin * 2.5-wh]
        let icon = ["icon_facebook_circle", "icon_twitter_circle"]
        var isEnabled = true
        var buttons: [UIButton] = []
        
        for i in 0..<2 {
            let button = UIButton(frame: CGRect(x: x[i], y: y, width: wh, height: wh))
            button.tag = i
            
            var icon_name = icon[i]
            
            if i == 1 && json.count == 1 {
                isEnabled = false
                button.adjustsImageWhenDisabled = false
                icon_name = "icon_twitter_circle_dis"
                button.tag = -1
            }
            
            button.setImage(UIImage(named: icon_name), for: .normal)
            button.addTarget(self, action: #selector(TapSNSButton(sender:)), for: .touchUpInside)
            button.isEnabled = isEnabled
            
            buttons.append(button)
        }
        return buttons
    }
    
    func CreateNameLabel(text: String) -> UILabel {
        let je_num = SearchJapaneseEnglish(text: text)
        let font_name = GetFontName(je_num: je_num, font_w: 6)
        var font_size = 0 as CGFloat
        if je_num == JapaneseEnglish.Japanese.rawValue {
            font_size = 26
        }else {
            font_size = 27
        }
        
        let x = 0 as CGFloat
        let y = latest_frame.origin.y+latest_frame.height+base_margin * 1.5
        let w = cardView.frame.width
        
        let name_label = UILabel(frame: CGRect(x: x, y: y, width: w, height: font_size))
        name_label.text = text
        name_label.textAlignment = .center
        name_label.font = UIFont(name: font_name, size: font_size)
        
        return name_label
    }
    
    func TapSNSButton(sender: UIButton) {
        if sender.tag != -1 {
            let url = URL(string: (appdelegate.data?.GetSNS())![sender.tag][Key.url.rawValue].stringValue)!
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
            }
        }
    }
    
    func CreateEditButton(cgrect: CGRect) -> UIButton {
        
        return UIButton()
    }
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        if viewController.restorationIdentifier! == StoryboardID.MyProfile.rawValue && preViewName == StoryboardID.MyProfile.rawValue {
            scrollView.scroll(to: .top, animated: true)
        }

        preViewName = viewController.restorationIdentifier!
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        cover_img.frame = CGRect(x:cover_img.frame.origin.x, y:scrollView.contentOffset.y, width:cover_img.frame.width, height:cover_img.frame.height)
    }
    
    func UpdateCardViewFrame(last_add_cgrect: CGRect) {
        let y = cover_img.frame.height * 0.8
        cardView.frame = CGRect(x: base_margin, y: y, width: self.view.bounds.width - base_margin * 2, height: last_add_cgrect.origin.y+last_add_cgrect.height + base_margin)
    }
    
    func CallUserDetailAPI() {
        if debug {
            let dummy = UserDetailDummyData().user_data
            self.AddViews(json: JSON(dummy))
        }else {
            let urlString: String = API.host.rawValue + API.v1.rawValue + API.users.rawValue + String(user_id)
            Alamofire.request(urlString, method: .get).responseJSON { (response) in
                guard let object = response.result.value else{return}
                let json = JSON(object)
                print("MyProfile results: ", json.count)
                
                self.AddViews(json: json)
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
