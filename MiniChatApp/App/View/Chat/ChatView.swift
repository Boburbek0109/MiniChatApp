//
//  ChatView.swift
//  MiniChatApp
//
//  Created by Bobur Sobirjanov on 6/28/26.
//

import SwiftUI
import FirebaseCore

struct ChatView: View {
    @State private var chatVM = ChatViewModel()
    @State private var composerState = MessageComposerState()
    @State private var inputPanelHeight: CGFloat = 56

    let receiver: AppUser

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 2/255, green: 6/255, blue: 23/255),
                    Color(red: 15/255, green: 23/255, blue: 42/255),
                    Color(red: 17/255, green: 24/255, blue: 39/255)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {

                if chatVM.isLoadingMessages {
                    ProgressView("Loading messages...")
                        .tint(.purple)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if chatVM.messages.isEmpty {
                    ContentUnavailableView(
                        "No messages yet",
                        systemImage: "bubble.left.and.bubble.right",
                        description: Text("Send the first message")
                    )
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    ScrollViewReader { proxy in
                        ScrollView {
                            LazyVStack(spacing: 12) {
                                ForEach(chatVM.messages) { message in
                                    MessageRow(message: message)
                                        .id(message.id)
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.top, 20)
                        }
                        .scrollEdgeEffectHidden(true, for: .bottom)
                        .contentMargins(.bottom, inputPanelHeight + 4, for: .scrollContent)
                        .defaultScrollAnchor(.bottom, for: .sizeChanges)
                        .onChange(of: chatVM.messages.count, initial: true) {
                            if let lastMessageId = chatVM.messages.last?.id {
                                Task {
                                    await chatVM.markChatAsRead(receiverId: receiver.uid)
                                }
                                withAnimation {
                                    proxy.scrollTo(lastMessageId, anchor: .bottom)
                                }
                            }
                        }
                    }
                }
            }
        }
        .overlay(alignment: .bottom){
            VStack(spacing: 8){
                if let errorMessage = chatVM.errorMessage {
                    Text(errorMessage)
                        .font(.caption)
                        .foregroundStyle(.red)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)
                }
                
                HStack(alignment: .bottom, spacing: 12) {
                    TextField("Type message...", text: $composerState.text, axis: .vertical)
                        .lineLimit(1...5)
                        .foregroundStyle(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .frame(minHeight: 44)
                        .glassEffect(.regular, in: .rect(cornerRadius: 22))

                    Button {
                        Task {
                            let draftBeforeSending = composerState.text
                            await chatVM.sendMessage(text: composerState.trimmedText, receiverId: receiver.uid)

                            if chatVM.errorMessage == nil && composerState.text == draftBeforeSending {
                                composerState.clear()
                            }
                        }
                    } label: {
                        Group {
                            if chatVM.isSending {
                                ProgressView()
                                    .tint(.white)
                            } else {
                                Image(systemName: "paperplane.fill")
                                    .foregroundStyle(.white)
                            }
                        }
                        .frame(width: 44, height: 44)
                        .glassEffect(.regular, in: .circle)
                    }
                    .disabled(!composerState.canSend || chatVM.isSending)
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .padding(.bottom, 4)
            }
            .onGeometryChange(for: CGFloat.self) { geo in
                geo.size.height
            } action: { newHeight in
                inputPanelHeight = newHeight
            }

        }
        .environment(\.colorScheme, .dark)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar{
            ToolbarItem(placement: .principal) {
                HStack(spacing: 14) {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [.purple, .pink],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 32, height: 32)
                        .overlay {
                            Text(String(receiver.username.first ?? "U"))
                                .foregroundStyle(.white)
                                .fontWeight(.bold)
                        }
                        .overlay {
                            if let avatarURL = receiver.avatarURL,
                               let url = URL(string: avatarURL) {
                                AsyncImage(url: url) { image in
                                    image
                                        .resizable()
                                        .scaledToFill()
                                } placeholder: {
                                    Color.clear
                                }
                                .frame(width: 32, height: 32)
                                .clipShape(Circle())
                            }
                        }

                    Text(receiver.username)
                        .foregroundStyle(.white)
                        .font(.headline)
                }
                .padding(.horizontal, 16)
            }
        }
        .onAppear {
            guard ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] != "1" else { return }
            chatVM.startListening(receiverId: receiver.uid)
        }
        .onDisappear {
            chatVM.stopListening()
        }
    }
}

#Preview("Chat screen") {
    if FirebaseApp.app() == nil {
        FirebaseApp.configure()
    }

    return NavigationStack {
        ChatView(receiver: AppUser(
            uid: "preview-user",
            username: "Alex",
            email: "",
            bio: "",
            avatarURL: nil,
            birthDate: nil
        ))
        .allowsHitTesting(false)
    }
}
