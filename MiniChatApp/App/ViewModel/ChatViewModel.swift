//
//  ChatViewModel.swift
//  MiniChatApp
//
//  Created by Bobur Sobirjanov on 6/21/26.
//

import Foundation
import FirebaseFirestore

@MainActor
@Observable
final class ChatViewModel{
    var messages: [ChatMessageModel] = []
    
    var errorMessage: String?
    var isSending = false
    var isLoadingMessages = false
    var isListening = false
    
    private var chatService = ChatService()
    private var listener: ListenerRegistration?
    
    func sendMessage(text: String, receiverId: String) async {
        guard !isSending else { return }
        
        isSending = true
        errorMessage = nil
        defer { isSending = false }
        do {
            try await chatService.sendMessage(messages: text, receiverId: receiverId)
            if isListening == false {
                startListening(receiverId: receiverId)
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func markChatAsRead(receiverId: String) async {
        
        do {
            try await chatService.markChatAsRead(receiverId: receiverId)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func startListening(receiverId: String) {
        stopListening()
        isLoadingMessages = true
        messages = []
        errorMessage = nil
        isListening = true
        
        do {
            listener = try chatService.observeMessages(receiverId: receiverId) { [weak self] newMessage in
                self?.messages = newMessage
                self?.isLoadingMessages = false
            } onError: { [weak self] error in
                self?.errorMessage = error.localizedDescription
                self?.isLoadingMessages = false
                self?.isListening = false
            }
        } catch {
            errorMessage = error.localizedDescription
            isLoadingMessages = false
            isListening = false
        }
    }
    
    func stopListening() {
        listener?.remove()
        listener = nil
        isListening = false
    }
    
}
