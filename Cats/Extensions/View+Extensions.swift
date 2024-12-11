import SwiftUI

private struct WindowKey: EnvironmentKey {
    static let defaultValue: UIWindow? = nil
}

extension EnvironmentValues {
    var window: UIWindow? {
        get { self[WindowKey.self] }
        set { self[WindowKey.self] = newValue }
    }
}

// MARK: - 日期相关扩展
extension Locale {
    /// 获取系统当前区域设置
    static var appLocale: Locale {
        // 获取系统首选语言
        if let languageCode = Locale.preferredLanguages.first {
            return Locale(identifier: languageCode)
        }
        return Locale.current
    }
    
    /// 判断当前是否为中文环境
    static var isChineseEnvironment: Bool {
        let languageCode = Locale.preferredLanguages.first ?? ""
        return languageCode.starts(with: "zh")
    }
}

extension DateFormatter {
    /// 根据系统语言自动配置的日期格式化器
    static let standard: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = .appLocale
        // 如果是中文环境使用中文格式，否则使用标准格式
        formatter.dateFormat = Locale.isChineseEnvironment ? "yyyy年MM月dd日" : "MMM d, yyyy"
        return formatter
    }()
}

extension View {
    /// 显示本地化的日期选择器 sheet
    func localizedDatePickerSheet(
        isPresented: Binding<Bool>,
        date: Binding<Date>,
        title: String = "选择日期",
        onConfirm: (() -> Void)? = nil
    ) -> some View {
        sheet(isPresented: isPresented) {
            DatePickerSheet(
                isPresented: isPresented,
                date: date,
                title: title,
                onConfirm: onConfirm
            )
        }
    }
} 