import SwiftUI

struct WeightRecordRow: View {
    let record: WeightRecord
    let previousRecord: WeightRecord?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(String(format: "%.2f kg", record.weight))
                    .font(.headline)
                
                if let change = record.weightChange(from: previousRecord) {
                    WeightChangeIndicator(change: change)
                }
                
                Spacer()
                
                Text(record.timestamp.formatted(date: .abbreviated, time: .shortened))
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            
            if let note = record.note {
                Text(note)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
        }
        .padding(.vertical, 4)
    }
}

private struct WeightChangeIndicator: View {
    let change: Double
    
    var body: some View {
        HStack(spacing: 2) {
            Image(systemName: change >= 0 ? "arrow.up.right" : "arrow.down.right")
            Text(String(format: "%.2f", abs(change)))
        }
        .font(.caption)
        .foregroundColor(change >= 0 ? .red : .green)
    }
} 