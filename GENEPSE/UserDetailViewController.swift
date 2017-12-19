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
        
        
        
        scrollView.contentSize = CGSize(width: self.view.bounds.width, height: 1000)

//
//        // 属性の追加
//        let attributeImageView = CreateAttributeImageView(attribute: data.GetAttr())
//        cardView.addSubview(attributeImageView)
//        UpdateCardViewFrame(last_add_cgrect: attributeImageView.frame)
//
//
//        // メインスキルの追加
//        let mainskillsLabels = self.CreateMainSkillsLabels(skills: data.GetMainSkills())
//
//        for (shadowView, skillLabel) in zip(mainskillsLabels.0, mainskillsLabels.1) {
//            cardView.addSubview(shadowView)
//            cardView.addSubview(skillLabel)
//        }
//
//
//        // 名前の追加
//        let nameLabel = self.CreateNameLabel(text: data.GetName())
//        cardView.addSubview(nameLabel)
//        UpdateCardViewFrame(last_add_cgrect: nameLabel.frame)
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
    
//    func CreateAttributeImageView(attribute: String) -> UIImageView {
//        let y = profileImageView.frame.origin.y + base_margin
//
//        let attributeImageView = UIImageView(image: UIImage(named: "attr_"+attribute))
//        attributeImageView.frame = CGRect(x: base_margin, y: y, width: profileImageView.frame.width*0.45, height: profileImageView.frame.height*0.2)
//        attributeImageView.contentMode = .scaleAspectFill
//
//        return attributeImageView
//    }
    
//    func CreateMainSkillsLabels(skills: Array<String>) -> (Array<UIView>, Array<UILabel>) {
//        var labels = [UILabel]()
//        var views = [UIView]()
//        let bg_color = UIColor.white
//
//        var labelstart_x = base_margin * 0.25
//        let label_y = profileImageView.frame.origin.y + profileImageView.frame.height
//
//        for skill in skills {
//            let je_num = SearchJapaneseEnglish(text: skill)
//            let font_name = GetFontName(je_num: je_num, font_w: 6)
//            var font_size = 0 as CGFloat
//            if je_num == JapaneseEnglish.Japanese.rawValue {
//                font_size = 20
//            }else {
//                font_size = 21
//            }
//
//            // skillラベルの生成
//            let label = UILabel(frame: CGRect(x: labelstart_x, y: label_y, width: 0, height: 0))
//            label.text = "  " + skill + "  "
//            label.font = UIFont(name: font_name, size: font_size)
//            label.backgroundColor = bg_color
//            label.sizeToFit()
//            label.layer.cornerRadius = 10
//            label.layer.masksToBounds = true
//            label.frame = CGRect(x: labelstart_x, y: label.frame.origin.y-label.frame.height - base_margin*0.25, width: 0, height: 0)   //プロフ画像のbottomからマージン分だけ上に
//            label.sizeToFit()   //w, hの再調整
//
//            labelstart_x = label.frame.origin.x + label.frame.width + base_margin*0.25
//
//            // 影Viewの生成
//            let offset = 1.5
//            let shadow = UIView(frame: CGRect(x: label.frame.origin.x, y: label.frame.origin.y, width: label.frame.width, height: label.frame.height))
//            shadow.layer.shadowColor = UIColor.black.cgColor
//            shadow.backgroundColor = bg_color
//            shadow.layer.shadowOpacity = 1.0
//            shadow.layer.shadowOffset = CGSize(width: offset, height: offset)
//            shadow.layer.shadowRadius = CGFloat(offset)
//            shadow.layer.cornerRadius = 10
//
//            labels.append(label)
//            views.append(shadow)
//        }
//        return (views, labels)
//    }
    
