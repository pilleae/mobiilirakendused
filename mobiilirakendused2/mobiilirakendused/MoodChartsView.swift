import SwiftUI
import SwiftUICharts


struct MoodChartsView: View {
    let moodColors = ["😄": Color.green, "😊": Color.yellow, "😔": Color.gray, "😢": Color.blue, "🤯": Color.pink, "👍": Color.orange]
    let moodEmojis = ["😄": "Happy", "😊": "Content", "😔": "Sad", "😢": "Crying", "🤯": "Stressed", "👍": "Good"]
    
    let moodHistory: [Mood]
    
    var body: some View {
        let moodCount = moodHistory.reduce(into: [:]) { counts, mood in
            counts[mood.mood, default: 0] += 1
        }
        
        let totalCount = moodCount.values.reduce(0, +)
        
        VStack {
            Spacer()
            PieChart(data: moodCount.map { ($0.key, Double($0.value)) }, colors: moodColors)
                .frame(width: 300, height: 300)
            Spacer()
            
            HStack(spacing: 10) {
                ForEach(moodEmojis.keys.sorted(), id: \.self) { mood in
                    VStack {
                        Circle()
                            .fill(moodColors[mood]!)
                            .frame(width: 20, height: 20)
                        Text(moodEmojis[mood]!)
                            .font(.caption)
                    }
                }
            }
            
            HStack(spacing: 10) {
                ForEach(moodColors.keys.sorted(), id: \.self) { mood in
                    let percentage = Double(moodCount[mood, default: 0]) / Double(totalCount) * 100
                    let percentageText = String(format: "%.0f%%", percentage)
                    VStack {
                        Text(percentageText)
                            .font(.caption)
                            .foregroundColor(moodColors[mood])
                    }
                    .padding(.horizontal, 8) // horizontal padding
                }
            }
            Spacer()
            Divider()
            Text("Total: \(totalCount)")
                .font(.headline)
        }
    }
}

struct PieChart: View {
    let data: [(String, Double)]
    let colors: [String: Color]
    var lineWidth: CGFloat = 20
    
    private var total: Double {
        data.reduce(0, { $0 + $1.1 })
    }
    
    private func startAngle(for index: Int) -> Angle {
        let sum = data[0..<index].reduce(0, { $0 + $1.1 })
        return .degrees(360 * sum / total)
    }
    
    private func endAngle(for index: Int) -> Angle {
        let sum = data[0...index].reduce(0, { $0 + $1.1 })
        return .degrees(360 * sum / total)
    }
    
    var body: some View {
        ZStack {
            ForEach(data.indices) { index in
                let color = colors[data[index].0] ?? .gray
                PieChartSlice(startAngle: startAngle(for: index),
                              endAngle: endAngle(for: index))
                    .fill(color)
                    .overlay(
                        PieChartSlice(startAngle: startAngle(for: index),
                                      endAngle: endAngle(for: index))
                            .stroke(Color.white, lineWidth: lineWidth)
                    )
            }
        }
    }
}
    struct PieChartSlice: Shape {
        let startAngle: Angle
        let endAngle: Angle
        
        func path(in rect: CGRect) -> Path {
            var path = Path()
            let center = CGPoint(x: rect.midX, y: rect.midY)
            let radius = min(rect.width, rect.height) / 2
            path.move(to: center)
            path.addArc(center: center,
                        radius: radius,
                        startAngle: startAngle,
                        endAngle: endAngle,
                        clockwise: false)
            path.closeSubpath()
            return path
        }
    }

