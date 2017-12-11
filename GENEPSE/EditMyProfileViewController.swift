//
//  EditMyProfileViewController.swift
//  GENEPSE
//
//  Created by 岩見建汰 on 2017/12/06.
//  Copyright © 2017年 Kenta. All rights reserved.
//

import UIKit
import Eureka
import Alamofire
import SwiftyJSON

class EditMyProfileViewController: FormViewController {

    var edit_id = 0
    var data = GetAppDelegate().data
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        InitNavigationController()
        CreateForms()
//        data = GetAppDelegate().data!
    }
    
//    override func viewWillAppear(_ animated: Bool) {
//        data = GetAppDelegate().data!
//    }
    
    public final class CustomPushRow<T: Equatable>: SelectorRow<PushSelectorCell<T>, SelectorViewController<T>>, RowType {
        
        public required init(tag: String?) {
            super.init(tag: tag)
            presentationMode = .show(controllerProvider: ControllerProvider.callback {
                return SelectorViewController<T>(){ _ in }
                }, onDismiss: { vc in
                    _ = vc.navigationController?.popViewController(animated: true)
            })
        }
    }
    
    
    func InitNavigationController() {
        let cancel_button = UIBarButtonItem(image: UIImage(named: "icon_close"), style: .plain, target: self, action: #selector(self.CloseEditMyProfileView(sender:)))
        let check_button = UIBarButtonItem(image: UIImage(named: "icon_upload"), style: .plain, target: self, action: #selector(self.TapUploadButton(sender:)))
        
        self.navigationController?.navigationBar.barTintColor = UIColor.black
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationItem.setLeftBarButton(cancel_button, animated: true)
        
        // プロダクト一覧画面になるため、その画面ではボタンを表示させない
        if edit_id != SectionID.products.rawValue {
            self.navigationItem.setRightBarButton(check_button, animated: true)
        }
    }
    
    func CreateForms() {
        LabelRow.defaultCellUpdate = { cell, row in
            cell.contentView.backgroundColor = .red
            cell.textLabel?.textColor = .white
            cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 13)
            cell.textLabel?.textAlignment = .right
        }
        
        let RuleRequired_M = "必須項目です"

        switch edit_id {
        case SectionID.name.rawValue:
            self.navigationItem.title = "Edit Main Infomation"
            
            form +++ Section("属性")
                <<< PickerInputRow<String>(""){
                    $0.title = ""
                    $0.options = ["Engineer", "Designer", "Business"]
                    $0.value = data?.GetAttr()
                    $0.add(rule: RuleRequired())
                    $0.validationOptions = .validatesOnChange
                    $0.tag = Key.attribute.rawValue
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
                        }
                        row.section?.insert(labelRow, at: row.indexPath!.row + index + 1)
                    }
                }
            }
            
            form +++ Section("活動地域")
                <<< TextRow(){
                    $0.title = ""
                    $0.placeholder = "◯◯区"
                    $0.value = data?.GetActivityBase()
                    $0.add(rule: RuleRequired())
                    $0.validationOptions = .validatesOnChange
                    $0.tag = Key.activity_base.rawValue
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
                        }
                        row.section?.insert(labelRow, at: row.indexPath!.row + index + 1)
                    }
                }
            }
            
            
            form +++ Section("自己紹介")
                <<< TextAreaRow(){
                    $0.title = ""
                    $0.placeholder = "私は今までに独学でXXを勉強し…"
                    $0.value = data?.GetOverview()
                    $0.add(rule: RuleRequired())
                    $0.validationOptions = .validatesOnChange
                    $0.tag = Key.overview.rawValue
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
                        }
                        row.section?.insert(labelRow, at: row.indexPath!.row + index + 1)
                    }
                }
            }
            
            break
            
        case SectionID.awards.rawValue:
            self.navigationItem.title = "Edit Awards"
            
            form +++ MultivaluedSection(
                multivaluedOptions: [.Insert, .Delete],
               header: "受賞歴",
               footer: "") {
                $0.addButtonProvider = { section in return ButtonRow(){
                    $0.title = "追加"
                    }
                }
                $0.multivaluedRowToInsertAt = { index in return NameRow() {
                    $0.placeholder = "◯◯賞(20XX)"
                    $0.tag = String(index)
                    }
                }
                
                let awards = data?.GetAwards()
                for (i, award) in (awards?.enumerated())! {
                    $0 <<< TextRow() {
                        $0.value = award
                        $0.tag = String(i)
                    }
                }
            }

            break
            
        case SectionID.skills.rawValue:
            self.navigationItem.title = "Edit Skills"
            let skills = ["Ruby", "Java", "Python", "Go", "MySQL", "PHP", "AE", "営業", "NLP"]

            form +++ MultivaluedSection(
                multivaluedOptions: [.Insert, .Delete],
                header: "スキル",
                footer: "") {
                    $0.addButtonProvider = { section in return ButtonRow(){
                        $0.title = "追加"
                        }
                    }
                    $0.multivaluedRowToInsertAt = { index in return PickerInputRow<String>() {
                        $0.options = skills
                        $0.tag = String(index)
                        }
                    }
                    
                    let user_skills = data?.GetSkills()
                    for (i, skill) in (user_skills?.enumerated())! {
                        $0 <<< PickerInputRow<String>() {
                            $0.value = skill
                            $0.tag = String(i)
                        }
                    }
            }
            break
            
        case SectionID.products.rawValue:
            self.navigationItem.title = "All Products"
            //MARK: Products
            if (data?.GetProducts())!.count == 0 {
                form +++ Section()
                    <<< ButtonRow() {
                        $0.title = "作品を追加"
                        $0.onCellSelection(self.showVC)
                }
            }else {
                let section = Section()
                section.tag = "ALL_P"
                
                for p in (data?.GetProducts())! {
                    let vc = ProductFromViewController()
                    vc.SetTitle(title: "Edit")
                    vc.SetIsAdd(flag: false)
                    vc.SetProductID(id: p["id"].intValue)
                    
                    let row = ButtonRow() {
                        $0.title = p["title"].stringValue
                        $0.tag = p["id"].stringValue
                        $0.presentationMode = .show(controllerProvider: ControllerProvider.callback {return vc},
                                                    onDismiss: { vc in
                                                        vc.navigationController?.popViewController(animated: true)}
                        )
                    }
                    section.append(row)
                }
                
                form.append(section)
                
                form +++ Section()
                    <<< ButtonRow() {
                        $0.title = "作品を追加"
                        $0.onCellSelection(self.showVC)
                }
            }
            
            break
            
        case SectionID.sns.rawValue:
            self.navigationItem.title = "Edit SNS"

            var url = ""
            
            for sns in (data?.GetSNS())! {
                if sns["provider"] == "twitter" {
                    url = sns["url"].stringValue
                    break
                }
            }
            
            form +++ Section("Twitter")
                <<< TextRow(){
                    $0.title = ""
                    $0.placeholder = "@◯◯◯◯◯◯"
                    $0.value = url
                    $0.tag = Key.sns.rawValue
            }
            break
            
        case SectionID.license.rawValue:
            self.navigationItem.title = "Edit Licenses"
            
            form +++ MultivaluedSection(
                multivaluedOptions: [.Insert, .Delete],
                header: "資格",
                footer: "") {
                    $0.addButtonProvider = { section in return ButtonRow(){
                        $0.title = "追加"
                        }
                    }
                    $0.multivaluedRowToInsertAt = { index in return TextRow() {
                        $0.placeholder = "◯◯管理技術者"
                        $0.tag = String(index)
                        }
                    }
                    
                    let licenses = (data?.GetLicenses())!
                    for (i, license) in licenses.enumerated() {
                        $0 <<< TextRow() {
                            $0.value = license
                            $0.tag = String(i)
                        }
                    }
            }
            break
            
        default:
            self.navigationItem.title = "Edit Other Infomation"
            
            form +++ Section("基本情報")
                <<< SegmentedRow<String>("sex") {
                    $0.options = ["男性", "女性", "その他"]
                    $0.title = "性別"
                    $0.value = (data?.GetGender())!
                    $0.tag = Key.gender.rawValue
                }
            
                <<< IntRow() {
                    $0.title = "年齢"
                    $0.placeholder = ""
                    $0.value = (data?.GetAge())!
                    $0.add(rule: RuleRequired())
                    $0.validationOptions = .validatesOnChange
                    $0.tag = Key.age.rawValue
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
                            }
                            row.section?.insert(labelRow, at: row.indexPath!.row + index + 1)
                        }
                    }
                }
            
                <<< TextRow(){
                    $0.title = "居住地"
                    $0.placeholder = "◯◯区"
                    $0.value = (data?.GetAddress())!
                    $0.add(rule: RuleRequired())
                    $0.validationOptions = .validatesOnChange
                    $0.tag = Key.address.rawValue
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
                            }
                            row.section?.insert(labelRow, at: row.indexPath!.row + index + 1)
                        }
                    }
                }
                
                <<< TextRow(){
                    $0.title = "最終学歴"
                    $0.placeholder = "XX大学YY学部 卒業"
                    $0.value = (data?.GetSchoolCareer())!
                    $0.add(rule: RuleRequired())
                    $0.validationOptions = .validatesOnChange
                    $0.tag = Key.school_career.rawValue
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
                            }
                            row.section?.insert(labelRow, at: row.indexPath!.row + index + 1)
                        }
                    }
                }
            break
        }
    }
    
    func showVC(_ cell: ButtonCellOf<String>, row: ButtonRow) {
        let productVC = ProductFromViewController()
        productVC.SetTitle(title: "Add")
        productVC.SetIsAdd(flag: true)
        productVC.SetProductID(id: 0)
        navigationController?.show(productVC, sender: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func SetEditID(id: Int) {
        edit_id = id
    }
    
    func CloseEditMyProfileView(sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func TapUploadButton(sender: UIButton) {
        var validate_err_count = 0
        
        for row in form.allRows {
            validate_err_count += row.validate().count
        }
        
        if validate_err_count == 0 {
            // TODO: データ保存・更新処理
            HEIRETU(values: form.values())
        }else {
            self.present(GetStandardAlert(title: "エラー", message: "必須項目を入力してください", b_title: "OK"),animated: true, completion: nil)
        }
    }
    
    func DataShaping(json: JSON) -> JSON {
//        awards
//        skills
//        sns
//        sikaku
//        gender, age, school_career, address
        
        return json
    }
    
    func HEIRETU(values: [String:Any?]) {
        guard let user_id = GetAppDelegate().user_id else {
            return
        }
        
        let group = DispatchGroup()
        let form_values = DataShaping(json: JSON(values))
        print(form_values)
        
        switch edit_id {
        case SectionID.name.rawValue:
            for form_value in form_values {
                let queue = DispatchQueue(label: "jp.classmethod.app.queue\(form_value.0)")
                queue.async(group: group) {
                    self.CallUpdateUserDataAPI(req: [form_value.0:form_value.1.stringValue], user_id: user_id)
                    print("queue \(form_value.0) done.")
                }
            }
            break
        default:
            break
        }
        
        
        
//            print(form_value.key, form_value.value)
//            let queue = DispatchQueue(label: "jp.classmethod.app.queue\(dic.key)")
//            queue.async(group: group) {
//                print("queue \(dic.key) done.")
//            }
//        }
        
        
        // タスクが全て完了したらメインスレッド上で処理を実行する
        group.notify(queue: DispatchQueue.main) {
            print("all task done.")
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    func CallUpdateUserDataAPI(req: [String:String], user_id: Int) {
        print("CALL API", req)
        let urlString: String = API.host.rawValue + API.v1.rawValue + API.users.rawValue + String(user_id)
        Alamofire.request(urlString, method: .patch, parameters: req, encoding: JSONEncoding(options: [])).responseJSON { (response) in
            guard let object = response.result.value else{return}
            let json = JSON(object)
            print(response.response?.statusCode)
            print(json)
        }
    }
}
