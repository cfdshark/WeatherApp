import SwiftUI

struct ForecastListView: View {
    let days: [ForecastDay]

    var body: some View {
        VStack(spacing: 18) {
            ForEach(days) { day in
                ForecastRowView(day: day)
            }
        }
    }
}
