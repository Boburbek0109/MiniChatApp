//
//  ChatListViewModel.swift
//  MiniChatApp
//
//  Created by Bobur Sobirjanov on 7/1/26.
//

import Foundation
import FirebaseFirestore

@Observable
final class ChatListViewModel {
    var chats: [ChatModel] = []
    var errorMessage: String?
     
    private let chatService = ChatService()
    private let profileService = ProfileService()
    private var listener: ListenerRegistration?
    
    var usersById: [String: AppUser] = [:]
    
    private func otherUserId(in chat: ChatModel, currentUserId: String) -> String? {
    return chat.participants.first { participantId in
        participantId != currentUserId
    }
}
    
    private func loadUser(for chats: [ChatModel], currentUserId: String) async {
    for chat in chats {
        if let otherUserId = otherUserId(in: chat, currentUserId: currentUserId) {
            if (usersById[otherUserId] == nil) {
                do {
                    let otherUser = try await profileService.fetchUser(uid: otherUserId)
                    usersById[otherUserId] = otherUser
                } catch {
                    errorMessage = error.localizedDescription
                }
            }
        }
    }
}
    
    func user(for chat: ChatModel, currentUserId: String) -> AppUser? {
        if let otherUserId = otherUserId(in: chat, currentUserId: currentUserId) {
            return usersById[otherUserId]
        }
        return nil
    }
    
    func startListening(currentUserId: String){
        stopListening()
        chats = []
        errorMessage = nil
        
        do {
            listener = try chatService.observeChats { [weak self] list in
                self?.chats = list
                Task { await self?.loadUser(for: list, currentUserId: currentUserId) }
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func stopListening(){
        listener?.remove()
        listener = nil
    }
    
    deinit{
        listener?.remove()
    }
}
