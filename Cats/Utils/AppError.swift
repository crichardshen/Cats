import Foundation

enum AppError: LocalizedError {
    case databaseError(String)
    case invalidInput(String)
    case imageProcessingError(String)
    
    var errorDescription: String? {
        switch self {
        case .databaseError(let message):
            return "数据库错误: \(message)"
        case .invalidInput(let message):
            return "输入错误: \(message)"
        case .imageProcessingError(let message):
            return "图片处理错误: \(message)"
        }
    }
} 