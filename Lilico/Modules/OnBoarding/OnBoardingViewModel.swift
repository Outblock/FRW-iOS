//
//  OnBoardingViewModel.swift
//  Lilico
//
//  Created by Selina on 1/6/2023.
//

import SwiftUI
import Combine
import SwiftUIPager

extension OnBoardingViewModel {
    enum PageType: String, CaseIterable {
        case nft
        case token
        case domain
        case site
        
        var testColor: Color {
            switch self {
            case .nft:
                return .systemRed
            case .token:
                return .systemBlue
            case .domain:
                return .systemYellow
            case .site:
                return .systemPink
            }
        }
        
        var bgImageName: String {
            return "onboarding-bg-\(self.rawValue)"
        }
        
        var imageName: String {
            return "onboarding-img-\(self.rawValue)"
        }
        
        var title: String {
            return "onboarding_title_\(self.rawValue)".localized
        }
        
        var desc: String {
            return "onboarding_desc_\(self.rawValue)".localized
        }
    }
}

class OnBoardingViewModel: ObservableObject {
    @Published var currentPageIndex: Int = 0
    @Published var page: Page = .first()
    
    var totalPages: Int {
        return PageType.count
    }
    
    var currentPageType: PageType {
        return PageType.allCases[currentPageIndex]
    }
    
    var isLastPage: Bool {
        return currentPageIndex == totalPages - 1
    }
    
    func onSkipBtnAction() {
        onStartBtnAction()
    }
    
    func onNextBtnAction() {
        if currentPageIndex < totalPages - 1 {
            withAnimation(.easeInOut(duration: 0.2)) {
                currentPageIndex += 1
                page.update(.new(index: currentPageIndex))
            }
        }
    }
    
    func onStartBtnAction() {
        
    }
    
    func onPageIndexChangeAction(_ newIndex: Int) {
        withAnimation(.easeInOut(duration: 0.2)) {
            currentPageIndex = newIndex
        }
    }
}
