import Foundation


// Struktur zum Dekodieren von JSON-Daten für verschiedene Kontinente
struct CountryData: Codable {
    let Europe: [String: String]?
    let Asia: [String: String]?
    let Africa: [String: String]?
    let NorthAmerica: [String: String]?
    let SouthAmerica: [String: String]?
    let Oceania: [String: String]?
    
    // Passt die JSON-Schlüssel an die Swift-Property-Namen an
    private enum CodingKeys: String, CodingKey {
        case Europe
        case Asia
        case Africa
        case NorthAmerica = "North America"
        case SouthAmerica = "South America"
        case Oceania
    }
}

// Struktur für ein einzelnes Land mit Name und Flagge
struct Country: Identifiable {
    let name: String
    let flag: String
    
    var id: String { name } // Name dient als eindeutige ID
}

// Klasse zum Verwalten und Laden von Ländern aus JSON-Dateien
class CountryManager {
    
    // Lädt Länder basierend auf der angegebenen Region
    static func loadCountries(for region: String) -> [Country] {
        switch region {
        case Region.wholeWorld.rawValue:
            return loadAllCountries()
        case Region.europe.rawValue:
            return loadCountriesFromFile("europe")
        case Region.asia.rawValue:
            return loadCountriesFromFile("asia")
        case Region.africa.rawValue:
            return loadCountriesFromFile("africa")
        case Region.northAmerica.rawValue:
            return loadCountriesFromFile("north_america")
        case Region.southAmerica.rawValue:
            return loadCountriesFromFile("south_america")
        case Region.oceania.rawValue:
            return loadCountriesFromFile("oceania")
        default:
            return []
        }
    }
    
    // Lädt Länder aus allen Regionen (außer „ganze Welt“)
    private static func loadAllCountries() -> [Country] {
        return Region.allCases
            .filter { $0 != .wholeWorld }
            .flatMap { loadCountriesFromFile($0.rawValue.lowercased().replacingOccurrences(of: " ", with: "_")) }
    }
    
    // Lädt Länder aus einer bestimmten JSON-Datei
    private static func loadCountriesFromFile(_ filename: String) -> [Country] {
        guard let url = Bundle.main.url(forResource: filename, withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let countryData = try? JSONDecoder().decode(CountryData.self, from: data) else {
            return []
        }
        
        let dict: [String: String]
        
        
        // Wählt die passende Region aus dem dekodierten Objekt
        switch filename {
        case "europe": dict = countryData.Europe ?? [:]
        case "asia": dict = countryData.Asia ?? [:]
        case "africa": dict = countryData.Africa ?? [:]
        case "north_america": dict = countryData.NorthAmerica ?? [:]
        case "south_america": dict = countryData.SouthAmerica ?? [:]
        case "oceania": dict = countryData.Oceania ?? [:]
        default: dict = [:]
        }
        
        // Wandelt das Dictionary in ein Array von Country-Objekten um
        return dict.map { Country(name: $0.key, flag: $0.value) }
    }
} 
