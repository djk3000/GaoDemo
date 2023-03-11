import Foundation

class DataFile {
    static let instance = DataFile()
    @Published var cities: [String] = []
    
    func setCity(city: String) {
        self.cities.append(city)
    }
}
