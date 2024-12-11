import SwiftUI
import PhotosUI

@available(iOS 16.0, *)
struct AddCatView: View {
    @StateObject private var viewModel: AddCatViewModel
    @Environment(\.dismiss) private var dismiss
    @Environment(\.window) private var window
    @State private var showingBirthDatePicker = false
    @State private var showingImportPicker = false
    @State private var showingImportError = false
    @Binding var isPresented: Bool
    @State private var pendingImport = false
    let onSave: (Cat) -> Void
    
    // 添加一个静态属性来保持 ViewModel 的引用
    private static var importingViewModel: AddCatViewModel?
    
    init(editingCat: Cat? = nil, existingCats: [Cat] = [], isPresented: Binding<Bool>, onSave: @escaping (Cat) -> Void) {
        let viewModel = AddCatViewModel(
            editingCat: editingCat,
            existingCats: existingCats,
            onSave: onSave,
            onImportSuccess: {
                NotificationCenter.default.post(name: NSNotification.Name("RefreshCatList"), object: nil)
            }
        )
        _viewModel = StateObject(wrappedValue: viewModel)
        _isPresented = isPresented
        self.onSave = onSave
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    Button("从文件导入") {
                        // 保存 ViewModel 的引用
                        Self.importingViewModel = viewModel
                        pendingImport = true
                        isPresented = false
                    }
                }
                
                basicInfoSection
                avatarSection
            }
            .navigationTitle(viewModel.isEditing ? "编辑宠物" : "添加宠物")
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
        .onChange(of: isPresented) { newValue in
            if !newValue && pendingImport {
                pendingImport = false
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                       let rootViewController = scene.windows.first?.rootViewController {
                        print("开始选择文件...")
                        ExportManager.shared.showFilePicker(from: rootViewController) { url in
                            print("文件选择完成，URL: \(String(describing: url))")
                            
                            guard let url = url else {
                                print("没有选择文件")
                                Self.importingViewModel = nil  // 清理引用
                                return
                            }
                            
                            DispatchQueue.main.async {
                                print("开始导入文件...")
                                if let viewModel = Self.importingViewModel {  // 使用保存的引用
                                    print("开始处理导入...")
                                    let success = ExportManager.shared.importCatData(from: url, existingCats: viewModel.existingCats)
                                    print("导入结果: \(success)")
                                    if success {
                                        viewModel.onImportSuccess?()
                                    } else {
                                        let alertController = UIAlertController(
                                            title: "导入失败",
                                            message: "无法导入选择的文件，请确保文件格式正确。",
                                            preferredStyle: .alert
                                        )
                                        alertController.addAction(UIAlertAction(title: "确定", style: .default))
                                        rootViewController.present(alertController, animated: true)
                                    }
                                } else {
                                    print("ViewModel 已被释放")
                                }
                                Self.importingViewModel = nil  // 清理引用
                            }
                        }
                    }
                }
            }
        }
    }
}

// MARK: - 视图组件
private extension AddCatView {
    var basicInfoSection: some View {
        Section(header: Text("基本信息")) {
            TextField("宠物名字", text: $viewModel.name)
            
            Picker("性别", selection: $viewModel.gender) {
                Text("未选择").tag(Cat.Gender?.none)
                ForEach(Cat.Gender.allCases, id: \.self) { gender in
                    Text(gender.rawValue).tag(Optional(gender))
                }
            }
            
            Button {
                showingBirthDatePicker = true
            } label: {
                HStack {
                    Text("出生日期")
                    Spacer()
                    Text(viewModel.birthDate.formattedYYYYMMDD())
                        .foregroundColor(.gray)
                }
            }
            .localizedDatePickerSheet(
                isPresented: $showingBirthDatePicker,
                date: $viewModel.birthDate,
                title: Locale.isChineseEnvironment ? "选择出生日期" : "Select Birth Date"
            )
            
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