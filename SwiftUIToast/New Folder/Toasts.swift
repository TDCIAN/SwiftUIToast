//
//  Toasts.swift
//  SwiftUIToast
//
//  Created by 김정민 on 10/17/24.
//

import SwiftUI

struct Toast: Identifiable {
    private(set) var id: String = UUID().uuidString
    var content: AnyView
    
    init(@ViewBuilder content: @escaping (String) -> some View) {
        // This ID can be used to remove tast from the context
        self.content = .init(content(id))
    }
    
    /// View Properties
    var offsetX: CGFloat = 0
    var isDeleting: Bool = false
}

extension View {
    @ViewBuilder
    // 2분 25초
    func interactiveToasts(_ toasts: Binding<[Toast]>) -> some View {
        self.frame(maxWidth: .infinity, maxHeight: .infinity)
            .overlay(alignment: .bottom) {
                ToastsView(toasts: toasts)
            }
    }
}

fileprivate struct ToastsView: View {
    @Binding var toasts: [Toast]
    
    /// View Properties
    @State private var isExpanded: Bool = false // The toast will get switched from ZStack to VStack when it's tapped, for that purpose, we can use this state property.
    
    var body: some View {
        ZStack(alignment: .bottom) {
            if self.isExpanded {
                Rectangle()
                    .fill(.ultraThinMaterial)
                    .ignoresSafeArea()
                    .onTapGesture {
                        self.isExpanded = false
                    }
            }
            
            // AnyLayout will seamlessly update its layout and items with animations
            let layout = self.isExpanded
            ? AnyLayout(VStackLayout(spacing:10)) // set spacing among toasts
            : AnyLayout(ZStackLayout())
            
            layout {
                ForEach(self.$toasts) { $toast in
                    
//                    let index = (self.toasts.firstIndex(where: { $0.id == toast.id }) ?? 0)
                    
                    // reverse the index to make it as a stacked cards
                    let index = (self.toasts.count - 1) - (self.toasts.firstIndex(where: { $0.id == toast.id }) ?? 0)
                    
                    toast.content
                        .offset(x: toast.offsetX)
                        .gesture(
                            DragGesture()
                                .onChanged { value in
                                    let xOffset = value.translation.width < 0
                                    ? value.translation.width
                                    : 0
                                    toast.offsetX = xOffset
                                }
                                .onEnded { value in
                                    let xOffset = value.translation.width + (value.velocity.width / 2)
                                    
                                    if -xOffset > 200 {
                                        /// Remove Toast
                                        /// Since the extension is a binding one, make sure you use the "$" symbol to access it.
                                        self.$toasts.delete(toast.id)
                                    } else {
                                        /// Reset Toasts to it's initial Position
                                        withAnimation {
                                            toast.offsetX = 0
                                        }
                                    }
                                }
                        )
                        .visualEffect { [isExpanded] emptyVisualEffect, geometryProxy in
                            emptyVisualEffect
                                .scaleEffect(
                                    isExpanded
                                    ? 1
                                    : self.scale(index), anchor: .bottom
                                )
                                .offset(
                                    y: isExpanded
                                    ? 0
                                    : self.offsetY(index)
                                )
                        }
                        .zIndex(toast.isDeleting ? 1000 : 0)
                        .frame(maxWidth: .infinity)
                        .transition(
                            .asymmetric(
                                insertion: .offset(y: 100),
                                removal: .move(edge: .leading)
                            )
                        )
                }
            }
            .onTapGesture {
                self.isExpanded.toggle()
            }
        }
        .animation(.bouncy, value: self.isExpanded)
        .padding(.bottom, 15)
        .onChange(of: self.toasts.isEmpty) { oldValue, newValue in
            if newValue {
                self.isExpanded = false
            }
        }
    }
    
    nonisolated func offsetY(_ index: Int) -> CGFloat {
        let offset = min(CGFloat(index) * 15, 30)
        
        return -offset
    }
    
    nonisolated func scale(_ index: Int) -> CGFloat {
        let scale = min(CGFloat(index) * 0.1, 1)
        
        return 1 - scale
    }
}

extension Binding<[Toast]> {
    /*
     This little extension will be useful to remove toasts based on there ID,
     and since I'm making changes to the binding value rather than the struct,
     the animation will be still active.
     (If you make changes to struct, then there will be no animations present.)
     */
    func delete(_ id: String) {
        if let toast = first(where: { $0.id == id }) {
            toast.wrappedValue.isDeleting = true
        }
        withAnimation(.bouncy) {
            self.wrappedValue.removeAll(where: { $0.id == id })
        }
    }
}

#Preview {
    ContentView()
}
