import SwiftUI

struct EmptyStateView: View {
    @Binding var showingAddCat: Bool
    
    var body: some View {
        VStack(spacing: Constants.UI.gridSpacing) {
            Image(systemName: "cat.fill")
                .resizable()
                .scaledToFit()
                .frame(width: Constants.UI.avatarSize)
                .foregroundColor(ThemeColors.forestGreen)
            
            Text("还没有添加猫咪")
                .font(.headline)
                .foregroundColor(.gray)
            
            Button(action: { showingAddCat = true }) {
                Text("添加猫咪")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.horizontal, 30)
                    .padding(.vertical, 15)
                    .background(ThemeColors.forestGreen)
                    .cornerRadius(25)
            }
        }
    }
} 