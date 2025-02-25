////
////  OnBoardingViewModel.swift
////  Flow Wallet
////
////  Created by Selina on 1/6/2023.
////
//
//import Combine
//import SwiftUI
//import SwiftUIPager
//
//// MARK: - OnBoardingViewModel.PageType
//
//extension OnBoardingViewModel {
//    enum PageType: String, CaseIterable {
//        case nft
//        case token
////        case domain
//        case site
//
//        // MARK: Internal
//
//        /// Basically only used in the text color of skip button
//        var needLightContent: Bool {
//            switch self {
////            case .domain:
////                return true
//            default:
//                return false
//            }
//        }
//
//        var bgColors: [Color] {
//            switch self {
//            case .nft:
//                return [Color(hex: "#d7d7e5"), Color(hex: "#695ddb")]
//            case .token:
//                return [Color(hex: "#bcdefa"), Color(hex: "#306ad6")]
////            case .domain:
////                return [Color(hex: "#606060"), Color.black]
//            case .site:
//                return [Color(hex: "#fde782"), Color(hex: "#20c477")]
//            }
//        }
//
//        var imageName: String {
//            "onboarding-img-\(rawValue)"
//        }
//
//        var title: String {
//            "onboarding_title_\(rawValue)".localized
//        }
//    }
//}
//
//// MARK: - OnBoardingViewModel
//
//class OnBoardingViewModel: ObservableObject {
//    @Published
//    var currentPageIndex: Int = 0
//    @Published
//    var page: Page = .first()
//
//    var totalPages: Int {
//        PageType.count
//    }
//
//    var currentPageType: PageType {
//        PageType.allCases[currentPageIndex]
//    }
//
//    var isLastPage: Bool {
//        currentPageIndex == totalPages - 1
//    }
//
//    static func installPage() -> [OnBoardingViewModel.PageType] {
//        let pages = [
//            OnBoardingViewModel.PageType.nft,
//            OnBoardingViewModel.PageType.token,
//            OnBoardingViewModel.PageType.site,
//        ]
//        return pages
//    }
//
//    func onSkipBtnAction() {
//        onStartBtnAction()
//    }
//
//    func onNextBtnAction() {
//        if currentPageIndex < totalPages - 1 {
//            withAnimation(.easeInOut(duration: 0.2)) {
//                currentPageIndex += 1
//                page.update(.new(index: currentPageIndex))
//            }
//        }
//    }
//
//    func onStartBtnAction() {
//        Router.coordinator.showRootView()
//    }
//
//    func onPageIndexChangeAction(_ newIndex: Int) {
//        withAnimation(.easeInOut(duration: 0.2)) {
//            currentPageIndex = newIndex
//        }
//    }
//}
