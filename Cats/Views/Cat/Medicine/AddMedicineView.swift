import SwiftUI

struct AddMedicineView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: AddMedicineViewModel
    
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
                    
                    DatePicker("开始日期", selection: $viewModel.startDate, displayedComponents: .date)
                    
                    DatePicker("结束日期（可选）", selection: $viewModel.endDate, displayedComponents: .date)
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
        }
    }
} 