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
    
    //MARK: DEBUG
    var debug = false
    
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
        scrollView.delegate = self
        
        InitScrollView()
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let back_button_y = UIApplication.shared.statusBarFrame.height
        
        cover_img.frame = CGRect(x:cover_img.frame.origin.x, y:scrollView.contentOffset.y, width:cover_img.frame.width, height:cover_img.frame.height)
        back_button.frame = CGRect(x:back_button.frame.origin.x, y:back_button_y+scrollView.contentOffset.y, width:back_button.frame.width, height:back_button.frame.height)
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
        UpdateCardViewFrame(last_add_cgrect: nameLabel.frame)
        
        // 属性の追加
        let attributeLabel = CreateAttributeLabel(attribute: data.GetAttr())
        cardView.addSubview(attributeLabel)
        latest_frame = attributeLabel.frame
        UpdateCardViewFrame(last_add_cgrect: attributeLabel.frame)
        
        
        // 活動拠点の追加
        let activity_baseView = CreateActivityBase(name: data.GetActivityBase())
        cardView.addSubview(activity_baseView.0)
        cardView.addSubview(activity_baseView.1)
        latest_frame = activity_baseView.1.frame
        UpdateCardViewFrame(last_add_cgrect: activity_baseView.1.frame)

        
        // スキルの追加
        let mainskillsLabels = CreateSkillsLabels(skills: data.GetSkills())
        for skillLabel in mainskillsLabels {
            cardView.addSubview(skillLabel as! UIView)
        }
        
        if mainskillsLabels.count != 0 {
            let tmp_view = mainskillsLabels.last! as! UIView
            latest_frame = tmp_view.frame
            UpdateCardViewFrame(last_add_cgrect: tmp_view.frame)
        }
        
        // 経歴の追加
        let careerLabel = CreateCareerLabel(text: data.GetOverview())
        cardView.addSubview(careerLabel)
        latest_frame = careerLabel.frame
        UpdateCardViewFrame(last_add_cgrect: careerLabel.frame)

        
        // worksの追加
        let works_sectionLable = CreateSectionLabel(text: "WORKS", space: 2.5, leftmargin: -(base_margin))
        cardView.addSubview(works_sectionLable)
        latest_frame = works_sectionLable.frame
        UpdateCardViewFrame(last_add_cgrect: works_sectionLable.frame)

        let works_scrollview = CreateWorks(products: data.GetProducts(), works_sectionLable: works_sectionLable)
        latest_frame = works_scrollview.frame
        UpdateCardViewFrame(last_add_cgrect: works_scrollview.frame)
        
        
        // basic infoの追加
        let info_sectionLable = CreateSectionLabel(text: "Basic Information", space: 1.0, leftmargin: 0.0)
        cardView.addSubview(info_sectionLable)
        latest_frame = info_sectionLable.frame
        UpdateCardViewFrame(last_add_cgrect: info_sectionLable.frame)
        
        let infoLabel = CreateBasicInformation()
        for label in infoLabel {
            cardView.addSubview(label)
            latest_frame = label.frame
            UpdateCardViewFrame(last_add_cgrect: label.frame)
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
    
    func CreateBackButton() -> UIButton {
        let button = UIButton(frame: CGRect(x: base_margin, y: 0, width: 50, height: 50))
        button.setImage(UIImage(named: "icon_back"), for: .normal)
        button.addTarget(self, action: #selector(TapBackButton(sender:)), for: .touchUpInside)
        return button
    }
    
    func TapBackButton(sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func UpdateCardViewFrame(last_add_cgrect: CGRect) {
        let y = cover_img.frame.height * 0.8
        cardView.frame = CGRect(x: base_margin, y: y, width: self.view.bounds.width - base_margin * 2, height: last_add_cgrect.origin.y+last_add_cgrect.height + base_margin * 20)
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
    
    //TODO: アイコンの位置調整
    func CreateSNSLabel(json: [JSON]) -> [UIButton] {
        let wh = base_margin * 4.5
        let y = cardView.bounds.origin.y - wh/2
        let x = [cardView.bounds.origin.x + base_margin * 5, cardView.bounds.width-base_margin * 5-wh]
        let icon = ["icon_facebook_circle", "icon_twitter_circle"]
        var isEnabled = true
        var buttons: [UIButton] = []
        
        for (i, sns) in json.enumerated() {
            let button = UIButton(frame: CGRect(x: x[i], y: y, width: wh, height: wh))
            button.tag = i
            
            var icon_name = icon[i]
            
            if sns[Key.url.rawValue].stringValue.count == 0 {
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
        let y = latest_frame.origin.y+latest_frame.height+base_margin * 2
        let w = cardView.frame.width
        
        var attr_str = NSMutableAttributedString(string: text)
        attr_str = AddAttributedTextLetterSpacing(space: 1.5, text: attr_str)
        
        let name_label = UILabel(frame: CGRect(x: x, y: y, width: w, height: font_size))
        name_label.attributedText = attr_str
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
        
        var border_w = 2.0
        if text.count == 0 {
            border_w = 0.0
        }
        
        var attr_text = NSMutableAttributedString(string: text)
        attr_text = AddAttributedTextLetterSpacing(space: 0.9, text: attr_text)
        
        let y = latest_frame.origin.y+latest_frame.height + base_margin
        let f_size = 14 as CGFloat
        let label = EdgeInsetLabel(frame: CGRect(x: 0, y: y, width: 0, height: f_size))
        
        label.attributedText = attr_text
        label.textAlignment = .center
        label.font = UIFont(name: FontName.DIN.rawValue, size: f_size)
        label.borderWidth = border_w
        label.borderColor = UIColor.black
        label.topTextInset = 2
        label.rightTextInset = 4
        label.bottomTextInset = 2
        label.leftTextInset = 4
        label.sizeToFit()
        
        label.frame = CGRect(x: cardView.frame.width/2 - label.frame.width/2, y: label.frame.origin.y, width: label.frame.width, height: label.frame.height)
        
        return label
    }
    
    func CreateActivityBase(name: String) -> (UIImageView, UILabel) {
        let homeImageView = UIImageView(image: UIImage(named: "icon_home"))
        let start_y = latest_frame.origin.y+latest_frame.height+base_margin * 3
        let font_size = 16 as CGFloat
        let homeImageView_wh = CGFloat(font_size-2)
        homeImageView.frame = CGRect(x: 0, y: start_y, width: homeImageView_wh, height: homeImageView_wh)
        
        let label = UILabel(frame: CGRect(x: 0, y: start_y, width: 0, height: 0))
        label.font = UIFont(name: FontName.J_W6.rawValue, size: font_size)
        label.text = name
        label.sizeToFit()
        
        let label_start_x = cardView.frame.width/2 - (homeImageView.frame.width + label.frame.width+base_margin) / 2
        homeImageView.frame = CGRect(x: label_start_x, y: start_y, width: homeImageView_wh, height: homeImageView_wh)
        label.frame = CGRect(x: homeImageView.frame.origin.x+homeImageView.frame.width+base_margin, y: start_y, width: 0, height: 0)
        label.sizeToFit()
        
        //ずれてしまった位置を再調整
        let difference = (label.frame.origin.y+label.frame.height/2) - (homeImageView.frame.origin.y+homeImageView.frame.height/2)
        
        homeImageView.frame = CGRect(x: label_start_x, y: start_y+difference, width: homeImageView_wh, height: homeImageView_wh)
        
        return (homeImageView, label)
    }
    
    func CreateSkillsLabels(skills: Array<String>) -> Array<Any> {
        var views:[Any] = []
        var y = latest_frame.height+latest_frame.origin.y + base_margin * 3
        var x = 0 as CGFloat
        var count = 0
        let margin_offset = 1 as CGFloat
        
        //初期配置をしてサイズを求めるためのループ
        for (i, skill) in skills.enumerated() {
            //スキルを3つ配置したら改行
            if i != 0 && i % 3 == 0 {
                count += 1
                let last_view = views.last! as! UIView
                x = 0
                y = last_view.frame.origin.y+last_view.frame.height + base_margin
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
    
    func CreateCareerLabel(text: String) -> UILabel {
        let label_start_y = latest_frame.origin.y+latest_frame.height + base_margin*2.5
        
        let x = cardView.frame.width * 0.1
        let w = cardView.frame.width * 0.8
        
        let career_label = UILabel(frame: CGRect(x: x, y: label_start_y, width: w, height: base_margin*2))
        career_label.font = UIFont(name: FontName.J_W3.rawValue, size: 14)
        career_label.backgroundColor = UIColor.clear
        career_label.numberOfLines = 0
        
        var attributedText = NSMutableAttributedString(string: text)
        attributedText = AddAttributedTextLineHeight(height: 26, text: attributedText)
        attributedText = AddAttributedTextLetterSpacing(space: 0, text: attributedText)
        
        career_label.attributedText = attributedText
        career_label.sizeToFit()
        
        return career_label
    }
    
    func CreateWorks(products: [JSON], works_sectionLable: UILabel) -> UIScrollView {
        /*** scrollviewの設置 ***/
        let x = latest_frame.origin.x
        let y = latest_frame.origin.y+latest_frame.height+base_margin*1.5
        let h = cardView.frame.width * 0.4
        let w = self.view.bounds.width
        let product_scrollview = UIScrollView()
        product_scrollview.frame = CGRect(x: x, y: y, width: w, height: h)
        
        cardView.addSubview(product_scrollview)
        /*** scrollviewの設置 ***/
        
        /*** productの設置 ***/
        var p_start_x = product_scrollview.bounds.origin.x
        let p_w = cardView.frame.width * 0.55
        
        for product in products {
            let id = product["id"].intValue
//            let title = product[Key.title.rawValue].stringValue
            let url = product[Key.url.rawValue].stringValue
            let image = product[Key.image.rawValue].stringValue
            
            // 画像の設置
            let productImageView = AsyncUIImageView(frame: CGRect(x: p_start_x, y: 0, width: p_w, height: h))
            productImageView.loadImage(urlString: image)
            productImageView.contentMode = .scaleAspectFill
            productImageView.layer.cornerRadius = 10
            productImageView.clipsToBounds = true
            
            //シャドウの設置
            let shadow = ViewUtility().CreateShadowView(target_frame: productImageView.frame, bg: UIColor.white, opacity: 0.1, size: 1, shadow_r: 1, corner_r: 10)
            product_scrollview.addSubview(shadow)
            product_scrollview.addSubview(productImageView)
            
            
            p_start_x = productImageView.frame.width + base_margin * 2.5
            
            let last = productImageView.frame.width + productImageView.frame.origin.x + base_margin*7
            product_scrollview.contentSize = CGSize(width: last, height: h)
            
            if url != "" {
                // linkボタンの設置
                let image_wh = 25 as CGFloat
                let EdgeInset = 6 as CGFloat
                let link_x = productImageView.frame.origin.x + base_margin*0.5
                let link_y = productImageView.frame.height - image_wh/2 - base_margin*2
                let link_button = UIButton(frame: CGRect(x: link_x, y: link_y, width: image_wh, height: image_wh))
                link_button.setImage(UIImage(named: "icon_link"), for: .normal)
                link_button.imageEdgeInsets = UIEdgeInsets(top: EdgeInset, left: EdgeInset, bottom: EdgeInset, right: EdgeInset)
                link_button.backgroundColor = UIColor.black
                link_button.layer.cornerRadius = image_wh/2
                link_button.layer.masksToBounds = true
                link_button.tag = id
                link_button.addTarget(self, action: #selector(TapLinkButton(sender:)), for: .touchUpInside)
                
                product_scrollview.addSubview(link_button)
            }
        }
        /*** productの設置 ***/

        return product_scrollview
    }
    
    func TapLinkButton(sender: UIButton){
        let id = sender.tag
        var url_str = ""
        
        for product in data.GetProducts() {
            if id == product["id"].intValue {
                url_str = product[Key.url.rawValue].stringValue
                break
            }
        }
        
        let url = URL(string: url_str)!
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }
    
    func CreateBasicInformation() -> [UILabel] {
        let info = [
            [data.GetGender(), "/", String(data.GetAge())+"歳"],
            [data.GetAddress()],
            [data.GetSchoolCareer()],
            InsertIntervalString(array: data.GetAwards(), insert_str: "\n"),
            InsertIntervalString(array: data.GetLicenses(), insert_str: "\n")
            ]
        
        let x = latest_frame.origin.x
        var y = latest_frame.origin.y+latest_frame.height+base_margin*3
        let w = self.view.bounds.width
        var labels:[UILabel] = []
        
        for section in info {
            //0歳(未設定)の場合や何も登録されていない場合は、何も表示しない
            if let str = section.last {
                if str == "0歳" || str.count == 0 {
                    continue
                }
            }else {
                continue
            }
            
            var text = ""
            let label = UILabel(frame: CGRect(x: x, y: y, width: w, height: 0))
            label.font = UIFont(name: FontName.J_W3.rawValue, size: 14)
            label.numberOfLines = 0
            
            for sentence in section {
                text += sentence
            }
            
            var attributedText = NSMutableAttributedString(string: text)
            attributedText = AddAttributedTextLineHeight(height: 21, text: attributedText)
            label.attributedText = attributedText
            label.sizeToFit()
            labels.append(label)
            
            y = label.frame.origin.y + label.frame.height + base_margin * 2
        }
        
        return labels
    }
    
    func CreateSectionLabel(text: String, space: Double, leftmargin: CGFloat) -> UILabel {
        let x = latest_frame.origin.x + leftmargin
        let y = latest_frame.origin.y+latest_frame.height+base_margin*3
        let label = UILabel(frame: CGRect(x: x, y: y, width: 0, height: 0))
        var attr_str = NSMutableAttributedString(string: text)
        attr_str = AddAttributedTextLetterSpacing(space: space, text: attr_str)
        label.attributedText = attr_str
        label.font = UIFont(name: FontName.DIN.rawValue, size: 30)
        label.sizeToFit()
        
        return label
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
