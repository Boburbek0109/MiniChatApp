//
//  UserSearchView.swift
//  MiniChatApp
//
//  Created by Bobur Sobirjanov on 7/7/26.
//

import SwiftUI

struct UserSearchView: View {
    @State private var searchVM = UserSearchViewModel()
    
    var body: some View {
        
        VStack(spacing: 12){
            
            Text("Search")
                .font(.largeTitle.bold())
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
            
            HStack{
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.secondary)
                
                TextField("Search users", text: $searchVM.searchText)
                
                Button{ searchVM.searchText = "" } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 22, weight: .bold))
                }
                .frame(width: 28, height: 28)
                .foregroundStyle(.secondary)
                .opacity(searchVM.searchText.isEmpty ? 0 : 1)
                .scaleEffect(searchVM.searchText.isEmpty ? 0.7 : 1)
                .disabled(searchVM.searchText.isEmpty)
                .animation(.spring(response: 0.25, dampingFraction: 0.8), value: searchVM.searchText.isEmpty)
                
            }
            .padding(.horizontal, 16)
            .frame(height: 52)
            .background{
                RoundedRectangle(cornerRadius: 20)
                    .fill(.ultraThinMaterial)
                    .shadow(color: .black.opacity(0.12), radius: 12, x: 0, y: 6)
            }
            .overlay{
                RoundedRectangle(cornerRadius: 20)
                    .stroke(.white.opacity(0.35), lineWidth: 1)
            }
            .padding(.horizontal)
            
            
            content
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        
        .task {
            await searchVM.loadUsers()
        }
        
        
    }
    
    @ViewBuilder
    private var content: some View {
        if searchVM.isLoading {
            ProgressView()
        } else if let errorMessage = searchVM.errorMessage {
            Text(errorMessage)
                .foregroundStyle(.red)
        } else if searchVM.filteredUsers.isEmpty {
            ContentUnavailableView.search(text: searchVM.searchText)
            
        } else {
            userList
        }
    }
    
    private var userList: some View {
        List(searchVM.filteredUsers) { user in
            NavigationLink {
                MessageView(receiver: user)
            } label: {
                UserSearchRow(user: user)
            }
        }
        .listStyle(.plain)
    }
}



#Preview {
    UserSearchView()
}


