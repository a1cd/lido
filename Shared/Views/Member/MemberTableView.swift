//
//  MemberTableView.swift
//  lido (macOS)
//
//  Created by Everett Wilber on 7/14/22.
//

import SwiftUI

struct MemberTableView: View {
    enum ViewMode: String, CaseIterable, Identifiable {
        var id: Self { self }
        case table
        case gallery
    }

    @EnvironmentObject var appData: AppData
//    @Binding var gardenId: Garden.ID?
    @State var searchText: String = ""
    @SceneStorage("viewMode") private var mode: ViewMode = .table
    @State private var selection = Set<Member.ID>()

    @State private var creatingMember = false
    
    @State var sortOrder: [KeyPathComparator<Member>] = [
        .init(\.last, order: SortOrder.forward)
    ]
    
    @State private var nonLocalizedError: Error? = nil
    @State private var nonLocalizedErrorOccurred = false
    
    func doForSelectedMembers(_ action: @MainActor @escaping (_ id: String) async throws -> ()) {
        let selection = selection
        do {
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
        } catch {
            nonLocalizedErrorOccurred = true
            nonLocalizedError = error
        }
        
    }
    
    var table: some View {
        Table(appData.members.list, selection: $selection, sortOrder: $sortOrder) {
            TableColumn("First", value: \.first)
            TableColumn("Last", value: \.last)
            TableColumn("Age", value: \.age) { member in
                Text(member.age.description)
            }
            TableColumn("Status", value: \.status) { member in
                Label(member.status.description, systemImage: member.status.symbol)
            }
            TableColumn("Location", value: \.location) { member in
                Label(member.location.description, systemImage: member.location.symbol)
            }
        }
    }
    
    @State var deleteConfirm: Bool = false
    
    var toolbar: some CustomizableToolbarContent {
        Group {
            ToolbarItem(id: "NewMember", placement: .primaryAction) {
                Button {
                    creatingMember = true
                } label: {
                    Label("Create New Member", systemImage: "plus")
                }
                .popover(isPresented: $creatingMember) {
                    NewMemberView(submit: {
                        creatingMember = false
                    })
                }
            }
            ToolbarItem(id: "DeleteMember", placement: .destructiveAction) {
                Button {
                    doForSelectedMembers(appData.deleteMember)
                    //FIXME: Will break if the above fails
                } label: {
                    Label("Delete", systemImage: "trash")
                }
                .disabled(selection.isEmpty)
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
                    Label("Set Status", systemImage: "person.crop.circle.badge")
                        .disabled(selection.isEmpty)
                }
                .disabled(selection.isEmpty)
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
                    Label("Set Location", systemImage: "mappin.and.ellipse")
                        .disabled(selection.isEmpty)
                }
                .disabled(selection.isEmpty)
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
                    Label("Set Location", systemImage: "mappin.and.ellipse")
                }
                .disabled(selection.isEmpty)
            }
        }
    }
    
    var body: some View {
        table
            .navigationTitle("Members")
            .toolbar(id: "TableToolbar") {
                toolbar
            }
            .alert(isPresented: $nonLocalizedErrorOccurred, content: {
                Alert(
                    title: Text("An Error Occurred"),
                    message: Text(nonLocalizedError!.localizedDescription),
                    dismissButton: .default(Text("OK"))
                )
            })
        
    }
}

struct MemberTableView_Previews: PreviewProvider {
    static var previews: some View {
        MemberTableView()
    }
}
