import SwiftUI

/// 通用的日期选择器 Sheet
struct DatePickerSheet: View {
    @Binding var isPresented: Bool
    @Binding var date: Date
    let title: String
    var onConfirm: (() -> Void)? = nil
    
    // 根据系统语言获取按钮文字
    private var cancelText: String {
        Locale.isChineseEnvironment ? "取消" : "Cancel"
    }
    
    private var confirmText: String {
        Locale.isChineseEnvironment ? "确定" : "Confirm"
    }
    
    var body: some View {
        VStack {
            HStack {
                Button(cancelText) {
                    isPresented = false
                }
                Spacer()
                Button(confirmText) {
                    onConfirm?()
                    isPresented = false
                }
            }
            .padding()
            
            DatePicker(
                title,
                selection: $date,
                displayedComponents: .date
            )
            .datePickerStyle(.graphical)
            .environment(\.calendar, Calendar(identifier: .gregorian))  // 使用公历
            .environment(\.locale, Locale.appLocale)  // 使用应用语言设置
        }
        .presentationDetents([.medium])
    }
} 