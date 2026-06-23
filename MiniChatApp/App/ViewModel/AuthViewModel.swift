//
//  AuthViewModel.swift
//  MiniChatApp
//
//  Created by Bobur Sobirjanov on 6/13/26.
//

import FirebaseAuth
import FirebaseFirestore

@Observable
final class AuthViewModel{
    
    var isLoading = false
    var user: User? = Auth.auth().currentUser
    var appUser: AppUser?
    var signOutErrorMessage: String?
    var loginErrorMessage: String?
    var registerErrorMessage: String?
    
    
    func register(email: String, password: String) async {
        isLoading = true
        registerErrorMessage = nil
        defer { isLoading = false }
        
        do{
            
            let user = try await Auth.auth()
                .createUser(withEmail: email, password: password)
                .user
            
            let appUser = AppUser(
                uid: user.uid,
                username: "",
                email: user.email ?? email,
                bio: "",
                avatarURL: nil,
                birthDate: nil)
            
            try Firestore.firestore()
                .collection("users")
                .document(user.uid)
                .setData(from: appUser)
            
            self.user = user
            self.appUser = appUser
        } catch {
            
            registerErrorMessage = error.localizedDescription
        }
    }
    
    func login(email: String, password: String) async {
        isLoading = true
        loginErrorMessage = nil
        defer { isLoading = false }
        
        do{
            let user = try await Auth.auth()
                .signIn(withEmail: email, password: password)
                .user
            
            let appUser = try await Firestore.firestore()
                .collection("users")
                .document(user.uid)
                .getDocument(as: AppUser.self)
            
            self.user = user
            self.appUser = appUser
        } catch {
            loginErrorMessage = error.localizedDescription
        }
    }
    
    func signOut() {
        signOutErrorMessage = nil
        appUser = nil
        do {
            try Auth.auth().signOut()
            user = nil
        } catch {
            signOutErrorMessage = error.localizedDescription
        }
    }
    
    func resetPassword(email: String) async{
        loginErrorMessage = nil
        
        do{
            try await Auth.auth().sendPasswordReset(withEmail: email)
        } catch {
            loginErrorMessage = error.localizedDescription
        }
    }
}
