import SwiftUI

struct FeedingRecordRow: View {
    let record: FeedingRecord
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(record.foodBrand)
                    .font(.headline)
                Spacer()
                Text(record.timestamp.formattedYYYYMMDD())
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            
            HStack {
                Label(record.foodType.rawValue, systemImage: "bowl.fill")
                Spacer()
                Text("\(String(format: "%.0f", record.amount))g")
            }
            .font(.subheadline)
            .foregroundColor(.gray)
            
            if let note = record.note {
                Text(note)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
        }
        .padding(.vertical, 4)
    }
} 