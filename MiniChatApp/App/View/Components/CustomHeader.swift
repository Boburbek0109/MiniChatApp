//
//  CustomHeader.swift
//  MiniChatApp
//
//  Created by Bobur Sobirjanov on 6/15/26.
//

import SwiftUI

struct CustomHeader: View {
    @Binding var isLargeHeader: Bool
    @Binding var topInset: CGFloat
    @Environment(\.colorScheme) private var colorScheme
    @Environment(AuthViewModel.self) private var authVM
    @Environment(ProfileViewModel.self) private var profileVM
    @State private var showsLogoutConfirmation = false
    
    var onEditProfile: () -> Void
    
    var body: some View {
        VStack(spacing: 12) {
            Rectangle()
                .foregroundStyle(.clear)
                .frame(width: 100, height: isLargeHeader ? 300 : 100)
                .clipShape(.circle)
            
            VStack(spacing: 20) {
                CustomNavigationBar()
                    .foregroundStyle(isLargeHeader ? .white : .primary)
                
                HeaderAction()
                    .foregroundStyle(isLargeHeader ? .white : .blue)
                    .geometryGroup()
            }
        }
        .padding(.horizontal, 15)
        .padding(.bottom, 15)
        .background(alignment: .top){
            GeometryReader {
                let size = $0.size
                let minY = $0.frame(in: .global).minY
                let topOffset = isLargeHeader ? minY : 0
                
                LogoView()
                    .frame(width: size.width, height: size.height + topOffset)
                    .clipShape(.rect(cornerRadius: isLargeHeader ? 0 : 50))
                    .offset(y: -topOffset)
            }
            .frame(width: isLargeHeader ? nil : 100, height: isLargeHeader ? nil : 100)
        }
        .padding(.top, 15)
    }
    /// PROFILE LOGO
    @ViewBuilder
    private func LogoView() -> some View{
        ZStack{
            Rectangle()
                .fill(.black)
            
            if let avatarURL = profileVM.avatarURL,
               let url = URL(string: avatarURL) {
                
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .scaledToFill()
                } placeholder: {
                    ProgressView()
                }
            } else {
                Image(systemName: "person.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundStyle(.white)
                    .frame(height: isLargeHeader ? 200 : 55)
                    .offset(y: isLargeHeader ? -topInset : 0)
            }
        }
    }
    
    /// NAVIGATION BAR
    @ViewBuilder
    private func CustomNavigationBar() -> some View{
        VStack(alignment: isLargeHeader ? .leading : .center, spacing: 6) {
            Text("Apple Developer")
                .font(.title)
                .fontWeight(.semibold)
            
            Text("133 Members, 13 online")
                .font(.callout)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: isLargeHeader ? .leading : .center)
        
        .visualEffect { contetn, proxy in
            let minY = proxy.frame(in: .scrollView(axis: .vertical)).minY
            let progress = max(min(minY / 50, 1), 0)
            
            return contetn
                .scaleEffect(0.7 + (0.3 * progress))
                .offset(y: minY < 0 ? -minY : 0)
        }
        .background(NavigationBarBackground())
        .zIndex(1000)
    }
    
    @ViewBuilder
    private func NavigationBarBackground() -> some View{
        GeometryReader{
            let minY = $0.frame(in: .scrollView(axis: .vertical)).minY
            let opacity: CGFloat = 1.0 - max(min(minY / 50, 1), 0)
            let tint: Color = colorScheme == .dark ? Color.black : Color.white
            
            ZStack{
                if #available(iOS 26, *){
                    Rectangle()
                        .fill(.clear)
                        .glassEffect(.clear.tint(tint.opacity(0.8)), in: .rect)
                        .mask {
                            LinearGradient(colors: [
                                .black,
                                .black,
                                .black,
                                .black,
                                .black.opacity(0.5),
                                .clear
                            ], startPoint: .top, endPoint: .bottom)
                        }
                } else {
                    Rectangle()
                        .fill(.clear)
                        .mask {
                            LinearGradient(colors: [
                                .black,
                                .black,
                                .black,
                                .black,
                                .black.opacity(0.5),
                                .clear
                            ], startPoint: .top, endPoint: .bottom)
                        }
                }
            }
            .padding(-20)
            .padding(.bottom, -40)
            .padding(.top, -topInset)
            .offset(y: -minY)
            .opacity(opacity)
        }
        .allowsHitTesting(false)
    }
    
    /// CUSTOM ACTION
    @ViewBuilder
    private func HeaderAction() -> some View{
        HStack{
            CustomActionButton(isLargeHeader: isLargeHeader, icon: "bell.fill", title: "Mute")
            CustomActionButton(isLargeHeader: isLargeHeader, icon: "magnifyingglass", title: "Search")
            CustomActionButton(isLargeHeader: isLargeHeader, icon: "rectangle.portrait.and.arrow.forward", title: "Log Out")
            { showsLogoutConfirmation = true }
            .confirmationDialog(
                "Are you sure you want to leave?",
                isPresented: $showsLogoutConfirmation) {
                Button("Log Out", role: .destructive) { authVM.signOut() }
                Button("Cancel", role: .cancel) {}
                }
            CustomActionButton(isLargeHeader: isLargeHeader, icon: "gearshape", title: "Edit Profile") { onEditProfile() }
        }
    }
}

