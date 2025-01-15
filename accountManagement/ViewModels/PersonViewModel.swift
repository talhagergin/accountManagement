import Foundation

class PersonViewModel: ObservableObject {
    @Published var people: [Person] = []
    
    private let userDefaults = UserDefaults.standard
    private let peopleKey = "savedPeople"
    
    init() {
        loadPeople()
    }
    
    func addPerson(name: String) {
        let newPerson = Person(name: name)
        people.append(newPerson)
        savePeople()
    }
    
    func getPerson(byId id: UUID) -> Person? {
        return people.first { $0.id == id }
    }
    
    private func savePeople() {
        if let encoded = try? JSONEncoder().encode(people) {
            userDefaults.set(encoded, forKey: peopleKey)
        }
    }
    
    private func loadPeople() {
        if let data = userDefaults.data(forKey: peopleKey),
           let decoded = try? JSONDecoder().decode([Person].self, from: data) {
            people = decoded
        }
    }
}
