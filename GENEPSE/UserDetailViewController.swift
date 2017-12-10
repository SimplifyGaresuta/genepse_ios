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

class UserDetailViewController: UIViewController {
    private var user_id = 0
    var base_margin = 0.0 as CGFloat
    
    var scrollView = UIScrollView()
    var cardView = UIView()
    var profileImageView = UIImageView()
    var latest_section_frame = CGRect()
    
    override func viewDidLoad() {
        CallUserDetailAPI()
        
        super.viewDidLoad()
        
        base_margin = self.view.bounds.width * 0.05
        self.view.backgroundColor = UIColor.white
        self.navigationItem.title = "User Detail"
        
        InitScrollView()
        InitCardView()
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
        
        cardView.frame = CGRect(x: base_margin, y: base_margin, width: self.view.bounds.width - base_margin * 2, height: self.view.bounds.height+1000)
        cardView.backgroundColor = UIColor.white
        
        cardView.layer.cornerRadius = 20
        cardView.layer.shadowOpacity = 0.2
        cardView.layer.shadowColor = UIColor.black.cgColor
        cardView.layer.shadowOffset = CGSize(width: 1, height: 1)
        cardView.layer.shadowRadius = 4
        cardView.layer.masksToBounds = false
        
        scrollView.addSubview(cardView)
    }
    
