import SwiftUI

struct CatCardView: View {
    let cat: Cat
    
    var body: some View {
        NavigationLink(destination: CatDetailView(cat: cat)) {
            VStack {
                CatAvatarView(avatarData: cat.avatar)
                    .frame(width: Constants.UI.avatarSize, height: Constants.UI.avatarSize)
                
                Text(cat.name)
                    .font(.headline)
                    .foregroundColor(.primary)
            }
            .cardStyle()
        }
    }
}

struct CatAvatarView: View {
    let avatarData: Data?
    
    var body: some View {
        if let avatarData = avatarData,
           let uiImage = UIImage(data: avatarData) {
            Image(uiImage: uiImage)
                .resizable()
                .scaledToFill()
                .clipShape(Circle())
        } else {
            Image(systemName: "cat.fill")
                .resizable()
                .scaledToFit()
                .padding(20)
                .foregroundColor(ThemeColors.forestGreen)
        }
    }
} 