//
//  UserToolbar.swift
//  lido
//
//  Created by Everett Wilber on 8/4/22.
//

import SwiftUI

struct UserToolbar: ViewModifier {
    
    @State private var selectionEmpty = true
    @State private var nonLocalizedError: Error? = nil
    @State private var nonLocalizedErrorOccurred = false
    @State private var creatingMember = false
    @State private var followLabelStatus: FollowLabel.FollowLabelType = .disabled
    
    @Binding var member: Member.ID?
    @Binding var selection: Set<Member.ID>
    
    @EnvironmentObject var appData: AppData
    
    var getFollowLabelStatus: FollowLabel.FollowLabelType {
        guard let session = appData.session else {
            return .disabled
        }
        guard let memberId = session.memberId else {
            return .disabled
        }
        guard let userSubscriptions = appData.members[memberId]?.subscriptions else {
            return .disabled
        }
        var idsFound = 0
        var idsNotFound = 0
        doForSelectedMembers({ id in
            if (userSubscriptions.contains(id)) {
                idsFound += 1
            } else {
                idsNotFound += 1
            }
        })
        if (idsFound > 0) && (idsNotFound > 0) {
            return .some
        } else if idsFound > 0 {
            return .all
        } else if idsNotFound > 0 {
            return .none
        } else {
            return .none
        }
    }
    
    func doForSelectedMembers(_ action: @MainActor @escaping (_ id: String) async throws -> ()) {
        let selection = selection
        do {
            if member != nil {
                try Task(priority: .userInitiated) {
                    try await action(member!)
                }
            } else {
                try Task(priority: .userInitiated) {
                    do {
                        try await withThrowingTaskGroup(of: String.self, returning: [String].self) { group in
                            var completedIds = [String]()
                            completedIds.reserveCapacity(selection.count)
                            
                            // adding tasks to the group and fetching movies
                            for id in selection {
                                group.addTask(priority: TaskPriority.userInitiated) {
                                    try await action(id)
                                    return id
                                }
                            }
                            
                            for try await result in group {
                                completedIds.append(result)
                            }
                            
                            return completedIds
                        }
                    } catch {
                        DispatchQueue.main.async {
                            nonLocalizedErrorOccurred = true
                            nonLocalizedError = error
                        }
                    }
                }
            }
        } catch {
            nonLocalizedErrorOccurred = true
            nonLocalizedError = error
        }
        
    }
    
    func doForSelectedMembers(_ action: (_ id: String) throws -> ()) rethrows {
        
        if member != nil {
            try action(member!)
        } else {
            for id in selection {
                try action(id)
            }
        }
    }
    
    var toolbar: some CustomizableToolbarContent {
        Group {
            ToolbarItem(id: "NewMember", placement: .primaryAction) {
                Button {
                    creatingMember = true
                } label: {
                    Label("createMember", systemImage: "plus")
                }
                .popover(isPresented: $creatingMember) {
                    NewMemberView(submit: {
                        creatingMember = false
                    })
                }
                //TODO: add help for all toolbar items
            }
            ToolbarItem(id: "DeleteMember", placement: .destructiveAction) {
                Button {
                    doForSelectedMembers(appData.deleteMember)
                    //FIXME: Will break if the above fails
                } label: {
                    Label("delete", systemImage: "trash")
                }
                .disabled(selectionEmpty && member==nil)
            }
            ToolbarItem(id: "SetStatus", placement: .primaryAction) {
                Menu {
                    ForEach(Member.Status.allCases) { status in
                        Button {
                            doForSelectedMembers({ id in
                                guard let location = appData.members.getMember(with: id)?.location else {return}
                                try await appData.setStatus(id, status, location)
                                //FIXME: Will break if the above fails
                            })
                        } label: {
                            status.label
                        }
                    }
                } label: {
                    Label("setStatus", systemImage: "person.crop.circle.badge")
                }
                .disabled(selectionEmpty && member==nil)
            }
            ToolbarItem(id: "SetLocation", placement: .primaryAction) {
                Menu {
                    ForEach(Member.Location.allCases) { location in
                        Button {
                            doForSelectedMembers({ id in
                                guard let status = appData.members.getMember(with: id)?.status else {return}
                                try await appData.setStatus(id, status, location)
                                //FIXME: Will break if the above fails
                            })
                            print("")
                        } label: {
                            location.label
                        }
                    }
                } label: {
                    Label("setLocation", systemImage: "mappin.and.ellipse")
                }
                .disabled(selectionEmpty && member==nil)
            }
            ToolbarItem(id: "SendMemberTo", placement: .primaryAction) {
                Menu {
                    ForEach(Member.Location.allCases) { location in
                        Button {
                            doForSelectedMembers({ id in
                                try await appData.sendMemberTo(id, location)
                                //FIXME: Will break if the above fails
                            })
                        } label: {
                            location.label
                        }
                    }
                } label: {
                    Label("sendMemberTo", systemImage: "arrow.forward.circle")
                }
                .disabled(selectionEmpty && member==nil)
            }
            ToolbarItem(id: "follow", placement: .primaryAction) {
                FollowLabel(followLabelStatus: self.$followLabelStatus) {
                    print(followLabelStatus)
                    switch followLabelStatus {
                    case .all:
                        doForSelectedMembers(appData.unsubscribeFrom)
                    case .some, .none:
                        doForSelectedMembers(appData.subscribeTo)
                    default:
                        return
                    }
                    //FIXME: Will break if the above fails
                }
            }
        }
    }
    
    func body(content: Content) -> some View {
        content
            .toolbar(id: "TableToolbar") {
                toolbar
            }
            .alert(isPresented: $nonLocalizedErrorOccurred, content: {
                Alert(
                    title: Text("error"),
                    message: Text(nonLocalizedError!.localizedDescription),
                    dismissButton: .default(Text("dismiss"))
                )
            })
            .onChange(of: self.selection, perform: { _ in
                selectionEmpty = selection.isEmpty
                followLabelStatus = getFollowLabelStatus
            })
            .onChange(of: self.appData.members, perform: { _ in
                followLabelStatus = getFollowLabelStatus
            })
    }
    
}

extension View {
    func userToolbar(_ selection: Binding<Set<Member.ID>>) -> some View {
        modifier(UserToolbar(member: .constant(nil), selection: selection))
    }
    func userToolbar(_ selection: Binding<Member.ID?>) -> some View {
        modifier(UserToolbar(member: selection, selection: .constant(.init([]))))
    }
}

//struct UserToolbar_Previews: PreviewProvider {
//    static var previews: some View {
//        UserToolbar()
//    }
//}
