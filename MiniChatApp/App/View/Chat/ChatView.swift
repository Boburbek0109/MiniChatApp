//
//  ChatView.swift
//  MiniChatApp
//
//  Created by Bobur Sobirjanov on 6/28/26.
//

//import SwiftUI
//import PhotosUI
//
//struct ChatScreen: View {
//
//    let receiverId: String
//    let myUserId: String
//    let token: String
//
//    @Environment(ChatViewModel.self) private var chatVM
//    @Environment(ProfileViewModel.self) private var profileVM
//
//    @State private var text = ""
//
//    @State private var selectedItem: PhotosPickerItem?
//    
////    @StateObject private var onlineStore = OnlineUsersStore.shared
//
//    var body: some View {
//
//        ZStack {
//
//            LinearGradient(
//                colors: [
//                    Color(red: 2/255, green: 6/255, blue: 23/255),
//                    Color(red: 15/255, green: 23/255, blue: 42/255),
//                    Color(red: 17/255, green: 24/255, blue: 39/255)
//                ],
//                startPoint: .top,
//                endPoint: .bottom
//            )
//            .ignoresSafeArea()
//
//            VStack(spacing: 0) {
//
//                // HEADER
//
//                HStack(spacing: 14) {
//
//                    ZStack(alignment: .bottomTrailing) {
//
//                        if !chatVM.userImage.isEmpty {
//
//                            AsyncImage(
//                                url: URL(string: chatVM.userImage)
//                            ) { image in
//
//                                image
//                                    .resizable()
//                                    .scaledToFill()
//
//                            } placeholder: {
//
//                                ProgressView()
//                            }
//                            .frame(width: 52, height: 52)
//                            .clipShape(Circle())
//
//                        } else {
//
//                            Circle()
//                                .fill(
//                                    LinearGradient(
//                                        colors: [
//                                            .purple,
//                                            .pink
//                                        ],
//                                        startPoint: .topLeading,
//                                        endPoint: .bottomTrailing
//                                    )
//                                )
//                                .frame(width: 52, height: 52)
//                                .overlay {
//
//                                    Text(
//                                        String(
//                                            chatVM.username.first ?? "U"
//                                        )
//                                    )
//                                    .foregroundColor(.white)
//                                    .fontWeight(.bold)
//                                }
//                        }
//
//                        Circle()
//                            .fill(
//                                onlineStore.isOnline(receiverId)
//                                ? Color.green
//                                : Color.gray
//                            )
//                            .frame(width: 14, height: 14)
//                    }
//
//                    VStack(alignment: .leading) {
//
//                        Text(chatVM.username)
//                            .foregroundColor(.white)
//                            .font(.title3.bold())
//
//                        Text(
//                            onlineStore.isOnline(receiverId)
//                            ? "Online"
//                            : "Offline"
//                        )
//                        .foregroundColor(
//                            onlineStore.isOnline(receiverId)
//                            ? .green
//                            : .gray
//                        )
//                        .font(.caption)
//                    }
//
//                    Spacer()
//                }
//                .padding(.horizontal, 16)
//                .padding(.top, 16)
//                .padding(.bottom, 18)
//
//                Divider()
//                    .overlay(
//                        Color.white.opacity(0.08)
//                    )
//
//                // MESSAGES
//
//                if chatVM.isLoading {
//
//                    Spacer()
//
//                    ProgressView()
//                        .tint(.purple)
//
//                    Spacer()
//
//                } else {
//
//                    ScrollViewReader { proxy in
//
//                        ScrollView {
//
//                            LazyVStack(
//                                spacing: 12
//                            ) {
//
//                                ForEach(chatVM.messages) { message in
//
//                                    MessageRow(
//                                        message: message,
//                                        isMe: message.userId == myUserId
//                                    )
//                                    .id(message.id)
//                                }
//                            }
//                            .padding(.horizontal, 16)
//                            .padding(.vertical, 20)
//                        }
//                        .onChange(of: chatVM.messages.count) { _ in
//
//                            if let last = chatVM.messages.last {
//
//                                withAnimation {
//
//                                    proxy.scrollTo(
//                                        last.id,
//                                        anchor: .bottom
//                                    )
//                                }
//                            }
//                        }
//                    }
//                }
//
//                // INPUT
//
//                HStack(alignment: .center, spacing: 12) {
//
//                    HStack(spacing: 10) {
//
//                        TextField(
//                            "Type message...",
//                            text: $text
//                        )
//                        .foregroundColor(.white)
//
//                        PhotosPicker(
//                            selection: $selectedItem,
//                            matching: .images
//                        ) {
//
//                            Image(systemName: "photo")
//                                .foregroundColor(
//                                    .white.opacity(0.7)
//                                )
//                        }
//                    }
//                    .padding(.horizontal, 16)
//                    .frame(height: 58)
//                    .background(
//                        Color.white.opacity(0.08)
//                    )
//                    .clipShape(
//                        RoundedRectangle(
//                            cornerRadius: 30
//                        )
//                    )
//
//                    Button {
//
//                        if !text.trimmingCharacters(
//                            in: .whitespaces
//                        ).isEmpty {
//
//                            chatVM.sendMessage(
//                                receiverId: receiverId,
//                                text: text
//                            )
//
//                            text = ""
//                        }
//
//                    } label: {
//
//                        Image(systemName: "paperplane.fill")
//                            .foregroundColor(.white)
//                            .frame(width: 58, height: 58)
//                            .background(
//                                LinearGradient(
//                                    colors: [
//                                        .purple,
//                                        .pink
//                                    ],
//                                    startPoint: .topLeading,
//                                    endPoint: .bottomTrailing
//                                )
//                            )
//                            .clipShape(Circle())
//                    }
//                }
//                .padding(16)
//            }
//        }
//        .task {
//
//            await chatVM.loadMessages(
//                receiverId: receiverId
//            )
//
//            await chatVM.loadReceiverInfo(
//                receiverId: receiverId
//            )
//
//            chatVM.connect(token: token)
//        }
//        .onAppear {
//            chatVM.connect(token: token)
//        }
//        .onChange(of: selectedItem) { item in
//            guard let item else { return }
//
//            Task {
//                guard let data = try? await item.loadTransferable(type: Data.self),
//                      let uiImage = UIImage(data: data),
//                      let compressed = uiImage.jpegData(compressionQuality: 0.2)
//                else {
//                    print("❌ Image convert failed")
//                    return
//                }
//
//                let base64 = compressed.base64EncodedString()
//                let imageUrl = "data:image/jpeg;base64,\(base64)"
//
//                print("📷 Image size:", compressed.count)
//
//                chatVM.sendImage(
//                    receiverId: receiverId,
//                    imageUrl: imageUrl
//                )
//            }
//        }
//    }
//}
