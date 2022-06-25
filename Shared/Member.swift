//
//  Member.swift
//  lido
//
//  Created by Everett Wilber on 6/21/22.
//

import Foundation

struct Member: Codable {
    var _id : String
    var dateAdded : Int?
    var dateChanged : Int?
    var first : String?
    var middleInitial : String?
    var last : String?
    var age : Int?
    var aftercare : Bool?
    var isCounsoleor : Bool?
    var memberSubscriptions : [String]?
    var sendTo : Int?
    var location : Int?
    var status : Int?
}
struct MemberCollection: Codable {
    init(array: [Member]) {
        list = array
    }
    var list: [Member]
    var debugDescription: String {
        get {
            return list.debugDescription
        }
    }
    func getMember(with id: String) -> Int? {
        return list.firstIndex(where: {$0._id == id}) ?? nil
    }
    
}
