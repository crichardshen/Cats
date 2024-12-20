import SwiftUI

struct CatCardView: View {
    let cat: Cat
    @ObservedObject var listViewModel: CatListViewModel
    
    var body: some View {
        NavigationLink {
            CatDetailView(cat: cat, listViewModel: listViewModel)
        } label: {
            ZStack(alignment: .topTrailing) {
                VStack {
                    CatAvatarView(avatarData: cat.avatar)
                        .frame(width: Constants.UI.avatarSize, height: Constants.UI.avatarSize)
                    
                    Text(cat.name)
                        .font(.headline)
                        .foregroundColor(.primary)
                }
                .cardStyle()
                
                if listViewModel.hasUncompletedMedicines(for: cat) {
                    Circle()
                        .fill(ThemeColors.notificationRed)
                        .frame(width: 12, height: 12)
                        .offset(x: -8, y: 8)
                }
            }
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