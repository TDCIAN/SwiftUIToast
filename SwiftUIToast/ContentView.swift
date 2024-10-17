//
//  ContentView.swift
//  SwiftUIToast
//
//  Created by 김정민 on 10/17/24.
//

import SwiftUI

struct ContentView: View {
    
    @State private var toasts: [Toast] = []
    
    var body: some View {
        NavigationStack {
            List {
                Text("Dummy List Row View")
            }
            .navigationTitle("Toast")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        self.showToast()
                    }, label: {
                        Text("Show")
                    })
                }
            }
        }
        .interactiveToasts(self.$toasts) // Place this modifier at the end of the view. If you're in sheet's/fullScreenCover, then place it inside of it as it's based on it's current context and not universal.
    }
    
    func showToast() {
        withAnimation(.bouncy) {
            let toast = Toast { id in
                ToastView(id)
            }
            
            self.toasts.append(toast)
        }
    }
    
    /// YOUR CUSTOM TOAST VIEW
    ///  This is just a simple toast view. Since the toast adapts the AnyView protocol, you can create whatever view
    ///  you need to be presented in the toast.
    ///  NOTE: Do not overweight the toast views.
    @ViewBuilder
    func ToastView(_ id: String) -> some View {
        VStack(alignment: .center) {
            HStack(spacing: 12) {
                Image(systemName: "square.and.arrow.up.fill")
                
                Text("Hello World!")
                    .font(.callout)
                
                Spacer(minLength: 0)
                
                Button(action: {
                    self.$toasts.delete(id)
                }, label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                })
            }
            .foregroundStyle(Color.primary)
            .padding(.vertical, 12)
            .padding(.leading, 15)
            .padding(.trailing, 10)
            .background {
                Capsule()
                    .fill(.background)
                    /// Shadows
                    .shadow(color: .black.opacity(0.06), radius: 3, x: -1, y: -3)
                    .shadow(color: .black.opacity(0.06), radius: 2, x: 1, y: 3)
            }
            .padding(.horizontal, 20)
        }

    }
}

#Preview {
    ContentView()
}
