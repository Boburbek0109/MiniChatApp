//
//  MessageView.swift
//  MiniChatApp
//
//  Created by Bobur Sobirjanov on 6/23/26.
//

import SwiftUI

struct MessageView: View {
    @Environment(ChatViewModel.self) private var chatVM
    @State private var messageText = ""
    
    let receiver: AppUser
    
    var body: some View {
        VStack {
            if chatVM.isLoadingMessages{
                ProgressView("Loading messages...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if chatVM.messages.isEmpty{
                ContentUnavailableView("No messages yet", systemImage: "bubble.left.and.bubble.right", description: Text("Send the first message"))
            } else {
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(chatVM.messages) { message in
                                MessageRow(message: message)
                                    .id(message.id)
                            }
                        }
                        .padding()
                    }
                    .onChange(of: chatVM.messages.count) {
                        if let lastMessageId = chatVM.messages.last?.id {
                            withAnimation {
                                proxy.scrollTo(lastMessageId, anchor: .bottom)
                            }
                        }
                    }
                }
            }
            
            if let errorMessage = chatVM.errorMessage{
                Text(errorMessage)
                    .font(.caption)
                    .foregroundStyle(.red)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
            }
            
            HStack {
                TextField("Type a message...", text: $messageText)
                    .textFieldStyle(.roundedBorder)
                    .frame(minHeight: 30)
                
                Button {
                    Task{
                        await chatVM.sendMessage(text: messageText, receiverId: receiver.uid)
                        
                        if chatVM.errorMessage == nil{
                            messageText = ""
                        }
                    }
                } label: {
                    if chatVM.isSending{
                        ProgressView()
                    } else {
                        Image(systemName: "paperplane.fill")
                            .foregroundColor(.blue)
                            .font(.system(size: 22))
                    }
                }
                .disabled(messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || chatVM.isSending)
            }
            .padding()
            .background(.ultraThinMaterial)
        }
        .navigationTitle(receiver.username)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            chatVM.startListening(receiverId: receiver.uid)
        }
        .onDisappear {
            chatVM.stopListening()
        }
    }
}
