//
//  Data.swift
//  lido
//
//  Created by Everett Wilber on 6/21/22.
//

import Foundation
import SwiftUI

@MainActor class AppData: ObservableObject, Equatable {
    @Published var username: String?
    @Published var password: String?
    @Published var token: String?
    @Published var members = MemberCollection(array: [])
    @Published var session: Session?
    @Published var loggedOut = true
    
    static let preview = {
        var out = AppData()
        out.members = MemberCollection.preview
        return out
    }()
    
    var notificationTokenState = NotificationTokenState.noToken
    
    enum NotificationTokenState: Equatable {
        case noToken
        case hasToken(Data)
        case declined
    }
    
//    private let hostName = "http://192.168.1.23:3000"
//    private let socketName = "ws://192.168.1.23:4000"
//    private let hostName = "http://192.168.200.135:3000"
//    private let socketName = "ws://192.168.200.135:4000"
    private let hostName = "http://localhost:3000"
    private let socketName = "ws://localhost:4000"
    
    private var websocket: WebSocketClient = .shared
    
    func reload() async throws {
        try await self.getMembers()
        if !self.websocket.opened {
            await self.setupWebsocket()
        }
    }
    
    func setNotificationToken(token: Data) async {
        notificationTokenState = .hasToken(token)
        if !loggedOut {
            do {
                try await sendNotificationToken()
            } catch {
                fatalError()
            }
        }
    }
    
    func sendNotificationToken() async throws {
        switch notificationTokenState {
        case .noToken:
            return
        case .declined:
            return
        case let .hasToken(data):
            let urlString = hostName+"/api/authenticate/add_device_notification_token"
            let url = URL(string: urlString)!
            var req = URLRequest(url: url)
            let body: [String: String] = ["deviceNotificationToken": data.hexEncodedString()]
            let finalBody = try? JSONSerialization.data(withJSONObject: body)
            req.httpMethod = "POST"
            req.httpBody = finalBody
            req.httpShouldHandleCookies = true
            URLSession.shared.configuration.httpShouldSetCookies = true
            req.addValue("application/json", forHTTPHeaderField: "Content-Type")
            req.addValue("application/json", forHTTPHeaderField: "Accept")
            let (_, response) = try await URLSession.shared.data(for: req)
            try handleStatus(response)
        }
    }
    
