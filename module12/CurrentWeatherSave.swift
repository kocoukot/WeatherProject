

import Foundation
import RealmSwift

class currentSavedWeather: Object{
    @objc dynamic var savedCurrentTemp = ""
    @objc dynamic var savedCurrentWeather = ""
}

class OneDay: Object {
    @objc dynamic var oneDayTitle = ""
    var oneDayHour = List<String>()
    var oneDayWeather = List<String>()
    var oneDayTempMax = List<Double>()
    var oneDayTempMin = List<Double>()
}

class AllDays: Object{
    var daysList = List<OneDay>()
    
}
