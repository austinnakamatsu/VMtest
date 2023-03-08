//
//  VMGroupDetailsView.swift
//  UTM Snapshot-Manager
//
//  Created by Jan Zombik on 06.03.23.
//

import SwiftUI
import UniformTypeIdentifiers

struct Purchase: Identifiable {
    let price: Decimal
    let id = UUID()
}

struct VMGroupDetailsView: View {
    @Binding var vmGroup: VMGroup
    
    let currencyStyle = Decimal.FormatStyle.Currency(code: "USD")

    
    var body: some View {
        Text("vmGroup \(vmGroup.name): \(vmGroup.vms.description)")
            .padding()
        Button("removeVM", action: removeLastVM)
        Button("addVM", action: addVMs)
    }
    
    private func removeLastVM() {
        _ = vmGroup.vms.popLast()
    }
    
    private func addVMs() {
        let utmType = UTType(filenameExtension: "utm", conformingTo: .package)
        let openPanel = NSOpenPanel()
        
        openPanel.allowedContentTypes = [utmType!]
        openPanel.allowsMultipleSelection = true
        openPanel.canChooseDirectories = true
        openPanel.canChooseFiles = true
        
        guard let urls = openPanel.runModal() == .OK ? openPanel.urls : nil else {
            return
        }
        
        let existingUrls = vmGroup.vms.map { $0.url }
        let newVMUrls = FileManager.utmPackageURLsAt(urls)
        for url in newVMUrls {
            guard !existingUrls.contains(url) else {
                continue
            }
            
            guard FileManager.isValidUTMPackageUrl(url) else {
                continue
            }
            
            vmGroup.vms.append( VM(validatedUrl: url))
        }
    }
}

struct VMGroupDetailsView_Previews: PreviewProvider {
    @State static private var vmGroup = VMGroup()
    
    static var previews: some View {
        VMGroupDetailsView(vmGroup: $vmGroup)
    }
}
