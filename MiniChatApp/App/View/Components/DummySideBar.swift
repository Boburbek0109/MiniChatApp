//
//  DummySideBar.swift
//  MiniChatApp
//
//  Created by Bobur Sobirjanov on 6/21/26.
//

import SwiftUI

struct DummySideBar: View {
    @Environment(AuthViewModel.self) private var authVM
    
    var onSettings: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Circle()
                .fill(.fill)
                .frame(width: 60, height: 60)
                .padding(.bottom, 10)
            
            Text(authVM.appUser?.username ?? "No username")
                .font(.title3)
                .fontWeight(.semibold)
            
            Text(authVM.appUser?.email ?? "")
                .foregroundStyle(.gray)
            
            //            HStack(spacing: 10) {
            //                Text("876 Following")
            //
            //                Text("123 Followers")
            //            }
            //            .font(.callout)
            //            .fontWeight(.medium)
            
            Button{
               onSettings()
            } label: {
                Label("Go to Settings", systemImage: "gearshape")
            }
            .padding(.top, 15)
            
            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(15)
    }
}
            
