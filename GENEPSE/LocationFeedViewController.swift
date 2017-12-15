//
//  LocationFeedViewController.swift
//  GENEPSE
//
//  Created by 岩見建汰 on 2017/12/13.
//  Copyright © 2017年 Kenta. All rights reserved.
//

import UIKit
import CoreLocation

class LocationFeedViewController: UIViewController {

    var cannotavailable_msg = EdgeInsetLabel()
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if CLLocationManager.locationServicesEnabled() {
            cannotavailable_msg.isHidden = true
            
            switch CLLocationManager.authorizationStatus() {
            case .notDetermined, .restricted, .denied:
                cannotavailable_msg.isHidden = false
                
            case .authorizedAlways, .authorizedWhenInUse:
                break
            }
        }else {
            cannotavailable_msg.isHidden = false
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        SetUpCanNotAvailableLocationFeedMSG()
        // Do any additional setup after loading the view.
    }
    
    func SetUpCanNotAvailableLocationFeedMSG() {
        cannotavailable_msg.font = UIFont(name: FontName.J_W3.rawValue, size: 15)
        cannotavailable_msg.numberOfLines = 0
        cannotavailable_msg.textAlignment = .center
        cannotavailable_msg.textColor = UIColor.gray
        cannotavailable_msg.attributedText = GetAttributedTextLineHeight(height: 20, text: "位置情報サービスが無効のため、\n情報を表示することができません")
        cannotavailable_msg.topTextInset = 20
        cannotavailable_msg.leftTextInset = 20
        cannotavailable_msg.bottomTextInset = 20
        cannotavailable_msg.rightTextInset = 20
        cannotavailable_msg.sizeToFit()
        
        cannotavailable_msg.center = self.view.center
        
        self.view.addSubview(cannotavailable_msg)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
