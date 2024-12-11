import SwiftUI

struct AddFeedingRecordView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: AddFeedingRecordViewModel
    @State private var showingDatePicker = false
    
    init(catId: UUID, editingRecord: FeedingRecord? = nil, onSave: @escaping (FeedingRecord) -> Void) {
        _viewModel = StateObject(wrappedValue: AddFeedingRecordViewModel(
            catId: catId,
            editingRecord: editingRecord,
            onSave: onSave
        ))
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("基本信息")) {
                    TextField("品牌", text: $viewModel.foodBrand)
                    
                    Picker("类型", selection: $viewModel.foodType) {
                        ForEach(FeedingRecord.FoodType.allCases, id: \.self) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                    
                    TextField("数量（克）", text: $viewModel.amount)
                        .keyboardType(.decimalPad)
                    
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