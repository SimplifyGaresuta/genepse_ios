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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let check_button = UIBarButtonItem(image: UIImage(named: "icon_check"), style: .plain, target: self, action: #selector(self.Save(sender:)))

        self.navigationItem.setRightBarButton(check_button, animated: true)
        self.navigationItem.title = view_title
        
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
        
        let productImageView = AsyncUIImageView()
        
        form +++ Section("タイトル")
            <<< TextRow(){
                $0.title = ""
                $0.placeholder = "ポートフォリオサイト"
                $0.value = product["title"].stringValue
                $0.add(rule: RuleRequired())
                $0.validationOptions = .validatesOnDemand
                $0.tag = "title"
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
            }
            .cellUpdate { cell, row in
                cell.accessoryView?.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
                
                if let image = row.value {
                    productImageView.image = image
                }else {
                    productImageView.image = nil
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
        
        let base_margin = self.view.frame.width * 0.1
        let h = self.view.frame.height*0.3
        let y = self.view.subviews[0].frame.height - h - base_margin*2
        
        productImageView.loadImage(urlString: product["image"].stringValue)
        productImageView.frame = CGRect(x: base_margin, y: y, width: self.view.frame.width-base_margin*2, height: h)
        productImageView.layer.cornerRadius = 10
        productImageView.clipsToBounds = true
        productImageView.contentMode = .scaleAspectFill
        self.view.subviews[0].addSubview(productImageView)

    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func Save(sender: UIButton) {
        if form.rowBy(tag: "title")?.validate().count == 0 {
            // TODO: データ保存・更新処理
            self.navigationController?.popViewController(animated: true)
        }
        
        self.present(GetStandardAlert(title: "エラー", message: "必須項目を入力してください", b_title: "OK"),animated: true, completion: nil)
    }
    
    func SetTitle(title: String) {
        view_title = title
    }
    
    func SetProduct(p: JSON) {
        product = p
    }
}
