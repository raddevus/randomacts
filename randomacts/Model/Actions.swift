//
//  Actions.swift
//  randomacts
//
//  Created by roger deutsch on 11/20/23.
//

import Foundation

struct Action: Codable{
    let screenName: String?
    let category: String?
    let subCategory: String?
    let description: String?
    let status: String?
    let created: String?
    let updated: String?
    let active: Bool?
}

struct Task: Codable{
    //let success: Bool
    let tasks: [Action]
    
}

var allCategories = Set<String>()
var allDescriptions = Set<String>()
