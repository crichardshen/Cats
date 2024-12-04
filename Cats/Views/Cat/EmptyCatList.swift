import SwiftUI

struct EmptyCatList: View {
    @Binding var showingAddSheet: Bool
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "cat.fill")
                .font(.system(size: 60))
                .foregroundColor(ThemeColors.forestGreen)
            
            Text("还没有添加猫咪")
                .font(.headline)
            
            Text("点击右上角的"+"添加您的第一只猫咪")
                .font(.subheadline)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
            
            Button {
                showingAddSheet = true
            } label: {
                Text("添加猫咪")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .background(ThemeColors.forestGreen)
                    .cornerRadius(10)
            }
        }
        .padding()
    }
} 