import SwiftUI

struct CatGridView: View {
    let cats: [Cat]
    @ObservedObject var listViewModel: CatListViewModel
    
    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: Constants.UI.gridSpacing) {
            ForEach(cats) { cat in
                CatCardView(cat: cat, listViewModel: listViewModel)
            }
        }
    }
} 