    func AddViews(json: JSON) {
        let data = GetDetailData(json: json)
        
        // プロフ画像の追加
        profileImageView = CreateProfileImageView(url: data.GetAvatarURL())
        cardView.addSubview(profileImageView)
        UpdateCardViewFrame(last_add_cgrect: profileImageView.frame)
        
        
        // 属性の追加
        let attributeLabels = CreateAttributeLabel(attribute: data.GetAttr())
        cardView.addSubview(attributeLabels.0)
        cardView.addSubview(attributeLabels.1)
        UpdateCardViewFrame(last_add_cgrect: attributeLabels.1.frame)
        
        
        // メインスキルの追加
        let mainskillsLabels = self.CreateMainSkillsLabels(skills: data.GetMainSkills())

        for (shadowView, skillLabel) in zip(mainskillsLabels.0, mainskillsLabels.1) {
            cardView.addSubview(shadowView)
            cardView.addSubview(skillLabel)
        }
        
        
        // 名前の追加
        let nameLabel = self.CreateNameLabel(text: data.GetName())
        cardView.addSubview(nameLabel)
        UpdateCardViewFrame(last_add_cgrect: nameLabel.frame)

        
        // 経歴の追加
        let careerLabel = self.CreateCareerLabel(text: data.GetOverview(), nameLabel_frame: nameLabel.frame)
        cardView.addSubview(careerLabel)
        UpdateCardViewFrame(last_add_cgrect: careerLabel.frame)
        
        // 受賞歴の追加
        let awards_sectionLable = self.CreateSectionLabel(text: "受賞歴", y: careerLabel.frame.origin.y+careerLabel.frame.height+base_margin*3)
        cardView.addSubview(awards_sectionLable)
        UpdateCardViewFrame(last_add_cgrect: awards_sectionLable.frame)
        latest_section_frame = awards_sectionLable.frame

        let awardsLabel = self.CreateAwardsLabel(awards: data.GetAwards())
        cardView.addSubview(awardsLabel)
        UpdateCardViewFrame(last_add_cgrect: awardsLabel.frame)
        
        
        // スキルの追加
        let skills_sectionLable = self.CreateSectionLabel(text: "スキル", y: awardsLabel.frame.origin.y+awardsLabel.frame.height+base_margin*3)
        cardView.addSubview(skills_sectionLable)
        UpdateCardViewFrame(last_add_cgrect: skills_sectionLable.frame)
        latest_section_frame = skills_sectionLable.frame

        let skillsLabels = self.CreateSkillsLabel(skills: data.GetSkills())
        for skillLabel in skillsLabels {
            cardView.addSubview(skillLabel)
        }
        
        if skillsLabels.count == 0 {
            UpdateCardViewFrame(last_add_cgrect: skills_sectionLable.frame)
        }else {
            UpdateCardViewFrame(last_add_cgrect: skillsLabels.last!.frame)
        }
        
        
        // 作品の追加
        var products_sectionLabel_y = 0.0 as CGFloat
        if skillsLabels.count == 0 {
            products_sectionLabel_y = skills_sectionLable.frame.origin.y+skills_sectionLable.frame.height
        }else {
            products_sectionLabel_y = skillsLabels.last!.frame.origin.y+skillsLabels.last!.frame.height
        }
        
        let products_sectionLable = self.CreateSectionLabel(text: "作品", y: products_sectionLabel_y+base_margin*3)
        
        cardView.addSubview(products_sectionLable)
        UpdateCardViewFrame(last_add_cgrect: products_sectionLable.frame)
        latest_section_frame = products_sectionLable.frame

        let productsViews = self.CreateProductLabel(json: json["products"])
        for pViews in productsViews.0 {
            cardView.addSubview(pViews.title)

            if let urlLabel = pViews.url {
                cardView.addSubview(pViews.link_img!)
                cardView.addSubview(urlLabel)
            }

            if let imageView = pViews.image {
                cardView.addSubview(pViews.image_shadow!)
                cardView.addSubview(imageView)
            }
        }
        
        if productsViews.0.count != 0 {
            UpdateCardViewFrame(last_add_cgrect: productsViews.1)
        }
        
        
        // SNSの追加
        var sns_sectionLable_y = 0.0 as CGFloat
        if productsViews.0.count == 0 {
            sns_sectionLable_y = products_sectionLable.frame.origin.y+products_sectionLable.frame.height
        }else {
            sns_sectionLable_y = productsViews.1.origin.y+productsViews.1.height
        }
        
        let sns_sectionLable = self.CreateSectionLabel(text: "SNS", y: sns_sectionLable_y+base_margin*3)
        cardView.addSubview(sns_sectionLable)
        UpdateCardViewFrame(last_add_cgrect: sns_sectionLable.frame)
        latest_section_frame = sns_sectionLable.frame

        let snsLabels = self.CreateSNSLabel(json: json["sns"])
        for s_Label in snsLabels {
            cardView.addSubview(s_Label.icon)
            cardView.addSubview(s_Label.url)
        }
        UpdateCardViewFrame(last_add_cgrect: snsLabels.last!.url.frame)
        
        
        // 資格の追加
        let license_sectionLable = self.CreateSectionLabel(text: "資格", y: snsLabels.last!.url.frame.origin.y+snsLabels.last!.url.frame.height+base_margin*3)
        cardView.addSubview(license_sectionLable)
        UpdateCardViewFrame(last_add_cgrect: license_sectionLable.frame)
        latest_section_frame = license_sectionLable.frame

        let licensesLabel = self.CreateLicenseLabel(licenses: data.GetLicenses())
        cardView.addSubview(licensesLabel)
        UpdateCardViewFrame(last_add_cgrect: licensesLabel.frame)
        
        
        // 基本情報の追加
        let basic_info_sectionLabel = self.CreateSectionLabel(text: "基本情報", y: licensesLabel.frame.origin.y+licensesLabel.frame.height+base_margin*3)
        cardView.addSubview(basic_info_sectionLabel)
        UpdateCardViewFrame(last_add_cgrect: basic_info_sectionLabel.frame)
        latest_section_frame = basic_info_sectionLabel.frame

        let infoLabels = self.CreateBasicInfoLabel(info: [data.GetGender(), String(data.GetAge()), data.GetAddress(), data.GetSchoolCareer()])
        for i_Label in infoLabels {
            cardView.addSubview(i_Label)
        }
        
        var scroll_button_start_cgrect = CGRect()
        if infoLabels.count == 0 {
            scroll_button_start_cgrect = basic_info_sectionLabel.frame
            UpdateCardViewFrame(last_add_cgrect: basic_info_sectionLabel.frame)
        }else {
            scroll_button_start_cgrect = infoLabels.last!.frame
            UpdateCardViewFrame(last_add_cgrect: infoLabels.last!.frame)
        }
        
        // トップへスクロールするボタンの追加
        cardView.addSubview(self.CreateTopToScrollButton(cgrect: scroll_button_start_cgrect))
        
        scrollView.contentSize = CGSize(width: self.view.bounds.width, height: cardView.frame.height+base_margin*2)
    }
    
    func UpdateCardViewFrame(last_add_cgrect: CGRect) {
        cardView.frame = CGRect(x: base_margin, y: base_margin, width: self.view.bounds.width - base_margin * 2, height: last_add_cgrect.origin.y+last_add_cgrect.height + base_margin)
    }
    
