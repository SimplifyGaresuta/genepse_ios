//
//  UserDetailViewController.swift
//  GENEPSE
//
//  Created by 岩見建汰 on 2017/12/04.
//  Copyright © 2017年 Kenta. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import Toucan

class UserDetailViewController: UIViewController, UIScrollViewDelegate {
    private var user_id = 0
    var data = DetailData()
    
    var base_margin = 0.0 as CGFloat
    
    var scrollView = UIScrollView()
    var cardView = UIView()
    var cover_img = UIImageView()
    var back_button = UIButton()
    var latest_frame = CGRect()
    
    var product_link:[String:String] = [:]
    var sns_link:[String:String] = [:]
    
    //MARK: DEBUG
    var debug = true
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
        UIApplication.shared.statusBarStyle = .default
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBar.isHidden = false
        UIApplication.shared.statusBarStyle = .lightContent
    }
    
    override func viewDidLoad() {
        CallUserDetailAPI()
        
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.white
        self.navigationItem.title = "User Detail"
        scrollView.delegate = self
        
        InitScrollView()
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        cover_img.frame = CGRect(x:cover_img.frame.origin.x, y:scrollView.contentOffset.y, width:cover_img.frame.width, height:cover_img.frame.height)
        back_button.frame = CGRect(x:back_button.frame.origin.x, y:scrollView.contentOffset.y, width:back_button.frame.width, height:back_button.frame.height)
    }

    
    func InitScrollView() {
        scrollView.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height)
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
        base_margin = self.view.bounds.width * 0.025
        
        data = GetDetailData(json: json)
        
        
        // 背景画像の追加
        let cover_img = CreateCoverImageView(url: data.GetCoverUrl())
        scrollView.addSubview(cover_img)
        self.cover_img = cover_img
        
        
        // Backボタンの追加
        let back_button = CreateBackButton()
        scrollView.addSubview(back_button)
        self.back_button = back_button
        
        
        // カードの追加
        InitCardView()
        
        
        // プロフ画像の追加
        let profileImageView = CreateProfileImageView(url: data.GetAvatarURL())
        cardView.addSubview(profileImageView)
        latest_frame = profileImageView.frame


        // SNSの設置
        let snsButtons = self.CreateSNSLabel(json: data.GetSNS())
        for s_button in snsButtons {
            cardView.addSubview(s_button)
        }
        
        
        // 名前の追加
        let nameLabel = CreateNameLabel(text: data.GetName())
        cardView.addSubview(nameLabel)
        latest_frame = nameLabel.frame
        
        
        // 属性の追加
        let attributeLabel = CreateAttributeLabel(attribute: data.GetAttr())
        cardView.addSubview(attributeLabel)
        latest_frame = attributeLabel.frame
        
        
        // 活動拠点の追加
        let activity_baseView = CreateActivityBase(name: data.GetActivityBase())
        cardView.addSubview(activity_baseView.0)
        cardView.addSubview(activity_baseView.1)
        latest_frame = activity_baseView.1.frame
        
        
        //TODO: スキルの追加
        let mainskillsLabels = CreateSkillsLabels(skills: data.GetSkills())
        for skillLabel in mainskillsLabels {
            cardView.addSubview(skillLabel as! UIView)
        }
        
        scrollView.contentSize = CGSize(width: self.view.bounds.width, height: 1000)



