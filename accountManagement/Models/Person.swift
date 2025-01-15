import Foundation

struct Person: Identifiable, Codable, Hashable {
    var id = UUID()
    var name: String
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: Person, rhs: Person) -> Bool {
        return lhs.id == rhs.id
    }
}
