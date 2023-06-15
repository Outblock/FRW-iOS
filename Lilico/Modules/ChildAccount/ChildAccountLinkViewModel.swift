//
//  ChildAccountLinkViewModel.swift
//  Lilico
//
//  Created by Selina on 15/6/2023.
//

import SwiftUI
import Combine

extension ChildAccountLinkViewModel {
    enum State {
        case idle
        case processing
        case success
        case fail
    }
}

class ChildAccountLinkViewModel: ObservableObject {
    @Published var title: String = "Link Account"
    @Published var state: ChildAccountLinkViewModel.State = .idle
    private let timer = Timer.publish(every: 2, on: .main, in: .common).autoconnect()
    private var cancelSets = Set<AnyCancellable>()
    
    func test() {
        timer.sink { _ in
            withAnimation(.easeInOut(duration: 0.25)) {
                switch self.state {
                case .idle:
                    self.state = .processing
                case .processing:
                    self.state = .success
                case .success:
                    self.state = .fail
                case .fail:
                    self.state = .idle
                }
            }
        }.store(in: &cancelSets)
    }
}
