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
//        self.view.backgroundColor = UIColor.blue
        print(edit_id)
        
        //MARK: 公式にあったコード
//        form +++ Section("Section1")
//            <<< TextRow(){ row in
//                row.title = "Text Row"
//                row.placeholder = "Enter text here"
//            }
//            <<< PhoneRow(){
//                $0.title = "Phone Row"
//                $0.placeholder = "And numbers here"
//            }
//            +++ Section("Section2")
//            <<< DateRow(){
//                $0.title = "Date Row"
//                $0.value = Date(timeIntervalSinceReferenceDate: 0)
//        }
        
//        form +++
//            MultivaluedSection(multivaluedOptions: [.Reorder, .Insert, .Delete],
//                               header: "Multivalued TextField",
//                               footer: ".Insert adds a 'Add Item' (Add New Tag) button row as last cell.") {
//                                $0.addButtonProvider = { section in
//                                    return ButtonRow(){
//                                        $0.title = "Add New Tag"
//                                    }
//                                }
//                                $0.multivaluedRowToInsertAt = { index in
//                                    return NameRow() {
//                                        $0.placeholder = "Tag Name"
//                                    }
//                                }
//                                $0 <<< NameRow() {
//                                    $0.placeholder = "Tag Name"
//                                }
//        }


    }
    
    //TODO: 各フォーム作成関数を呼び出す
    func CreateForms() {
        switch edit_id {
        case SectionID.name.rawValue:
            // textフィールド
            // textview
            break
        case SectionID.awards.rawValue:
            // textフィード(+)
            break
        case SectionID.skills.rawValue:
            // textフィールド(+)
            break
        case SectionID.products.rawValue:
            // textフィールド&&textフィールド,ImageRow(+)
            break
        case SectionID.sns.rawValue:
            // picker&&textフィールド(+)
            break
        case SectionID.license.rawValue:
            // textフィールド(+)
            break
        default:
            // textフィールド*4(うち，number1つ)
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
