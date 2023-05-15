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
        
        
        
        
        // Computes the count of each mood for all entries
        let allMoodCount = moodHistory.reduce(into: [:]) { counts, mood in
            counts[mood.mood, default: 0] += 1
        }
        
        // Computes the count of each mood for this month's entries
        let thisMonthMoodCount = moodHistory.filter { mood in
            let month = Calendar.current.component(.month, from: mood.date)
            let year = Calendar.current.component(.year, from: mood.date)
            let currentMonth = Calendar.current.component(.month, from: Date())
            let currentYear = Calendar.current.component(.year, from: Date())
            return month == currentMonth && year == currentYear
        }.reduce(into: [:]) { counts, mood in
            counts[mood.mood, default: 0] += 1
        }
        
        // Computes the count of each mood for today's entries
        let todayMoodCount = moodHistory.filter { mood in
            let date = Calendar.current.component(.day, from: mood.date)
            let month = Calendar.current.component(.month, from: mood.date)
            let year = Calendar.current.component(.year, from: mood.date)
            let currentDay = Calendar.current.component(.day, from: Date())
            let currentMonth = Calendar.current.component(.month, from: Date())
            let currentYear = Calendar.current.component(.year, from: Date())
            return date == currentDay && month == currentMonth && year == currentYear
        }.reduce(into: [:]) { counts, mood in
            counts[mood.mood, default: 0] += 1
        }
        
        
        ScrollView {
            VStack {
                Text("Mood Summary")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(Color.gray)
                
                
                // Displays the pie chart of mood distribution for all entries
                VStack{
                    Text("All Time Entries")
                        .font(.headline)
                        .foregroundColor(Color.gray)
                    PieChart(data: allMoodCount.map { ($0.key, Double($0.value)) }, colors: moodColors)
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
                    
                    Spacer()
                    
                }
                // Displays the pie chart of mood distribution for this months entries
                VStack{
                    Text("This Month's Entries")
                        .font(.headline)
                        .foregroundColor(Color.gray)
                    PieChart(data: thisMonthMoodCount.map { ($0.key, Double($0.value)) }, colors: moodColors)
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
                    
                    Spacer()
                    
                }
                
                // Displays the pie chart of mood distribution for today's entries
                VStack{
                    Text("Today's Entries")
                        .font(.headline)
                        .foregroundColor(Color.gray)
                    PieChart(data: todayMoodCount.map { ($0.key, Double($0.value)) }, colors: moodColors)
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
                    
                    Spacer()
                    
                }
                .padding(.horizontal) // add horizontal padding here to prevent overlap with the NavigationView
                .frame(maxWidth: .infinity) // expand the frame to the full width of the screen
            }
            .padding(.vertical)
            .frame(maxWidth: .infinity, alignment: .leading) // center the content vertically and align it to the left
        }
    }
}



// pie chart view
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
            ForEach(Array(data.indices), id: \.self) { index in
                let color = colors[data[index].0] ?? .gray
                let percentage = Int((data[index].1 / total) * 100)
                PieChartSlice(startAngle: startAngle(for: index),
                              endAngle: endAngle(for: index),
                              center: CGPoint(x: 150, y: 150),
                              radius: 150,
                              percentage: percentage,
                              color: color)
            }
        }
    }
}



struct PieChartSlice: View {
    let startAngle: Angle
    let endAngle: Angle
    let center: CGPoint
    let radius: CGFloat
    let percentage: Int
    let color: Color
    
    var body: some View {
        let midAngle = (startAngle + endAngle) / 2
        let slicePath = Path { path in
            path.move(to: center)
            path.addArc(center: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: false)
        }
        return ZStack {
            slicePath.fill(color)
            slicePath.stroke(Color.white, lineWidth: 2)
            Text("\(percentage)%").position(CGPoint(x: center.x + cos(midAngle.radians) * radius / 2, y: center.y + sin(midAngle.radians) * radius / 2))
        }
    }
}
