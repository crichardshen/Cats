import SwiftUI

struct CatListView: View {
    @StateObject private var viewModel = CatListViewModel()
    @State private var showingAddSheet = false
    
    var body: some View {
        NavigationView {
            ZStack {
                ThemeColors.paleGreen  // 添加背景色
                    .ignoresSafeArea()
                
                ScrollView {
                    if viewModel.cats.isEmpty {
                        EmptyCatList(showingAddSheet: $showingAddSheet)
                            .padding()
                    } else {
                        CatGridView(cats: viewModel.cats, listViewModel: viewModel)
                            .padding()
                    }
                }
            }
            .navigationTitle("我的猫咪")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingAddSheet = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(ThemeColors.forestGreen)
                    }
                }
            }
            .sheet(isPresented: $showingAddSheet) {
                AddCatView { cat in
                    viewModel.addCat(cat)
                }
            }
        }
    }
}

#Preview {
    CatListView()
} 