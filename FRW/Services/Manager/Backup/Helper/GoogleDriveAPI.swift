//
//  GoogleDriveAPI.swift
//  Flow Wallet
//
//  Created by Selina on 20/7/2022.
//

import Foundation
import GoogleAPIClientForREST_Drive
import GoogleAPIClientForRESTCore
import GoogleSignIn
import GTMSessionFetcherCore

class GoogleDriveAPI {
    private let user: GIDGoogleUser
    private let service: GTLRDriveService

    init(user: GIDGoogleUser, service: GTLRDriveService) {
        self.user = user
        self.service = service
    }

    func getFileId(fileName: String) async throws -> String? {
        let query = GTLRDriveQuery_FilesList.query()
        query.spaces = "appDataFolder"
        query.fields = "nextPageToken, files(id, name)"
        query.pageSize = 10

        return try await withCheckedThrowingContinuation { continuation in
            service.executeQuery(query) { _, results, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }

                guard let fileListObject = results as? GTLRDrive_FileList, let files = fileListObject.files else {
                    continuation.resume(returning: nil)
                    return
                }

                for file in files {
                    if file.name == fileName {
                        continuation.resume(returning: file.identifier)
                        return
                    }
                }

                continuation.resume(returning: nil)
            }
        }
    }

    func getFileData(fileId: String) async throws -> Data? {
        let query = GTLRDriveQuery_FilesGet.queryForMedia(withFileId: fileId)

        return try await withCheckedThrowingContinuation { continuation in
            service.executeQuery(query) { _, file, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }

                guard let data = (file as? GTLRDataObject)?.data else {
                    continuation.resume(returning: nil)
                    return
                }

                continuation.resume(returning: data)
            }
        }
    }

    func write(content: Data, to fileName: String) async throws {
        guard let fileId = try await getFileId(fileName: fileName) else {
            debugPrint("GoogleDriveAPI -> write(): fileId is empty")
            _ = try await createFile(fileName: fileName, content: content)
            return
        }

        let parameter = GTLRUploadParameters(data: content, mimeType: "application/json")

        let file = GTLRDrive_File()
        file.name = fileName

        let query = GTLRDriveQuery_FilesUpdate.query(withObject: file, fileId: fileId, uploadParameters: parameter)

        try await withUnsafeThrowingContinuation { (continuation: UnsafeContinuation<Void, Error>) in
            service.executeQuery(query) { _, _, error in
                if let error = error {
                    debugPrint("GoogleDriveAPI -> write(): error: \(error)")
                    continuation.resume(throwing: error)
                    return
                }

                continuation.resume()
            }
        }
    }

    private func createFile(fileName: String, content: Data) async throws -> String {
        let parameter = GTLRUploadParameters(data: content, mimeType: "application/json")

        let file = GTLRDrive_File()
        file.name = fileName
        file.parents = ["appDataFolder"]

        let query = GTLRDriveQuery_FilesCreate.query(withObject: file, uploadParameters: parameter)

        return try await withCheckedThrowingContinuation { continuation in
            service.executeQuery(query) { _, file, error in
                if let error = error {
                    debugPrint("GoogleDriveAPI -> createFile(): error: \(error)")
                    continuation.resume(throwing: error)
                    return
                }

                guard let file = file as? GTLRDrive_File, let fileId = file.identifier, !fileId.isEmpty else {
                    debugPrint("GoogleDriveAPI -> createFile(): fileObject error")
                    continuation.resume(throwing: GoogleBackupError.createFileError)
                    return
                }

                debugPrint("GoogleDriveAPI -> createFile(): fileId = \(fileId)")
                continuation.resume(returning: fileId)
            }
        }
    }
}
