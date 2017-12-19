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
        cardView.addSubview(CreateEditButton(cgrect: nameLabel.frame, id: SectionID_New.main.rawValue))
        
        
        // 属性の追加
        let attributeLabel = CreateAttributeLabel(attribute: (appdelegate.data?.GetAttr())!)
        cardView.addSubview(attributeLabel)
        latest_frame = attributeLabel.frame
        UpdateCardViewFrame(last_add_cgrect: attributeLabel.frame)
        
        
        // 活動拠点の追加
        let activity_baseView = CreateActivityBase(name: (appdelegate.data?.GetActivityBase())!)
        cardView.addSubview(activity_baseView.0)
        cardView.addSubview(activity_baseView.1)
        latest_frame = activity_baseView.1.frame
        UpdateCardViewFrame(last_add_cgrect: activity_baseView.1.frame)
        
        
        // スキルの追加
        let mainskillsLabels = CreateSkillsLabels(skills: (appdelegate.data?.GetSkills())!)
        for skillLabel in mainskillsLabels {
            cardView.addSubview(skillLabel as! UIView)
        }
        
        if mainskillsLabels.count != 0 {
            let tmp_view = mainskillsLabels.last! as! UIView
            latest_frame = tmp_view.frame
            UpdateCardViewFrame(last_add_cgrect: tmp_view.frame)
        }
        
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
        
        let y = latest_frame.origin.y+latest_frame.height+base_margin * 1.5
        let name_label = UILabel(frame: CGRect(x: 0, y: y, width: 0, height: font_size))
        name_label.text = text
        name_label.textAlignment = .center
        name_label.font = UIFont(name: font_name, size: font_size)
        name_label.sizeToFit()
        
        let new_x = (cardView.bounds.width/2+cardView.bounds.origin.x) - name_label.bounds.width/2
        name_label.frame = CGRect(x: new_x, y: y, width: name_label.bounds.width, height: font_size)
        
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
    
    func CreateAttributeLabel(attribute: String) -> UILabel {
        var text = ""
        switch attribute {
        case AttributeStr.Designer.rawValue:
            text = AttributeStr_L.Designer.rawValue
        case AttributeStr.Engineer.rawValue:
            text = AttributeStr_L.Engineer.rawValue
        case AttributeStr.Business.rawValue:
            text = AttributeStr_L.Business.rawValue
        default:
            break
        }
        
        var attr_text = NSMutableAttributedString(string: text)
        attr_text = AddAttributedTextLetterSpacing(space: 0.9, text: attr_text)
        
        let y = latest_frame.origin.y+latest_frame.height + base_margin * 0.5
        let f_size = 14 as CGFloat
        let label = EdgeInsetLabel(frame: CGRect(x: 0, y: y, width: 0, height: f_size))
        
        label.attributedText = attr_text
        label.textAlignment = .left
        label.font = UIFont(name: FontName.DIN.rawValue, size: f_size)
        label.borderWidth = 1
        label.borderColor = UIColor.black
        label.topTextInset = 2
        label.rightTextInset = 5
        label.bottomTextInset = 2
        label.leftTextInset = 5
        label.sizeToFit()
        
        label.frame = CGRect(x: cardView.frame.width/2 - label.frame.width/2, y: label.frame.origin.y, width: label.frame.width, height: label.frame.height)
        
        return label
    }
    
    func CreateActivityBase(name: String) -> (UIImageView, UILabel) {
        let homeImageView = UIImageView(image: UIImage(named: "icon_home"))
        let start_y = latest_frame.origin.y+latest_frame.height+base_margin
        let homeImageView_wh = 16 as CGFloat
        homeImageView.frame = CGRect(x: 0, y: start_y, width: homeImageView_wh, height: homeImageView_wh)
        
        let label = UILabel(frame: CGRect(x: 0, y: start_y, width: 0, height: 0))
        label.font = UIFont(name: FontName.J_W6.rawValue, size: 16)
        label.text = name
        label.sizeToFit()
        
        let label_start_x = cardView.frame.width/2 - (homeImageView.frame.width + label.frame.width+base_margin*0.5) / 2
        homeImageView.frame = CGRect(x: label_start_x, y: start_y, width: homeImageView_wh, height: homeImageView_wh)
        label.frame = CGRect(x: homeImageView.frame.origin.x+homeImageView.frame.width+base_margin*0.5, y: start_y, width: 0, height: 0)
        label.sizeToFit()
        
        return (homeImageView, label)
    }
    
    func CreateSkillsLabels(skills: Array<String>) -> Array<Any> {
        var views:[Any] = []
        var y = latest_frame.height+latest_frame.origin.y + base_margin
        var x = 0 as CGFloat
        var count = 0
        let margin_offset = 0.5 as CGFloat
        
        //初期配置をしてサイズを求めるためのループ
        for (i, skill) in skills.enumerated() {
            //スキルを3つ配置したら改行
            if i != 0 && i % 3 == 0 {
                count += 1
                let last_view = views.last! as! UIView
                x = 0
                y = last_view.frame.origin.y+last_view.frame.height + base_margin*0.5
                _ = views.popLast()
            }
            
            var attr_str = NSMutableAttributedString(string: skill)
            let je_num = SearchJapaneseEnglish(text: skill)
            let font_name = GetFontName(je_num: je_num, font_w: 6)
            var font_size = 0 as CGFloat
            if je_num == JapaneseEnglish.Japanese.rawValue {
                font_size = 14
            }else {
                font_size = 15
                attr_str = AddAttributedTextLetterSpacing(space: 0.2, text: attr_str)
            }
            
            //skillラベル追加
            let label = UILabel(frame: CGRect(x: x, y: y, width: 0, height: 0))
            label.attributedText = attr_str
            label.font = UIFont(name: font_name, size: font_size)
            label.sizeToFit()
            views.append(label)
            
            x = label.frame.origin.x + label.frame.width + base_margin*margin_offset
            
            //スラッシュ画像追加
            let slash = UIImageView(image: UIImage(named: "icon_slash"))
            slash.frame = CGRect(x: x, y: y, width: 5, height: 15)
            views.append(slash)
            
            x = slash.frame.origin.x + slash.frame.width + base_margin*margin_offset
        }
        
        _ = views.popLast()
        
        var s = 0
        var e = 4
        //行数分だけループ
        for _ in 0...count {
            var sum_w = 0 as CGFloat
            
            //スキル3つ分の幅を合算
            for view in views.safeRange(range: Range(s...e)).map({$0}) {
                let tmp = view as! UIView
                sum_w += tmp.frame.width
            }
            sum_w += (base_margin*margin_offset)*4
            
            var start_x = cardView.frame.width/2 - sum_w/2
            
            //xを調整して中央に配置
            for view in views.safeRange(range: Range(s...e)).map({$0}) {
                if let label = view as? UILabel {
                    label.frame = CGRect(x: start_x, y: label.frame.origin.y, width: 0, height: 0)
                    label.sizeToFit()
                    start_x = label.frame.origin.x + label.frame.width + base_margin*margin_offset
                }else {
                    let slash = view as! UIImageView
                    slash.frame = CGRect(x: start_x, y: slash.frame.origin.y, width: 5, height: 15)
                    start_x = slash.frame.origin.x + slash.frame.width + base_margin*margin_offset
                }
            }
            s = e+1
            e = s+4
        }
        
        return views
    }
    
    func CreateEditButton(cgrect: CGRect, id: Int) -> UIButton {
        let image_wh = 30 as CGFloat
        let EdgeInset = 5 as CGFloat
        let x = cgrect.origin.x + cgrect.width + base_margin * 0.5
        let button = UIButton(frame: CGRect(x: x, y: cgrect.origin.y, width: image_wh, height: image_wh))
        button.setImage(UIImage(named: "icon_edit"), for: .normal)
        button.imageEdgeInsets = UIEdgeInsets(top: EdgeInset, left: EdgeInset, bottom: EdgeInset, right: EdgeInset)
        button.addTarget(self, action: #selector(TapEditButton(sender:)), for: .touchUpInside)
        button.tag = id
        
        return button
    }
    
    func TapEditButton(sender: UIButton) {
        print(sender.tag)
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
