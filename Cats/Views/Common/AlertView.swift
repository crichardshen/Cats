import SwiftUI

struct AlertInfo: Identifiable {
    let id = UUID()
    let title: String
    let message: String
    let primaryButton: Alert.Button
    let secondaryButton: Alert.Button?
}

extension View {
    func alert(_ alertInfo: Binding<AlertInfo?>) -> some View {
        alert(
            item: alertInfo,
            content: { info in
                info.secondaryButton != nil ?
                Alert(
                    title: Text(info.title),
                    message: Text(info.message),
                    primaryButton: info.primaryButton,
                    secondaryButton: info.secondaryButton!
                ) :
                Alert(
                    title: Text(info.title),
                    message: Text(info.message),
                    dismissButton: info.primaryButton
                )
            }
        )
    }
} 