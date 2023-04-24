import SwiftUI
import SwiftUICharts


struct MoodChartsView: View {
    
    // Defines the colors for each mood
    let moodColors = ["😄": Color.green, "😊": Color.yellow, "😔": Color.gray, "😢": Color.blue, "🤯": Color.pink, "👍": Color.orange]
    
    // Defines the labels for each mood
    let moodEmojis = ["😄": "Happy", "😊": "Content", "😔": "Sad", "😢": "Crying", "🤯": "Stressed", "👍": "Good"]
    
    // The list of mood entries
    let moodHistory: [Mood]
    
    var body: some View {
        
        // Computes the count of each mood
        let moodCount = moodHistory.reduce(into: [:]) { counts, mood in
            counts[mood.mood, default: 0] += 1
        }
        
        // Computes the total count of moods
        let totalCount = moodCount.values.reduce(0, +)
        
        VStack {
            Spacer()
            
            // Displays the pie chart of mood distribution
            PieChart(data: moodCount.map { ($0.key, Double($0.value)) }, colors: moodColors)
                .frame(width: 300, height: 300)
            Spacer()
            
            
            // Displays the mood labels
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
            
            
            // Displays the mood distribution percentages
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

            // Displays the total mood count
            Text("Total: \(totalCount)")
                .font(.headline)
        }
    }
}


// pie chart view
struct PieChart: View {
    
    let data: [(String, Double)]
    let colors: [String: Color]
    var lineWidth: CGFloat = 20
    
    // Computes the total value of the chart data
    private var total: Double {
        data.reduce(0, { $0 + $1.1 })
    }
    
    // Computes the start angle of the specified data element
    private func startAngle(for index: Int) -> Angle {
        let sum = data[0..<index].reduce(0, { $0 + $1.1 })
        return .degrees(360 * sum / total)
    }
    
    // Computes the end angle of the specified data element
    private func endAngle(for index: Int) -> Angle {
        let sum = data[0...index].reduce(0, { $0 + $1.1 })
        return .degrees(360 * sum / total)
    }
    
    
    //displays a pie chart based on the data provided. chart slices are created using the PieChartSlice struct.
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

// creates a path for the chart slice using the start and end angles, the center point of the slice, and the radius of the slice.
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

