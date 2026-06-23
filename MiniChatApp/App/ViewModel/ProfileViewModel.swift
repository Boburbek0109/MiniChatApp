//
//  ProfileViewModel.swift
//  MiniChatApp
//
//  Created by Bobur Sobirjanov on 6/15/26.
//

import SwiftUI
import PhotosUI
import UIKit


@Observable
final class ProfileViewModel{
    var profile: AppUser?
    
    var username = ""
    var bio = ""
    var avatarURL: String?
    var birthDate = Date()
    var hasBirthday = false
    
    var selectedImageData: Data?
    
    var isLoading = false
    var errorMessage: String?
    var isSaved = false
    
    private let profileService = ProfileService()
    
    func loadProfile() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let profile = try await profileService.fetchCurrentUserProfile()
            self.profile = profile
            
            username = profile.username
            bio = profile.bio
            avatarURL = profile.avatarURL
            
            if let birthDate = profile.birthDate{
                self.birthDate = birthDate
                self.hasBirthday = true
            } else {
                self.hasBirthday = false
            }
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
    
    func saveProfile() async {
        guard var profile else { return }
        isLoading = true
        isSaved = false
        errorMessage = nil
        
        do {
            var finalPhotoURL = avatarURL
            
            if let selectedImageData {
                finalPhotoURL = try await profileService.uploadProfileImage(selectedImageData)
            }
            
            profile.username = username.trimmingCharacters(in: .whitespacesAndNewlines)
            profile.bio = bio.trimmingCharacters(in: .whitespacesAndNewlines)
            profile.avatarURL = finalPhotoURL
            profile.birthDate = hasBirthday ? birthDate : nil
            
            try await profileService.updateProfile(profile)
            self.profile = profile
            self.avatarURL = finalPhotoURL
            self.selectedImageData = nil
            isSaved = true
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
    
    func loadSelectedImage(from selectedPhotoItem: PhotosPickerItem?) async{
        guard let selectedPhotoItem else { return }
        
        do{
            guard let originData = try await selectedPhotoItem.loadTransferable(type: Data.self),
                  let imageData = UIImage(data: originData),
                  let compressedData = imageData.jpegData(compressionQuality: 0.85)
            else { return }
            
            selectedImageData = compressedData
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}




