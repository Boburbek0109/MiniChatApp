//
//  ProfileView.swift
//  MiniChatApp
//
//  Created by Bobur Sobirjanov on 6/15/26.
//

import SwiftUI
import FirebaseCore

struct ProfileView: View {
    @Environment(ProfileViewModel.self) var profileVM
    
    @State private var isLargeHeader = false
    @State private var topInset: CGFloat = 0
    @State private var scrollPhase: ScrollPhase = .idle
    
    var onEditProfile: () -> Void
    
    var body: some View {
        ScrollView{
            LazyVStack{
                Text("Hello")
            }
            .padding(15)
            .padding(.bottom, 1000)
            .safeAreaInset(edge: .top, spacing: 0) {
                CustomHeader(isLargeHeader: $isLargeHeader, topInset: $topInset, onEditProfile: onEditProfile)
            }
        }
        
        .background(.fill.tertiary)
        .onScrollGeometryChange(for: CGFloat.self){
            $0.contentInsets.top
        } action: { oldValue, newValue in
            topInset = newValue
        }
        
        .onScrollGeometryChange(for: CGFloat.self){
            $0.contentOffset.y + $0.contentInsets.top
        } action: { oldValue, newValue in
            if scrollPhase == .interacting {
                withAnimation(.snappy(duration: 0.2, extraBounce: 0)) {
                    isLargeHeader = newValue < -10 || (isLargeHeader && newValue < 0)
                }
            }
        }
        .task {
            await profileVM.loadProfile()
        }
        .onChange(of: isLargeHeader, { oldValue, newValue in
            
        })
        .onScrollPhaseChange{ oldPhase, newPhase in
            scrollPhase = newPhase
        }
        
    }
}

