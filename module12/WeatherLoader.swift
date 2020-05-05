
import Foundation
import Alamofire
import SVProgressHUD


protocol WeatherDelegate{
    func loadedForcastWeather(forcastTemp: [ForcastTemperature], forcastWeather: [ForcastWeather], forcastDate: [CLong])
}

class WeatherLoader{
    var delegate: WeatherDelegate?
    
    func loadWeatherAlamo(completionTemp: @escaping ([CurrentTemperature]) -> Void,completionWeather: @escaping ([CurrentWeather]) -> Void ){

        Alamofire.request("http://api.openweathermap.org/data/2.5/weather?q=Moscow,RU&units=metric&lang=ru&appid=176b2cfc4f08fe90fbc1830e77a2669e").responseJSON
            { response in
                if let object = response.result.value,
                    let jsonDict = object as? NSDictionary{
                    var currentTemp:[CurrentTemperature] = []
                    var currentWeather:[CurrentWeather] = []
                    
                    let weatherArray = jsonDict["weather"] as! [[String:Any]]
                    if let category = CurrentWeather(data: weatherArray.first! as NSDictionary){
                        currentWeather.append(category)
                    }
                    
                    for (_ ,data) in jsonDict where data is NSDictionary{
                        if let category = CurrentTemperature(data: data as! NSDictionary){
                            currentTemp.append(category)
                        }
                    }
                    DispatchQueue.main.async {
                        completionTemp(currentTemp)
                        completionWeather(currentWeather)
                    }
                }
        }
        
    }
    
    func loadForcastWeatherAlamo(){

        Alamofire.request("http://api.openweathermap.org/data/2.5/forecast?q=Moscow,RU&units=metric&lang=ru&appid=176b2cfc4f08fe90fbc1830e77a2669e").responseJSON{response in
            if let object = response.result.value,
                let jsonDict = object as? NSDictionary{
                let listDict = jsonDict["list"] as! Array<Any>
                
                var forcastTemp:[ForcastTemperature] = []
                var forcastWeather:[ForcastWeather] = []
                var forcastDate: [CLong] = []
                
                for d in 0...listDict.count - 1{
                    let dayDict = listDict[d] as! NSDictionary
                    
                    for (_ ,data) in dayDict where data is NSDictionary{
                        if let category = ForcastTemperature(data: data as! NSDictionary){
                            forcastTemp.append(category)
                        }
                    }
                    
                    let weatherArray = dayDict["weather"] as! [[String:Any]]
                    if let category = ForcastWeather(data: weatherArray.first! as NSDictionary){
                        forcastWeather.append(category)
                    }
                    
                    let date = dayDict["dt"] as? CLong
                    forcastDate.append(date! - 14400)
                }
                DispatchQueue.main.async {

                    self.delegate?.loadedForcastWeather(forcastTemp: forcastTemp, forcastWeather: forcastWeather, forcastDate: forcastDate)
                }
            }
        }
    }
}