//    func CreateNameLabel(text: String) -> UILabel {
//        let je_num = SearchJapaneseEnglish(text: text)
//        let font_name = GetFontName(je_num: je_num, font_w: 6)
//        var font_size = 0 as CGFloat
//        if je_num == JapaneseEnglish.Japanese.rawValue {
//            font_size = 37
//        }else {
//            font_size = 39
//        }
//
//        let name_label = UILabel(frame: CGRect(x: base_margin, y: profileImageView.frame.height+base_margin, width: cardView.frame.width-base_margin, height: base_margin))
//        name_label.text = text
//        name_label.font = UIFont(name: font_name, size: font_size)
//        name_label.sizeToFit()
//
//        return name_label
//    }
    
    
//    func CreateActivityBaseLabel(name: String, namelabel_cgrect: CGRect) -> UILabel {
//
//        if name == "" {
//            return UILabel()
//        }
//
//        let x = namelabel_cgrect.origin.x + namelabel_cgrect.width + base_margin*1.5
//        let y = namelabel_cgrect.origin.y
//
//        let label = EdgeInsetLabel(frame: CGRect(x: x, y: y, width: namelabel_cgrect.width, height: namelabel_cgrect.height+base_margin))
//        label.text = name
//        label.font = UIFont(name: FontName.J_W6.rawValue, size: 23)
//        label.textColor = UIColor.white
//        label.backgroundColor = UIColor.black
//
//        //サイズをfitさせて残りの高さを計算
//        label.sizeToFit()
//        let fit_height = label.frame.height
//        let rest_h = namelabel_cgrect.height - fit_height
//
//        label.topTextInset = rest_h/2
//        label.bottomTextInset = rest_h/2
//        label.leftTextInset = 20
//        label.rightTextInset = 20
//        label.sizeToFit()
//        label.layer.cornerRadius = 20
//        label.layer.masksToBounds = true
//
//        return label
//    }
    
//    func CreateCareerLabel(text: String, nameLabel_frame: CGRect) -> UILabel {
//        let label_start_y = nameLabel_frame.origin.y+nameLabel_frame.height
//
//        let career_label = UILabel(frame: CGRect(x: base_margin, y: label_start_y+base_margin*0.5, width: cardView.frame.width-base_margin*2, height: base_margin*2))
//        career_label.font = UIFont(name: FontName.J_W3.rawValue, size: 15)
//        career_label.backgroundColor = UIColor.clear
//        career_label.numberOfLines = 0
//
//        //行間調整
////        career_label.attributedText = GetAttributedTextLineHeight(height: 22, text: text)
//
//        career_label.sizeToFit()
//        return career_label
//    }
    
//    func CreateSectionLabel(text: String, y: CGFloat) -> UILabel {
//        let label = UILabel(frame: CGRect(x: base_margin, y: y, width: 0, height: 0))
//        label.text = text
//        label.font = UIFont(name: FontName.J_W6.rawValue, size: 21)
//        label.sizeToFit()
//
//        return label
//    }
    
//    func CreateAwardsLabel(awards: Array<String>) -> UILabel {
//        let label = UILabel(frame: CGRect(x: base_margin, y: latest_section_frame.origin.y+latest_section_frame.height+base_margin*0.25, width: 0, height: 0))
//
//        var text = ""
//        for award in awards {
//            text += award + "\n"
//        }
//
//        if !text.isEmpty {
//            text = text.substring(to: text.index(before: text.endIndex))
//        }
//
////        label.attributedText = GetAttributedTextLineHeight(height: 20, text: text)
//        label.font = UIFont(name: FontName.J_W3.rawValue, size: 15)
//        label.numberOfLines = awards.count
//        label.sizeToFit()
//
//        return label
//    }
    
