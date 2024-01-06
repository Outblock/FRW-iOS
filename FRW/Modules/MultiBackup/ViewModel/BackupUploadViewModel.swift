//
//  BackupUploadViewModel.swift
//  FRW
//
//  Created by cat on 2023/12/14.
//

import Foundation
import SwiftUI

enum BackupProcess {
    case idle,upload,regist, finish
    
    var next: BackupProcess {
        switch self {
        case .idle:
                .upload
        case .upload:
                .regist
        case .regist:
                .finish
        case .finish:
                .idle
        }
    }
    
    var title: String {
        switch self {
        case .idle:
            "backup.status.create".localized
        case .upload:
            "backup.status.upload".localized
        case .regist:
            "backup.status.regist".localized
        case .finish:
            "backup.status.finish".localized
        }
    }
    
    var icon: String {
        switch self {
        case .idle:
            ""
        case .upload:
            ""
        case .regist:
            ""
        case .finish:
            "backup.status.finish"
        }
    }
}

//MARK: - BackupUploadViewModel

class BackupUploadViewModel: ObservableObject {
    let items: [BackupType] = [.google, .passkey, .icloud, .phrase]
    
    @Published var currentIndex: Int = 0
    @Published var process: BackupProcess = .idle
    @Published var hasError: Bool = false
    
    var currentType: BackupType = .google {
        didSet {
            currentIndex = currentType.rawValue
        }
    }
    
    
    init() {
        
    }
    
    func reset() {
        hasError = false
        process = .idle
        
    }
    
    //MARK: UI element
    var currentIcon: String {
        currentType.iconName()
    }
    
    var currentTitle: String {
        "backup".localized + " \(currentIndex+1):\(currentType.title) " + "backup".localized
    }
    
    var currentNote: String {
        currentType.noteDes
    }
    
    var currentButton: String {
        process.title
    }
    
    //MARK: backup on Goodle Drive
    
    func prepareGoodle() {
        
    }
}
