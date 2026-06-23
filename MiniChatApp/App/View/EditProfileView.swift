//
//  EditProfileView.swift
//  MiniChatApp
//
//  Created by Bobur Sobirjanov on 6/15/26.
//

import SwiftUI
import PhotosUI

struct EditProfileView: View {
    @Environment(AuthViewModel.self) private var authVM
    @Environment(ProfileViewModel.self) private var profileVM
    
    @State private var selectedPhotoItem: PhotosPickerItem?
    
    var body: some View {
        @Bindable var profileVM = profileVM
        Form{
            Section("Photo"){
                HStack{
                    Spacer()
                    
                    if let selectedImageData = profileVM.selectedImageData,
                       let uiImage = UIImage(data: selectedImageData){
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 90, height: 90)
                            .clipShape(Circle())
                    } else if let photoURL = profileVM.avatarURL,
                              let url = URL(string: photoURL){
                        AsyncImage(url: url) { image in
                            image
                                .resizable()
                                .scaledToFill()
                        } placeholder: {
                            ProgressView()
                        }
                        .frame(width: 90, height: 90)
                        .clipShape(Circle())
                    } else {
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .frame(width: 90, height: 90)
                            .foregroundStyle(.gray)
                    }
                    Spacer()
                }
                
                PhotosPicker("Change Photo",
                             selection: $selectedPhotoItem,
                             matching: .images)
            }
            
            Section("Basic info"){
                TextField("Name", text: $profileVM.username)
                    .textInputAutocapitalization(.never)
            }
            
            Section("Birthday"){
                Toggle("Add birthday", isOn: $profileVM.hasBirthday)
                
                if profileVM.hasBirthday{
                    DatePicker("Birthday", selection: $profileVM.birthDate, displayedComponents: .date)
                }
            }
            
            Section("Bio"){
                TextEditor(text: $profileVM.bio)
                    .frame(minHeight: 100)
            }
            
            if let errorMessage = profileVM.errorMessage{
                Section{
                    Text(errorMessage)
                        .foregroundStyle(.red)
                }
            }
        }
        .navigationTitle("Edit Profile")
        .toolbar{
            ToolbarItem(placement: .topBarTrailing) {
                Button("Save"){
                    Task{
                        await profileVM.saveProfile()
                    }
                }
                .disabled(profileVM.isLoading)
            }
        }
        .task {
            await profileVM.loadProfile()
        }
        .onChange(of: selectedPhotoItem) {
            Task{
                await profileVM.loadSelectedImage(from: selectedPhotoItem)
            }
        }
        .alert("Profile updated", isPresented: $profileVM.isSaved){
            Button("Got it!") {}
        } message: {
            Text("Your profile was updated successfully")
                .foregroundStyle(.green)
        }
    }
}
