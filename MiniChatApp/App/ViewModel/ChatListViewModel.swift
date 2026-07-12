//
//  ChatListViewModel.swift
//  MiniChatApp
//
//  Created by Bobur Sobirjanov on 7/1/26.
//

import Foundation
import FirebaseFirestore

@MainActor
@Observable
final class ChatListViewModel {
    var chats: [ChatModel] = []
    var errorMessage: String?
    var isLoading = false
     
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
        
        let missingUserIds = Set(chats.compactMap { chat in
            otherUserId(in: chat, currentUserId: currentUserId)
        }.filter { usersById[$0] == nil })
        
        await withTaskGroup(of: (String, AppUser?).self) { group in
            for userId in missingUserIds {
                group.addTask{ [ profileService ] in
                    do {
                        let user = try await profileService.fetchUser(uid: userId)
                        return (userId, user)
                    } catch {
                        print("DEBUG: Failed to load user \(userId): \(error)")
                        return (userId, nil)
                    }
                }
            }
            
            for await (userId, user) in group {
                if let user {
                    usersById[userId] = user
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
        isLoading = true
        
        do {
            listener = try chatService.observeChats { [weak self] list in
                self?.chats = list
                self?.isLoading = false
                Task { await self?.loadUser(for: list, currentUserId: currentUserId) }
            } onError: { [weak self] error in
                self?.errorMessage = error.localizedDescription
                self?.isLoading = false
            }
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
        }
    }
    
    func stopListening(){
        listener?.remove()
        listener = nil
    }
}
