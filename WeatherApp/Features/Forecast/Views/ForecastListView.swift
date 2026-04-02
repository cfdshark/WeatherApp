import SwiftUI

struct ForecastListView: View {
    let days: [ForecastDay]
    let onDoubleTapDay: (ForecastDay) -> Void

    var body: some View {
        VStack(spacing: 18) {
            ForEach(days) { day in
                ForecastRowView(day: day)
                    .onTapGesture(count: 2) {
                        onDoubleTapDay(day)
                    }
            }
        }
    }
}
