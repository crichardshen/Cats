import SwiftUI

struct AddFeedingRecordView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: AddFeedingRecordViewModel
    
    init(catId: UUID, editingRecord: FeedingRecord? = nil, onSave: @escaping (FeedingRecord) -> Void) {
        _viewModel = StateObject(wrappedValue: AddFeedingRecordViewModel(catId: catId, editingRecord: editingRecord, onSave: onSave))
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("食物信息")) {
                    TextField("品牌", text: $viewModel.foodBrand)
                    
                    Picker("类型", selection: $viewModel.foodType) {
                        ForEach(FeedingRecord.FoodType.allCases, id: \.self) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                    
                    HStack {
                        Text("数量")
                        TextField("克", text: $viewModel.amount)
                            .keyboardType(.decimalPad)
                        Text("g")
                    }
                }
                
                Section(header: Text("时间")) {
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
            .navigationTitle("添加喂食记录")
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