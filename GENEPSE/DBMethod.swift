//
//  DBMethod.swift
//  GENEPSE
//
//  Created by 岩見建汰 on 2017/12/10.
//  Copyright © 2017年 Kenta. All rights reserved.
//

import RealmSwift

class DBMethod {
    func RecordCount(_ DBName: Object.Type) -> Int {
        var dbrecordcount = 0
        
        do{
            dbrecordcount = try (Realm().objects(DBName).count)
            
        }catch{
            //Error
        }
        return dbrecordcount
    }
    
    func Add(_ record: Object){
        do{
            let realm = try Realm()
            try realm.write{
                realm.add(record)
            }
        }catch{
            //Error
        }
    }
    
    func GetAll(_ DBName: Object.Type) -> User? {
        do{
            let realm = try Realm()
            return realm.objects(User.self).first!
        }catch{
            return nil
        }
    }
}
