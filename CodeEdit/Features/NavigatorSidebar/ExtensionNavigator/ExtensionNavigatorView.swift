//
//  ExtensionNavigatorView.swift
//  CodeEdit
//
//  Created by Pavel Kasila on 6.04.22.
//

import SwiftUI
import Combine

struct ExtensionNavigatorView: View {
    @EnvironmentObject var workspace: WorkspaceDocument
    @EnvironmentObject var extensionManager: ExtensionManager

    @ObservedObject var data: ExtensionNavigatorData
    @State var showing = false

    var body: some View {
        List(extensionManager.extensions) { ext in
            HStack {
                if let icon = ext.icon {
                    Image(nsImage: icon)
                } else {
                    Text("No Image")
                }
                Text(ext.localizedName)
            }
        }
    }
}
