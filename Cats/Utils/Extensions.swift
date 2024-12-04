import SwiftUI

// 日期格式化扩展
extension Date {
    var formattedDate: String {
        self.formatted(date: .long, time: .omitted)
    }
}

// 视图修饰符扩展
extension View {
    func cardStyle() -> some View {
        self
            .padding()
            .background(ThemeColors.lightGreen.opacity(0.3))
            .cornerRadius(Constants.UI.cornerRadius)
            .shadow(radius: Constants.UI.shadowRadius)
    }
}

// 数字格式化扩展
extension Double {
    var weightString: String {
        String(format: "%.1f kg", self)
    }
} 