//
//  ProfileViewModel.swift
//  MiniChatApp
//
//  Created by Bobur Sobirjanov on 6/15/26.
//

import SwiftUI
import PhotosUI
import UIKit

@MainActor
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
    var isProfileMissing = false
    
    private let profileService = ProfileService()
    
    var hasProfileChanges: Bool{
        guard let profile else  { return false }
        
        return selectedImageData != nil ||
        username.trimmingCharacters(in: .whitespacesAndNewlines) != profile.username ||
        bio.trimmingCharacters(in: .whitespacesAndNewlines) != profile.bio ||
        (hasBirthday ? birthDate : nil) != profile.birthDate
    }
    
    func loadProfile() async {
        isLoading = true
        isProfileMissing = false
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
        } catch ProfileError.profileNotFound {
            isProfileMissing = true
            errorMessage = ProfileError.profileNotFound.localizedDescription
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
    
    func recoverMissingProfile() async {
        
        if isLoading == true {
            return
        }
        
        isLoading = true
        
        do{
            try await profileService.createMissingProfile()
            await loadProfile()
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
    
    func clearProfile() {
        
        hasBirthday = false
        isLoading = false
        isSaved = false
        birthDate = Date()
        profile = nil
        username = ""
        bio = ""
        avatarURL = nil
        selectedImageData = nil
        errorMessage = nil
        isProfileMissing = false
        
    }
}

