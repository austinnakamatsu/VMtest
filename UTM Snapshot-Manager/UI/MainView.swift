//
//  ContentView.swift
//  UTM Snapshot-Manager
//
//  Created by Jan Zombik on 03.03.23.
//

import SwiftUI
import UniformTypeIdentifiers

enum Genre: String, Hashable, CaseIterable {
    case action = "Action"
    case horror = "Horror"
    case ficion = "Fiction"
    case kids = "Kids"
}

struct Movie {
    let name: String
    let genre: Genre
}

struct MainView: View {
    @ObservedObject private var userSettings = UserSettings()
    
    @State private var selectedGenre: Genre?
    
    let columns: [GridItem] = [.init(.fixed(400)), .init(.fixed(400))]
    
    var body: some View {
        NavigationSplitView {
            /*List(Genre.allCases, id: \.self, selection: $selectedGenre) { genre in
                NavigationLink(genre.rawValue, value: genre)
            }*/
            List {
                VMGroupsView()
            }
            .environmentObject(userSettings)
        } detail: {
            VStack {
                Button {
                    self.createDemoVMGroup()
                } label: {
                    Text("Create demo VM group")
                }
            }
            
        }
    }
    
    private func showOpenPanel() -> [URL]? {
        let utmType = UTType(filenameExtension: "utm", conformingTo: .package)
        let openPanel = NSOpenPanel()
        
        openPanel.allowedContentTypes = [utmType!]
        openPanel.allowsMultipleSelection = true
        openPanel.canChooseDirectories = true
        openPanel.canChooseFiles = true
        
        let response = openPanel.runModal()
        return response == .OK ? openPanel.urls : nil
    }
    
    private func createDemoVMGroup() {
        guard let baseUrls = self.showOpenPanel() else {
            return
        }
        
        let vmUrls = FileManager.utmPackageURLsAt(baseUrls)
        let vms = vmUrls
            .filter { FileManager.isValidUTMPackageUrl($0) }
            .map { VM(validatedUrl: $0) }
        let vmTestGroup = VMGroup(id: UUID(), name: "Test", vms: vms)
        
        self.userSettings.vmGroups.append(vmTestGroup)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
