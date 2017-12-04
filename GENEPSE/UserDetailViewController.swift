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
    
    var cardScrollView = UIScrollView()
    var profileImageView = UIImageView()
    
//    var user_data = JSON()
    
    override func viewDidLoad() {
        CallUserDetailAPI()
        
        super.viewDidLoad()
        base_margin = self.view.bounds.width * 0.05
        navigation_bar_end_position = (self.navigationController?.navigationBar.frame.size.height)! + (self.navigationController?.navigationBar.frame.origin.y)!
        self.view.backgroundColor = UIColor.white
        
        InitCardScrollView()
    }
    
    func InitCardScrollView () {
        cardScrollView.frame = CGRect(x: base_margin, y: navigation_bar_end_position+base_margin, width: self.view.bounds.width - base_margin * 2, height: self.view.bounds.height)
        cardScrollView.backgroundColor = UIColor.white
        
        cardScrollView.layer.cornerRadius = 20
        cardScrollView.layer.shadowOpacity = 1.0
        cardScrollView.layer.shadowColor = UIColor.black.cgColor
        cardScrollView.layer.shadowOffset = CGSize(width: 2, height: 2)
        cardScrollView.layer.shadowRadius = 10
        cardScrollView.layer.masksToBounds = false
        
        self.view.addSubview(cardScrollView)
    }
    
    func AddViews(json: JSON) {
        guard let name = json["name"].string else{return}
        guard let overview = json["overview"].string else{return}
        guard let profile_img = json["profile_img"].string else{return}
        guard let attr = json["attr"].string else{return}
        guard let main_skills:[String] = json["main_skills"].arrayValue.map({ $0.stringValue}) else{return}
        
        
        profileImageView = CreateProfileImageView(url: profile_img)
        cardScrollView.addSubview(profileImageView)
        
        let attributeLabels = CreateAttributeLabel(attribute: attr)
        cardScrollView.addSubview(attributeLabels.0)
        cardScrollView.addSubview(attributeLabels.1)
        
        let mainskillsLabels = self.CreateMainSkillsLabels(skills: main_skills)
        for (shadowView, skillLabel) in zip(mainskillsLabels.0, mainskillsLabels.1) {
            cardScrollView.addSubview(shadowView)
            cardScrollView.addSubview(skillLabel)
        }
    }
    
    func CreateProfileImageView(url: String) -> UIImageView {
        let imageView = AsyncUIImageView(frame: CGRect(x: 0, y: 0, width: cardScrollView.frame.width, height: self.view.frame.height*0.5))
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
