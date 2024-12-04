import SwiftUI

struct CatListView: View {
    @StateObject private var viewModel = CatListViewModel()
    @State private var showingAddSheet = false
    
    var body: some View {
        ZStack {
            ThemeColors.paleGreen
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
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("我的宠物")
                    .font(.headline)
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showingAddSheet = true
                } label: {
                    Text("添加宠物")
                        .font(.subheadline)
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

#Preview {
    NavigationView {
        CatListView()
    }
} 