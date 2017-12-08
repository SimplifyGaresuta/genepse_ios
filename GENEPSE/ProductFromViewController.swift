//
//  ProductFromViewController.swift
//  GENEPSE
//
//  Created by 岩見建汰 on 2017/12/07.
//  Copyright © 2017年 Kenta. All rights reserved.
//

import UIKit
import Eureka
import ImageRow
import SwiftyJSON

class ProductFromViewController: FormViewController {

    var cellImageView = UIImageView()
    private var view_title = ""
    private var product = JSON()
    
    override func viewWillAppear(_ animated: Bool) {
//        CreateFrom()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let check_button = UIBarButtonItem(image: UIImage(named: "icon_check"), style: .plain, target: self, action: #selector(self.Save(sender:)))

        self.navigationItem.setRightBarButton(check_button, animated: true)
        self.navigationItem.title = view_title
        
        CreateFrom()
    }
    
    func CreateFrom() {
        form +++ Section("タイトル")
            <<< TextRow(){
                $0.title = ""
                $0.placeholder = "ポートフォリオサイト"
                $0.value = product["title"].stringValue
        }
        
        form +++ Section("URL")
            <<< URLRow(){
                $0.title = ""
                $0.placeholder = "http://◯◯.◯◯◯.◯◯"
                $0.value = URL(string: product["url"].stringValue)
        }
        
        form +++ Section("画像")
            <<< ImageRow() {
                let imageView = AsyncUIImageView()
                imageView.loadImage(urlString: product["image"].stringValue)
                //                imageView.contentMode = .scaleAspectFill
                //                imageView.layer.cornerRadius = 10
                //                imageView.layer.masksToBounds = true
                
                $0.title = "画像を選択する"
                $0.sourceTypes = .PhotoLibrary
                $0.clearAction = .no
                $0.value = imageView.image
                }
                .cellUpdate { cell, row in
                    cell.accessoryView?.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
                    
                    if let image = row.value {
                        self.cellImageView.image = image
                    }
        }
        
        let base_margin = self.view.frame.width * 0.1
        let h = self.view.frame.height*0.3
        let y = self.view.subviews[0].frame.height - h - base_margin*2
        cellImageView.frame = CGRect(x: base_margin, y: y, width: self.view.frame.width-base_margin*2, height: h)
        cellImageView.layer.cornerRadius = 10
        cellImageView.clipsToBounds = true
        cellImageView.contentMode = .scaleAspectFill
        self.view.subviews[0].addSubview(cellImageView)
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func Save(sender: UIButton) {
        print("tap Add product save")
        self.navigationController?.popViewController(animated: true)
    }
    
    func SetTitle(title: String) {
        view_title = title
    }
    
    func SetProduct(p: JSON) {
        product = p
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