//
//
//
//
//        //拠点ラベルを追加
//        let activitybaseLabel = self.CreateActivityBaseLabel(name: data.GetActivityBase(), namelabel_cgrect: nameLabel.frame)
//        cardView.addSubview(activitybaseLabel)
//
//
//        // 経歴の追加
//        let careerLabel = self.CreateCareerLabel(text: data.GetOverview(), nameLabel_frame: nameLabel.frame)
//        cardView.addSubview(careerLabel)
//        UpdateCardViewFrame(last_add_cgrect: careerLabel.frame)
//
//        // 受賞歴の追加
//        let awards_sectionLable = self.CreateSectionLabel(text: "受賞歴", y: careerLabel.frame.origin.y+careerLabel.frame.height+base_margin*3)
//        cardView.addSubview(awards_sectionLable)
//        UpdateCardViewFrame(last_add_cgrect: awards_sectionLable.frame)
//        latest_section_frame = awards_sectionLable.frame
//
//        let awardsLabel = self.CreateAwardsLabel(awards: data.GetAwards())
//        cardView.addSubview(awardsLabel)
//        UpdateCardViewFrame(last_add_cgrect: awardsLabel.frame)
//
//
//        // スキルの追加
//        let skills_sectionLable = self.CreateSectionLabel(text: "スキル", y: awardsLabel.frame.origin.y+awardsLabel.frame.height+base_margin*3)
//        cardView.addSubview(skills_sectionLable)
//        UpdateCardViewFrame(last_add_cgrect: skills_sectionLable.frame)
//        latest_section_frame = skills_sectionLable.frame
//
//        let skillsLabels = self.CreateSkillsLabel(skills: data.GetSkills())
//        for skillLabel in skillsLabels {
//            cardView.addSubview(skillLabel)
//        }
//
//        if skillsLabels.count == 0 {
//            UpdateCardViewFrame(last_add_cgrect: skills_sectionLable.frame)
//        }else {
//            UpdateCardViewFrame(last_add_cgrect: skillsLabels.last!.frame)
//        }
//
//
//        // 作品の追加
//        var products_sectionLabel_y = 0.0 as CGFloat
//        if skillsLabels.count == 0 {
//            products_sectionLabel_y = skills_sectionLable.frame.origin.y+skills_sectionLable.frame.height
//        }else {
//            products_sectionLabel_y = skillsLabels.last!.frame.origin.y+skillsLabels.last!.frame.height
//        }
//
//        let products_sectionLable = self.CreateSectionLabel(text: "作品", y: products_sectionLabel_y+base_margin*3)
//
//        cardView.addSubview(products_sectionLable)
//        UpdateCardViewFrame(last_add_cgrect: products_sectionLable.frame)
//        latest_section_frame = products_sectionLable.frame
//
//        let productsViews = self.CreateProductLabel(json: json["products"])
//        for pViews in productsViews.0 {
//            cardView.addSubview(pViews.title)
//
//            if let urlLabel = pViews.url {
//                cardView.addSubview(pViews.link_img!)
//                cardView.addSubview(urlLabel)
//            }
//
//            if let imageView = pViews.image {
//                cardView.addSubview(pViews.image_shadow!)
//                cardView.addSubview(imageView)
//            }
//        }
//
//        if productsViews.0.count != 0 {
//            UpdateCardViewFrame(last_add_cgrect: productsViews.1)
//        }
//
//


