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
        self.extendedLayoutIncludesOpaqueBars = true
        self.navigationController?.navigationBar.isTranslucent = false
        InitNavigationController()
        CreateForms()
    }
    
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
        if edit_id != SectionID_New.works.rawValue {
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
        case SectionID_New.main.rawValue:
            self.navigationItem.titleView = ViewUtility().CreateTitleLabelView(title: "Edit Main", font_name: FontName.DIN.rawValue, font_size: 20)
            
            // 属性フォーム
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
            
            
            // 拠点フォーム
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
            
            
            // スキルフォーム
            form +++ MultivaluedSection(
                multivaluedOptions: [.Insert, .Delete],
                header: "スキル",
                footer: "") {
                    $0.addButtonProvider = { section in return ButtonRow(){
                        $0.title = "追加"
                        }
                    }
                    $0.multivaluedRowToInsertAt = { index in return PickerInputRow<String>() {
                        $0.options = GetAllSkills()
                        $0.tag = "skill_"+String(index)
                        }
                    }

                    let user_skills = data?.GetSkills()
                    for (i, skill) in (user_skills?.enumerated())! {
                        $0 <<< PickerInputRow<String>() {
                            $0.value = skill
                            $0.tag = "skill_"+String(-i-1)
                            $0.options = GetAllSkills()
                        }
                    }
            }
            
            // 自己紹介フォーム
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
            
        case SectionID_New.works.rawValue:
            self.navigationItem.titleView = ViewUtility().CreateTitleLabelView(title: "All Products", font_name: FontName.DIN.rawValue, font_size: 20)
            
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
            
        case SectionID_New.info.rawValue:
            self.navigationItem.titleView = ViewUtility().CreateTitleLabelView(title: "Edit Basic Infomation", font_name: FontName.DIN.rawValue, font_size: 20)
            
            // 性別フォーム
            form +++ Section("性別")
            <<< SegmentedRow<String>("sex") {
                $0.options = ["男性", "女性", "その他"]
                $0.title = ""
                $0.value = (data?.GetGender())!
                $0.tag = Key.gender.rawValue
            }
            
            
            // 年齢フォーム
            form +++ Section("年齢")
                <<< IntRow() {
                    $0.title = ""
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
            
            
            // 居住地フォーム
            form +++ Section("居住地")
                <<< TextRow(){
                    $0.title = ""
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
            
            
            // 最終学歴フォーム
            form +++ Section("最終学歴")
                <<< TextRow(){
                    $0.title = ""
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
            
            
            // 受賞フォーム
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
                    $0.tag = "award_"+String(index)
                    }
                }

                let awards = data?.GetAwards()
                for (i, award) in (awards?.enumerated())! {
                    $0 <<< TextRow() {
                        $0.value = award
                        $0.tag = "award_"+String(-i-1)
                    }
                }
            }
            
            
            // 資格フォーム
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
                        $0.tag = "license_"+String(index)
                        }
                    }

                    let licenses = (data?.GetLicenses())!
                    for (i, license) in licenses.enumerated() {
                        $0 <<< TextRow() {
                            $0.value = license
                            $0.tag = "license_"+String(-i-1)
                        }
                    }
            }

        default:
            break
        }
        

//        case SectionID.sns.rawValue:
//            self.navigationItem.title = "Edit SNS"
//
//            var url = ""
//
//            for sns in (data?.GetSNS())! {
//                if sns["provider"] == "twitter" {
//                    url = sns["url"].stringValue
//                    break
//                }
//            }
//
//            form +++ Section("Twitter")
//                <<< TextRow(){
//                    $0.title = ""
//                    $0.placeholder = "@◯◯◯◯◯◯"
//                    $0.value = url
//                    $0.tag = Key.sns.rawValue
//            }
//            break
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
            DataShape_CallAPI(values: form.values())
        }else {
            self.present(GetStandardAlert(title: "エラー", message: "必須項目を入力してください", b_title: "OK"),animated: true, completion: nil)
        }
    }

    func DataShape_CallAPI(values: [String:Any?]) {
        guard let user_id = GetAppDelegate().user_id else {
            return
        }
        
        var req_array:[String:Any] = [:]
//        let form_values_json = JSON(values)
        // mainならskillを追加、それ以外なら賞と資格を追加
        if edit_id == SectionID_New.main.rawValue {
            let skills = MultivaluedSectionDataShape(dict: values, tag: "skill_")
            if skills.count == 0 {
                req_array[Key.skills.rawValue] = [""]
            }else {
                req_array[Key.skills.rawValue] = skills
            }
        }else {
            let awards = MultivaluedSectionDataShape(dict: values, tag: "award_")
            let licenses = MultivaluedSectionDataShape(dict: values, tag: "license_")
            if awards.count == 0 {
                req_array[Key.awards.rawValue] = [""]
            }else {
                req_array[Key.awards.rawValue] = awards
            }
            
            if licenses.count == 0 {
                req_array[Key.licenses.rawValue] = [""]
            }else {
                req_array[Key.licenses.rawValue] = licenses
            }
        }
        
        // 上記のskill,award,license以外の普通の項目を追加
        for element in values {
            if !element.key.contains("skill_") && !element.key.contains("award_") && !element.key.contains("license_") {
                req_array[element.key] = element.value
            }
        }
        
        print(req_array)
        
        CallUpdateUserDataAPI(req_dict: req_array, user_id: user_id)
    }
    
    func MultivaluedSectionDataShape(dict: [String:Any?], tag: String) -> Array<String> {
        var values: [String] = []
        var tmp_plus: [Int:String] = [:]
        var tmp_minus: [Int:String] = [:]
        
        for element in dict {
            if element.key.contains(tag) {
                //result example: ["skill_8", "8"]
                var result_plus: [String] = []
                var result_minus: [String] = []
                
                //プラスとマイナスで使用する変数を変える(後ほどソートを逆順にするため)
                if element.key.pregMatche(pattern: tag+"([0-9]+)", matches: &result_plus) {
                    tmp_plus[Int(result_plus[1])!] = dict[result_plus[0]] as? String
                }else {
                    let _ = element.key.pregMatche(pattern: tag+"(-[0-9]+)", matches: &result_minus)
                    tmp_minus[Int(result_minus[1])!] = dict[result_minus[0]] as? String
                }
            }
        }
        
        let tmp_plus_sorted = tmp_plus.sorted(by: {$0.key < $1.key})
        let tmp_minus_sorted = tmp_minus.sorted(by: {$0.key > $1.key})
        
        for tmp in tmp_minus_sorted {
            values.append(tmp.value)
        }
        for tmp in tmp_plus_sorted {
            values.append(tmp.value)
        }
        
        return values
    }
    
    func CallUpdateUserDataAPI(req_dict: [String:Any], user_id: Int) {
        
        print("CALL API", req_dict)
        let urlString: String = API.host.rawValue + API.v1.rawValue + API.users.rawValue + String(user_id)
        Alamofire.request(urlString, method: .patch, parameters: req_dict, encoding: JSONEncoding(options: [])).responseJSON { (response) in
            
            // 200系以外ならエラー
            CheckHTTPStatus(statusCode: response.response?.statusCode, VC: self)
            
            print(JSON(response.result.value))
        }
    }
}
