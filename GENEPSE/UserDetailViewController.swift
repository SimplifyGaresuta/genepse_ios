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
    var navigation_bar_end_position = 0.0 as CGFloat
    
    var scrollView = UIScrollView()
    var cardView = UIView()
    var profileImageView = UIImageView()
    var nameLabel = UILabel()
    var awards_sectionLable = UILabel()
    var skills_sectionLable = UILabel()
    var products_sectionLable = UILabel()
    
    
    override func viewDidLoad() {
        CallUserDetailAPI()
        
        super.viewDidLoad()
        base_margin = self.view.bounds.width * 0.05
        navigation_bar_end_position = (self.navigationController?.navigationBar.frame.size.height)! + (self.navigationController?.navigationBar.frame.origin.y)!
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
        
        //TODO: cardViewのサイズを可変にする
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
        guard let name = json["name"].string else{return}
        guard let overview = json["overview"].string else{return}
        guard let profile_img = json["profile_img"].string else{return}
        guard let attr = json["attr"].string else{return}
        guard let main_skills:[String] = json["main_skills"].arrayValue.map({ $0.stringValue}) else{return}
        guard let awards:[String] = json["awards"].arrayValue.map({ $0.stringValue}) else{return}
        guard let skills:[String] = json["skills"].arrayValue.map({ $0.stringValue}) else{return}
        
        guard let license:[String] = json["license"].arrayValue.map({ $0.stringValue}) else{return}
        guard let gender = json["gender"].string else{return}
        guard let age = json["age"].int else{return}
        guard let address = json["address"].string else{return}
        guard let school_career = json["school_career"].string else{return}
        
        // プロフ画像の追加
        profileImageView = CreateProfileImageView(url: profile_img)
        cardView.addSubview(profileImageView)
        
        // 属性の追加
        let attributeLabels = CreateAttributeLabel(attribute: attr)
        cardView.addSubview(attributeLabels.0)
        cardView.addSubview(attributeLabels.1)
        
        // メインスキルの追加
        let mainskillsLabels = self.CreateMainSkillsLabels(skills: main_skills)
        for (shadowView, skillLabel) in zip(mainskillsLabels.0, mainskillsLabels.1) {
            cardView.addSubview(shadowView)
            cardView.addSubview(skillLabel)
        }
        
        // 名前の追加
        self.nameLabel = self.CreateNameLabel(text: name)
        cardView.addSubview(self.nameLabel)
        
        // 経歴の追加
        let careerLabel = self.CreateCareerLabel(text: overview)
        cardView.addSubview(careerLabel)
        
        // 受賞歴の追加
        awards_sectionLable = self.CreateSectionLabel(text: "受賞歴", y: careerLabel.frame.origin.y+careerLabel.frame.height+base_margin*3)
        cardView.addSubview(awards_sectionLable)
        
        let awardsLabel = self.CreateAwardsLabel(awards: awards)
        cardView.addSubview(awardsLabel)
        
        // スキルの追加
        skills_sectionLable = self.CreateSectionLabel(text: "スキル", y: awardsLabel.frame.origin.y+awardsLabel.frame.height+base_margin*3)
        cardView.addSubview(skills_sectionLable)
        
        let skillsLabels = self.CreateSkillsLabel(skills: skills)
        for skillLabel in skillsLabels {
            cardView.addSubview(skillLabel)
        }
        
        // 作品の追加
        products_sectionLable = self.CreateSectionLabel(text: "作品", y: skillsLabels.last!.frame.origin.y+skillsLabels.last!.frame.height+base_margin*3)
        cardView.addSubview(products_sectionLable)
        
        let productsViews = self.CreateProductLabel(json: json["products"])
        for pViews in productsViews {
            cardView.addSubview(pViews.title)
            
            if let urlLabel = pViews.url {
                cardView.addSubview(urlLabel)
            }
            
            if let imageView = pViews.image {
                cardView.addSubview(imageView)
            }
        }
        
        scrollView.contentSize = CGSize(width: self.view.bounds.width, height: cardView.frame.height+base_margin*2)
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
        case "DESIGNER":
            bg_color = UIColor.red
            break
        case "ENGINEER":
            bg_color = UIColor.blue
            break
        default:
            bg_color = UIColor.green
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
    
    func CreateCareerLabel(text: String) -> UILabel {
        let label_start_y = nameLabel.frame.origin.y+nameLabel.frame.height
        
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
    
    func CreateAwardsLabel(awards: Array<String>) -> UILabel {
        let label = UILabel(frame: CGRect(x: base_margin, y: awards_sectionLable.frame.origin.y+awards_sectionLable.frame.height+base_margin*0.1, width: 0, height: 0))
        
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
        var start_y = skills_sectionLable.frame.origin.y + skills_sectionLable.frame.height + base_margin*0.1
        var labels = [UILabel]()
        
        for skill in skills {
            let label = UILabel(frame: CGRect(x: start_x, y: start_y, width: 0, height: 0))
            label.text = "  " + skill + "  "
            label.font = UIFont(name: "AmericanTypewriter-Bold", size: 15)
            label.backgroundColor = UIColor.gray
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
    
    //TODO: セクションタイトルの下にマージン，urlの先頭にリンクの画像貼る？，urlと画像のマージン
    //TODO: 画像と次のタイトルとのマージン
    //TODO: 画像の幅を小さく，角丸，影
    
    func CreateProductLabel(json: JSON) -> [(title: UILabel, url: UILabel?, image: AsyncUIImageView?)] {
        var productsViews: [(title: UILabel, url: UILabel?, image: AsyncUIImageView?)] = []
        
        //MARK: next_y = セクションタイトルのbottomで初期化
        var next_y = products_sectionLable.frame.origin.y + products_sectionLable.frame.height
        
        json.forEach { (_, obj) in
            var pViews: (title: UILabel, url: UILabel?, image: AsyncUIImageView?) = (title: UILabel(), url: nil, image: nil)
            
            //next_yからプロダクトタイトルの追加
            let titleLabel = UILabel(frame: CGRect(x: base_margin, y: next_y, width: 0, height: 0))
            titleLabel.text = obj["title"].string
            titleLabel.font = UIFont(name: "AmericanTypewriter-Bold", size: 15)
            titleLabel.sizeToFit()
            pViews.title = titleLabel
            
            //next_yをプロダクトタイトルに更新
            next_y = titleLabel.frame.origin.y + titleLabel.frame.height
            
            //URLがあったら,next_yからURLラベルの追加
            if !(obj["url"].string?.isEmpty)! {
                let urlLabel = UILabel(frame: CGRect(x: base_margin, y: next_y, width: 0, height: 0))
                urlLabel.text = obj["url"].string
                urlLabel.font = UIFont(name: "AmericanTypewriter-Bold", size: 12)
                urlLabel.sizeToFit()
                pViews.url = urlLabel
                
                //next_yをURLラベルに更新
                next_y = urlLabel.frame.origin.y + urlLabel.frame.height
            }
            
            //画像があったら，next_yから画像の追加
            if !(obj["image"].string?.isEmpty)! {
                let imageView = AsyncUIImageView(frame: CGRect(x: base_margin, y: next_y, width: cardView.frame.width-base_margin*2, height: self.view.frame.height*0.3))
                imageView.loadImage(urlString: obj["image"].string!)
                imageView.contentMode = .scaleAspectFill
                pViews.image = imageView
            
                //next_yを画像に更新
                next_y = imageView.frame.origin.y + imageView.frame.height
            }
            
            productsViews.append(pViews)

        }
        
        return productsViews
    }
    
    //TODO: SNSラベル追加 作業中
    func CreateSNSLabel(json: JSON) {
        json["sns"].forEach { (i, j) in
            print(i, j["provider"], j["url"])
        }
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
