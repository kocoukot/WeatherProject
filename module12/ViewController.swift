
import UIKit
import RealmSwift


class ViewController: UIViewController {
    private let realm = try! Realm()
    
    
    var daysArray:Dictionary<String,String> = [:]
    let savedWeather = currentSavedWeather()
    
    @IBOutlet weak var currentWeatherLabel: UILabel!
    @IBOutlet weak var currentTempLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        currentWeatherLoad()
    }
    
    private func currentWeatherLoad(){
        let count = realm.objects(currentSavedWeather.self).count-1
        if realm.objects(currentSavedWeather.self)[count] != nil{
            let weather = realm.objects(currentSavedWeather.self)[count]
            self.currentTempLabel.text = weather.savedCurrentTemp
            self.currentWeatherLabel.text = weather.savedCurrentWeather
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        WeatherLoader().loadWeatherAlamo(completionTemp: { currentTemperature in
            self.currentTempLabel.text = "\(String((currentTemperature[0].temp))) °С"
           
            self.savedWeather.realm?.beginWrite()
            self.savedWeather.savedCurrentTemp = "\(String((currentTemperature[0].temp))) °С"
            do {
                try self.savedWeather.realm?.commitWrite()
            } catch {
                print ()
            }
        } , completionWeather: { currentWeather in
            self.currentWeatherLabel.text = (currentWeather[0].currentWeather)
            self.savedWeather.realm?.beginWrite()
            self.savedWeather.savedCurrentWeather = (currentWeather[0].currentWeather)
            do {
                try self.savedWeather.realm?.commitWrite()
            } catch {
                print ()
            }
        })
        try! realm.write{
            realm.add(savedWeather)
        }
        
        let loader = WeatherLoader()
        loader.delegate = self
        loader.loadForcastWeatherAlamo()
    }
}

extension ViewController:WeatherDelegate{
    
    func loadedForcastWeather(forcastTemp: [ForcastTemperature], forcastWeather: [ForcastWeather], forcastDate: [CLong]){
        let testAllDays = AllDays()
        let formatterWeekDay = DateFormatter()
        let formatterDay = DateFormatter()
        let formatterTime = DateFormatter()
        formatterDay.dateFormat = "dd-MM"
        formatterWeekDay.dateFormat = "EEEE"
        formatterTime.dateFormat = "HH-mm"
        
        for d in 0...forcastDate.count-1{
            let date = Date(timeIntervalSince1970: TimeInterval(forcastDate[d]))
            self.daysArray[formatterDay.string(from: date)] = formatterWeekDay.string(from: date)
        }
        
        for (key, date) in self.daysArray.sorted(by: <){
            let testOneDay = OneDay()              
            testOneDay.oneDayTitle = "\(key), \(date)"
            
            for d in 0...forcastDate.count-1{
                let date = Date(timeIntervalSince1970: TimeInterval(forcastDate[d]))
                if formatterDay.string(from: date) == key {
                    testOneDay.oneDayHour.append(formatterTime.string(from: date))
                    testOneDay.oneDayWeather.append(forcastWeather[d].forcastWeather)
                    testOneDay.oneDayTempMax.append(forcastTemp[d].forcastTempMax)
                    testOneDay.oneDayTempMin.append(forcastTemp[d].forcastTempMin)
                }
            }
            testAllDays.daysList.append(testOneDay)
        }
        try! realm.write{
            realm.add(testAllDays)
        }
        tableView.reloadData()
    }
    
}


extension ViewController: UITableViewDataSource, UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        var title = ""
        if realm.objects(AllDays.self).last != nil{
            let temp = realm.objects(AllDays.self).last!
            title = temp.daysList[section].oneDayTitle
        }
        return title
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        var numberOfSections: Int = 0
        if realm.objects(AllDays.self).last != nil{
            let temp = realm.objects(AllDays.self).last!
            numberOfSections = temp.daysList.count
        }
        return numberOfSections
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        var numberofrows: Int = 0
        if realm.objects(AllDays.self).last != nil{
            let temp = realm.objects(AllDays.self).last!
            let day = temp.daysList[section]
            numberofrows = day.oneDayHour.count
        }
        return numberofrows
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        let cell = tableView.dequeueReusableCell(withIdentifier: "forcastCell") as! ForcastCell
        if realm.objects(AllDays.self).last != nil{
            let temp = realm.objects(AllDays.self).last!
            let day = temp.daysList[indexPath.section]
            cell.dateLabel.text = day.oneDayHour[indexPath.row]
            cell.weatherLabel.text = day.oneDayWeather[indexPath.row]
            cell.maxTempLabel.text = "\(day.oneDayTempMax[indexPath.row])"
            cell.minTempLabel.text = "\(day.oneDayTempMin[indexPath.row])"
        }
        return cell
    }
}


