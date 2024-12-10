import SwiftUI

struct CustomIntervalPicker: View {
    @Binding var years: String
    @Binding var months: String
    @Binding var days: String
    @Binding var hours: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("设置时间间隔")
                .font(.subheadline)
                .foregroundColor(.gray)
            
            VStack(spacing: 12) {
                IntervalField(value: $years, unit: "年")
                IntervalField(value: $months, unit: "月")
                IntervalField(value: $days, unit: "天")
                IntervalField(value: $hours, unit: "小时")
            }
            
            if let nextTime = calculateNextTime() {
                Text("下次用药时间：\(nextTime.formattedYYYYMMDD())")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
    }
    
    private func calculateNextTime() -> Date? {
        let y = Int(years) ?? 0
        let m = Int(months) ?? 0
        let d = Int(days) ?? 0
        let h = Int(hours) ?? 0
        
        if y == 0 && m == 0 && d == 0 && h == 0 { return nil }
        
        let frequency = Medicine.Frequency.custom(
            years: y,
            months: m,
            days: d,
            hours: h
        )
        return frequency.nextOccurrence()
    }
}

struct IntervalField: View {
    @Binding var value: String
    let unit: String
    
    var body: some View {
        HStack {
            Text(unit)
                .frame(width: 60, alignment: .leading)
            
            TextField("0", text: $value)
                .keyboardType(.numberPad)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .frame(maxWidth: 100)
                .onChange(of: value) { newValue in
                    value = newValue.filter { $0.isNumber }
                    if let num = Int(value) {
                        value = String(num)
                    }
                }
        }
    }
} 