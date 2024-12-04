import SwiftUI

struct FeedingRecordFilterView: View {
    @Binding var selectedFoodType: FeedingRecord.FoodType?
    @Binding var selectedDateRange: FeedingRecordViewModel.DateRange
    
    var body: some View {
        VStack(spacing: 20) {
            // 食物类型选择
            VStack(alignment: .leading) {
                Text("食物类型")
                    .font(.headline)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        FilterChip(
                            title: "全部",
                            isSelected: selectedFoodType == nil,
                            action: { selectedFoodType = nil }
                        )
                        
                        ForEach(FeedingRecord.FoodType.allCases, id: \.self) { type in
                            FilterChip(
                                title: type.rawValue,
                                isSelected: selectedFoodType == type,
                                action: { selectedFoodType = type }
                            )
                        }
                    }
                    .padding(.horizontal)
                }
            }
            
            // 日期范围选择
            VStack(alignment: .leading) {
                Text("时间范围")
                    .font(.headline)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(FeedingRecordViewModel.DateRange.allCases, id: \.self) { range in
                            FilterChip(
                                title: range.rawValue,
                                isSelected: selectedDateRange == range,
                                action: { selectedDateRange = range }
                            )
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
        .padding(.vertical)
    }
}

private struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(isSelected ? ThemeColors.forestGreen : Color.gray.opacity(0.1))
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(15)
        }
    }
} 