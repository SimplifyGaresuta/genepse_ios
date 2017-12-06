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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        CreateForms()
    }
    
    //TODO: 各フォーム作成関数を呼び出す(必要ないかも?)
    func CreateForms() {
        switch edit_id {
        case SectionID.name.rawValue:
            form +++ Section("活動拠点")
                <<< TextRow(){
                    $0.title = ""
                    $0.placeholder = "◯◯区"
            }
            
            form +++ Section("自己紹介")
                <<< TextAreaRow(){
                    $0.title = ""
                    $0.placeholder = "私は今までに独学でXXを勉強し…"
            }
            
            break
        case SectionID.awards.rawValue:
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
                $0 <<< TextRow() {
                    $0.placeholder = "◯◯賞(20XX)"
                }
            }

            break
        case SectionID.skills.rawValue:
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
                    $0 <<< TextRow() {
                        $0.placeholder = "Python"
                    }
            }
            break
        case SectionID.products.rawValue:
            // textフィールド&&textフィールド,ImageRow(+)
            break
        case SectionID.sns.rawValue:
            form +++ Section("Twitter")
                <<< TextRow(){
                    $0.title = ""
                    $0.placeholder = "@◯◯◯◯◯◯"
                    $0.value = "@◯◯◯◯◯◯"
            }
            break
        case SectionID.license.rawValue:
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
                    $0 <<< TextRow() {
                        $0.placeholder = "◯◯管理技術者"
                    }
                    $0 <<< TextRow() {
                        $0.placeholder = "XX管理技術者"
                    }
            }
            break
        default:
            form +++ Section("基本情報")
                <<< SegmentedRow<String>("sex") {
                    $0.options = ["男性", "女性", "その他"]
                    $0.title = "性別"
                    $0.value = "男性"
                }
            
                <<< IntRow() {
                    $0.title = "年齢"
                    $0.placeholder = ""
                }
            
                <<< TextRow(){
                    $0.title = "居住地"
                    $0.placeholder = "◯◯区"
                }
                
                <<< TextRow(){
                    $0.title = "最終学歴"
                    $0.placeholder = "XX大学YY学部 卒業"
                }
            break
        }
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
