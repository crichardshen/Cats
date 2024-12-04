import SwiftUI

struct CatGridView: View {
    let cats: [Cat]
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: Constants.UI.gridSpacing) {
                ForEach(cats) { cat in
                    CatCardView(cat: cat)
                }
            }
            .padding()
        }
    }
} 