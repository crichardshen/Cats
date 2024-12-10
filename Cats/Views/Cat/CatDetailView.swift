import SwiftUI

struct CatDetailView: View {
    @StateObject private var viewModel: CatDetailViewModel
    @ObservedObject var listViewModel: CatListViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var showingExportResult = false
    @State private var exportedFileURL: URL?
    
    init(cat: Cat, listViewModel: CatListViewModel) {
        _viewModel = StateObject(wrappedValue: CatDetailViewModel(cat: cat))
        self.listViewModel = listViewModel
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: Constants.UI.gridSpacing) {
                VStack(spacing: 16) {
                    CatAvatarView(avatarData: viewModel.cat.avatar)
                        .frame(width: Constants.UI.avatarSize, height: Constants.UI.avatarSize)
                    
                    InfoCard(cat: viewModel.cat)
                }
                .cardStyle()
                .padding(.horizontal)
                .onTapGesture {
                    viewModel.showingEditSheet = true
                }
                
                FunctionCards(
                    cat: viewModel.cat,
                    listViewModel: listViewModel,
                    onExport: {
                        if let fileURL = ExportManager.shared.exportCatData(viewModel.cat) {
                            exportedFileURL = fileURL
                            showingExportResult = true
                        }
                    }
                )
            }
        }
        .navigationTitle(viewModel.cat.name)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                CatDetailMenu(
                    showingEditSheet: $viewModel.showingEditSheet,
                    showingDeleteAlert: $viewModel.showingDeleteAlert,
                    onExport: {
                        if let fileURL = ExportManager.shared.exportCatData(viewModel.cat) {
                            exportedFileURL = fileURL
                            showingExportResult = true
                        }
                    }
                )
            }
        }
        .sheet(isPresented: $viewModel.showingEditSheet) {
            AddCatView(
                editingCat: viewModel.cat,
                existingCats: listViewModel.cats,
                isPresented: $viewModel.showingEditSheet,
                onSave: { updatedCat in
                    listViewModel.updateCat(updatedCat)
                    viewModel.cat = updatedCat
                }
            )
        }
        .alert("删除宠物", isPresented: $viewModel.showingDeleteAlert) {
            Button("取消", role: .cancel) { }
            Button("删除", role: .destructive) {
                listViewModel.deleteCat(viewModel.cat)
                dismiss()
            }
        } message: {
            Text("确定要删除\(viewModel.cat.name)吗？此操作不可撤销。")
        }
        .alert("导出成功", isPresented: $showingExportResult) {
            Button("在文件中查看") {
                if let url = exportedFileURL,
                   let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                   let rootViewController = windowScene.windows.first?.rootViewController {
                    ExportManager.shared.showInFiles(url, from: rootViewController)
                }
            }
            Button("确定", role: .cancel) { }
        } message: {
            if let url = exportedFileURL {
                Text("文件已导出到：\n\(url.path)")
            }
        }
    }
}

// MARK: - 子视图
private extension CatDetailView {
    struct InfoCard: View {
        let cat: Cat
        
        var body: some View {
            VStack(alignment: .leading, spacing: 10) {
                InfoRow(title: "名字", value: cat.name)
                if let gender = cat.gender {
                    InfoRow(title: "性别", value: gender.rawValue)
                }
                if let birthDate = cat.birthDate {
                    InfoRow(title: "出生日期", value: birthDate.formattedYYYYMMDD())
                }
                if let weight = cat.weight {
                    InfoRow(title: "体重", value: String(format: "%.1f kg", weight))
                }
            }
        }
    }
    
    struct CatDetailMenu: View {
        @Binding var showingEditSheet: Bool
        @Binding var showingDeleteAlert: Bool
        var onExport: () -> Void
        
        var body: some View {
            Menu {
                Button {
                    showingEditSheet = true
                } label: {
                    Label("编辑", systemImage: "pencil")
                }
                
                Button {
                    onExport()
                } label: {
                    Label("导出数据", systemImage: "square.and.arrow.up")
                }
                
                Button(role: .destructive) {
                    showingDeleteAlert = true
                } label: {
                    Label("删除", systemImage: "trash")
                }
            } label: {
                Image(systemName: "ellipsis.circle")
                    .foregroundColor(ThemeColors.forestGreen)
                    .imageScale(.large)
            }
        }
    }
    
    struct InfoRow: View {
        let title: String
        let value: String
        
        var body: some View {
            HStack {
                Text(title)
                    .foregroundColor(.gray)
                Spacer()
                Text(value)
            }
        }
    }
    
    struct FunctionCards: View {
        let cat: Cat
        let listViewModel: CatListViewModel
        @ObservedObject var medicineViewModel: MedicineViewModel
        var onExport: () -> Void
        
        init(cat: Cat, listViewModel: CatListViewModel, onExport: @escaping () -> Void) {
            self.cat = cat
            self.listViewModel = listViewModel
            self.onExport = onExport
            _medicineViewModel = ObservedObject(wrappedValue: MedicineViewModel(catId: cat.id))
        }
        
        private var hasUncompletedMedicines: Bool {
            let todayMedicines = medicineViewModel.medicinesForDate(Date())
            return todayMedicines.contains { !$0.isCompleted }
        }
        
        var body: some View {
            VStack(spacing: 15) {
                NavigationLink(destination: FeedingRecordListView(catId: cat.id)) {
                    FunctionCard(
                        title: "饮食记录",
                        icon: "fork.knife",
                        color: ThemeColors.forestGreen,
                        showNotification: false
                    )
                }
                
                NavigationLink(destination: WeightRecordListView(catId: cat.id)) {
                    FunctionCard(
                        title: "体重管理",
                        icon: "scalemass.fill",
                        color: ThemeColors.forestGreen,
                        showNotification: false
                    )
                }
                
                NavigationLink(destination: MedicineListView(catId: cat.id, listViewModel: listViewModel)) {
                    FunctionCard(
                        title: "医药管理",
                        icon: "cross.case.fill",
                        color: ThemeColors.forestGreen,
                        showNotification: hasUncompletedMedicines
                    )
                }
                
                Button(action: onExport) {
                    FunctionCard(
                        title: "导出数据",
                        icon: "square.and.arrow.up",
                        color: ThemeColors.forestGreen,
                        showNotification: false
                    )
                }
            }
            .padding(.horizontal)
        }
    }
    
    struct FunctionCard: View {
        let title: String
        let icon: String
        let color: Color
        let showNotification: Bool
        
        var body: some View {
            HStack {
                Label(title, systemImage: icon)
                    .font(.headline)
                    .foregroundColor(color)
                
                if showNotification {
                    Circle()
                        .fill(ThemeColors.notificationRed)
                        .frame(width: 8, height: 8)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
            }
            .padding()
            .background(Color.white)
            .cornerRadius(10)
            .shadow(radius: 2)
        }
    }
} 