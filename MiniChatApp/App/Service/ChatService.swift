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
    
    private var chatCollection: CollectionReference{
        chatDB.collection("chats")
    }
    
    private func makeChatId(senderId: String, receiverId: String) -> String{
        [senderId, receiverId].sorted().joined(separator: "_")
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
        let chatRef = chatCollection.document(chatId)
        let messageRef = chatRef.collection("messages").document()
        
        let messageData: [String: Any] = [
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
            "updatedAt": FieldValue.serverTimestamp(),
            "unreadCounts.\(receiverId)": FieldValue.increment(Int64(1)),
            "unreadCounts.\(senderId)": 0
        ]
        
        let batch = chatDB.batch()
        
        batch.setData(chatData, forDocument: chatRef, merge: true)
        batch.setData(messageData, forDocument: messageRef)
        
        try await batch.commit()
    }
    
    func observeMessages(receiverId: String, onChange: @escaping ([ChatMessageModel]) -> Void, onError: @escaping (Error) -> Void ) throws -> ListenerRegistration {
        guard let currentUser = Auth.auth().currentUser else {
            throw ChatServiceError.notLoggedIn
        }
        
        let senderId = currentUser.uid
        let chatId = makeChatId(senderId: senderId, receiverId: receiverId)
        
        return chatCollection
            .document(chatId)
            .collection("messages")
            .order(by: "createdAt", descending: false)
            .addSnapshotListener { snapShot, error in
                
                if let error{
                    print("DEBUG: Error on observing messages: \(error.localizedDescription)")
                    onError(error)
                    return
                }
                
                guard let documents = snapShot?.documents else {
                    onChange([])
                    return
                }
                
                let messages = documents.compactMap { document in
                    do {
                       return try document.data(as: ChatMessageModel.self)
                    } catch {
                        print("DEBUG: Failed to decode message \(document.documentID): \(error)")
                        return nil
                    }
                }
                
                onChange(messages)
            }
    }
    
    func observeChats(onChange: @escaping ([ChatModel]) -> Void, onError: @escaping (Error) -> Void) throws -> ListenerRegistration {
        
        guard let currentUser = Auth.auth().currentUser else {
            throw ChatServiceError.notLoggedIn
        }
        
        return chatCollection
            .whereField("participants", arrayContains: currentUser.uid)
            .order(by: "updatedAt", descending: true)
            .addSnapshotListener { snapShot, error in
                if let error{
                    print("DEBUG: Error on observing chats: \(error.localizedDescription)")
                    onError(error)
                    return
                }
                
                let chats: [ChatModel] = snapShot?.documents.compactMap { document -> ChatModel? in
                    do {
                       return try document.data(as: ChatModel.self)
                    } catch {
                        print("DEBUG: Error on observing chats: \(document.documentID): \(error)")
                        return nil
                    }
                } ?? []
                
                onChange(chats)
            }
    }
    
    func markChatAsRead(receiverId: String ) async throws {
        guard let currentUser = Auth.auth().currentUser else {
            throw ChatServiceError.notLoggedIn
        }
        
        let senderId = currentUser.uid
        let chatId = makeChatId(senderId: senderId, receiverId: receiverId)
        let chatRef = chatCollection.document(chatId)
        
        try await chatRef.updateData([
            "unreadCounts.\(senderId)": 0
        ])
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
