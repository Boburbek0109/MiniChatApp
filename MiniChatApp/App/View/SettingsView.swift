//
//  SettingsView.swift
//  MiniChatApp
//
//  Created by Bobur Sobirjanov on 6/15/26.
//

import SwiftUI

struct SettingsView: View {
    @AppStorage("appTextSize") private var appTextSize: AppTextSize = .medium
    @AppStorage("appTheme") private var appTheme: AppTheme = .system
    
    @Environment(AuthViewModel.self) private var authVM
    @State private var showsLogoutAlert = false
    @State private var showDeleteAlert = false
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        
        Form{
            Section("Text Size"){
                Picker("Text Size", selection: $appTextSize){
                    ForEach(AppTextSize.allCases){ size in
                        Text(size.title)
                            .tag(size)
                    }
                }
            }
            
            Section("Appereance") {
                Picker("Theme", selection: $appTheme) {
                    ForEach(AppTheme.allCases) { theme in
                        Text(theme.title)
                            .tag(theme)
                    }
                }
            }
            
            Section{
                HStack(spacing: 12) {
                    Button("Log Out"){ showsLogoutAlert = true }
                        .confirmationDialog("Are you sure you want to leave?", isPresented: $showsLogoutAlert) {
                                Button("Log Out", role: .destructive) { authVM.signOut() }
                                Button("Cancel", role: .cancel) {}
                            }
                    
                    Text("|")
                        .foregroundStyle(.secondary)
                    
                    Button("Delete Account"){ showDeleteAlert = true }
                        .alert("U cant delete this:(", isPresented: $showDeleteAlert){
                            Button("Back to Home", role: .destructive) { dismiss() }
                        } message: {
                            Text("Deleting function is not ready yet!")
                        }
                    
                    
                }
                .buttonStyle(.borderless)
                .font(.footnote)
                .frame(maxWidth: .infinity, alignment: .center)
            }
            .listRowBackground(Color.clear)
        }
        .navigationTitle("Setting")
        
    }
}


#Preview {
    SettingsView()
        .environment(AuthViewModel())
}
