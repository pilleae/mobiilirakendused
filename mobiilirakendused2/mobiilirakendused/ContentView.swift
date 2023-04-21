import SwiftUI

class Mood: Identifiable, Codable {
    let id: UUID
    let mood: String
    let activity: String
    let personWith: String
    let image: UIImage?
    let date: Date
        
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy"
        return formatter.string(from: date)
    }
    
    init(mood: String, activity: String, personWith: String, image: UIImage?, date: Date) {
        self.id = UUID()
        self.mood = mood
        self.activity = activity
        self.personWith = personWith
        self.image = image
        self.date = date
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(mood, forKey: .mood)
        try container.encode(activity, forKey: .activity)
        try container.encode(personWith, forKey: .personWith)
        try container.encode(date, forKey: .date)
        
        if let image = image, let imageData = image.pngData() {
            try container.encode(imageData, forKey: .image)
        }
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        mood = try container.decode(String.self, forKey: .mood)
        activity = try container.decode(String.self, forKey: .activity)
        personWith = try container.decode(String.self, forKey: .personWith)
        date = try container.decode(Date.self, forKey: .date)
        
        if let imageData = try container.decodeIfPresent(Data.self, forKey: .image) {
            image = UIImage(data: imageData)
        } else {
            image = nil
        }
    }
    
    private enum CodingKeys: String, CodingKey {
        case id, mood, activity, personWith, image, date
    }
}

struct ContentView: View {
    let moodColors = ["😄": Color.green, "😊": Color.yellow, "😔": Color.gray, "😢": Color.blue, "🤯": Color.pink, "👍": Color.orange ]
    let activityTypes = ["Work", "Leisure", "Exercise", "Other"]
    let persons = ["Mari", "Peeter", "Taavi", "Aivo"]
    @State var selectedMood = ""
    @State var selectedActivityType = ""
    @State var selectedPerson = ""
    @State var moodHistory: [Mood] = []
    @State var showImagePicker = false
    @State private var isLoggedIn = false
    @AppStorage("moodHistory") var moodHistoryData: Data?
    
   

        
        
        let columns = [
            GridItem(.flexible(), spacing: 16),
            GridItem(.flexible(), spacing: 16)
        ]
        
        init() {
            if let data = moodHistoryData {
                let decoder = JSONDecoder()
                if let savedMoodHistory = try? decoder.decode([Mood].self, from: data) {
                    self._moodHistory = State(initialValue: savedMoodHistory)
                }
            } else {
                self._moodHistory = State(initialValue: [])
            }
        }
        
        func saveMood(withImage image: UIImage?, activity: String, personWith: String) {
            let mood = Mood(mood: selectedMood, activity: activity, personWith: personWith, image: image, date: Date())
            self.moodHistory.append(mood)
            if let encoded = try? JSONEncoder().encode(moodHistory) {
                self.moodHistoryData = encoded
            }
        }
//        
    
    var body: some View {
        if isLoggedIn {
        // Show rest of the app
        TabView {
            VStack {
                Text("How are you feeling?")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(Color.gray)
                    .bold()
                    .padding(.top, 50.0)
                    .padding(.vertical, 50.0)
                Spacer()
                Text(selectedMood)
                    .font(.system(size: 70))
                    .padding(0.0)
                Spacer()
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(moodColors.keys.sorted(), id: \.self) { color in
                        Button(action: {
                            self.selectedMood = color
                        }) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 10)
                                    .foregroundColor(moodColors[color])
                                Text(color)
                                    .font(.system(size: 55))
                                    .foregroundColor(.white)
                            }
                            .frame(height: 100.0)
                        }
                    }
                }
                .padding([.leading, .bottom, .trailing], 16.0)
                
                HStack {
                    Picker("Activity Type", selection: $selectedActivityType) {
                        ForEach(activityTypes, id: \.self) {
                            Text($0)
                        }
                    }
                    .padding()
                    
                    Picker("Persons", selection: $selectedPerson) {
                        ForEach(persons, id: \.self) {
                            Text($0)
                        }
                    }
                    .padding()
                }
                
                Button(action: {
                    self.showImagePicker = true
                }) {
                    Text("Add Photo")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding(.bottom, 50.0)
                .sheet(isPresented: $showImagePicker) {
                    ImagePickerView(onImageSelected: { image in
                        self.saveMood(withImage: image, activity: selectedActivityType, personWith: selectedPerson)
                        self.showImagePicker = false
                    })
                }
            }
            .tabItem {
                Image(systemName: "plus.circle.fill")
                Text("New Mood")
            }
            
            VStack {
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(moodHistory) { mood in
                            ZStack {
                                RoundedRectangle(cornerRadius: 10)
                                    .foregroundColor(moodColors[mood.mood])
                                VStack {
                                    if let image = mood.image {
                                        Image(uiImage: image)
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(width: 50, height: 50)
                                    }
                                    Text("\(mood.activity)")
                                        .font(.system(size: 12))
                                    Text("\(mood.personWith)")
                                        .font(.system(size: 12))
                                    Text("\(mood.formattedDate)")
                                        .font(.system(size: 12))
                                }
                                .padding(4)
                                Button(action: {
                                    self.deleteMood(mood)
                                }) {
                                    Image(systemName: "trash")
                                        .foregroundColor(.white)
                                }
                                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                                .padding(8)
                                
                            }
                            .frame(height: 100)
                            
                        }
                    }
                    .padding()
                }
                Spacer()
            }
            .tabItem {
                Image(systemName: "clock.fill")
                Text("Mood History")
                
            }
            
            PersonalDataView()
               .tabItem {
                   Image(systemName: "person.fill")
                   Text("Personal Data")
               }
            UserListView()
                   .navigationTitle("Users")
                   .tabItem {
                       Image(systemName: "person.2.fill")
                       Text("Users")
            }
            
            MoodChartsView(moodHistory: moodHistory)
                                .tabItem {
                                    Image(systemName: "chart.pie.fill")
                                    Text("Chart")
                                }
        
        }
        }else {
            LoginView(isLoggedIn: $isLoggedIn)
        }
    }
        
    
    
    func deleteMood(_ mood: Mood) {
        if let index = moodHistory.firstIndex(where: { $0.id == mood.id }) {
            moodHistory.remove(at: index)
        }
    }

  
    

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
}
