//
//  OnBoardingView.swift
//  Lilico
//
//  Created by Selina on 1/6/2023.
//

import SwiftUI
import Combine
import SwiftUIPager

struct OnBoardingView: View {
    @StateObject private var vm = OnBoardingViewModel()
    
    var body: some View {
        VStack {
            headerContainer
            bodyContainer
            bottomContainer
        }
        .backgroundFill {
            ZStack {
                ForEach(enumerating: OnBoardingViewModel.PageType.allCases, id: \.self) { index, type in
                    LinearGradient(colors: type.bgColors, startPoint: .top, endPoint: .bottom)
                        .opacity(vm.currentPageIndex >= index ? 1 : 0)
                }
            }
        }
    }
}

// MARK: - top bottom view
extension OnBoardingView {
    var headerContainer: some View {
        HStack {
            Spacer()
            skipBtn
        }
        .frame(height: 63)
        .padding(.horizontal, 24)
    }
    
    var skipBtn: some View {
        Button {
            vm.onSkipBtnAction()
        } label: {
            Text("skip".localized)
                .font(.inter(size: 14, weight: .medium))
                .foregroundColor(vm.currentPageType.needLightContent ? .white : Color(hex: "#333333"))
                .padding(.horizontal, 12)
                .frame(height: 24)
                .background(Color.white.opacity(0.24))
                .shadow(color: Color(hex: "#000000", alpha: 0.08), radius: 16, x: 0, y: 4)
                .cornerRadius(14)
        }
        .transition(.opacity)
    }
    
    var bottomContainer: some View {
        HStack {
            OnBoardingView.PageControl(numberOfPages: OnBoardingViewModel.PageType.count, currentPage: $vm.currentPageIndex)
            Spacer()
            
            if vm.isLastPage {
                startBtn
                    .transition(.opacity)
            } else {
                nextBtn
            }
        }
        .frame(height: 63)
        .padding(.horizontal, 24)
    }
    
    var nextBtn: some View {
        Button {
            vm.onNextBtnAction()
        } label: {
            ZStack {
                Image("onboarding-arrow-right")
            }
            .frame(width: 50, height: 50)
            .background(Circle().strokeBorder(.white, lineWidth: 1))
        }
    }
    
    var startBtn: some View {
        Button {
            vm.onStartBtnAction()
        } label: {
            HStack(spacing: 24) {
                Text("start".localized)
                    .font(.montserrat(size: 20, weight: .regular))
                    .foregroundColor(.white)
                Image("onboarding-arrow-right")
            }
            .padding(.horizontal, 16)
            .frame(height: 50)
            .background(RoundedRectangle(cornerRadius: 26).strokeBorder(.white, lineWidth: 1))
        }
    }
}

// MARK: - body view
extension OnBoardingView {
    var bodyContainer: some View {
        GeometryReader { geoProxy in
            Pager(page: vm.page, data: OnBoardingViewModel.PageType.allCases, id: \.self) { type in
                createPageView(type, size: geoProxy.size)
            }
            .bounces(false)
            .onPageWillChange({ willIndex in
                vm.onPageIndexChangeAction(willIndex)
            })
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
    
    private func createPageView(_ type: OnBoardingViewModel.PageType, size: CGSize) -> some View {
        VStack(spacing: 0) {
            Image(type.imageName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(maxWidth: .infinity)
                .padding(.bottom, 40)
            
            Text(type.title)
                .font(.montserrat(size: 36, weight: .semibold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
                .multilineTextAlignment(.leading)
                .padding(.bottom, 20)
            
            Text(type.desc)
                .font(.inter(size: 14, weight: .medium))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
                .multilineTextAlignment(.leading)
            
            Spacer()
        }
        .padding(.horizontal, 24)
        .frame(width: size.width, height: size.height)
        .contentShape(Rectangle())
    }
}

// MARK: - components
extension OnBoardingView {
    struct PageControl: View {
        @State var numberOfPages: Int
        @Binding var currentPage: Int
        
        var body: some View {
            HStack(spacing: 12) {
                ForEach(0..<numberOfPages, id: \.self) { index in
                    Circle()
                        .frame(width: 8, height: 8)
                        .foregroundColor(currentPage == index ? Color(hex: "#579AF2") : Color.white)
                }
            }
        }
    }
}
