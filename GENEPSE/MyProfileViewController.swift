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

class MyProfileViewController: UIViewController {

    private var user_id = 0
    var base_margin = 0.0 as CGFloat
    
    var scrollView = UIScrollView()
    var cardView = UIView()
    var profileImageView = UIImageView()
    var latest_section_frame = CGRect()
    var profile_data = MyProfileData()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.navigationItem.title = "MyProfile"
    }
    
    override func viewDidLoad() {
        CallUserDetailAPI()
        
        super.viewDidLoad()
        
        base_margin = self.view.bounds.width * 0.05
        self.view.backgroundColor = UIColor.white
        
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
        cardView.layer.shadowOpacity = 1.0
        cardView.layer.shadowColor = UIColor.black.cgColor
        cardView.layer.shadowOffset = CGSize(width: 2, height: 2)
        cardView.layer.shadowRadius = 10
        cardView.layer.masksToBounds = false
        
        scrollView.addSubview(cardView)
    }
    
    func AddViews(json: JSON) {
        let activity_base = json["activity_base"].stringValue
        let name = json["name"].stringValue
        let overview = json["overview"].stringValue
        let profile_img = json["profile_img"].stringValue
        let attr = json["attr"].stringValue
        let main_skills:[String] = json["main_skills"].arrayValue.map({$0.stringValue})
        let awards:[String] = json["awards"].arrayValue.map({$0.stringValue})
        let skills:[String] = json["skills"].arrayValue.map({$0.stringValue})
        let sns = json["sns"].arrayValue
        let licenses:[String] = json["license"].arrayValue.map({$0.stringValue})
        let gender = json["gender"].stringValue
        let age = json["age"].intValue
        let address = json["address"].stringValue
        let school_career = json["school_career"].stringValue
        
        profile_data.SetActivityBase(activity_base: activity_base)
        profile_data.SetName(name: name)
        profile_data.SetOverview(overview: overview)
        profile_data.SetProfileImg(profile_img: profile_img)
        profile_data.SetAttr(attr: attr)
        profile_data.SetMainSkills(main_skills: main_skills)
        profile_data.SetAwards(awards: awards)
        profile_data.SetSkills(skills: skills)
        profile_data.SetSNS(sns: sns)
        profile_data.SetLicenses(licenses: licenses)
        profile_data.SetGender(gender: gender)
        profile_data.SetAge(age: age)
        profile_data.SetAddress(address: address)
        profile_data.SetSchoolCareer(school_career: school_career)
        
        // プロフ画像の追加
        profileImageView = CreateProfileImageView(url: profile_img)
        cardView.addSubview(profileImageView)
        UpdateCardViewFrame(last_add_cgrect: profileImageView.frame)
        
        
        // 属性の追加
        let attributeLabels = CreateAttributeLabel(attribute: attr)
        cardView.addSubview(attributeLabels.0)
        cardView.addSubview(attributeLabels.1)
        UpdateCardViewFrame(last_add_cgrect: attributeLabels.1.frame)
        
        
        // メインスキルの追加
        let mainskillsLabels = self.CreateMainSkillsLabels(skills: main_skills)
        for (shadowView, skillLabel) in zip(mainskillsLabels.0, mainskillsLabels.1) {
            cardView.addSubview(shadowView)
            cardView.addSubview(skillLabel)
        }
        UpdateCardViewFrame(last_add_cgrect: mainskillsLabels.1.last!.frame)
        
        
        // 名前の追加
        let nameLabel = self.CreateNameLabel(text: name)
        cardView.addSubview(nameLabel)
        cardView.addSubview(self.CreateEditButton(cgrect: nameLabel.frame, id: SectionID.name.rawValue))
        UpdateCardViewFrame(last_add_cgrect: mainskillsLabels.1.last!.frame)
        
        
        // 経歴の追加
        let careerLabel = self.CreateCareerLabel(text: overview, nameLabel_frame: nameLabel.frame)
        cardView.addSubview(careerLabel)
        UpdateCardViewFrame(last_add_cgrect: careerLabel.frame)
        
        // 受賞歴の追加
        let awards_sectionLable = self.CreateSectionLabel(text: "受賞歴", y: careerLabel.frame.origin.y+careerLabel.frame.height+base_margin*3)
        cardView.addSubview(awards_sectionLable)
        cardView.addSubview(self.CreateEditButton(cgrect: awards_sectionLable.frame, id: SectionID.awards.rawValue))
        UpdateCardViewFrame(last_add_cgrect: awards_sectionLable.frame)
        latest_section_frame = awards_sectionLable.frame
        
        let awardsLabel = self.CreateAwardsLabel(awards: awards)
        cardView.addSubview(awardsLabel)
        UpdateCardViewFrame(last_add_cgrect: awardsLabel.frame)
        
        
        // スキルの追加
        let skills_sectionLable = self.CreateSectionLabel(text: "スキル", y: awardsLabel.frame.origin.y+awardsLabel.frame.height+base_margin*3)
        cardView.addSubview(skills_sectionLable)
        cardView.addSubview(self.CreateEditButton(cgrect: skills_sectionLable.frame, id: SectionID.skills.rawValue))
        UpdateCardViewFrame(last_add_cgrect: skills_sectionLable.frame)
        latest_section_frame = skills_sectionLable.frame
        
        let skillsLabels = self.CreateSkillsLabel(skills: skills)
        for skillLabel in skillsLabels {
            cardView.addSubview(skillLabel)
        }
        UpdateCardViewFrame(last_add_cgrect: skillsLabels.last!.frame)
        
        
        // 作品の追加
        let products_sectionLable = self.CreateSectionLabel(text: "作品", y: skillsLabels.last!.frame.origin.y+skillsLabels.last!.frame.height+base_margin*3)
        cardView.addSubview(products_sectionLable)
        cardView.addSubview(self.CreateEditButton(cgrect: products_sectionLable.frame, id: SectionID.products.rawValue))
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
        UpdateCardViewFrame(last_add_cgrect: productsViews.1)
        
        
        // SNSの追加
        let sns_sectionLable = self.CreateSectionLabel(text: "SNS", y: productsViews.1.origin.y+productsViews.1.height+base_margin*3)
        cardView.addSubview(sns_sectionLable)
        cardView.addSubview(self.CreateEditButton(cgrect: sns_sectionLable.frame, id: SectionID.sns.rawValue))
        UpdateCardViewFrame(last_add_cgrect: sns_sectionLable.frame)
        latest_section_frame = sns_sectionLable.frame
        
        let snsLabels = self.CreateSNSLabel(json: sns)
        for s_Label in snsLabels {
            cardView.addSubview(s_Label.icon)
            cardView.addSubview(s_Label.url)
        }
        UpdateCardViewFrame(last_add_cgrect: snsLabels.last!.url.frame)
        
        
        // 資格の追加
        let license_sectionLable = self.CreateSectionLabel(text: "資格", y: snsLabels.last!.url.frame.origin.y+snsLabels.last!.url.frame.height+base_margin*3)
        cardView.addSubview(license_sectionLable)
        cardView.addSubview(self.CreateEditButton(cgrect: license_sectionLable.frame, id: SectionID.license.rawValue))
        UpdateCardViewFrame(last_add_cgrect: license_sectionLable.frame)
        latest_section_frame = license_sectionLable.frame
        
        let licensesLabel = self.CreateLicenseLabel(licenses: licenses)
        cardView.addSubview(licensesLabel)
        UpdateCardViewFrame(last_add_cgrect: licensesLabel.frame)
        
        
        // 基本情報の追加
        let basic_info_sectionLabel = self.CreateSectionLabel(text: "基本情報", y: licensesLabel.frame.origin.y+licensesLabel.frame.height+base_margin*3)
        cardView.addSubview(basic_info_sectionLabel)
        cardView.addSubview(self.CreateEditButton(cgrect: basic_info_sectionLabel.frame, id: SectionID.info.rawValue))
        UpdateCardViewFrame(last_add_cgrect: basic_info_sectionLabel.frame)
        latest_section_frame = basic_info_sectionLabel.frame
        
        let infoLabels = self.CreateBasicInfoLabel(info: [gender, String(age), address, school_career])
        for i_Label in infoLabels {
            cardView.addSubview(i_Label)
        }
        UpdateCardViewFrame(last_add_cgrect: infoLabels.last!.frame)
        
        
        // トップへスクロールするボタンの追加
        cardView.addSubview(self.CreateTopToScrollButton(cgrect: infoLabels.last!.frame))
        
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
        var bg_color: UIColor
        switch attribute {
        case "Designer":
            bg_color = UIColor.hexStr(hexStr: AttributeColor.red.rawValue as NSString, alpha: 1.0)
            break
        case "Engineer":
            bg_color = UIColor.hexStr(hexStr: AttributeColor.blue.rawValue as NSString, alpha: 1.0)
            break
        default:
            bg_color = UIColor.hexStr(hexStr: AttributeColor.green.rawValue as NSString, alpha: 1.0)
            break
        }
        
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
            // skillラベルの生成
            let label = UILabel(frame: CGRect(x: labelstart_x, y: label_y, width: 0, height: 0))
            label.text = "  " + skill + "  "
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
        let name_label = UILabel(frame: CGRect(x: base_margin, y: profileImageView.frame.height+base_margin, width: cardView.frame.width-base_margin, height: base_margin))
        name_label.text = text
        name_label.font = UIFont(name: "AmericanTypewriter-Bold", size: 40)
        name_label.sizeToFit()
        
        return name_label
    }
    
    func CreateCareerLabel(text: String, nameLabel_frame: CGRect) -> UILabel {
        let label_start_y = nameLabel_frame.origin.y+nameLabel_frame.height
        
        let career_label = UILabel(frame: CGRect(x: base_margin, y: label_start_y+base_margin*0.5, width: cardView.frame.width-base_margin*2, height: base_margin*2))
        career_label.font = UIFont(name: "AmericanTypewriter-Bold", size: UIFont.systemFontSize)
        career_label.backgroundColor = UIColor.clear
        career_label.numberOfLines = 0
        
        let lineHeight:CGFloat = 23.0
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
        label.font = UIFont(name: "AmericanTypewriter-Bold", size: 20)
        label.sizeToFit()
        
        return label
    }
    
    func CreateEditButton(cgrect: CGRect, id: Int) -> UIButton {
        let x = cardView.frame.origin.x + cardView.frame.width - base_margin*2.5
        let y = cgrect.origin.y + cgrect.height - cgrect.height/2
        let button = UIButton(frame: CGRect(x: x, y: y, width: base_margin, height: base_margin))
        button.contentMode = .scaleAspectFill
        button.setImage(UIImage(named: "edit_icon"), for: .normal)
        button.center = CGPoint(x: x, y: y)
        button.tag = id
        button.addTarget(self, action: #selector(self.TapEditButton(sender:)), for: .touchUpInside)
        
        return button
    }
    
    func TapEditButton(sender: UIButton) {
        let edit_myprofile_VC = EditMyProfileViewController()
        edit_myprofile_VC.SetEditID(id: sender.tag)
        edit_myprofile_VC.SetMyProfileData(data: profile_data)
        
        let navController = UINavigationController(rootViewController: edit_myprofile_VC)
        self.present(navController, animated:true, completion: nil)
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
    
    func CreateSNSLabel(json: [JSON]) -> ([(icon: UIImageView, url: UILabel)]) {
        var SNSViews: [(icon: UIImageView, url: UILabel)] = []
        var next_y = latest_section_frame.origin.y + latest_section_frame.height + base_margin*0.5
        
        for sns in json {
            var image_name = ""
            switch sns["provider"] {
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
            urlLabel.text = sns["url"].string
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
                
                if index == 1 {
                    label.text = label.text! + "歳"
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
        let urlString: String = "https://kentaiwami.jp/FiNote/django.cgi/api/v1/get_users/"
        Alamofire.request(urlString, method: .get).responseJSON { (response) in
            guard let object = response.result.value else{return}
            let json = JSON(object)
            print(json.count)
            
            //MARK: ダミーデータ
            let dummy_data = UserDetailDummyData()
            self.AddViews(json: JSON(dummy_data.user_data))
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