//
//
//        // 資格の追加
//        let license_sectionLable = self.CreateSectionLabel(text: "資格", y: snsLabels.last!.url.frame.origin.y+snsLabels.last!.url.frame.height+base_margin*3)
//        cardView.addSubview(license_sectionLable)
//        UpdateCardViewFrame(last_add_cgrect: license_sectionLable.frame)
//        latest_section_frame = license_sectionLable.frame
//
//        let licensesLabel = self.CreateLicenseLabel(licenses: data.GetLicenses())
//        cardView.addSubview(licensesLabel)
//        UpdateCardViewFrame(last_add_cgrect: licensesLabel.frame)
//
//
//        // 基本情報の追加
//        let basic_info_sectionLabel = self.CreateSectionLabel(text: "基本情報", y: licensesLabel.frame.origin.y+licensesLabel.frame.height+base_margin*3)
//        cardView.addSubview(basic_info_sectionLabel)
//        UpdateCardViewFrame(last_add_cgrect: basic_info_sectionLabel.frame)
//        latest_section_frame = basic_info_sectionLabel.frame
//
//        let infoLabels = self.CreateBasicInfoLabel(info: [data.GetGender(), String(data.GetAge()), data.GetAddress(), data.GetSchoolCareer()])
//        for i_Label in infoLabels {
//            cardView.addSubview(i_Label)
//        }
//
//        var scroll_button_start_cgrect = CGRect()
//        if infoLabels.count == 0 {
//            scroll_button_start_cgrect = basic_info_sectionLabel.frame
//            UpdateCardViewFrame(last_add_cgrect: basic_info_sectionLabel.frame)
//        }else {
//            scroll_button_start_cgrect = infoLabels.last!.frame
//            UpdateCardViewFrame(last_add_cgrect: infoLabels.last!.frame)
//        }
//
//        // トップへスクロールするボタンの追加
//        cardView.addSubview(self.CreateTopToScrollButton(cgrect: scroll_button_start_cgrect))
    }
    
    func CreateCoverImageView(url: String) -> AsyncUIImageView {
        let h = self.view.frame.height * 0.3
        let cover_img = AsyncUIImageView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: h))
        cover_img.loadImage(urlString: url)
        cover_img.contentMode = .scaleAspectFill
        
        return cover_img
    }
    
    func CreateBackButton() -> UIButton {
        let statusBar_h = UIApplication.shared.statusBarFrame.height
        let button = UIButton(frame: CGRect(x: base_margin, y: statusBar_h+base_margin*5, width: 50, height: 50))
        button.setImage(UIImage(named: "icon_back"), for: .normal)
        button.addTarget(self, action: #selector(TapBackButton(sender:)), for: .touchUpInside)
        return button
    }
    
    func TapBackButton(sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func UpdateCardViewFrame(last_add_cgrect: CGRect) {
        cardView.frame = CGRect(x: base_margin, y: base_margin, width: self.view.bounds.width - base_margin * 2, height: last_add_cgrect.origin.y+last_add_cgrect.height + base_margin)
    }
    
    func CreateProfileImageView(url: String) -> UIImageView {
        let escapedAddress = url.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
        let url = URL(string: escapedAddress!)!
        
        do {
            let imageData: NSData = try NSData(contentsOf: url)
            let wh = base_margin * 12.5
            let x = cardView.frame.width / 2 - wh/2
            let y = cardView.bounds.origin.y - wh/2
            
            let resizedAndMaskedImage = Toucan(image: UIImage(data: imageData as Data)!).resize(CGSize(width: wh, height: wh), fitMode: Toucan.Resize.FitMode.clip).maskWithEllipse().image
            let imageview = UIImageView(image: resizedAndMaskedImage)
            imageview.frame = CGRect(x: x, y: y, width: wh, height: wh)
            
            return imageview
        }catch{
            print(error)
        }
        
        return UIImageView()
    }
    
    func CreateSNSLabel(json: [JSON]) -> [UIButton] {
        let wh = base_margin * 4.5
        let y = cardView.bounds.origin.y - wh/2
        let x = [cardView.bounds.origin.x + base_margin * 5, cardView.bounds.width-base_margin * 5-wh]
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
    
    func TapSNSButton(sender: UIButton) {
        if sender.tag != -1 {
            let url = URL(string: data.GetSNS()[sender.tag][Key.url.rawValue].stringValue)!
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
            }
        }
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
        
        let y = latest_frame.origin.y+latest_frame.height + base_margin
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
        let start_y = latest_frame.origin.y+latest_frame.height+base_margin*2
        let homeImageView_wh = 16 as CGFloat
        homeImageView.frame = CGRect(x: 0, y: start_y, width: homeImageView_wh, height: homeImageView_wh)
        
        let label = UILabel(frame: CGRect(x: 0, y: start_y, width: 0, height: 0))
        label.font = UIFont(name: FontName.J_W6.rawValue, size: 16)
        label.text = name
        label.sizeToFit()
        
        let label_start_x = cardView.frame.width/2 - (homeImageView.frame.width + label.frame.width+base_margin) / 2
        homeImageView.frame = CGRect(x: label_start_x, y: start_y, width: homeImageView_wh, height: homeImageView_wh)
        label.frame = CGRect(x: homeImageView.frame.origin.x+homeImageView.frame.width+base_margin, y: start_y, width: 0, height: 0)
        label.sizeToFit()
        
        return (homeImageView, label)
    }
    
    func CreateSkillsLabels(skills: Array<String>) -> Array<Any> {
        var views:[Any] = []
        var y = latest_frame.height+latest_frame.origin.y + base_margin
        var x = 0 as CGFloat
        var sum_w = 0 as CGFloat
        
        //初期配置をしてサイズを求めるためのループ
        for (i, skill) in skills.enumerated() {
            //スキルを3つ配置したら改行
            if i != 0 && i % 3 == 0 {
                _ = views.popLast()
                let last_view = views.last! as! UILabel
                x = 0
                y = last_view.frame.origin.y+last_view.frame.height + base_margin*3
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
            
            x = label.frame.origin.x + label.frame.width + base_margin*0.25
            sum_w += label.frame.width+base_margin*0.25
            
            //スラッシュ画像追加
            let slash = UIImageView(image: UIImage(named: "icon_slash"))
            slash.frame = CGRect(x: x, y: y, width: 5, height: 15)
            views.append(slash)
            
            x = slash.frame.origin.x + slash.frame.width + base_margin*0.25
            sum_w += slash.frame.width+base_margin*0.25
        }
        
        let last_view = views.last! as! UIImageView
        sum_w -= last_view.frame.width+base_margin*0.25
        _ = views.popLast()
        
        var start_x = (cardView.frame.width - sum_w) / 2
        
//        for view in views {
//            if let label = view as? UILabel {
//                label.frame = CGRect(x: start_x, y: label.frame.origin.y, width: 0, height: 0)
//                label.sizeToFit()
//                start_x = label.frame.origin.x + label.frame.width + base_margin*0.25
//            }else {
//                let slash = view as! UIImageView
//                slash.frame = CGRect(x: start_x, y: slash.frame.origin.y, width: 5, height: 15)
//                start_x = slash.frame.origin.x + slash.frame.width + base_margin*0.25
//            }
//        }
        
        return views
    }
    
    func TapURLLabel(sender: UITapGestureRecognizer){
        let id = (sender.view?.tag)!
        
        let url = URL(string: product_link[String(id)]!)!
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }
    
    
    func TapScrollTop(sender: UIButton) {
        scrollView.scroll(to: .top, animated: true)
    }
    
    func SetUserID(id: Int) {
        user_id = id
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
                print("User Detail results: ", json.count)
                
                self.AddViews(json: json)
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
