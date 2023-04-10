import SwiftUI



struct Mood: Identifiable {
    let id = UUID()
    let mood: String
    let image: UIImage?
    let date: Date
}

struct ContentView: View {
    let moodColors = ["😄": Color.green, "😊": Color.yellow, "😔": Color.gray, "😢": Color.blue, "🚀": Color.pink, "👍": Color.orange," 🤯": Color.gray, "🤪": Color.purple ]
    @State var selectedMood = ""
    @State var moodHistory: [Mood] = []
    @State var showImagePicker = false
    
    let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
        //GridItem(.flexible(), spacing: 16)
    ]
    

    
    var body: some View {
        TabView {
            
            VStack {
                
                Spacer()
                Text(selectedMood)
                    .font(.system(size: 80))
                    .padding()
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
                                    .font(.system(size: 50))
                                    .foregroundColor(.white)
                            }
                            .frame(height: 100)
                        }
                    }
                }
                .padding(.bottom, 50)
                
                
                Button(action: {
                    self.showImagePicker = true
                }) {
                    Text("Add Photo")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .sheet(isPresented: $showImagePicker) {
                    ImagePickerView(onImageSelected: { image in
                        self.saveMood(withImage: image)
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
                                    Text("\(mood.date)")
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
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
        }
       
    }
    
    
    func deleteMood(_ mood: Mood) {
        if let index = moodHistory.firstIndex(where: { $0.id == mood.id }) {
            moodHistory.remove(at: index)
        }
    }
    
    func saveMood(withImage image: UIImage?) {
        let newMood = Mood(mood: selectedMood, image: image, date: Date())
        moodHistory.append(newMood)
        selectedMood = ""
    }


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
}
