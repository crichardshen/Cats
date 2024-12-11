import SwiftUI

struct AddWeightRecordView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: AddWeightRecordViewModel
    @State private var showingDatePicker = false  // 添加日期选择器状态
    
    init(catId: UUID, editingRecord: WeightRecord? = nil, onSave: @escaping (WeightRecord) -> Void) {
        _viewModel = StateObject(wrappedValue: AddWeightRecordViewModel(
            catId: catId,
            editingRecord: editingRecord,
            onSave: onSave
        ))
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("基本信息")) {
                    TextField("体重（kg）", text: $viewModel.weight)
                        .keyboardType(.decimalPad)
                    
                    // 添加日期选择按钮
                    Button {
                        showingDatePicker = true
                    } label: {
                        HStack {
                            Text("日期")
                            Spacer()
                            Text(viewModel.timestamp.formattedYYYYMMDD())
                                .foregroundColor(.gray)
                        }
                    }
                }
                
                Section(header: Text("备注")) {
                    TextField("备注信息", text: $viewModel.note)
                }
            }
            .navigationTitle(viewModel.isEditing ? "编辑记录" : "添加记录")
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
                isPresented: $showingDatePicker,
                date: $viewModel.timestamp,
                title: Locale.isChineseEnvironment ? "选择日期" : "Select Date"
            )
        }
    }
} 