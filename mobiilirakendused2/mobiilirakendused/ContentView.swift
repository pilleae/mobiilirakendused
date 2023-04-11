import SwiftUI


struct PersonalDataView: View {
    @State private var name: String = ""
    @State private var age: String = ""
    @State private var wakingHours: String = ""
    @State private var selectedTimePeriod: String = "AM"
    
    @AppStorage("name") var savedName: String = ""
    @AppStorage("age") var savedAge: String = ""
    @AppStorage("wakingHours") var savedWakingHours: String = ""

    var body: some View {
        VStack(alignment: .leading) {
            Text("Name")
                .font(.headline)
            
            TextField("", text: $name)
                .textFieldStyle(PlainTextFieldStyle())
                .padding()
                .background(Color.white)
                .cornerRadius(10)
                .shadow(radius: 3)

            Text("Age")
                .font(.headline)
                .padding(.top)
            
            TextField("", text: $age)
                .textFieldStyle(PlainTextFieldStyle())
                .padding()
                .background(Color.white)
                .cornerRadius(10)
                .shadow(radius: 3)
            
            Text("Normal waking hours")
                .font(.headline)
                .padding(.top)

            HStack {
                TextField("", text: $wakingHours)
                    .textFieldStyle(PlainTextFieldStyle())
                    .keyboardType(.numberPad)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(10)
                    .shadow(radius: 3)

                Picker("Time period", selection: $selectedTimePeriod) {
                    Text("AM").tag("AM")
                    Text("PM").tag("PM")
                }
                .pickerStyle(SegmentedPickerStyle())
                .frame(maxWidth: 80)
                .padding(.trailing)
            }
            .padding(.bottom)

            Spacer()

            Button(action: savePersonalData) {
                HStack {
                    Spacer()
                    Text("Save")
                        .font(.headline)
                        .foregroundColor(.white)
                    Spacer()
                }
                .padding()
                .background(Color.blue)
                .cornerRadius(10)
                .shadow(radius: 3)
            }
            .padding(.bottom)
        }
        .padding()
        .navigationTitle("Personal Data")
        .onAppear {
            loadPersonalData()
        }
    }
    
    private func savePersonalData() {
        savedName = name
        savedAge = age
        savedWakingHours = wakingHours + " " + selectedTimePeriod
    }
    
    private func loadPersonalData() {
        name = savedName
        age = savedAge
        let parts = savedWakingHours.split(separator: " ")
        if parts.count == 2 {
            wakingHours = String(parts[0])
            selectedTimePeriod = String(parts[1])
        }
    }
}


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
    
   
    
    let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    init() {
        if let data = UserDefaults.standard.data(forKey: "moodHistory") {
            let decoder = JSONDecoder()
            if let savedMoodHistory = try? decoder.decode([Mood].self, from: data) {
                self._moodHistory = State(initialValue: savedMoodHistory)
            }
        } else {
            self._moodHistory = State(initialValue: [])
        }
    }
    
    var body: some View {
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
            
        }
       
    }
    
    
    func deleteMood(_ mood: Mood) {
        if let index = moodHistory.firstIndex(where: { $0.id == mood.id }) {
            moodHistory.remove(at: index)
        }
    }

    func saveMood(withImage image: UIImage?, activity: String, personWith: String) {
        let newMood = Mood(mood: selectedMood, activity: activity, personWith: selectedPerson, image: image, date: Date())
        moodHistory.append(newMood)
        selectedMood = ""
        
        // Save the new mood to UserDefaults
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(moodHistory) {
            UserDefaults.standard.set(encoded, forKey: "moodHistory")
        }
    }
    
    

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
}