    func setupWebsocket() async {
        websocket.subscribeToService(with: receivedData)
        let verification = WebsocketMessage(username: username, sessionId: token)
        do {
            try await websocket.sendMessage(message: verification)
        } catch {
            print(error)
            print(#filePath+" "+"\(#line)")
        }
    }
    
    struct WebsocketMessage: Codable {
        var username: String?
        var sessionId: String?
        var newMembers: MemberCollection?
        var changedMembers: MemberCollection?
        var deletedMembers: MemberCollection?
    }
    
    @MainActor func receivedData(_ data: Data?) {
        print("receivedCallback called at " + #function)
        print(data as Any)
        guard (data != nil) else {return}
        do {
            let message = try JSONDecoder().decode(WebsocketMessage.self, from: data!)
            print(message)
            DispatchQueue.main.async {
                if message.changedMembers != nil {
                    for member in message.changedMembers!.list {
                        withAnimation {
                            if let memberId = self.members.getMemberIndex(with: member._id) {
                                self.members.list[memberId] = member
                            } else {
                                self.members.list.append(member)
                            }
                        }
                    }
                }
                if message.newMembers != nil {
                    withAnimation {
                        self.members.list.append(contentsOf: message.newMembers!.list)
                    }
                }
                if message.deletedMembers != nil {
                    withAnimation {
                        for member in message.deletedMembers!.list {
                            guard let deleteIndex = self.members.getMemberIndex(with: member._id) else { continue }
                            self.members.list.remove(at: deleteIndex)
                        }
                    }
                }
            }
        } catch {
            print(error)
            print(#filePath+" "+"\(#line)")
        }
    }
    enum CommunicationError: Error {
        case forbidden
        case unauthenticated
        case serverError(Int)
        case otherErrorCode(Int)
        var description: String {
            switch self {
            case .forbidden:
                return "You do not have the permission to do that!"
            case .unauthenticated:
                return "You are not authenticated."
            case let .serverError(code):
                return "Server responded with error code: \(code)."
            case let .otherErrorCode(code):
                return "The server responded with an unknown response code: \(code)."
            }
        }
    }
    private func handleStatus(_ fromResponse: URLResponse) throws {
        let status = (fromResponse as? HTTPURLResponse)?.statusCode ?? -1
        guard (200...299).contains(status) else {
            print("badRequest");
            if status == 403 {
                throw CommunicationError.forbidden
            } else if status == 401 {
                throw CommunicationError.unauthenticated
            } else if (500...599).contains(status) {
                throw CommunicationError.serverError(status)
            } else if status == -1 {throw CommunicationError.otherErrorCode(status)}
            else {throw CommunicationError.otherErrorCode(status)}
        }
        
    }
    struct Session: Codable, Equatable {
        var username: String
        var sessionId: String
        var userId: String?
        var memberId: String?
        
        static func == (lhs: AppData.Session, rhs: AppData.Session) -> Bool {
            return lhs.username == rhs.username &&
            lhs.sessionId == rhs.sessionId &&
            lhs.userId == rhs.userId &&
            lhs.memberId == rhs.memberId
        }
    }
    typealias SessionResponse = Session
    func getSessionToken() async throws {
        let urlString = hostName+"/api/authenticate/new_session"
        let url = URL(string: urlString)!
        do {
            var req = URLRequest(url: url)
            let body: [String: String] = ["username": username ?? "", "password": password ?? ""]
            let finalBody = try? JSONSerialization.data(withJSONObject: body)
            req.httpMethod = "POST"
            req.httpBody = finalBody
            req.httpShouldHandleCookies = true
            URLSession.shared.configuration.httpShouldSetCookies = true
            req.addValue("application/json", forHTTPHeaderField: "Content-Type")
            req.addValue("application/json", forHTTPHeaderField: "Accept")
            let (data, response) = try await URLSession.shared.data(for: req)
            try handleStatus(response)
            let string = String.init(data: data, encoding: .utf8)
            let sessionResponse = try! JSONDecoder().decode(SessionResponse.self, from: data)
            token = sessionResponse.sessionId
            username = sessionResponse.username
            self.session = sessionResponse
            print("username: "+(username ?? "nil"))
            print("token: "+(token ?? "nil"))
            password = nil
            print(string ?? "nil")
        } catch {
            if let urlError = error as? URLError {
                print(urlError)
                throw urlError
            } else {
                print(error)
                throw error
            }
        }
        try await sendNotificationToken()
    }
    func getMembers() async throws {
        print("fetchingMembers")
        let ourlString = hostName+"/api/members"
        let ourl = URL(string: ourlString)!
        do {
            var req = URLRequest(url: ourl)
            req.httpMethod = "GET"
            req.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
//            req.httpShouldHandleCookies = true
//            URLSession.shared.configuration.httpShouldSetCookies = true
            req.addValue("application/json", forHTTPHeaderField: "Content-Type")
            req.addValue("application/json", forHTTPHeaderField: "Accept")
            let (data, response) = try await URLSession.shared.data(for: req)
            try handleStatus(response)
            let string = String.init(data: data, encoding: .utf8)
            var members = try JSONDecoder().decode(MemberCollection.self, from: data)
            for i in 0..<members.list.count {
                members.list[i].appData = self
            }
            print(URLSession.shared.configuration.httpCookieStorage?.cookies?[1].value ?? "nil")
            DispatchQueue.main.async {
                withAnimation {
                    self.members = members
                }
            }
//            self.members.list.sorted(by: { one, two in
//                one._id > two._id
//            })
            print(string ?? "nil")
        } catch {
            print("error")
            if let urlError = error as? URLError {
                print(urlError)
                throw urlError
            } else {
                print(error)
                throw error
            }
        }
    }
    struct NewMember: Codable {
        var first: String?
        var middleInitial: String?
        var last: String?
        var age: Int?
        var aftercare: Bool
        var isCounsoleor: Bool
        var dict: [String: Any] {
            return [
                "first": first as Any,
                "middleInitial": middleInitial as Any,
                "last": last as Any,
                "age": age as Any,
                "aftercare": aftercare as Any,
                "isCounsoleor": isCounsoleor as Any
            ]
        }
    }
    struct AddMemberResponse: Codable {
        var insertedId: String?
        var acknowledged: Bool
        var insertedValue: Member?
    }
    func addMember(member: NewMember) async throws {
        print("addingToken")
//        if token == nil {
//            try await getSessionToken()
//        }
        let ourlString = hostName+"/api/members"
        let ourl = URL(string: ourlString)!
        var req = URLRequest(url: ourl)
        //FIXME: handle url errors...
//        do {
        let finalBody = try? JSONSerialization.data(withJSONObject: member.dict)
        req.httpMethod = "POST"
        req.httpBody = finalBody
        req.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        req.addValue("application/json", forHTTPHeaderField: "Content-Type")
        req.addValue("application/json", forHTTPHeaderField: "Accept")
        let (data, response) = try await URLSession.shared.data(for: req)
        try handleStatus(response)
        let string = String.init(data: data, encoding: .utf8)
//        let decodedResponse = try JSONDecoder().decode(AddMemberResponse.self, from: data)
//        members.list.append(decodedResponse.insertedValue)
        print(string ?? "nil")
//        } catch (URLError.)
    }
    struct DeleteMemberResponse: Codable {
        var deletedCount: Int
        var acknowledged: Bool
    }
    func deleteMember(_ id: String) async throws {
        print("deleting member")
//        if token == nil {
//            try await getSessionToken()
//        }
        let ourlString = hostName+"/api/members"
        let ourl = URL(string: ourlString)!
        var req = URLRequest(url: ourl)
        //FIXME: handle url errors...
//        do {
        let body: [String: String] = [
            "id": id
        ]
        let finalBody = try? JSONSerialization.data(withJSONObject: body)
        req.httpMethod = "DELETE"
        req.httpBody = finalBody
        req.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        req.addValue("application/json", forHTTPHeaderField: "Content-Type")
        req.addValue("application/json", forHTTPHeaderField: "Accept")
        let (data, response) = try await URLSession.shared.data(for: req)
        try handleStatus(response)
        let string = String.init(data: data, encoding: .utf8)
        let decodedResponse = try JSONDecoder().decode(DeleteMemberResponse.self, from: data)
        if (decodedResponse.acknowledged) {
            withAnimation {
                self.members.removeMember(with: id)
            }
        }
        print(string ?? "nil")
//        } catch (URLError.)
    }
    func subscribeTo(_ id: String) async throws {
        print("subscribing to member with id "+id)
//        if token == nil {
//            try await getSessionToken()
//        }
        let ourlString = hostName+"/api/subscribe"
        let ourl = URL(string: ourlString)!
        var req = URLRequest(url: ourl)
        //FIXME: handle url errors...
//        do {
        let body: [String: String] = [
            "id": id
        ]
        let finalBody = try? JSONSerialization.data(withJSONObject: body)
        req.httpMethod = "POST"
        req.httpBody = finalBody
        req.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        req.addValue("application/json", forHTTPHeaderField: "Content-Type")
        req.addValue("application/json", forHTTPHeaderField: "Accept")
        let (data, response) = try await URLSession.shared.data(for: req)
        try handleStatus(response)
        let string = String.init(data: data, encoding: .utf8)
//        withAnimation {
//            self.members[id]?.id
//        }
        //FIXME: Animate
        print(string ?? "nil")
//        } catch (URLError.)
    }
    func unsubscribeFrom(_ id: String) async throws {
        print("unsubscribing from member with id "+id)
//        if token == nil {
//            try await getSessionToken()
//        }
        let ourlString = hostName+"/api/subscribe"
        let ourl = URL(string: ourlString)!
        var req = URLRequest(url: ourl)
        //FIXME: handle url errors...
//        do {
        let body: [String: String] = [
            "id": id
        ]
        let finalBody = try? JSONSerialization.data(withJSONObject: body)
        req.httpMethod = "DELETE"
        req.httpBody = finalBody
        req.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        req.addValue("application/json", forHTTPHeaderField: "Content-Type")
        req.addValue("application/json", forHTTPHeaderField: "Accept")
        let (data, response) = try await URLSession.shared.data(for: req)
        try handleStatus(response)
        let string = String.init(data: data, encoding: .utf8)
//        withAnimation {
//            self.members
//        }
        //FIXME: Animate
        print(string ?? "nil")
//        } catch (URLError.)
    }
    struct SetStatusRequest: Codable {
        var memberId: String
        var statusId: Member.Status?
        var locationId: Member.Location?
    }
    func setStatus(_ id: String, _ status: Member.Status, _ location: Member.Location) async throws {
        print("deleting member")
//        if token == nil {
//            try await getSessionToken()
//        }
        let ourlString = hostName+"/api/member_status/set"
        let ourl = URL(string: ourlString)!
        var req = URLRequest(url: ourl)
        //FIXME: handle url errors...
//        do {
        let body = SetStatusRequest(memberId: id, statusId: status, locationId: location)
        let finalBody = try? JSONEncoder().encode(body)
        req.httpMethod = "POST"
        req.httpBody = finalBody
        req.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        req.addValue("application/json", forHTTPHeaderField: "Content-Type")
        req.addValue("application/json", forHTTPHeaderField: "Accept")
        let (_, response) = try await URLSession.shared.data(for: req)
        try handleStatus(response)
        members.list[members.getMemberIndex(with: id)!].status = status
        members.list[members.getMemberIndex(with: id)!].location = location
    }
    func sendMemberTo(_ id: String, _ location: Member.Location) async throws {
        print("deleting member")
//        if token == nil {
//            try await getSessionToken()
//        }
        let ourlString = hostName+"/api/member_status/notify_change"
        let ourl = URL(string: ourlString)!
        var req = URLRequest(url: ourl)
        //FIXME: handle url errors...
//        do {
        let body = SetStatusRequest(memberId: id, locationId: location)
        let finalBody = try? JSONEncoder().encode(body)
        req.httpMethod = "POST"
        req.httpBody = finalBody
        req.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        req.addValue("application/json", forHTTPHeaderField: "Content-Type")
        req.addValue("application/json", forHTTPHeaderField: "Accept")
        let (_, response) = try await URLSession.shared.data(for: req)
        try handleStatus(response)
        members.list[members.getMemberIndex(with: id)!].sendTo = location
    }
    func logout() async throws {
        
    }
    
    static func == (lhs: AppData, rhs: AppData) -> Bool {
        return lhs.username == rhs.username &&
        lhs.password == rhs.password &&
        lhs.token == rhs.token &&
        lhs.members == rhs.members &&
        lhs.session == rhs.session &&
        lhs.loggedOut == rhs.loggedOut &&
        lhs.notificationTokenState == rhs.notificationTokenState &&
        lhs.hostName == rhs.hostName &&
        lhs.socketName == rhs.socketName &&
        lhs.websocket == rhs.websocket
    }
}

extension Data {
    struct HexEncodingOptions: OptionSet {
        let rawValue: Int
        static let upperCase = HexEncodingOptions(rawValue: 1 << 0)
    }

    func hexEncodedString(options: HexEncodingOptions = []) -> String {
        let format = options.contains(.upperCase) ? "%02hhX" : "%02hhx"
        return self.map { String(format: format, $0) }.joined()
    }
}
