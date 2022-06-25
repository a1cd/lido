//
//  Data.swift
//  lido
//
//  Created by Everett Wilber on 6/21/22.
//

import Foundation

class AppData: ObservableObject {
    @Published var username: String?
    @Published var password: String?
    @Published var token: String?
    @Published var members = MemberCollection(array: [])
    
    private let hostName = "http://localhost:3000"
    private let socketName = "ws://localhost:4000"
    
    private var websocket: WebSocketClient = .shared
    
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
        } catch {
            print(error)
            print(#filePath+" "+"\(#line)")
        }
    }
    
    func getSessionToken() async {
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
            guard (response as? HTTPURLResponse)?.statusCode == 200 else {
                print("badRequest"); return
            }
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
            print("error")
            print(error)
        }
        
    }
    func getMembers() async {
        if token == nil {
            await getSessionToken()
        }
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
            guard (response as? HTTPURLResponse)?.statusCode == 200 else { print("badRequest"); return }
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
            print(error)
            print(#filePath+" "+"\(#line)")
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
        var insertedId: String
        var acknowledged: Bool
        var insertedValue: Member
    }
    func addMember(member: NewMember) async throws {
        print("addingToken")
        if token == nil {
            await getSessionToken()
        }
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
        let status = (response as? HTTPURLResponse)?.statusCode ?? -1
        let isOK = status >= 200 && status < 300
        guard isOK else {
            print("badRequest");
            throw URLError(URLError.Code(rawValue: (response as? HTTPURLResponse)?.statusCode ?? 0))
        }
        let string = String.init(data: data, encoding: .utf8)
        let decodedResponse = try JSONDecoder().decode(AddMemberResponse.self, from: data)
//        members.list.append(decodedResponse.insertedValue)
        print(string ?? "nil")
//        } catch (URLError.)
    }
    struct DeleteMemberResponse: Codable {
        var deletedCount: Int
        var acknowledged: Bool
    }
    func deleteMember(_ index: Int) async throws {
        print("deleting member")
        if token == nil {
            await getSessionToken()
        }
        let ourlString = hostName+"/api/members"
        let ourl = URL(string: ourlString)!
        var req = URLRequest(url: ourl)
        //FIXME: handle url errors...
//        do {
        let body: [String: String] = [
            "id": members.list[index]._id
        ]
        let finalBody = try? JSONSerialization.data(withJSONObject: body)
        req.httpMethod = "DELETE"
        req.httpBody = finalBody
        req.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        req.addValue("application/json", forHTTPHeaderField: "Content-Type")
        req.addValue("application/json", forHTTPHeaderField: "Accept")
        let (data, response) = try await URLSession.shared.data(for: req)
        let status = (response as? HTTPURLResponse)?.statusCode ?? -1
        let isOK = status >= 200 && status < 300
        guard isOK else {
            print("badRequest");
            throw URLError(URLError.Code(rawValue: (response as? HTTPURLResponse)?.statusCode ?? 0))
        }
        let string = String.init(data: data, encoding: .utf8)
        let decodedResponse = try JSONDecoder().decode(DeleteMemberResponse.self, from: data)
        if (decodedResponse.acknowledged) {
            members.list.remove(at: index)
        }
        print(string ?? "nil")
//        } catch (URLError.)
    }
}
