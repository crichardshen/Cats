import SwiftUI

struct CatListView: View {
    @StateObject private var viewModel = CatListViewModel()
    @State private var showingAddCat = false
    
    var body: some View {
        ZStack {
            ThemeColors.paleGreen
                .ignoresSafeArea()
            
            VStack {
                if viewModel.cats.isEmpty {
                    EmptyStateView(showingAddCat: $showingAddCat)
                } else {
                    CatGridView(cats: viewModel.filteredCats)
                }
            }
        }
        .navigationTitle("我的猫咪")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                AddButton(showingAddCat: $showingAddCat)
            }
        }
        .searchable(text: $viewModel.searchText, prompt: "搜索猫咪")
        .sheet(isPresented: $showingAddCat) {
            if #available(iOS 16.0, *) {
                AddCatView { cat in
                    viewModel.addCat(cat)
                }
            }
        }
    }
}

#Preview {
    NavigationView {
        CatListView()
    }
} 