//    func CreateSkillsLabel(skills: [String]) -> Array<UILabel> {
//        var start_x = base_margin
//        var start_y = latest_section_frame.origin.y + latest_section_frame.height + base_margin*0.25
//        var labels = [UILabel]()
//
//        for skill in skills {
//            let je_num = SearchJapaneseEnglish(text: skill)
//            let font_name = GetFontName(je_num: je_num, font_w: 6)
//            var font_size = 0 as CGFloat
//            if je_num == JapaneseEnglish.Japanese.rawValue {
//                font_size = 15
//            }else {
//                font_size = 16
//            }
//
//            let label = UILabel(frame: CGRect(x: start_x, y: start_y, width: 0, height: 0))
//            label.text = "  " + skill + "  "
//            label.font = UIFont(name: font_name, size: font_size)
//            label.backgroundColor = UIColor.hexStr(hexStr: SkillTagColor.gray.rawValue as NSString, alpha: 1.0)
//            label.textColor = UIColor.white
//            label.sizeToFit()
//            label.layer.cornerRadius = 10
//            label.layer.masksToBounds = true
//
//            //追加しようとしているラベルがカード幅を超える場合
//            if (label.frame.origin.x+label.frame.width) > (cardView.frame.origin.x+cardView.frame.width-base_margin) {
//                start_y = label.frame.origin.y + label.frame.height + base_margin*0.25
//
//                label.frame = CGRect(x: base_margin, y: start_y, width: 0, height: 0)
//                label.sizeToFit()
//            }
//
//            labels.append(label)
//            start_x = label.frame.origin.x + label.frame.width + base_margin*0.25
//        }
//
//        return labels
//    }
    
//    func CreateProductLabel(json: JSON) -> ([(title: UILabel, url: UILabel?, link_img: UIImageView?, image: AsyncUIImageView?, image_shadow: UIView?)], CGRect) {
//        var productsViews: [(title: UILabel, url: UILabel?, link_img: UIImageView?, image: AsyncUIImageView?, image_shadow: UIView?)] = []
//        var last_add_view_frame = CGRect()
//
//        // next_y = セクションタイトルのbottomで初期化
//        var next_y = latest_section_frame.origin.y + latest_section_frame.height + base_margin*0.5
//
//        json.forEach { (i, obj) in
//            var pViews: (title: UILabel, url: UILabel?, link_img: UIImageView?, image: AsyncUIImageView?, image_shadow: UIView?) = (title: UILabel(), url: nil, link_img: nil, image: nil, image_shadow: nil)
//
//            //next_yからプロダクトタイトルの追加
//            let titleLabel = UILabel(frame: CGRect(x: base_margin, y: next_y, width: 0, height: 0))
//            titleLabel.text = obj["title"].string
//            titleLabel.font = UIFont(name: FontName.J_W6.rawValue, size: 17)
//            titleLabel.sizeToFit()
//            pViews.title = titleLabel
//
//            //最後に追加したviewとして記録
//            last_add_view_frame = titleLabel.frame
//
//            //next_yをプロダクトタイトルに更新
//            next_y = titleLabel.frame.origin.y + titleLabel.frame.height + base_margin*0.25
//
//            //URLがあったら,next_yからURLラベルの追加
//            if !(obj[Key.url.rawValue].string?.isEmpty)! {
//                let linkImageView = UIImageView(image: UIImage(named: "link_icon"))
//
//                let tap = UITapGestureRecognizer(target: self, action: #selector(self.TapURLLabel(sender:)))
//                product_link[i] = obj[Key.url.rawValue].stringValue
//
//                linkImageView.contentMode = .scaleAspectFill
//                linkImageView.frame = CGRect(x: base_margin, y: next_y, width: base_margin*0.8, height: base_margin*0.8)
//
//                let start_x = linkImageView.frame.origin.x + linkImageView.frame.width
//                let urlLabel = UILabel(frame: CGRect(x: start_x+base_margin*0.1, y: next_y, width: 0, height: 0))
//
//                urlLabel.tag = Int(i)!
//                urlLabel.text = obj[Key.url.rawValue].string
//                urlLabel.font = UIFont(name: FontName.URL.rawValue, size: 15)
//                urlLabel.sizeToFit()
//                urlLabel.isUserInteractionEnabled = true
//                urlLabel.addGestureRecognizer(tap)
//
//                pViews.url = urlLabel
//                pViews.link_img = linkImageView
//
//                //最後に追加したviewとして記録
//                last_add_view_frame = urlLabel.frame
//
//                //next_yをURLラベルに更新
//                next_y = urlLabel.frame.origin.y + urlLabel.frame.height + base_margin*0.5
//            }
//
//            //画像があったら，next_yから画像の追加
//            if !(obj["image"].string?.isEmpty)! {
//                let imageView = AsyncUIImageView(frame: CGRect(x: base_margin, y: next_y, width: cardView.frame.width-base_margin*2, height: self.view.frame.height*0.3))
//                imageView.loadImage(urlString: obj["image"].string!)
//                imageView.contentMode = .scaleAspectFill
//                imageView.layer.cornerRadius = 10
//                imageView.layer.masksToBounds = true
//
//                // 影をつけるためのViewを作成
//                let shadow_view = UIView(frame: imageView.frame)
//                shadow_view.backgroundColor = UIColor.white
//                shadow_view.layer.shadowColor = UIColor.black.cgColor
//                shadow_view.layer.shadowOpacity = 0.5
//                shadow_view.layer.shadowOffset = CGSize(width: 2, height: 2)
//                shadow_view.layer.shadowRadius = 2
//                shadow_view.layer.cornerRadius = 10
//
//                pViews.image = imageView
//                pViews.image_shadow = shadow_view
//
//                //最後に追加したviewとして記録
//                last_add_view_frame = imageView.frame
//
//                //next_yを画像に更新
//                next_y = imageView.frame.origin.y + imageView.frame.height + base_margin*1.25
//            }
//
//            productsViews.append(pViews)
//
//        }
//
//        return (productsViews, last_add_view_frame)
//    }
    
    func TapURLLabel(sender: UITapGestureRecognizer){
        let id = (sender.view?.tag)!
        
        let url = URL(string: product_link[String(id)]!)!
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }
        
    
//    func CreateLicenseLabel(licenses: Array<String>) -> UILabel {
//        let label = UILabel(frame: CGRect(x: base_margin, y: latest_section_frame.origin.y+latest_section_frame.height+base_margin*0.25, width: 0, height: 0))
//
//        var text = ""
//        for license in licenses {
//            text += license + "\n"
//        }
//
//        if !text.isEmpty {
//            text = text.substring(to: text.index(before: text.endIndex))
//        }
//
//        //行間調整
////        label.attributedText = GetAttributedTextLineHeight(height: 20, text: text)
//
//        label.font = UIFont(name: FontName.J_W3.rawValue, size: 15)
//        label.numberOfLines = licenses.count
//        label.sizeToFit()
//
//        return label
//    }
    
