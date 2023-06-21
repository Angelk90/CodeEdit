//
//  WorkspaceDocument+presentedSubitem.swift
//  CodeEdit
//
//  Created by Wouter Hennen on 20/06/2023.
//

import SwiftUI

extension WorkspaceDocument {
    override nonisolated func presentedSubitem(at oldURL: URL, didMoveTo newURL: URL) {
        Task { @MainActor in
            moveFile(at: oldURL, didMoveTo: newURL)
        }
    }

    @MainActor
    fileprivate func moveFile(at oldURL: URL, didMoveTo newURL: URL) {
        guard let basePath = fileURL?.path() else { return }

        // We need to apply this weird trick as oldURL and newURL might differ in URL formatting.
        let oldPath = oldURL.path().split(separator: basePath).last ?? ""
        let newPath = newURL.path().split(separator: basePath).last ?? ""

        // The old resource location
        let oldPathComponents = oldPath.split(separator: "/").map { String($0) }

        // The folder where the resource will be placed in
        let newPathComponents = newPath.split(separator: "/").dropLast().map { String($0) }

        // Get resource, parent folder and new parent folder
        guard
            let resolved = fileTree?.resolveItem(components: oldPathComponents),
            let parentFolder = resolved.parentFolder,
            let newParentFolder = fileTree?.resolveItem(components: newPathComponents) as? Folder
        else {
            showError(FileError.couldNotResolveFile)
            return
        }

        // Move resource from old to new folder
        parentFolder.removeChild(resolved)
        newParentFolder.children.append(resolved)
        resolved.parentFolder = newParentFolder

        do {
            if let newName = try newURL.resourceValues(forKeys: [.nameKey]).name {
                resolved.name = newName
            } else {
                showError(FileError.noFileName)
            }
        } catch {
            showError(error)
        }
        onRefresh?()
    }
}