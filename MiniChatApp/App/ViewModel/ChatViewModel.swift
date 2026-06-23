//
//  ChatViewModel.swift
//  MiniChatApp
//
//  Created by Bobur Sobirjanov on 6/21/26.
//

import Foundation

@Observable
final class ChatViewModel{
    var messages: [ChatMessageModel] = []
    
    var messageText = ""
    var errorMessage: String?
    var isSending = false
    
    private var chatService = ChatService()
    
    func sendMessage(receiverId: String) async {
        guard !isSending else { return }
        
        isSending = true
        errorMessage = nil
        defer { isSending = false }
        do {
            try await chatService.sendMessage(message: messageText, receiverId: receiverId)
            messageText = ""
        } catch {
            errorMessage = error.localizedDescription
        }
//         isSending = false
    }
}
