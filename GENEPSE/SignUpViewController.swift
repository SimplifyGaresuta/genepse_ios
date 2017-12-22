//
//  SignUpViewController.swift
//  GENEPSE
//
//  Created by 岩見建汰 on 2017/12/10.
//  Copyright © 2017年 Kenta. All rights reserved.
//

import UIKit
import WebKit
import Alamofire
import SwiftyJSON
import Kanna
import RealmSwift

class SignUpViewController: UIViewController, WKNavigationDelegate {

    var start_facebookButton = UIButton()
    let indicator = Indicator()
    let instagramWebView = WKWebView()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        InitView()
    }
    
    func InitView() {
        let full_w = self.view.frame.width
        let full_h = self.view.frame.height
        
        let bgImageView = UIImageView(image: UIImage(named: "signup_background"))
        bgImageView.frame = CGRect(x: 0, y: 0, width: full_w, height: full_h)
        bgImageView.contentMode = .scaleAspectFill
        self.view.addSubview(bgImageView)
        
        bgImageView.translatesAutoresizingMaskIntoConstraints = false
        bgImageView.topAnchor.constraint(equalTo:self.view.topAnchor).isActive = true
        bgImageView.trailingAnchor.constraint(equalTo:self.view.trailingAnchor).isActive = true
        bgImageView.bottomAnchor.constraint(equalTo:self.view.bottomAnchor).isActive = true
        bgImageView.leadingAnchor.constraint(equalTo:self.view.leadingAnchor).isActive = true
        
        //TODO: frameを要検討
        let button_w = self.view.frame.width * 0.55
        let button_h = self.view.frame.height * 0.07
        let button_x = self.view.frame.width/2 - button_w/2
        let button_y = self.view.frame.height * 0.82
        
        start_facebookButton.frame = CGRect(x: button_x, y: button_y, width: button_w, height: button_h)
        start_facebookButton.setImage(UIImage(named: "icon_start_fb"), for: .normal)
        start_facebookButton.contentMode = .scaleAspectFill
        start_facebookButton.addTarget(self, action: #selector(self.TapStartButton(sender:)), for: .touchUpInside)
        self.view.addSubview(start_facebookButton)
    }
    
    func InitWebView(url: String) {
        let requestURL = NSURL(string: url)
        let request = NSURLRequest(url: requestURL! as URL)

        instagramWebView.load(request as URLRequest)
        instagramWebView.navigationDelegate = self
        self.view = instagramWebView
        
        indicator.showIndicator(view: self.view)
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        self.indicator.stopIndicator()
    }
    
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        webView.evaluateJavaScript("document.body.innerHTML") { (obj, err) in
            if let obj_unrap = obj {
                //返ってきたjson文字列をviewから削除
                webView.evaluateJavaScript("document.getElementsByTagName('html')[0].innerHTML=\"\"", completionHandler: nil)
                
                let obj_str = obj_unrap as! String
                guard let doc = HTML(html: obj_str, encoding: .utf8) else{return}
                var raw_text = ""
                
                //preタグ抽出
                for pre in doc.xpath("//pre") {
                    raw_text = pre.text!
                    break
                }
                
                //数値のみ取り出し
                let splitNumbers = (raw_text.components(separatedBy: NSCharacterSet.decimalDigits.inverted))
                let number = splitNumbers.joined()
                print("user_id: ", number)
                
                let user = User()
                user.user_id = Int(number)!
                DBMethod().Add(user)
                GetAppDelegate().user_id = user.user_id

                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let signupVC = storyboard.instantiateViewController(withIdentifier: "Init")
                signupVC.modalTransitionStyle = .flipHorizontal
                self.present(signupVC, animated: true, completion: nil)
                self.instagramWebView.removeFromSuperview()
            }
        }
    }
    
    func TapStartButton(sender: UIButton) {
        start_facebookButton.isEnabled = false
        CallSignUpAPI()
    }
    
    func CallSignUpAPI(){
        let urlString: String = API.host.rawValue + API.v1.rawValue + API.login_url.rawValue + API.provider.rawValue
        
        Alamofire.request(urlString, method: .get).responseJSON { (response) in
            guard let object = response.result.value else{return}
            let json = JSON(object)
            print(json)
            
            self.InitWebView(url: json[Key.login_url.rawValue].stringValue)
            
            self.start_facebookButton.isEnabled = true
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
