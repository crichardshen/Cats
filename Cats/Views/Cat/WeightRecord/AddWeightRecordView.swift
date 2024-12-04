import SwiftUI

struct AddWeightRecordView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: AddWeightRecordViewModel
    
    init(catId: UUID, editingRecord: WeightRecord? = nil, onSave: @escaping (WeightRecord) -> Void) {
        _viewModel = StateObject(wrappedValue: AddWeightRecordViewModel(catId: catId, editingRecord: editingRecord, onSave: onSave))
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("体重信息")) {
                    HStack {
                        Text("体重")
                        TextField("公斤", text: $viewModel.weight)
                            .keyboardType(.decimalPad)
                        Text("kg")
                    }
                    
                    HStack {
                        Text("时间")
                        Spacer()
                        Text(viewModel.timestamp.formattedYYYYMMDD())
                            .foregroundColor(.gray)
                    }
                }
                
                Section(header: Text("备注")) {
                    TextField("备注信息", text: $viewModel.note)
                }
            }
            .navigationTitle(viewModel.isEditing ? "编辑体重记录" : "添加体重记录")
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