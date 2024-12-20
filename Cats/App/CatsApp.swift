import SwiftUI

@main
struct CatsApp: App {
    @State private var isShowingLaunchScreen = true
    @State private var showContent = false
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                NavigationView {
                    CatListView(showContent: $showContent)
                }
                .navigationViewStyle(.stack)
                
                if isShowingLaunchScreen {
                    LaunchScreen()
                        .transition(.opacity)
                        .zIndex(1)
                }
            }
            .preferredColorScheme(.light)
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    withAnimation(.easeInOut(duration: Constants.UI.animationDuration)) {
                        isShowingLaunchScreen = false
                        showContent = true
                    }
                }
            }
        }
    }
} 