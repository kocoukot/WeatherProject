
import Foundation

class CurrentTemperature {
    let temp: Double
    
    init?(data: NSDictionary){
        guard
            let temp = data["temp"] as? Double
            else {
                return nil
        }
        self.temp = temp
    }
}

class CurrentWeather {
    let currentWeather: String
    
    init?(data: NSDictionary){
        guard
            let currentWeather = data["description"] as? String
            else {
                return nil
        }
        self.currentWeather = currentWeather
    }
}

class ForcastTemperature{
    let forcastTemp: Double
    let forcastTempMin: Double
    let forcastTempMax: Double
    
    init?(data: NSDictionary){
        guard
            let forcastTemp = data["temp"] as? Double,
            let forcastTempMin = data["temp_min"] as? Double,
            let forcastTempMax = data["temp_max"] as? Double
            else {
                return nil
        }
        self.forcastTemp = forcastTemp
        self.forcastTempMin = forcastTempMin
        self.forcastTempMax = forcastTempMax
    }
}

class ForcastWeather {
    let forcastWeather: String
    
    init?(data: NSDictionary){
        guard
            let forcastWeather = data["description"] as? String
            else {
                return nil
        }
        self.forcastWeather = forcastWeather
    }
}
