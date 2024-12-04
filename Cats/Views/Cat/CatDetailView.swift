import SwiftUI

struct CatDetailView: View {
    @StateObject private var viewModel: CatDetailViewModel
    @EnvironmentObject private var listViewModel: CatListViewModel
    @Environment(\.dismiss) private var dismiss
    
    init(cat: Cat) {
        _viewModel = StateObject(wrappedValue: CatDetailViewModel(cat: cat))
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: Constants.UI.gridSpacing) {
                CatAvatarView(avatarData: viewModel.cat.avatar)
                    .frame(width: Constants.UI.avatarSize * 1.5, height: Constants.UI.avatarSize * 1.5)
                
                InfoCard(cat: viewModel.cat)
                
                FunctionCards(cat: viewModel.cat)
            }
        }
        .navigationTitle(viewModel.cat.name)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                CatDetailMenu(
                    showingEditSheet: $viewModel.showingEditSheet,
                    showingDeleteAlert: $viewModel.showingDeleteAlert
                )
            }
        }
        .sheet(isPresented: $viewModel.showingEditSheet) {
            AddCatView(editingCat: viewModel.cat) { updatedCat in
                listViewModel.updateCat(updatedCat)
                viewModel.cat = updatedCat
            }
        }
        .alert("删除猫咪", isPresented: $viewModel.showingDeleteAlert) {
            Button("取消", role: .cancel) { }
            Button("删除", role: .destructive) {
                listViewModel.deleteCat(viewModel.cat)
                dismiss()
            }
        } message: {
            Text("确定要删除\(viewModel.cat.name)吗？此操作不可撤销。")
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
                    InfoRow(title: "出生日期", value: birthDate.formatted(date: .long, time: .omitted))
                }
                if let weight = cat.weight {
                    InfoRow(title: "体重", value: String(format: "%.1f kg", weight))
                }
            }
            .cardStyle()
            .padding(.horizontal)
        }
    }
    
    struct CatDetailMenu: View {
        @Binding var showingEditSheet: Bool
        @Binding var showingDeleteAlert: Bool
        
        var body: some View {
            Menu {
                Button("编辑") {
                    showingEditSheet = true
                }
                Button("删除", role: .destructive) {
                    showingDeleteAlert = true
                }
            } label: {
                Image(systemName: "ellipsis.circle")
                    .foregroundColor(ThemeColors.forestGreen)
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
        
        var body: some View {
            VStack(spacing: 15) {
                NavigationLink(destination: FeedingRecordListView(catId: cat.id)) {
                    FunctionCard(
                        title: "饮食记录",
                        icon: "bowl.fill",
                        color: ThemeColors.forestGreen
                    )
                }
                
                NavigationLink(destination: WeightRecordListView(catId: cat.id)) {
                    FunctionCard(
                        title: "体重管理",
                        icon: "scalemass.fill",
                        color: ThemeColors.forestGreen
                    )
                }
                
                NavigationLink(destination: MedicineListView(catId: cat.id)) {
                    FunctionCard(
                        title: "医药管理",
                        icon: "cross.case.fill",
                        color: ThemeColors.forestGreen
                    )
                }
                // 其他功能卡片将在后续添加...
            }
            .padding(.horizontal)
        }
    }
    
    struct FunctionCard: View {
        let title: String
        let icon: String
        let color: Color
        
        var body: some View {
            HStack {
                Label(title, systemImage: icon)
                    .font(.headline)
                    .foregroundColor(color)
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