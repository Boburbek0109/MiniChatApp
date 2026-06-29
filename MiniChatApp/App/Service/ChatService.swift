//
//  ChatService.swift
//  MiniChatApp
//
//  Created by Bobur Sobirjanov on 6/20/26.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

final class ChatService{
    private var chatDB = Firestore.firestore()
    
    private var chatColletction: CollectionReference{
        chatDB.collection("chats")
    }
    
    func sendMessage(messages: String, receiverId: String) async throws {
        guard let currentUser = Auth.auth().currentUser else {
            throw ChatServiceError.notLoggedIn
        }

        let senderId = currentUser.uid
        
        let messageText = messages.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !messageText.isEmpty else {
            throw ChatServiceError.emptyMessage
        }
        
        let chatId = makeChatId(senderId: senderId, receiverId: receiverId)
        let chatRef = chatColletction.document(chatId)
        let messageRef = chatRef.collection("messages").document()
        
        let messageData: [String: Any] = [
            "id": messageRef.documentID,
            "chatId": chatId,
            "senderId": senderId,
            "receiverId": receiverId,
            "senderEmail": currentUser.email ?? "",
            "messages": messageText,
            "createdAt": FieldValue.serverTimestamp()
        ]
        
        let chatData: [String: Any] = [
            "id": chatId,
            "participants": [senderId, receiverId],
            "lastMessage": messageText,
            "lastSenderId": senderId,
            "updatedAt": FieldValue.serverTimestamp()
        ]
        
        let batch = chatDB.batch()
        
        batch.setData(chatData, forDocument: chatRef, merge: true)
        batch.setData(messageData, forDocument: messageRef)
        
        try await batch.commit()
    }
    
    func observeMessages(receiverId: String, onChange: @escaping ([ChatMessageModel]) ->Void) -> ListenerRegistration {
        
    }
    
    private func makeChatId(senderId: String, receiverId: String) -> String{
        [senderId, receiverId].sorted().joined(separator: "_")
    }
}


enum ChatServiceError: LocalizedError{
    case notLoggedIn
    case emptyMessage
    
    var errorDescription: String? {
        switch self {
        case .notLoggedIn:
            return "User is not logged in"
        case .emptyMessage:
            return "Message is empty"
        }
    }
}
