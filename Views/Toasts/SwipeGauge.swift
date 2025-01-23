import SwiftUI

struct SwipeGauge: View {
    var intensity: Double
    var icon: String?
    var body: some View {
        Gauge(value: intensity) {
            if let icon = icon {
                Image(systemName: icon)
            }
        }
        .gaugeStyle(.accessoryCircularCapacity)
        .scaleEffect(1.5)
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.gray)
                .frame(width: 120, height: 120)
        ).opacity(0.75)
    }
}

struct SwipeGauge_Previews: PreviewProvider {
    static var previews: some View {
        SwipeGauge(intensity: 0.4)
    }
}
