//
//  Member.swift
//  lido
//
//  Created by Everett Wilber on 6/21/22.
//

import Foundation

struct Member: Codable, Identifiable {
    var id: String {
        return _id
    }
    init(_id: String? = nil, dateAdded: Int? = nil, dateChanged: Int? = nil, first: String? = nil, middleInitial: String? = nil, last: String? = nil, age: Int? = nil, aftercare: Bool? = nil, isCounsoleor: Bool? = nil, memberSubscriptions: [String]? = nil, sendTo: Location? = nil, location: Location? = nil, status: Status? = nil) {
        self._id = _id ?? ""
        self.dateAdded = dateAdded
        self.dateChanged = dateChanged
        self.first = first
        self.middleInitial = middleInitial
        self.last = last
        self.age = age
        self.aftercare = aftercare
        self.isCounsoleor = isCounsoleor
        self.memberSubscriptions = memberSubscriptions
        self.sendTo = sendTo
        self.location = location
        self.status = status
    }
    static let test = Member(
        _id: "[ID garbage]",
        dateAdded: 19301,
        dateChanged: 30193193,
        first: "Everett",
        middleInitial: "C",
        last: "Wilber",
        age: 16,
        aftercare: true,
        isCounsoleor: true,
        memberSubscriptions: [],
        sendTo: Location.upperCarpool,
        location: Location.afternoonOption,
        status: Status.at
    )
    var _id: String
    var dateAdded: Int?
    var dateChanged: Int?
    var first: String?
    var middleInitial: String?
    var last: String?
    var age: Int?
    var aftercare: Bool?
    var isCounsoleor: Bool?
    var memberSubscriptions: [String]?
    var sendTo: Location?
    var location: Location?
    var status: Status?
    var personName: PersonNameComponents {
        return PersonNameComponents(
            givenName: first,
            middleName: middleInitial,
            familyName: last
        )
    }
    var systemImage: String {
        if self.isCounsoleor == nil {
            return "person.fill.questionmark"
        }
        if self.isCounsoleor! {
            return "rectangle.inset.filled.and.person.filled"
        } else {
            return "person.crop.square"
        }
    }
    enum Key: CodingKey {
        case rawValue
    }
    
    enum CodingError: Error {
        case unknownValue
    }
    
    enum Location: Int, Codable, CaseIterable, Identifiable {
        case unknown = 0
        case atCamp = 1
        case inCabin = 2
        case summit = 3
        case afternoonOption = 4
        case upperCarpool = 5
        case lowerCarpool = 6
        case car = 7
        var id: Self { self }
        var symbol: String {
            switch self {
            case .unknown:
                return "questionmark.circle"
            case .atCamp:
                return "arrow.down.circle"
            case .inCabin:
                return "house"
            case .summit:
                return "triangle.tophalf.filled"
            case .afternoonOption:
                return "sun.and.horizon"
            case .upperCarpool:
                return "arrow.up"
            case .lowerCarpool:
                return "arrow.down"
            case .car:
                return "car"
            }
        }
        var description: String {
            switch self {
            case .unknown:
                return "unknown"
            case .atCamp:
                return "camp"
            case .inCabin:
                return "their cabin"
            case .summit:
                return "their summit"
            case .afternoonOption:
                return "their afternoon option"
            case .upperCarpool:
                return "upper carpool"
            case .lowerCarpool:
                return "lower carpool"
            case .car:
                return "a car"
            }
        }
        
        init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            let rawValue = try container.decode(Int.self)
            if (0...7).contains(rawValue) {
                self.init(rawValue: rawValue)!
            } else {
                throw CodingError.unknownValue
            }
        }
        func encode(to encoder: Encoder) throws {
            var container = encoder.singleValueContainer()
            try container.encode(self.rawValue)
        }
    }
    enum Status: Int, Codable, CaseIterable, Identifiable {
        case unknown = 0
        case at = 1
        case headingTo = 2
        case sentTo = 3
        case packingUp = 4
        var id: Self { self }
        var symbol: String {
            switch self {
            case .unknown:
                return "questionmark.circle"
            case .at:
                return "at"
            case .headingTo:
                return "figure.walk"
            case .sentTo:
                return "figure.walk"
            case .packingUp:
                return "tray.and.arrow.down"
            }
        }
        var description: String {
            switch self {
            case .unknown:
                return "unknown"
            case .at:
                return "at"
            case .headingTo:
                return "on the way to"
            case .sentTo:
                return "sent to"
            case .packingUp:
                return "packing up to"
            }
        }
        init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            let rawValue = try container.decode(Int.self)
            if (0...4).contains(rawValue) {
                self.init(rawValue: rawValue)!
            } else {
                throw CodingError.unknownValue
            }
        }
        func encode(to encoder: Encoder) throws {
            var container = encoder.singleValueContainer()
            try container.encode(self.rawValue)
        }
    }
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
