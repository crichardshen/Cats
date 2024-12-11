import Foundation

extension Medicine.Frequency {
    // 添加计算属性来获取每日次数
    var timesPerDay: Int {
        switch self {
        case .daily(let times):
            return times
        case .weekly, .monthly, .custom:
            return 1  // 其他频率默认每天一次
        }
    }
}
