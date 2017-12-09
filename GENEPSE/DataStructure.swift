//
//  DataStructure.swift
//  GENEPSE
//
//  Created by 岩見建汰 on 2017/12/08.
//  Copyright © 2017年 Kenta. All rights reserved.
//

import Foundation
import SwiftyJSON

class MyProfileData {
    struct MyprofileData {
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
    
    private var profile_data = MyprofileData()

    func SetActivityBase(activity_base: String) {
        profile_data.activity_base = activity_base
    }
    
    func SetName(name: String) {
        profile_data.name = name
    }

    func SetOverview(overview: String) {
        profile_data.overview = overview
    }
    
    func SetAvatarUrl(avatar_url: String) {
        profile_data.avatar_url = avatar_url
    }
    
    func SetAttr(attr: String) {
        profile_data.attr = attr
    }
    
    func SetMainSkills(main_skills: Array<String>) {
        profile_data.main_skills = main_skills
    }
    
    func SetAwards(awards: Array<String>) {
        profile_data.awards = awards
    }
    
    func SetSkills(skills: Array<String>) {
        profile_data.skills = skills
    }
    
    func SetProducts(products: Array<JSON>) {
        profile_data.products = products
    }
    
    func SetSNS(sns: Array<JSON>) {
        profile_data.sns = sns
    }
    
    func SetLicenses(licenses: Array<String>) {
        profile_data.licenses = licenses
    }
    
    func SetGender(gender: String) {
        profile_data.gender = gender
    }
    
    func SetAge(age: Int) {
        profile_data.age = age
    }
    
    func SetAddress(address: String) {
        profile_data.address = address
    }
    
    func SetSchoolCareer(school_career: String) {
        profile_data.school_career = school_career
    }
    
    
    func GetActivityBase() -> String {
        return profile_data.activity_base
    }
    
    func GetName() -> String {
        return profile_data.name
    }
    
    func GetOverview() -> String {
        return profile_data.overview
    }
    
    func GetProfileImg() -> String {
        return profile_data.avatar_url
    }
    
    func GetAttr() -> String {
        return profile_data.attr
    }
    
    func GetMainSkills() -> Array<String> {
        return profile_data.main_skills
    }
    
    func GetAwards() -> Array<String> {
        return profile_data.awards
    }
    
    func GetSkills() -> Array<String> {
        return profile_data.skills
    }
    
    func GetProducts() -> Array<JSON> {
        return profile_data.products
    }
    
    func GetSNS() -> Array<JSON> {
        return profile_data.sns
    }
    
    func GetLicenses() -> Array<String> {
        return profile_data.licenses
    }
    
    func GetGender() -> String {
        return profile_data.gender
    }
    
    func GetAge() -> Int {
        return profile_data.age
    }
    
    func GetAddress() -> String {
        return profile_data.address
    }
    
    func GetSchoolCareer() -> String {
        return profile_data.school_career
    }
}