    func CreateProfileImageView(url: String) -> UIImageView {
        let imageView = AsyncUIImageView(frame: CGRect(x: 0, y: 0, width: cardView.frame.width, height: self.view.frame.height*0.5))
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
    
    func CreateAttributeLabel(attribute: String) -> (UIView, UILabel) {
        let bg_color = GetAttributeColor(attr: attribute)
        
        let label_start_y = profileImageView.frame.origin.y + base_margin
        
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
    
    func CreateNameLabel(text: String) -> UILabel {
        let je_num = SearchJapaneseEnglish(text: text)
        let font_name = GetFontName(je_num: je_num, font_w: 6)
        var font_size = 0 as CGFloat
        if je_num == JapaneseEnglish.Japanese.rawValue {
            font_size = 37
        }else {
            font_size = 39
        }
        
        let name_label = UILabel(frame: CGRect(x: base_margin, y: profileImageView.frame.height+base_margin, width: cardView.frame.width-base_margin, height: base_margin))
        name_label.text = text
        name_label.font = UIFont(name: font_name, size: font_size)
        name_label.sizeToFit()
        
        return name_label
    }
    
    func CreateCareerLabel(text: String, nameLabel_frame: CGRect) -> UILabel {
        let label_start_y = nameLabel_frame.origin.y+nameLabel_frame.height
        
        let career_label = UILabel(frame: CGRect(x: base_margin, y: label_start_y+base_margin*0.5, width: cardView.frame.width-base_margin*2, height: base_margin*2))
        career_label.font = UIFont(name: FontName.J_W3.rawValue, size: 15)
        career_label.backgroundColor = UIColor.clear
        career_label.numberOfLines = 0
        
        let lineHeight:CGFloat = 22.0
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.minimumLineHeight = lineHeight
        paragraphStyle.maximumLineHeight = lineHeight
        paragraphStyle.lineBreakMode = .byTruncatingTail
        let attributedText = NSMutableAttributedString(string: text)
        attributedText.addAttribute(NSParagraphStyleAttributeName, value: paragraphStyle, range: NSMakeRange(0, attributedText.length))
        career_label.attributedText = attributedText
        
        career_label.sizeToFit()
        return career_label
    }
    
    func CreateSectionLabel(text: String, y: CGFloat) -> UILabel {
        let label = UILabel(frame: CGRect(x: base_margin, y: y, width: 0, height: 0))
        label.text = text
        label.font = UIFont(name: FontName.J_W6.rawValue, size: 21)
        label.sizeToFit()
        
        return label
    }
    
    func CreateAwardsLabel(awards: Array<String>) -> UILabel {
        let label = UILabel(frame: CGRect(x: base_margin, y: latest_section_frame.origin.y+latest_section_frame.height+base_margin*0.1, width: 0, height: 0))
        
        var text = ""
        for award in awards {
            text += award + "\n"
        }
        
        if !text.isEmpty {
            text = text.substring(to: text.index(before: text.endIndex))
        }
        
        label.text = text
        label.font = UIFont(name: "AmericanTypewriter-Bold", size: 15)
        label.numberOfLines = awards.count
        label.sizeToFit()
        
        return label
    }
    
    func CreateSkillsLabel(skills: [String]) -> Array<UILabel> {
        var start_x = base_margin
        var start_y = latest_section_frame.origin.y + latest_section_frame.height + base_margin*0.1
        var labels = [UILabel]()
        
        for skill in skills {
            let label = UILabel(frame: CGRect(x: start_x, y: start_y, width: 0, height: 0))
            label.text = "  " + skill + "  "
            label.font = UIFont(name: "AmericanTypewriter-Bold", size: 15)
            label.backgroundColor = UIColor.hexStr(hexStr: SkillTagColor.gray.rawValue as NSString, alpha: 1.0)
            label.textColor = UIColor.white
            label.sizeToFit()
            label.layer.cornerRadius = 10
            label.layer.masksToBounds = true
            
            //追加しようとしているラベルがカード幅を超える場合
            if (label.frame.origin.x+label.frame.width) > (cardView.frame.origin.x+cardView.frame.width-base_margin) {
                start_y = label.frame.origin.y + label.frame.height + base_margin*0.25
                
                label.frame = CGRect(x: base_margin, y: start_y, width: 0, height: 0)
                label.sizeToFit()
            }
            
            labels.append(label)
            start_x = label.frame.origin.x + label.frame.width + base_margin*0.25
        }
        
        return labels
    }
    
    func CreateProductLabel(json: JSON) -> ([(title: UILabel, url: UILabel?, link_img: UIImageView?, image: AsyncUIImageView?, image_shadow: UIView?)], CGRect) {
        var productsViews: [(title: UILabel, url: UILabel?, link_img: UIImageView?, image: AsyncUIImageView?, image_shadow: UIView?)] = []
        var last_add_view_frame = CGRect()
        
        // next_y = セクションタイトルのbottomで初期化
        var next_y = latest_section_frame.origin.y + latest_section_frame.height + base_margin*0.5
        
        json.forEach { (_, obj) in
            var pViews: (title: UILabel, url: UILabel?, link_img: UIImageView?, image: AsyncUIImageView?, image_shadow: UIView?) = (title: UILabel(), url: nil, link_img: nil, image: nil, image_shadow: nil)
            
            //next_yからプロダクトタイトルの追加
            let titleLabel = UILabel(frame: CGRect(x: base_margin, y: next_y, width: 0, height: 0))
            titleLabel.text = obj["title"].string
            titleLabel.font = UIFont(name: "AmericanTypewriter-Bold", size: 15)
            titleLabel.sizeToFit()
            pViews.title = titleLabel
            
            //最後に追加したviewとして記録
            last_add_view_frame = titleLabel.frame
            
            //next_yをプロダクトタイトルに更新
            next_y = titleLabel.frame.origin.y + titleLabel.frame.height
            
            //URLがあったら,next_yからURLラベルの追加
            if !(obj["url"].string?.isEmpty)! {
                let linkImageView = UIImageView(image: UIImage(named: "link_icon"))
                linkImageView.contentMode = .scaleAspectFill
                linkImageView.frame = CGRect(x: base_margin, y: next_y, width: base_margin*0.8, height: base_margin*0.8)
                
                let start_x = linkImageView.frame.origin.x + linkImageView.frame.width
                let urlLabel = UILabel(frame: CGRect(x: start_x+base_margin*0.1, y: next_y, width: 0, height: 0))
                urlLabel.text = obj["url"].string
                urlLabel.font = UIFont(name: "AmericanTypewriter-Bold", size: 12)
                urlLabel.sizeToFit()
                pViews.url = urlLabel
                pViews.link_img = linkImageView
                
                //最後に追加したviewとして記録
                last_add_view_frame = urlLabel.frame
                
                //next_yをURLラベルに更新
                next_y = urlLabel.frame.origin.y + urlLabel.frame.height + base_margin*0.5
            }
            
            //画像があったら，next_yから画像の追加
            if !(obj["image"].string?.isEmpty)! {
                let imageView = AsyncUIImageView(frame: CGRect(x: base_margin, y: next_y, width: cardView.frame.width-base_margin*2, height: self.view.frame.height*0.3))
                imageView.loadImage(urlString: obj["image"].string!)
                imageView.contentMode = .scaleAspectFill
                imageView.layer.cornerRadius = 10
                imageView.layer.masksToBounds = true
                
                // 影をつけるためのViewを作成
                let shadow_view = UIView(frame: imageView.frame)
                shadow_view.backgroundColor = UIColor.white
                shadow_view.layer.shadowColor = UIColor.black.cgColor
                shadow_view.layer.shadowOpacity = 0.5
                shadow_view.layer.shadowOffset = CGSize(width: 2, height: 2)
                shadow_view.layer.shadowRadius = 2
                shadow_view.layer.cornerRadius = 10
                
                pViews.image = imageView
                pViews.image_shadow = shadow_view
                
                //最後に追加したviewとして記録
                last_add_view_frame = imageView.frame

                //next_yを画像に更新
                next_y = imageView.frame.origin.y + imageView.frame.height + base_margin*1.25
            }
            
            productsViews.append(pViews)

        }
        
        return (productsViews, last_add_view_frame)
    }
    
    func CreateSNSLabel(json: JSON) -> ([(icon: UIImageView, url: UILabel)]) {
        var SNSViews: [(icon: UIImageView, url: UILabel)] = []
        var next_y = latest_section_frame.origin.y + latest_section_frame.height + base_margin*0.5
        
        json.forEach { (_, obj) in
            var image_name = ""
            switch obj["provider"] {
            case "facebook":
                image_name = "facebook_icon"
                break
            case "twitter":
                image_name = "twitter_icon"
                break
                
            default:
                break
            }
            
            let iconImageView = UIImageView(image: UIImage(named: image_name))
            iconImageView.contentMode = .scaleAspectFill
            iconImageView.frame = CGRect(x: base_margin, y: next_y, width: base_margin, height: base_margin)
            
            let start_x = iconImageView.frame.origin.x + iconImageView.frame.width + base_margin*0.25
            let urlLabel = UILabel(frame: CGRect(x: start_x, y: next_y, width: 0, height: 0))
            urlLabel.text = obj["url"].string
            urlLabel.font = UIFont(name: "AmericanTypewriter-Bold", size: 12)
            urlLabel.sizeToFit()
            
            // アイコンとのずれを調整するために高さをアイコンに揃える
            urlLabel.frame = CGRect(x: urlLabel.frame.origin.x, y: urlLabel.frame.origin.y, width: urlLabel.frame.width, height: iconImageView.frame.height)

            
            next_y = urlLabel.frame.origin.y + urlLabel.frame.height + base_margin*0.5
            SNSViews.append(icon: iconImageView, url: urlLabel)
        }
        
        return SNSViews
    }
    
    func CreateLicenseLabel(licenses: Array<String>) -> UILabel {
        let label = UILabel(frame: CGRect(x: base_margin, y: latest_section_frame.origin.y+latest_section_frame.height+base_margin*0.1, width: 0, height: 0))
        
        var text = ""
        for license in licenses {
            text += license + "\n"
        }
        
        if !text.isEmpty {
            text = text.substring(to: text.index(before: text.endIndex))
        }
        
        label.text = text
        label.font = UIFont(name: "AmericanTypewriter-Bold", size: 15)
        label.numberOfLines = licenses.count
        label.sizeToFit()
        
        return label
    }
    
    func CreateBasicInfoLabel(info: Array<String>) -> Array<UILabel> {
        let info_name = ["性別", "年齢", "居住地", "学歴"]
        var infoLabels = [UILabel]()
        var start_y = latest_section_frame.origin.y + latest_section_frame.height + base_margin*0.25
        
        for (index, info_str) in info.enumerated() {
            if !(info_str.isEmpty) {
                let label = UILabel(frame: CGRect(x: base_margin, y: start_y, width: 0, height: 0))
                label.text = info_name[index] + "：" + info_str
                label.font = UIFont(name: "AmericanTypewriter-Bold", size: 15)
                
                // 0歳(初期状態)だった場合はテキストをリセット
                if index == 1 {
                    if info[index] == "0" {
                        label.text = ""
                    }else {
                        label.text = label.text! + "歳"
                    }
                }
                
                label.sizeToFit()
                
                infoLabels.append(label)
                start_y = label.frame.origin.y + label.frame.height + base_margin*0.1
            }
        }
        
        return infoLabels
    }
    
    func CreateTopToScrollButton(cgrect: CGRect) -> UIButton {
        let button = UIButton()
        let image = UIImage(named: "up_arrow")
        
        let x = cardView.frame.origin.x + cardView.frame.width - base_margin*3.5
        let y = cgrect.origin.y + cgrect.height - base_margin*2
        let size = base_margin*2.5
        
        button.frame = CGRect(x: x, y: y, width: size, height: size)
        button.setImage(image, for: .normal)
        button.imageView?.contentMode = .scaleAspectFit
        button.contentHorizontalAlignment = .fill
        button.contentVerticalAlignment = .fill
        button.addTarget(self, action: #selector(self.TapScrollTop(sender:)),
                         for: .touchUpInside)

        return button
    }
    
    func TapScrollTop(sender: UIButton) {
        scrollView.scroll(to: .top, animated: true)
    }
    
    func SetUserID(id: Int) {
        user_id = id
    }
    
    func CallUserDetailAPI() {
        let urlString: String = API.host.rawValue + API.v1.rawValue + API.users.rawValue + String(user_id)
        Alamofire.request(urlString, method: .get).responseJSON { (response) in
            guard let object = response.result.value else{return}
            let json = JSON(object)
            print(json.count)
            
            let dummy = UserDetailDummyData().user_data
            self.AddViews(json: JSON(dummy))
//            self.AddViews(json: json)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
