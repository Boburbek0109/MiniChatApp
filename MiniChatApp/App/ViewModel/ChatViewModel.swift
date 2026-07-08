//
//  ChatViewModel.swift
//  MiniChatApp
//
//  Created by Bobur Sobirjanov on 6/21/26.
//

import FirebaseFirestore

@Observable
final class ChatViewModel{
    var messages: [ChatMessageModel] = []
    
    var errorMessage: String?
    var isSending = false
    var isLoadingMessages = false
    
    private var chatService = ChatService()
    private var listener: ListenerRegistration?
    
    func sendMessage(text: String, receiverId: String) async {
        guard !isSending else { return }
        
        isSending = true
        errorMessage = nil
        defer { isSending = false }
        do {
            try await chatService.sendMessage(messages: text, receiverId: receiverId)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func startListening(receiverId: String) {
        stopListening()
        isLoadingMessages = true
        messages = []
        errorMessage = nil
        
        do {
            listener = try chatService.observeMessages(receiverId: receiverId) { [weak self] newMessage in
                self?.messages = newMessage
                self?.isLoadingMessages = false
            } onError: { [weak self] error in
                self?.errorMessage = error.localizedDescription
                self?.isLoadingMessages = false
            }
        } catch {
            errorMessage = error.localizedDescription
            isLoadingMessages = false
        }
    }
    
    func stopListening() {
        listener?.remove()
        listener = nil
    }
    
    deinit{
        listener?.remove()
    }
}
