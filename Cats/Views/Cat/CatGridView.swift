import SwiftUI

struct CatGridView: View {
    let cats: [Cat]
    @ObservedObject var listViewModel: CatListViewModel
    
    private let spacing: CGFloat = Constants.UI.gridSpacing
    private let columns = [
        GridItem(.flexible(), spacing: Constants.UI.gridSpacing),
        GridItem(.flexible(), spacing: Constants.UI.gridSpacing)
    ]
    
    var body: some View {
        LazyVGrid(
            columns: columns,
            spacing: spacing
        ) {
            ForEach(cats) { cat in
                CatCardView(cat: cat, listViewModel: listViewModel)
            }
        }
    }
} 