//    func CreateBasicInfoLabel(info: Array<String>) -> Array<UILabel> {
//        let info_name = ["性別", "年齢", "居住地", "学歴"]
//        var infoLabels = [UILabel]()
//        var start_y = latest_section_frame.origin.y + latest_section_frame.height + base_margin*0.5
//
//        for (index, info_str) in info.enumerated() {
//            if !(info_str.isEmpty) {
//                let label = UILabel(frame: CGRect(x: base_margin, y: start_y, width: 0, height: 0))
//                label.text = info_name[index] + "：" + info_str
//                label.font = UIFont(name: FontName.J_W3.rawValue, size: 15)
//
//                // 0歳(初期状態)だった場合はテキストをリセット
//                if index == 1 {
//                    if info[index] == "0" {
//                        label.text = ""
//                    }else {
//                        label.text = label.text! + "歳"
//                    }
//                }
//
//                label.sizeToFit()
//
//                infoLabels.append(label)
//                start_y = label.frame.origin.y + label.frame.height + base_margin*0.1
//            }
//        }
//
//        return infoLabels
//    }
    
//    func CreateTopToScrollButton(cgrect: CGRect) -> UIButton {
//        let button = UIButton()
//        let image = UIImage(named: "up_arrow")
//
//        let x = cardView.frame.origin.x + cardView.frame.width - base_margin*3.5
//        let y = cgrect.origin.y + cgrect.height - base_margin*2
//        let size = base_margin*2.5
//
//        button.frame = CGRect(x: x, y: y, width: size, height: size)
//        button.setImage(image, for: .normal)
//        button.imageView?.contentMode = .scaleAspectFit
//        button.contentHorizontalAlignment = .fill
//        button.contentVerticalAlignment = .fill
//        button.addTarget(self, action: #selector(self.TapScrollTop(sender:)),
//                         for: .touchUpInside)
//
//        return button
//    }
    
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
