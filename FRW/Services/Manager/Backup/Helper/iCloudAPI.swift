//
//  iCloudAPI.swift
//  Flow Wallet
//
//  Created by Selina on 28/7/2022.
//

import Combine
import UIKit

class iCloudAPI: UIDocument {
    private(set) var data: Data?
    private lazy var workingQueue: OperationQueue = {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        return queue
    }()

    private var cancelSets = Set<AnyCancellable>()
    
    override func load(fromContents contents: Any, ofType typeName: String?) throws {
        debugPrint("iCloudAPI -> load")
        
        guard let contents = contents as? Data else {
            debugPrint("iCloudAPI -> load: invalidLoadData")
            throw iCloudBackupError.invalidLoadData
        }
        
        data = contents
        debugPrint("iCloudAPI -> load: success, data.count = \(data?.count ?? -1)")
    }
    
    override func contents(forType typeName: String) throws -> Any {
        debugPrint("iCloudAPI -> contents")
        
        guard let data = data else {
            debugPrint("iCloudAPI -> contents: noDataToSave")
            throw iCloudBackupError.noDataToSave
        }
        
        debugPrint("iCloudAPI -> contents: success, data.count = \(data.count)")
        return data
    }
    
    func isExist() async throws -> Bool {
        debugPrint("iCloudAPI -> isExist")
        
        let query = NSMetadataQuery()
        query.operationQueue = workingQueue
        query.predicate = NSPredicate(format: "%K == %@", NSMetadataItemFSNameKey, BackupManager.backupFileName)
        query.searchScopes = [
            NSMetadataQueryUbiquitousDocumentsScope
        ]
        
        cancelSets.removeAll()
        
        query.operationQueue?.addOperation {
            debugPrint("iCloudAPI -> isExist: query.start()")
            query.start()
        }
        
        return try await withCheckedThrowingContinuation { config in
            NotificationCenter.default.publisher(for: .NSMetadataQueryDidFinishGathering).sink { [weak self] _ in
                debugPrint("iCloudAPI -> isExist: query callback, resultCount = \(query.resultCount)")
                query.disableUpdates()
                query.stop()
                self?.cancelSets.removeAll()
                
                guard let results = query.results as? [NSMetadataItem], let item = results.first else {
                    debugPrint("iCloudAPI -> isExist: results or item is nil")
                    config.resume(returning: false)
                    return
                }
                
                guard let isUploaded = item.value(forAttribute: NSMetadataUbiquitousItemIsUploadedKey) as? Bool else {
                    debugPrint("iCloudAPI -> isExist: checkFileUploadedStatusError")
                    config.resume(throwing: iCloudBackupError.checkFileUploadedStatusError)
                    return
                }
                
                debugPrint("iCloudAPI -> isExist: isUploaded = \(isUploaded)")
                config.resume(returning: isUploaded)
            }.store(in: &cancelSets)
        }
    }
    
    func isExist(name: String = BackupManager.backupFileName) async throws -> Bool {
        debugPrint("iCloudAPI -> isExist")
        
        let query = NSMetadataQuery()
        query.operationQueue = workingQueue
        query.predicate = NSPredicate(format: "%K == %@", NSMetadataItemFSNameKey, name)
        query.searchScopes = [
            NSMetadataQueryUbiquitousDocumentsScope
        ]
        
        cancelSets.removeAll()
        
        query.operationQueue?.addOperation {
            debugPrint("iCloudAPI -> isExist: query.start()")
            query.start()
        }
        
        return try await withCheckedThrowingContinuation { config in
            NotificationCenter.default.publisher(for: .NSMetadataQueryDidFinishGathering).sink { [weak self] _ in
                debugPrint("iCloudAPI -> isExist: query callback, resultCount = \(query.resultCount)")
                query.disableUpdates()
                query.stop()
                self?.cancelSets.removeAll()
                
                guard let results = query.results as? [NSMetadataItem], let item = results.first else {
                    debugPrint("iCloudAPI -> isExist: results or item is nil")
                    config.resume(returning: false)
                    return
                }
                
                guard let isUploaded = item.value(forAttribute: NSMetadataUbiquitousItemIsUploadedKey) as? Bool else {
                    debugPrint("iCloudAPI -> isExist: checkFileUploadedStatusError")
                    config.resume(throwing: iCloudBackupError.checkFileUploadedStatusError)
                    return
                }
                
                debugPrint("iCloudAPI -> isExist: isUploaded = \(isUploaded)")
                config.resume(returning: isUploaded)
            }.store(in: &cancelSets)
        }
    }
}

extension iCloudAPI {
    func getFileData() async throws -> Data {
        debugPrint("iCloudAPI -> getFileData")
        
        let result = await open()
        if !result {
            debugPrint("iCloudAPI -> getFileData: openFileError")
            throw iCloudBackupError.openFileError
        }
        
        guard let data = data else {
            debugPrint("iCloudAPI -> getFileData: opendFileDataIsNil")
            throw iCloudBackupError.opendFileDataIsNil
        }
        
        debugPrint("iCloudAPI -> getFileData: success, data.count = \(data.count)")
        return data
    }
    
    func write(content: Data) async throws -> Bool {
        debugPrint("iCloudAPI -> write")
        let isExist = try await isExist()
        data = content
        
        let result = await save(to: fileURL, for: isExist ? .forOverwriting : .forCreating)
        debugPrint("iCloudAPI -> write: result = \(result)")
        
        return result
    }
}
