import SwiftUI

struct CatListView: View {
    @StateObject private var viewModel = CatListViewModel()
    @State private var showingAddSheet = false
    @Binding var showContent: Bool
    
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
            .scrollContentBackground(.hidden)
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("我的宠物")
                    .font(.headline)
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                if !viewModel.cats.isEmpty {
                    Button {
                        showingAddSheet = true
                    } label: {
                        Text("添加宠物")
                            .font(.subheadline)
                            .foregroundColor(ThemeColors.forestGreen)
                    }
                }
            }
        }
        .sheet(isPresented: $showingAddSheet) {
            AddCatView(
                existingCats: viewModel.cats,
                isPresented: $showingAddSheet,
                onSave: { cat in
                    viewModel.addCat(cat)
                }
            )
        }
        .onAppear {
            NotificationCenter.default.addObserver(
                forName: NSNotification.Name("RefreshCatList"),
                object: nil,
                queue: .main
            ) { _ in
                viewModel.loadCats()
            }
        }
    }
} 
