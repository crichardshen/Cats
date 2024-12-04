import SwiftUI
import PhotosUI

@available(iOS 16.0, *)
struct AddCatView: View {
    @StateObject private var viewModel: AddCatViewModel
    @Environment(\.dismiss) private var dismiss
    var onSave: (Cat) -> Void
    
    init(editingCat: Cat? = nil, onSave: @escaping (Cat) -> Void) {
        _viewModel = StateObject(wrappedValue: AddCatViewModel(editingCat: editingCat))
        self.onSave = onSave
    }
    
    var body: some View {
        NavigationView {
            Form {
                basicInfoSection
                avatarSection
            }
            .navigationTitle(viewModel.isEditing ? "编辑猫咪" : "添加猫咪")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(viewModel.isEditing ? "保存" : "添加") {
                        onSave(viewModel.createCat())
                        dismiss()
                    }
                    .disabled(!viewModel.canSave)
                }
            }
        }
    }
}

// MARK: - 视图组件
private extension AddCatView {
    var basicInfoSection: some View {
        Section(header: Text("基本信息")) {
            TextField("猫咪名字", text: $viewModel.name)
            
            Picker("性别", selection: $viewModel.gender) {
                Text("未选择").tag(Cat.Gender?.none)
                ForEach(Cat.Gender.allCases, id: \.self) { gender in
                    Text(gender.rawValue).tag(Optional(gender))
                }
            }
            
            DatePicker("出生日期", selection: $viewModel.birthDate, displayedComponents: .date)
            
            TextField("体重（kg）", text: $viewModel.weight)
                .keyboardType(.decimalPad)
        }
    }
    
    var avatarSection: some View {
        Section(header: Text("头像")) {
            PhotosPicker(selection: $viewModel.imageSelection, matching: .images) {
                HStack {
                    Text("选择头像")
                    Spacer()
                    if let image = viewModel.avatarImage {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 40)
                            .clipShape(Circle())
                    }
                }
            }
        }
    }
} 