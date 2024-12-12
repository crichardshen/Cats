import SwiftUI

struct CatCard: View {
    let cat: Cat
    let hasUncompletedMedicines: Bool
    
    var body: some View {
        VStack(spacing: 12) {
            CatAvatarView(avatarData: cat.avatar)
                .frame(width: 80, height: 80)
            
            VStack(spacing: 4) {
                Text(cat.name)
                    .font(.headline)
                
                if let gender = cat.gender {
                    Text(gender.rawValue)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
            }
            
            if hasUncompletedMedicines {
                Circle()
                    .fill(ThemeColors.notificationRed)
                    .frame(width: 8, height: 8)
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 2)
    }
} 