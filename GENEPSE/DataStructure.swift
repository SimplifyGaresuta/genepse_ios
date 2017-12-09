//
//  DataStructure.swift
//  GENEPSE
//
//  Created by 岩見建汰 on 2017/12/08.
//  Copyright © 2017年 Kenta. All rights reserved.
//

import Foundation
import SwiftyJSON

class DetailData {
    struct DetailData {
        var name = ""
        var overview = ""
        var avatar_url = ""
        var attr = ""
        var main_skills:[String] = []
        var awards:[String] = []
        var skills:[String] = []
        var products:[JSON] = []
        var sns:[JSON] = []
        var licenses:[String] = []
        var gender = ""
        var age = 0
        var address = ""
        var school_career = ""
        var activity_base = ""
    }
    
    private var data = DetailData()

    func SetActivityBase(activity_base: String) {
        data.activity_base = activity_base
    }
    
    func SetName(name: String) {
        data.name = name
    }

    func SetOverview(overview: String) {
        data.overview = overview
    }
    
    func SetAvatarUrl(avatar_url: String) {
        data.avatar_url = avatar_url
    }
    
    func SetAttr(attr: String) {
        data.attr = attr
    }
    
    func SetMainSkills(main_skills: Array<String>) {
        data.main_skills = main_skills
    }
    
    func SetAwards(awards: Array<String>) {
        data.awards = awards
    }
    
    func SetSkills(skills: Array<String>) {
        data.skills = skills
    }
    
    func SetProducts(products: Array<JSON>) {
        data.products = products
    }
    
    func SetSNS(sns: Array<JSON>) {
        data.sns = sns
    }
    
    func SetLicenses(licenses: Array<String>) {
        data.licenses = licenses
    }
    
    func SetGender(gender: String) {
        data.gender = gender
    }
    
    func SetAge(age: Int) {
        data.age = age
    }
    
    func SetAddress(address: String) {
        data.address = address
    }
    
    func SetSchoolCareer(school_career: String) {
        data.school_career = school_career
    }
    
    
    func GetActivityBase() -> String {
        return data.activity_base
    }
    
    func GetName() -> String {
        return data.name
    }
    
    func GetOverview() -> String {
        return data.overview
    }
    
    func GetAvatarURL() -> String {
        return data.avatar_url
    }
    
    func GetAttr() -> String {
        return data.attr
    }
    
    func GetMainSkills() -> Array<String> {
        return data.main_skills
    }
    
    func GetAwards() -> Array<String> {
        return data.awards
    }
    
    func GetSkills() -> Array<String> {
        return data.skills
    }
    
    func GetProducts() -> Array<JSON> {
        return data.products
    }
    
    func GetSNS() -> Array<JSON> {
        return data.sns
    }
    
    func GetLicenses() -> Array<String> {
        return data.licenses
    }
    
    func GetGender() -> String {
        return data.gender
    }
    
    func GetAge() -> Int {
        return data.age
    }
    
    func GetAddress() -> String {
        return data.address
    }
    
    func GetSchoolCareer() -> String {
        return data.school_career
    }
}
