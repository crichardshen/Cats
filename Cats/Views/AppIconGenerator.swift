import SwiftUI

struct AppIconGenerator: View {
    let size: CGFloat
    
    init(size: CGFloat = 1024) {
        self.size = size
    }
    
    var body: some View {
        ZStack {
            // 背景
            Rectangle()
                .fill(ThemeColors.paleGreen)
            
            // 猫咪图标
            Image(systemName: "cat.fill")
                .resizable()
                .scaledToFit()
                .padding(30)
                .foregroundColor(ThemeColors.forestGreen)
        }
        .frame(width: size, height: size)  // 使用传入的尺寸
        .clipShape(RoundedRectangle(cornerRadius: size * 0.2))  // 添加圆角
    }
}

#Preview {
    VStack(spacing: 20) {
        // 预览不同尺寸
        AppIconGenerator(size: 180)  // iPhone @3x
        AppIconGenerator(size: 120)  // iPhone @2x
        AppIconGenerator(size: 80)   // Spotlight
        AppIconGenerator(size: 60)   // Notification
    }
    .padding()
} 