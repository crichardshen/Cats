import SwiftUI

@main
struct CatsApp: App {
    @State private var isShowingLaunchScreen = true
    
    var body: some Scene {
        WindowGroup {
            NavigationView {
                ZStack {
                    CatListView()
                    
                    if isShowingLaunchScreen {
                        LaunchScreen()
                            .transition(.opacity)
                            .zIndex(1)
                    }
                }
                .navigationViewStyle(.stack)
            }
            .preferredColorScheme(.light)
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    withAnimation(.easeInOut(duration: Constants.UI.animationDuration)) {
                        isShowingLaunchScreen = false
                    }
                }
            }
        }
    }
} 
