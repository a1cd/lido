//
//  Data.swift
//  lido
//
//  Created by Everett Wilber on 6/21/22.
//

import Foundation
import SwiftUI

@MainActor class AppData: ObservableObject {
    @Published var username: String?
    @Published var password: String?
    @Published var token: String?
    @Published var members = MemberCollection(array: [])
    @Published var loggedOut = true
    
    private let hostName = "http://192.168.1.23:3000"
    private let socketName = "ws://192.168.1.23:4000"
    
    private var websocket: WebSocketClient = .shared
    
    func reload() async throws {
        try await self.getMembers()
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
    
    func receivedData(_ data: Data?) {
        print("receivedCallback called at " + #function)
        print(data)
        guard (data != nil) else {return}
        do {
            let message = try JSONDecoder().decode(WebsocketMessage.self, from: data!)
            print(message)
            if message.changedMembers != nil {
                for member in message.changedMembers!.list {
                    if let memberId = members.getMember(with: member._id) {
                        members.list[memberId] = member
                    } else {
                        members.list.append(member)
                    }
                    
                }
            }
            if message.newMembers != nil {
                members.list.append(contentsOf: message.newMembers!.list)
            }
            if message.deletedMembers != nil {
                for member in message.deletedMembers!.list {
                    guard let deleteIndex = members.getMember(with: member._id) else { continue }
                    members.list.remove(at: deleteIndex)
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
            var foundUsername = false
            var foundToken = false
            for cookie in (URLSession.shared.configuration.httpCookieStorage?.cookies(for: url) ?? Array<HTTPCookie>()) {
                if (cookie.name == "sessionId") {
                    token = cookie.value
                    foundToken = true
                }
                if (cookie.name == "username") {
                    username = cookie.value
                    foundUsername = true
                }
            }
            if (!(foundUsername && foundToken)) {
                print(string)
                print("not found")
                print("username: "+(username ?? "nil"))
                print("token: "+(token ?? "nil"))
            }
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
        
    }
    func getMembers() async throws {
        if token == nil {
            try await getSessionToken()
        }
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
            let members = try JSONDecoder().decode(MemberCollection.self, from: data)
            print(URLSession.shared.configuration.httpCookieStorage?.cookies?[1].value ?? "nil")
            self.members = members
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
                "first": first,
                "middleInitial": middleInitial,
                "last": last,
                "age": age,
                "aftercare": aftercare,
                "isCounsoleor": isCounsoleor
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
            withAnimation(.default, {
                members.list.remove(at: members.getMember(with: id)!)
            })
        }
        print(string ?? "nil")
//        } catch (URLError.)
    }
    struct SetStatusRequest: Codable {
        var memberId: String
        var statusId: Member.Status
        var locationId: Member.Location
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
        let (data, response) = try await URLSession.shared.data(for: req)
        try handleStatus(response)
        members.list[members.getMember(with: id)!].status = status
        members.list[members.getMember(with: id)!].location = location
    }
    func logout() async throws {
        
    }
}
