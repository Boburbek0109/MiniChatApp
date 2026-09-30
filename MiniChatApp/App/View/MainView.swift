//
//  MainView.swift
//  MiniChatApp
//
//  Created by Bobur Sobirjanov on 6/13/26.
//

import SwiftUI
import FirebaseCore

enum AppRoute: Hashable{
    case settings
    case editProfile
}

struct MainView: View{
    @Environment(AuthViewModel.self) private var authVM
    @Environment(ProfileViewModel.self) private var profileVM
    
    @State private var activeTab = 0
    @State private var navigationPath: NavigationPath = .init()
    @State private var isOpen = false
    
    var body: some View{
        
        let isMenuEnable = navigationPath.isEmpty
        
        CustomSideMenu(isEnabeld: isMenuEnable, isOpen: $isOpen) { _ in
            DummySideBar{
                isOpen = false
                navigationPath.append(AppRoute.settings)}
        } contetn: { _ in
            NavigationStack(path: $navigationPath){
                MainTabView(
                    activeTab: $activeTab,
                    onEditProfile: { navigationPath.append(AppRoute.editProfile) }
                )
                .toolbarVisibility(.hidden, for: .navigationBar)
                .navigationDestination(for: AppRoute.self) { route in
                    switch route{
                    case .settings:
                        SettingsView()
                        
                    case .editProfile:
                        EditProfileView()
                    }
                }
            }
        }
    }
}

#Preview {
    if FirebaseApp.app() == nil {
        FirebaseApp.configure()
    }
    return MainView()
        .environment(AuthViewModel())
        .environment(ProfileViewModel())
}
