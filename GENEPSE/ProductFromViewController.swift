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

    private var view_title = ""
    private var product = JSON()
    private var editMyprofVC = EditMyProfileViewController()
    let productImageView = AsyncUIImageView()
    private var is_imageloaded = false

    override func viewDidLoad() {
        super.viewDidLoad()

        let check_button = UIBarButtonItem(image: UIImage(named: "icon_check"), style: .plain, target: self, action: #selector(self.Save(sender:)))

        self.navigationItem.setRightBarButton(check_button, animated: true)
        self.navigationItem.title = view_title
        
//        is_imageloaded = false
//        is_add = false
        
        CreateFrom()
    }
    
    func CreateFrom() {
        LabelRow.defaultCellUpdate = { cell, row in
            cell.textLabel?.textColor = .white
            cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 13)
            cell.textLabel?.textAlignment = .right
        }
        let RuleRequired_M = "必須項目です"
        let RuleRequired_Warning_M = "項目を埋めてアピール力をあげましょう"
        
        
        
        form +++ Section("タイトル")
            <<< TextRow(){
                $0.title = ""
                $0.placeholder = "ポートフォリオサイト"
                $0.value = product["title"].stringValue
                $0.add(rule: RuleRequired())
                $0.validationOptions = .validatesOnDemand
                $0.tag = Key.title.rawValue
        }
        .onRowValidationChanged { cell, row in
            let rowIndex = row.indexPath!.row
            while row.section!.count > rowIndex + 1 && row.section?[rowIndex  + 1] is LabelRow {
                row.section?.remove(at: rowIndex + 1)
            }
            if !row.isValid {
                for (index, _) in row.validationErrors.map({ $0.msg }).enumerated() {
                    let labelRow = LabelRow() {
                        $0.title = RuleRequired_M
                        $0.cell.height = { 30 }
                        $0.cell.backgroundColor = UIColor.red
                    }
                    row.section?.insert(labelRow, at: row.indexPath!.row + index + 1)
                }
            }
        }
        
        form +++ Section("URL")
            <<< URLRow(){
                $0.title = ""
                $0.placeholder = "http://◯◯.◯◯◯.◯◯"
                $0.value = URL(string: product["url"].stringValue)
                $0.add(rule: RuleRequired())
                $0.validationOptions = .validatesOnChange
                $0.tag = Key.url.rawValue
        }
        .onRowValidationChanged { cell, row in
            let rowIndex = row.indexPath!.row
            while row.section!.count > rowIndex + 1 && row.section?[rowIndex  + 1] is LabelRow {
                row.section?.remove(at: rowIndex + 1)
            }
            if !row.isValid {
                for (index, _) in row.validationErrors.map({ $0.msg }).enumerated() {
                    let labelRow = LabelRow() {
                        $0.title = RuleRequired_Warning_M
                        $0.cell.height = { 30 }
                        $0.cell.backgroundColor = UIColor.orange
                    }
                    row.section?.insert(labelRow, at: row.indexPath!.row + index + 1)
                }
            }
        }
        
        form +++ Section("画像")
            <<< ImageRow() {
                $0.title = "画像を選択する"
                $0.sourceTypes = .PhotoLibrary
                $0.clearAction = .yes(style: UIAlertActionStyle.destructive)
                $0.add(rule: RuleRequired())
                $0.validationOptions = .validatesOnChange
                $0.tag = Key.image.rawValue
            }
            .cellUpdate { cell, row in
                cell.accessoryView?.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
                
                if let image = row.value {
                    self.productImageView.image = image
                }else {
                    self.productImageView.image = nil
                }
        }
        .onRowValidationChanged { cell, row in
            let rowIndex = row.indexPath!.row
            while row.section!.count > rowIndex + 1 && row.section?[rowIndex  + 1] is LabelRow {
                row.section?.remove(at: rowIndex + 1)
            }
            if !row.isValid {
                for (index, _) in row.validationErrors.map({ $0.msg }).enumerated() {
                    let labelRow = LabelRow() {
                        $0.title = RuleRequired_Warning_M
                        $0.cell.height = { 30 }
                        $0.cell.backgroundColor = UIColor.orange
                    }
                    row.section?.insert(labelRow, at: row.indexPath!.row + index + 1)
                }
            }
        }
        
        SetLoadedImage()
    }
    
    func SetLoadedImage() {
        let base_margin = self.view.frame.width * 0.1
        let h = self.view.frame.height*0.3
        let y = self.view.subviews[0].frame.height - h - base_margin*2
        
        productImageView.loadImageWithHandler(urlString: product["image"].stringValue) { (data, resp, err) in
            if err == nil {
                let image = UIImage(data:data!)
                self.productImageView.image = image
                self.productImageView.frame = CGRect(x: base_margin, y: y, width: self.view.frame.width-base_margin*2, height: h)
                self.productImageView.layer.cornerRadius = 10
                self.productImageView.clipsToBounds = true
                self.productImageView.contentMode = .scaleAspectFill
                self.view.subviews[0].addSubview(self.productImageView)
                
                let imageRow = self.form.rowBy(tag: Key.image.rawValue) as! ImageRow
                imageRow.value = self.productImageView.image
                print(self.productImageView.image)
                print(imageRow.value)
                
                self.is_imageloaded = true
            }else {
                print("AsyncImageView:Error \(String(describing: err?.localizedDescription))")
            }
        }
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func Save(sender: UIButton) {
        if !is_imageloaded {
            self.present(GetStandardAlert(title: "通信エラー", message: "再度やり直してください", b_title: "OK"),animated: true, completion: nil)
        }
        
        if form.rowBy(tag: "title")?.validate().count != 0 {
            self.present(GetStandardAlert(title: "エラー", message: "必須項目を入力してください", b_title: "OK"),animated: true, completion: nil)
        }
        
        let values = form.values()
        guard let image = values[Key.image.rawValue] as? UIImage else {return}
        guard let title = values[Key.title.rawValue] as? String else {return}
        guard let url = values[Key.url.rawValue] as? URL else {return}
        let id = product["id"].intValue
        
        editMyprofVC.SetUpdateData(title: title, url: url, image: image, id: id)
        editMyprofVC.SetIsProductFromVCDisplay(flag: true)
        self.navigationController?.popViewController(animated: true)
    }
    
    func SetTitle(title: String) {
        view_title = title
    }
    
    var is_add = false
    func SetIsAdd(flag: Bool) {
        is_add = flag
    }
    
    func SetProduct(p: JSON) {
        product = p
    }
    
    func SetAllProductVC(vc: EditMyProfileViewController) {
        editMyprofVC = vc
    }
}
