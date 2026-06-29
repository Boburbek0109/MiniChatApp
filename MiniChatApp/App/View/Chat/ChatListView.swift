//
//  ChatListView.swift
//  MiniChatApp
//
//  Created by Bobur Sobirjanov on 6/25/26.
//

import SwiftUI

struct ChatListView: View {
    @State private var isheaderVisile = true
        
    var body: some View {
            
        ZStack(alignment: .top){
            ScrollView{
                LazyVStack{
                    
                    ForEach(0..<20, id: \.self) { _ in
                        ChatListRow()
                    }
                }
                .padding(.top, 70)
            }
            .onScrollGeometryChange(for: CGFloat.self) { geometry in
                geometry.contentOffset.y + geometry.contentInsets.top
            } action: { oldValue, newValue in
                let delta = newValue - oldValue
                
                guard abs(delta) > 2 else { return }
                
                if delta > 0, newValue > 20{
                    isheaderVisile = false
                } else if delta < 0 {
                    isheaderVisile = true
                }
                
            }
            
            ChatListHeader()
                .offset(y: isheaderVisile ?  0 : -80)
                .opacity(isheaderVisile ? 1 : 0)
                .animation(.easeOut(duration: 0.35), value: isheaderVisile)
        }
    }
}


#Preview {
    ChatListView()
}
