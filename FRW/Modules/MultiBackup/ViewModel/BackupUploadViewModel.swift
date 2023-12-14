//
//  BackupUploadViewModel.swift
//  FRW
//
//  Created by cat on 2023/12/14.
//

import Foundation
import SwiftUI

class BackupUploadViewModel: ObservableObject {
    let items: [BackupType] = [.google, .passkey]
    @Published var currentIndex = 0
    
    
    init() {
        
    }
    
    
}
