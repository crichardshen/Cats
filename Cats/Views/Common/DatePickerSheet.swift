import SwiftUI

/// 通用的日期选择器 Sheet
struct DatePickerSheet: View {
    @Binding var isPresented: Bool
    @Binding var date: Date
    let title: String
    var onConfirm: (() -> Void)? = nil
    
    // 添加状态来跟踪当前选择的日期
    @State private var selectedDate: Date
    
    init(isPresented: Binding<Bool>, date: Binding<Date>, title: String, onConfirm: (() -> Void)? = nil) {
        _isPresented = isPresented
        _date = date
        self.title = title
        self.onConfirm = onConfirm
        _selectedDate = State(initialValue: date.wrappedValue)
    }
    
    private var cancelText: String {
        Locale.isChineseEnvironment ? "取消" : "Cancel"
    }
    
    private var confirmText: String {
        Locale.isChineseEnvironment ? "确定" : "Confirm"
    }
    
    private var todayText: String {
        Locale.isChineseEnvironment ? "回到今日" : "Today"
    }
    
    private var isToday: Bool {
        let result = Calendar.current.isDateInToday(selectedDate)
        print("Selected date: \(selectedDate), isToday: \(result)")
        return result
    }
    
    // 添加一个计算属性来获取屏幕高度
    private var screenHeight: CGFloat {
        UIScreen.main.bounds.height
    }
    
    // 计算日历视图的相对高度
    private var calendarHeight: CGFloat {
        screenHeight * 0.45  // 使用屏幕高度的 45%
    }
    
    // 计算整个 sheet 的相对高度
    private var sheetHeight: CGFloat {
        screenHeight * 0.52  // 使用屏幕高度的 52%
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                DatePicker(
                    title,
                    selection: $selectedDate,
                    displayedComponents: .date
                )
                .datePickerStyle(.graphical)
                .environment(\.calendar, Calendar(identifier: .gregorian))
                .environment(\.locale, Locale.appLocale)
                .onChange(of: selectedDate) { newDate in
                    print("Date changed to: \(newDate)")
                    date = selectedDate
                }
                .frame(height: calendarHeight)  // 使用相对高度
                
                Spacer(minLength: 0)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(cancelText) {
                        isPresented = false
                    }
                }
                
                ToolbarItem(placement: .principal) {
                    if !Calendar.current.isDateInToday(selectedDate) {
                        Button(action: {
                            print("Today button tapped")
                            withAnimation {
                                selectedDate = Date()
                                date = selectedDate
                            }
                        }) {
                            HStack {
                                Image(systemName: "calendar")
                                Text(todayText)
                            }
                            .foregroundColor(ThemeColors.forestGreen)
                        }
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(confirmText) {
                        date = selectedDate
                        onConfirm?()
                        isPresented = false
                    }
                }
            }
        }
        .presentationDetents([.height(sheetHeight)])  // 使用相对高度
        .presentationDragIndicator(.hidden)
    }
} 