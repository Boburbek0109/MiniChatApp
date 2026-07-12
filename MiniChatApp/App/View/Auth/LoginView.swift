//
//  LoginView.swift
//  MiniChatApp
//
//  Created by Bobur Sobirjanov on 6/13/26.
//

import SwiftUI

struct LoginView: View{
    
    @Environment(AuthViewModel.self) private var authVM
    
    @State private var email = ""
    @State private var password = ""
    @State private var showPassword = false
    @State private var resetPasswordMessage: String?
    
    private var isFormValid: Bool {
        email.contains("@") && password.count >= 8
    }
    
    var body: some View{
        
        ScrollView{
            VStack(spacing: 15) {
                
                Text("Log In")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                TextField("Email", text: $email, prompt: Text("Email").foregroundStyle(.blue))
                    .textContentType(.emailAddress)
                    .keyboardType(.emailAddress)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .padding(10)
                    .background(.gray.opacity(0.12))
                    .overlay {
                        RoundedRectangle(cornerRadius: 10).stroke(.blue, lineWidth: 2)
                    }
                
                HStack{
                    Group{
                        if showPassword{
                            TextField("Password", text: $password, prompt: Text("Password").foregroundStyle(.red))
                        }else {
                            SecureField("Password", text: $password, prompt: Text("Password").foregroundStyle(.red))
                        }
                    }
                    .textContentType(.password)
                    
                    Button{
                        showPassword.toggle()
                    } label: {
                        Image(systemName: showPassword ? "eye.slash" : "eye")
                            .foregroundStyle(.red)
                    }
                }
                .padding(10)
                .background(.gray.opacity(0.12))
                .overlay {
                    RoundedRectangle(cornerRadius: 10).stroke(.red, lineWidth: 2)
                }
                
                if let errorMessage = authVM.loginErrorMessage{
                    Text(errorMessage)
                        .font(.footnote)
                        .foregroundStyle(.red)
                        .multilineTextAlignment(.center)
                }
                
                if let resetPasswordMessage {
                    Text(resetPasswordMessage)
                        .font(.footnote)
                        .foregroundStyle(.green)
                }
                
                Button{
                    Task{
                        await authVM.login(email: email, password: password)
                    }
                } label: {
                    Text(authVM.isLoading ? "Logging in..." : "Log in")
                        .font(.title3)
                        .bold()
                        .foregroundStyle(.white)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(.blue, in: RoundedRectangle(cornerRadius: 12))
                .disabled(!isFormValid || authVM.isLoading)
                .opacity(isFormValid && !authVM.isLoading ? 1 : 0.5)
                
                Button("Enter your email first"){
                    Task {
                        resetPasswordMessage = nil
                        await authVM.resetPassword(email: email)
                        
                        if authVM.loginErrorMessage == nil {
                            resetPasswordMessage = "Password reset email sent"
                        }
                    }
                }
                .disabled(!email.contains("@") || authVM.isLoading)
                
                NavigationLink{
                    RegisterView()
                } label: {
                    HStack(spacing: 4){
                        Text("Don't have an account? ")
                        Text("Sign Up")
                            .underline()
                            .foregroundStyle(.blue)
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .containerRelativeFrame(.vertical, alignment: .center)
            .padding(.horizontal)
        }
    }
}

#Preview {
    LoginView()
        .environment(AuthViewModel())
}
