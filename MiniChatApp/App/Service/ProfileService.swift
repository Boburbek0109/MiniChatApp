//
//  ProfileService.swift
//  MiniChatApp
//
//  Created by Bobur Sobirjanov on 6/15/26.
//

import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

final class ProfileService {
    private let database = Firestore.firestore()
    private let storage = Storage.storage()

    private var usersCollection: CollectionReference {
        database.collection("users")
    }
    
    private func privateProfileRef(uid: String) -> DocumentReference {
        return usersCollection
            .document(uid)
            .collection("private")
            .document("profile")
        
    }

    func fetchCurrentUserProfile() async throws -> AppUser {
        guard let user = Auth.auth().currentUser else {
            throw ProfileError.notLoggedIn
        }
        let snapshot = try await usersCollection.document(user.uid).getDocument()
        guard snapshot.exists else{
            throw ProfileError.profileNotFound
        }
        
        if snapshot.data()?["email"] != nil{
            return try snapshot.data(as: AppUser.self)
        }
        
        let publicProfile = try snapshot.data(as: PublicProfile.self)
        let privateProfile = try await fetchPrivateProfile()
        
        guard let email = user.email else{
            throw ProfileError.emailUnavailable
        }
        
        return AppUser(
            uid: user.uid,
            username: publicProfile.username,
            email: email,
            bio: publicProfile.bio,
            avatarURL: publicProfile.avatarURL,
            birthDate: privateProfile.birthDate)
    }

    func updateProfile(_ profile: AppUser) async throws {
        guard let uid = Auth.auth().currentUser?.uid else { throw ProfileError.notLoggedIn }
        
        var privateProfile = try await fetchPrivateProfile()
        privateProfile.birthDate = profile.birthDate
        
        var publicProfile = PublicProfile.init(uid: uid, username: profile.username, bio: profile.bio, avatarURL: profile.avatarURL)
        
        if privateProfile.isEmailPublic {
            publicProfile.visibleEmail = Auth.auth().currentUser?.email
        }
        
        if privateProfile.isBirthdayPublic {
            publicProfile.visibleBirthDate = privateProfile.birthDate
        }

        try await createProfiles(publicProfile: publicProfile, privateProfile: privateProfile)
    }

    func uploadProfileImage(_ imageData: Data) async throws -> String {
        guard let uid = Auth.auth().currentUser?.uid else {
            throw ProfileError.notLoggedIn
        }

        let ref = storage.reference()
            .child("profile_images")
            .child("\(uid).jpg")

        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"

        _ = try await ref.putDataAsync(imageData, metadata: metadata)

        let url = try await ref.downloadURL()
        return url.absoluteString
    }

    func updateAuthDisplayNameAndPhoto(name: String, photoURL: String?) async throws {
        guard let user = Auth.auth().currentUser else {
            throw ProfileError.notLoggedIn
        }

        let request = user.createProfileChangeRequest()
        request.displayName = name

        if let photoURL, let url = URL(string: photoURL) {
            request.photoURL = url
        }

        try await request.commitChanges()
    }

    func sendEmailChangeVerification(to newEmail: String) async throws {
        guard let user = Auth.auth().currentUser else {
            throw ProfileError.notLoggedIn
        }

        try await user.sendEmailVerification(beforeUpdatingEmail: newEmail)
    }
    
    func fetchUser(uid: String) async throws -> AppUser {
        let snapshot = try await usersCollection.document(uid).getDocument()
        let publicProfile = try snapshot.data(as: PublicProfile.self)
        
        return AppUser(
            uid: uid,
            username: publicProfile.username,
            email: publicProfile.visibleEmail ?? "",
            bio: publicProfile.bio,
            avatarURL: publicProfile.avatarURL,
            birthDate: publicProfile.visibleBirthDate)
    }
    
    func fetchUsers(uid: String) async throws -> [AppUser] {
        
        let snapshot = try await usersCollection
            .whereField("uid", isNotEqualTo: uid)
            .getDocuments()
        return try snapshot.documents.map { document in
            let publicProfile = try document.data(as: PublicProfile.self)
            
            return AppUser(
                uid: publicProfile.uid,
                username: publicProfile.username,
                email: publicProfile.visibleEmail ?? "",
                bio: publicProfile.bio,
                avatarURL: publicProfile.avatarURL,
                birthDate: publicProfile.visibleBirthDate)
        }
    }
    
    func createMissingProfile() async throws {
        guard let user = Auth.auth().currentUser else {
            throw ProfileError.notLoggedIn
        }
        
        guard let email = user.email else {
            throw ProfileError.emailUnavailable
        }
        
        let newProfile = AppUser(
            uid: user.uid,
            username: "",
            email: email,
            bio: "",
            avatarURL: nil,
            birthDate: nil)
        
        let profileData = try Firestore.Encoder().encode(newProfile)
        let profileRef = usersCollection.document(user.uid)
        
        _ = try await database.runTransaction{ transaction, errorPointer in
            do {
                let snapshot = try transaction.getDocument(profileRef)
                
                if !snapshot.exists {
                    transaction.setData(profileData, forDocument: profileRef)
                }
            } catch {
                errorPointer?.pointee = error as NSError
            }
            return nil
        }
    }
    
    func fetchPrivateProfile() async throws -> PrivateProfile {
        
        guard let user = Auth.auth().currentUser else {
            throw ProfileError.notLoggedIn
        }
        
        let profileRef = privateProfileRef(uid: user.uid)
        let snapshot = try await  profileRef.getDocument()
        
        if snapshot.exists == false {
            return PrivateProfile(birthDate: nil)
        }
        
        return try snapshot.data(as: PrivateProfile.self)
    }
    
    func savePrivateProfile(profile: PrivateProfile) async throws {
        
        guard let uid = Auth.auth().currentUser?.uid else {
            throw ProfileError.notLoggedIn
        }
        
        let currentProfile = try await fetchCurrentUserProfile()
        var publicProfile = PublicProfile.init(uid: uid, username: currentProfile.username, bio: currentProfile.bio, avatarURL: currentProfile.avatarURL)
        
        if profile.isEmailPublic {
            publicProfile.visibleEmail = Auth.auth().currentUser?.email
        }
        
        if profile.isBirthdayPublic{
            publicProfile.visibleBirthDate = currentProfile.birthDate
        }
        
        var privateProfile = profile
        privateProfile.birthDate = currentProfile.birthDate
        try await createProfiles(publicProfile: publicProfile, privateProfile: privateProfile)
    }
    
    func createProfiles(publicProfile: PublicProfile, privateProfile: PrivateProfile) async throws {
        
        guard let uid = Auth.auth().currentUser?.uid else {
            throw ProfileError.notLoggedIn
        }
        let privateData = try Firestore.Encoder().encode(privateProfile)
        let privateRef = privateProfileRef(uid: uid)
        
        let publicData = try Firestore.Encoder().encode(publicProfile)
        let publicRef = usersCollection.document(uid)
        try await database.batch().setData(privateData, forDocument: privateRef).setData(publicData, forDocument: publicRef).commit()
        
    }
}


enum ProfileError: LocalizedError {
    case notLoggedIn
    case profileNotFound
    case emailUnavailable
    
    var errorDescription: String? {
        switch self {
        case .notLoggedIn:
            return "User is not logged in"
            
        case .profileNotFound:
            return "Profile not found"
            
        case .emailUnavailable:
            return "Email address is unavailable for this account"
        }
    }
}
