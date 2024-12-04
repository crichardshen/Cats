import SwiftUI

struct AddButton: View {
    @Binding var showingAddCat: Bool
    
    var body: some View {
        Button(action: { showingAddCat = true }) {
            Image(systemName: "plus.circle.fill")
                .foregroundColor(ThemeColors.forestGreen)
                .imageScale(.large)
        }
    }
} 