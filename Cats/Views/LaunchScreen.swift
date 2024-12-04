import SwiftUI

struct LaunchScreen: View {
    var body: some View {
        ZStack {
            ThemeColors.paleGreen
                .ignoresSafeArea()
            
            VStack {
                Image(systemName: "cat.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .foregroundColor(ThemeColors.forestGreen)
                
//                Text("猫咪管理")
//                    .font(.largeTitle)
//                    .foregroundColor(ThemeColors.forestGreen)
            }
        }
    }
} 
