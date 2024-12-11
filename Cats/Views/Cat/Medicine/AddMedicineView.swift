import SwiftUI

struct AddMedicineView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: AddMedicineViewModel
    @State private var showingStartDatePicker = false
    @State private var showingEndDatePicker = false
    
    init(catId: UUID, editingMedicine: Medicine? = nil, onSave: @escaping (Medicine) -> Void) {
        _viewModel = StateObject(wrappedValue: AddMedicineViewModel(
            catId: catId,
            editingMedicine: editingMedicine,
            onSave: onSave
        ))
    }
    
    var body: some View {
        NavigationView {
            Form {
                // 基本信息
                Section(header: Text("基本信息")) {
                    TextField("名称", text: $viewModel.name)
                    
                    Picker("类型", selection: $viewModel.type) {
                        ForEach(Medicine.MedicineType.allCases, id: \.self) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                    
                    // 开始日期
                    Button {
                        showingStartDatePicker = true
                    } label: {
                        HStack {
                            Text("开始日期")
                            Spacer()
                            Text(viewModel.startDate.formattedYYYYMMDD())
                                .foregroundColor(.gray)
                        }
                    }
                    
                    // 结束日期
                    Toggle(isOn: $viewModel.hasEndDate) {
                        Text("设置结束日期")
                    }
                    
                    if viewModel.hasEndDate {
                        Button {
                            showingEndDatePicker = true
                        } label: {
                            HStack {
                                Text("结束日期")
                                Spacer()
                                Text(viewModel.endDate.formattedYYYYMMDD())
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                }
                
                // 频率设置
                Section(header: Text("使用频率")) {
                    FrequencyPicker(frequency: $viewModel.frequency)
                }
                
                // 备注
                Section(header: Text("备注")) {
                    TextField("备注信息", text: $viewModel.note)
                }
            }
            .navigationTitle(viewModel.isEditing ? "修改药物/疫苗" : "配置药物/疫苗")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("保存") {
                        viewModel.save()
                        dismiss()
                    }
                    .disabled(!viewModel.canSave)
                }
            }
            .localizedDatePickerSheet(
                isPresented: $showingStartDatePicker,
                date: $viewModel.startDate,
                title: Locale.isChineseEnvironment ? "选择开始日期" : "Select Start Date"
            )
            .localizedDatePickerSheet(
                isPresented: $showingEndDatePicker,
                date: $viewModel.endDate,
                title: Locale.isChineseEnvironment ? "选择结束日期" : "Select End Date"
            )
        }
    }
}

// 添加这个扩展来隐藏键盘/日期选择器
extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
} 
