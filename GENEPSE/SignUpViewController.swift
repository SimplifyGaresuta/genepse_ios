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
        
        let bgImageView = UIImageView(image: UIImage(named: "sample2.jpg"))
        bgImageView.frame = CGRect(x: 0, y: 0, width: full_w, height: full_h)
        bgImageView.contentMode = .scaleAspectFill
        self.view.addSubview(bgImageView)
        
        //TODO: frameを要検討
        let genepse_tokyoImageView = UIImageView(image: UIImage(named: "genepse_tokyo.png"))
        genepse_tokyoImageView.frame = CGRect(x: 100, y: 100, width: full_w*0.5, height: 10)
        genepse_tokyoImageView.contentMode = .scaleAspectFill
        self.view.addSubview(genepse_tokyoImageView)
        
        //TODO: frameを要検討
        start_facebookButton = UIButton(frame: CGRect(x: 100, y: 500, width: full_w*0.5, height: 50))
        start_facebookButton.contentMode = .scaleAspectFill
        start_facebookButton.setImage(UIImage(named: "start_facebook.png"), for: .normal)
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
