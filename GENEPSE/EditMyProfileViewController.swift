//
//  EditMyProfileViewController.swift
//  GENEPSE
//
//  Created by 岩見建汰 on 2017/12/06.
//  Copyright © 2017年 Kenta. All rights reserved.
//

import UIKit
import Eureka

class EditMyProfileViewController: FormViewController {

    var edit_id = 0
    var profile_data = MyProfileData()
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
        let check_button = UIBarButtonItem(image: UIImage(named: "icon_check"), style: .plain, target: self, action: #selector(self.Save(sender:)))
        
        self.navigationController?.navigationBar.barTintColor = UIColor.black
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationItem.setLeftBarButton(cancel_button, animated: true)
        self.navigationItem.setRightBarButton(check_button, animated: true)
    }
    
    func CreateForms() {
        switch edit_id {
        case SectionID.name.rawValue:
            self.navigationItem.title = "Edit Main Infomation"
            
            form +++ Section("活動拠点")
                <<< TextRow(){
                    $0.title = ""
                    $0.placeholder = "◯◯区"
                    $0.value = profile_data.GetActivityBase()
            }
            
            form +++ Section("自己紹介")
                <<< TextAreaRow(){
                    $0.title = ""
                    $0.placeholder = "私は今までに独学でXXを勉強し…"
                    $0.value = profile_data.GetOverview()
            }
            
            break
        case SectionID.awards.rawValue:
            self.navigationItem.title = "Edit Awards"
            
            form +++ MultivaluedSection(
                multivaluedOptions: [.Reorder, .Insert, .Delete],
               header: "受賞歴",
               footer: "") {
                $0.addButtonProvider = { section in return ButtonRow(){
                    $0.title = "追加"
                    }
                }
                $0.multivaluedRowToInsertAt = { index in return NameRow() {
                    $0.placeholder = "◯◯賞(20XX)"
                    }
                }
                
                for award in profile_data.GetAwards() {
                    $0 <<< TextRow() {
                        $0.value = award
                    }
                }
                
                $0 <<< TextRow() {
                    $0.placeholder = "◯◯賞(20XX)"
                }
            }

            break
        case SectionID.skills.rawValue:
            self.navigationItem.title = "Edit Skills"
            
            form +++ MultivaluedSection(
                multivaluedOptions: [.Reorder, .Insert, .Delete],
                header: "スキル",
                footer: "プログラミング言語、使用可能ツールなど様々なスキルを1つずつ入力してください") {
                    $0.addButtonProvider = { section in return ButtonRow(){
                        $0.title = "追加"
                        }
                    }
                    $0.multivaluedRowToInsertAt = { index in return TextRow() {
                        $0.placeholder = "Python"
                        }
                    }
                    
                    for skill in profile_data.GetSkills() {
                        $0 <<< TextRow() {
                            $0.value = skill
                        }
                    }
                    
                    $0 <<< TextRow() {
                        $0.placeholder = "Python"
                    }
            }
            break
        case SectionID.products.rawValue:
            self.navigationItem.title = "All Products"
            
            let section = Section()
            
            for p in profile_data.GetProducts() {
                let vc = ProductFromViewController()
                vc.SetProduct(p: p)
                vc.SetTitle(title: "Edit")
                
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
            break
        case SectionID.sns.rawValue:
            for sns in profile_data.GetSNS() {
                if sns["provider"] != "facebook" {
                    form +++ Section(sns["provider"].stringValue)
                        <<< TextRow(){
                            $0.title = ""
                            $0.placeholder = "@◯◯◯◯◯◯"
                            $0.value = sns["url"].stringValue
                    }
                }
            }
            break
        case SectionID.license.rawValue:
            self.navigationItem.title = "Edit Licenses"
            
            form +++ MultivaluedSection(
                multivaluedOptions: [.Reorder, .Insert, .Delete],
                header: "資格",
                footer: "") {
                    $0.addButtonProvider = { section in return ButtonRow(){
                        $0.title = "追加"
                        }
                    }
                    $0.multivaluedRowToInsertAt = { index in return TextRow() {
                        $0.placeholder = "◯◯管理技術者"
                        }
                    }
                    
                    for license in profile_data.GetLicenses() {
                        $0 <<< TextRow() {
                            $0.value = license
                        }
                    }
                    
                    $0 <<< TextRow() {
                        $0.placeholder = "◯◯管理技術者"
                    }
            }
            break
        default:
            self.navigationItem.title = "Edit Other Infomation"
            
            form +++ Section("基本情報")
                <<< SegmentedRow<String>("sex") {
                    $0.options = ["男性", "女性", "その他"]
                    $0.title = "性別"
                    $0.value = profile_data.GetGender()
                }
            
                <<< IntRow() {
                    $0.title = "年齢"
                    $0.placeholder = ""
                    $0.value = profile_data.GetAge()
                }
            
                <<< TextRow(){
                    $0.title = "居住地"
                    $0.placeholder = "◯◯区"
                    $0.value = profile_data.GetAddress()
                }
                
                <<< TextRow(){
                    $0.title = "最終学歴"
                    $0.placeholder = "XX大学YY学部 卒業"
                    $0.value = profile_data.GetSchoolCareer()
                }
            break
        }
    }
    
    func showVC(_ cell: ButtonCellOf<String>, row: ButtonRow) {
        let productVC = ProductFromViewController()
        productVC.SetTitle(title: "Add")
        navigationController?.show(productVC, sender: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func SetEditID(id: Int) {
        edit_id = id
    }
    
    func SetMyProfileData(data: MyProfileData) {
        profile_data = data
    }
    
    func CloseEditMyProfileView(sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func Save(sender: UIButton) {
        print("Tap AddRow")
        self.dismiss(animated: true, completion: nil)
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
