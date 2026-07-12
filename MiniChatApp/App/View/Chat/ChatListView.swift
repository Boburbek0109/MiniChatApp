//
//  ChatListView.swift
//  MiniChatApp
//
//  Created by Bobur Sobirjanov on 6/25/26.
//

import SwiftUI
import FirebaseCore
import FirebaseAuth

struct ChatListView: View {
    @State private var listVM = ChatListViewModel()
    @Environment(AuthViewModel.self) var authVM
    
    @State private var isheaderVisile = true
        
    var body: some View {
            
        ZStack(alignment: .top){
            if listVM.isLoading {
                ProgressView()
            } else if let errorMessage = listVM.errorMessage {
                ContentUnavailableView("Something went wrong", systemImage: "exclamationmark.triangle", description: Text(errorMessage))
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(.top, 70)
            }
            else if listVM.chats.isEmpty{
                ContentUnavailableView("No chats yet", systemImage: "message", description: Text("Start new chat with Searching"))
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(.top, 70)
            } else {
                ScrollView{
                    LazyVStack{
                        ForEach(listVM.chats) { chat in
                            if let currentUserId = authVM.user?.uid{
                                if let user = listVM.user(for: chat, currentUserId: currentUserId){
                                    ChatListRow(user: user, chat: chat)
                                    
                                }
                            }
                        }
                    }
                    .padding(.top, 70)
                }
                .onScrollGeometryChange(for: CGFloat.self) { geometry in
                    geometry.contentOffset.y + geometry.contentInsets.top
                } action: { oldValue, newValue in
                    let delta = newValue - oldValue
                    
                    guard abs(delta) > 2 else { return }
                    
                    if delta > 0, newValue > 20{
                        isheaderVisile = false
                    } else if delta < 0 {
                        isheaderVisile = true
                    }
                    
                }
            }
            
            ChatListHeader()
                .offset(y: isheaderVisile ?  0 : -80)
                .opacity(isheaderVisile ? 1 : 0)
                .animation(.easeOut(duration: 0.35), value: isheaderVisile)
        }
        .onAppear{
            guard let currentUserId = authVM.user?.uid else { return }
            listVM.startListening(currentUserId: currentUserId) }
        .onDisappear{ listVM.stopListening() }
    }
}


#Preview {
    if FirebaseApp.app() == nil {
        FirebaseApp.configure()
    }
    
    return ChatListView()
        .environment(ProfileViewModel())
        .environment(AuthViewModel())
}
