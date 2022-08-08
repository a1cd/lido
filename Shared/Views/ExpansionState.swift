//
//  ExpansionState.swift
//  lido
//
//  Created by Everett Wilber on 7/16/22.
//

import Foundation

struct ExpansionState: RawRepresentable {

    var ids: Set<AnyHashable>

    let browse: AnyHashable = "browse"
    
    init?(rawValue: String) {
        ids = Set(rawValue.components(separatedBy: ",").compactMap(Int.init))
    }

    init() {
        ids = []
    }

    var rawValue: String {
        ids.map({ "\($0)" }).joined(separator: ",")
    }

    var isEmpty: Bool {
        ids.isEmpty
    }

    func contains(_ id: AnyHashable) -> Bool {
        ids.contains(id)
    }

    mutating func insert(_ id: AnyHashable) {
        ids.insert(id)
    }

    mutating func remove(_ id: AnyHashable) {
        ids.remove(id)
    }

    subscript(year: AnyHashable) -> Bool {
        get {
            // Expand the current year by default
            ids.contains(year) ? true : year == browse
        }
        set {
            if newValue {
                ids.insert(year)
            } else {
                ids.remove(year)
            }
        }
    }
}
