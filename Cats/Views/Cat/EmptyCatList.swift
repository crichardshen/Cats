import SwiftUI

struct EmptyCatList: View {
    @Binding var showingAddSheet: Bool
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "cat.fill")
                .font(.system(size: 60))
                .foregroundColor(ThemeColors.forestGreen)
            
            Text("还没有添加宠物")
                .font(.headline)
            
            Text("点击以下按钮添加你的第一只宠物")
                .font(.subheadline)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
            
            Button {
                showingAddSheet = true
            } label: {
                Text("添加宠物")
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