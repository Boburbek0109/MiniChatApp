//
//  MainTabView.swift
//  MiniChatApp
//
//  Created by Bobur Sobirjanov on 6/13/26.
//

import SwiftUI

struct MainTabView: View{
    @Binding var activeTab: Int
    var onEditProfile: () -> Void
    
    var body: some View{
        TabView(selection: $activeTab){
            Tab.init("Home", systemImage: "house", value: 0){
                ChatListView()
            }
            
            Tab.init("Search", systemImage: "magnifyingglass", value: 1){
                
            }
            
            Tab.init("Notification", systemImage: "bell", value: 2){
                
            }
            
            Tab.init("Profile", systemImage: "person", value: 3){
                ProfileView(onEditProfile: onEditProfile)
            }
        }
    }
}
