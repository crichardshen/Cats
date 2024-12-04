import Foundation

enum Constants {
    enum Database {
        static let fileName = "cats.sqlite"
        static let dateFormat = "yyyy-MM-dd"
    }
    
    enum UI {
        static let cornerRadius: CGFloat = 15
        static let shadowRadius: CGFloat = 3
        static let avatarSize: CGFloat = 120
        static let gridSpacing: CGFloat = 20
        static let animationDuration: Double = 0.3
    }
    
    enum ImageCompression {
        static let quality: CGFloat = 0.8
    }
} 