import SwiftUI

struct CatRow: View {
    let cat: Cat
    
    var body: some View {
        HStack(spacing: 12) {
            // 头像
            CatAvatarView(avatarData: cat.avatar)
                .frame(width: 50, height: 50)
            
            // 信息
            VStack(alignment: .leading, spacing: 4) {
                Text(cat.name)
                    .font(.headline)
                
                HStack(spacing: 8) {
                    if let gender = cat.gender {
                        Text(gender.rawValue)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    
                    if let birthDate = cat.birthDate {
                        Text(birthDate.formattedYYYYMMDD())
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                }
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
        }
        .padding(.vertical, 8)
    }
} 