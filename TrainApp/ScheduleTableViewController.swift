//
//  ScheduleTableViewController.swift
//  Aikataulut
//
//  Created by Elmo Tiitola on 9.2.2018.
//  Copyright © 2018 Elmo Tiitola. All rights reserved.
//

/*Tällä luokalla ohjataan ikkunaa jossa näytetään tietyn aseman aikataulutiedot. Luokassa myös ladataan API:lta
tarvittavat tiedot. Ohjelman aloitusnäkymässä avautuu tottakaki Tampereen aseman aikataulu-näkymä.*/

import UIKit

class ScheduleTableViewController: UITableViewController, UISearchBarDelegate {

    
    //Alla olevissa structeissa muodostetaan rakenne ladattavalle datalle.
    struct Causes: Decodable {
        
        let categoryCode: String?
        let categoryCodeId: Int?
        let categoryName: String?
        let description: String?
        let detailedCategoryCode: String?
        let detailedCategoryCodeId: Int?
        let detailedCategoryName: String?
        let id: Int?
        let passengerTerm: Dictionary<String,String>?
        let thirdCategoryCode: String?
        let thirdCategoryCodeId: Int?
        let thirdCategoryName: String?
        let validFrom: String?
        let validTo: String?
    }
    
    struct TimeTableStation: Decodable {
        
        let actualTime: String?
        let cancelled: Bool
        let causes: [Causes]
        let commercialStop: Bool?
        let commercialTrack: String?
        let countryCode: String
        let differenceInMinutes: Int?
        let estimateSource: String?
        let liveEstimateTime: String?
        let scheduledTime: String
        let stationShortCode: String
        let stationUICCode: Int
        let trainready:Dictionary<String, String>?
        let trainStopping: Bool
        let type: String
    }
    
    struct StationSchedules: Decodable {
        
        let cancelled: Bool
        let commuterLineID: String?
        let deleted: Bool?
        let departureDate: String
        let operatorShortCode: String
        let operatorUICCode: Int
        let runningCurrently: Bool
        let timeTableRows: [TimeTableStation]
        let timetableAcceptanceDate: String
        let timetableType: String
        let trainCategory: String
        let trainNumber: Int
        let trainType: String
        let version: Int
    }
    
    struct Stations: Decodable {
        
        let passengerTraffic: Bool
        let type: String
        let stationName: String
        let stationShortCode: String
        let stationUICCode: Int
        let countryCode: String
        let longtitude: Double?
        let latitude: Double?
    }
    
    //Tarvittavien muuttujien alustukset.
    var stations: [Stations] = []
    var stationArriveSchedules: [StationSchedules] = []
    var stationDepartureSchedules: [StationSchedules] = []
    var stationName: String = "Tampere asema"
    var indexRow = 0
    var indexSection = 0
    
   
    //Jos jo ladattu näkymä tuodaan ruutuun jostain syystä uudemman kerran.
    override func viewDidAppear(_ animated: Bool) {
        
        loadCitySchedules(cityName: stationName)
        updateUserInterface()
    }
    
    
    //Näkymän käynnistäminen kun se avataan ensimmäisen kerran.
    override func viewDidLoad() {
        
        super.viewDidLoad()
        loadStationsData()
        self.tableView.rowHeight = 100
        updateUserInterface()
    }
    

    //Lataa tietyn aseman aikataulut. Parametri cityName on halutun kaupungin nimi.
    func loadCitySchedules(cityName: String) {

        self.loadCityDepartureSchedules(cityName: cityName, completionHandler: {
            (success) in self.loadCityArriveSchedules(cityName: cityName, completionHandler: {
                (success) in self.updateUserInterface()
            })
        })
    }
    
    
    /*Ladataan saapuvien junien aikataulut tietyssä kaupungissa. cityName haluttu kaupunki.
 completionHandler hoitaa että tiedot ladataan ennen kuin jatketaan eteenpäin koodissa.*/
    func loadCityArriveSchedules(cityName: String, completionHandler: @escaping (Bool) -> ()) {
        
        let numberOfSchedules: String = "10"
        var stationArriveScheduleUrl: String
        var stationShortCode : String = "TPE"
        
        for name in (stations) {
            
            if name.stationName == cityName {
                
                stationShortCode = name.stationShortCode
                break
            }
        }

        stationArriveScheduleUrl = ("https://rata.digitraffic.fi/api/v1/live-trains/station/" + stationShortCode + "?arrived_trains=0&arriving_trains=" + numberOfSchedules + "&departed_trains=0&departing_trains=0&include_nonstopping=false")

        guard let ArriveUrl = URL(string: stationArriveScheduleUrl)
            else {
                
                return
            }

            URLSession.shared.dataTask(with: ArriveUrl) {
                (ArriveData, response, error) in

                guard let ArriveData = ArriveData
                    else {
                        
                        return
                    }

                do {
                    
                    self.stationArriveSchedules = try JSONDecoder().decode([StationSchedules].self, from:ArriveData)
                    completionHandler(true) //onnistui.
                }
                    
                catch let jsonError {
                    print("Error", jsonError)
                }
            }.resume()
    }


    /*Ladataan lähtevien junien aikataulut tietyssä kaupungissa. cityName haluttu kaupunki.
     completionHandler hoitaa että tiedot ladataan ennen kuin jatketaan eteenpäin koodissa.*/
    func loadCityDepartureSchedules(cityName: String, completionHandler: @escaping (Bool) -> ()) {

        let numberOfSchedules: String = "10"
        var stationDepartureScheduleUrl: String
        var stationShortCode : String = "TPE"
        for name in (stations) {
            
            if name.stationName == cityName {
                
                stationShortCode = name.stationShortCode
                break
            }
        }
        
        stationDepartureScheduleUrl = ("https://rata.digitraffic.fi/api/v1/live-trains/station/" + stationShortCode + "?arrived_trains=0&arriving_trains=0&departed_trains=0&departing_trains=" + numberOfSchedules + "&include_nonstopping=false")
        
        guard let DepartureUrl = URL(string: stationDepartureScheduleUrl)
            else {
                
                return
            }
        
        URLSession.shared.dataTask(with: DepartureUrl) {
            (DepartureData, response, error) in
            
            guard let DepartureData = DepartureData
                else {
                    
                    return
                }
            
            do {
                
                self.stationDepartureSchedules = try JSONDecoder().decode([StationSchedules].self, from:DepartureData)
                completionHandler(true) //onnistui.
            }
            catch let jsonError {
                print("Error", jsonError)
            }
            }.resume()
    }
    
    
    //Lataa tiedot asemista muuttujaa.
    func loadStationsData() {
        
        let VRstationsUrl = ("https://rata.digitraffic.fi/api/v1/metadata/stations")
        
        guard let url = URL(string: VRstationsUrl)
            else {
                
                return
        }
        
        URLSession.shared.dataTask(with: url) {
            (data, response, error) in
            
            guard let data = data
                else {
                    
                    return
            }
            
            do {
                
                self.stations = try JSONDecoder().decode([Stations].self, from:data)
            }
                
            catch let jsonError {
                
                print("Error", jsonError)
            }
            }.resume()
    }
    
    
    //Päivittää näkymän.
    func updateUserInterface() {

        DispatchQueue.main.async{
            self.tableView.reloadData()
        }
    }
    
    
    /*Palauttaa ajan jolloin juna saapuu tai lähtee tietyltä asemalta. stationName on aseman nimi.
    Indexeillä löydetään aikataulutiedoista oikea kaupunki ja lähteekö vai lähteekö juna.*/
    func findArriveTime(stationName: String, indexSection: Int, indexRow: Int) -> String {
        
        var foundShortCode = ""
        

            
            for station in stations {
                
                if station.stationName == stationName {
                    
                    foundShortCode = station.stationShortCode
                }
                
                for station in stationArriveSchedules[indexRow].timeTableRows {
                    
                    if foundShortCode == station.stationShortCode {
                        
                        if station.type == "ARRIVAL" {
                            let time = String(station.scheduledTime)
                            let startindexHour = time.index(time.startIndex, offsetBy: 11)
                            let endindexHour = time.index(time.endIndex, offsetBy: -11)
                            let startindexMinutes = time.index(time.startIndex, offsetBy: 14)
                            let endindexMinutes = time.index(time.endIndex, offsetBy: -8)
                            
                            var Hours: Int = Int(time[startindexHour..<endindexHour])!
                            if Hours < 22 && Hours > 00 {
                                Hours = Hours + 2
                            }
                            else if Hours > 21 && Hours < 24 {
                                Hours = 24 - Hours
                            }
                            
                            let Minutes: Int = Int(time[startindexMinutes..<endindexMinutes])!
                            
                            var HoursString: String
                            var MinutesString: String
                            if Hours < 10 {
                                HoursString = "0" + String(Hours)
                            }
                            else {
                                HoursString = String(Hours)
                            }
                            if Minutes < 10 {
                                MinutesString = "0" + String(Minutes)
                            }
                            else {
                                MinutesString = String(Minutes)
                            }
                            
                            let result = HoursString + ":" + MinutesString
                            return result
                        }
                        
                    }
                }
            }
        return ""
    }
    
    
    /*Palauttaa ajan jolloin juna saapuu tai lähtee tietyltä asemalta. stationName on aseman nimi.
     Indexeillä löydetään aikataulutiedoista oikea kaupunki ja lähteekö vai lähteekö juna.*/
    func findDepartureTime(stationName: String, indexSection: Int, indexRow: Int) -> String {
        
        var foundShortCode = ""
        
            for station in stations {
                
                if station.stationName == stationName {
                    
                    foundShortCode = station.stationShortCode
                    
                }
                
                for station in stationDepartureSchedules[indexRow].timeTableRows {
                    
                    if foundShortCode == station.stationShortCode {
                        
                        if station.type == "DEPARTURE" {
                            
                            let time = String(station.scheduledTime)
                            let startindexHour = time.index(time.startIndex, offsetBy: 11)
                            let endindexHour = time.index(time.endIndex, offsetBy: -11)
                            let startindexMinutes = time.index(time.startIndex, offsetBy: 14)
                            let endindexMinutes = time.index(time.endIndex, offsetBy: -8)
                            
                            var Hours: Int = Int(time[startindexHour..<endindexHour])!
                            if Hours < 22 && Hours > 00 {
                                
                                Hours = Hours + 2
                            }
                            else if Hours > 21 && Hours < 24 {
                                
                                Hours = 24 - Hours
                            }
                            
                            let Minutes: Int = Int(time[startindexMinutes..<endindexMinutes])!
                            
                            var HoursString: String
                            var MinutesString: String
                            if Hours < 10 {
                                
                                HoursString = "0" + String(Hours)
                            }
                            else {
                                
                                HoursString = String(Hours)
                            }
                            if Minutes < 10 {
                                
                                MinutesString = "0" + String(Minutes)
                            }
                            else {
                                
                                MinutesString = String(Minutes)
                            }
                            
                            let result = HoursString + ":" + MinutesString
                            return result
                        }
                    }
                }
        }
        return ""
    }

    
    override func didReceiveMemoryWarning() {
        
        super.didReceiveMemoryWarning()
    }


    //Lähtevä ja saapuva sektio.
    override func numberOfSections(in tableView: UITableView) -> Int {

        return 2
    }

    
    //Rivien määrä on haettujen tietojen lukumäärä.
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        if section == 0 {
            return stationArriveSchedules.count
        }
        else {
            return stationDepartureSchedules.count
        }
        
    }

    
    //Muodostaa rivin annettujen tietojen perusteella ja palauttaa sen näkymään.
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
 
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let trainNumberLabel = cell.viewWithTag(2) as! UILabel
        let trainTypeImage = cell.viewWithTag(1) as! UIImageView
        let trainTimeLabel = cell.viewWithTag(3) as! UILabel

        if indexPath.section == 0 {
            
            let scheduleObject = self.stationArriveSchedules[indexPath.row]
            trainTypeImage.image = UIImage(named: scheduleObject.trainType + ".png")
            trainNumberLabel.text = String(scheduleObject.trainNumber)
            trainTimeLabel.text = findArriveTime(stationName: stationName, indexSection: indexPath.section, indexRow: indexPath.row)
            
        }
            
        else if indexPath.section == 1 {
            
            let scheduleObject = self.stationDepartureSchedules[indexPath.row]
            trainTypeImage.image = UIImage(named: scheduleObject.trainType + ".png")
            trainNumberLabel.text = String(scheduleObject.trainNumber)
            trainTimeLabel.text = findDepartureTime(stationName: stationName, indexSection: indexPath.section, indexRow: indexPath.row)
        }

        return cell
    }
    
    
    //Tekee sektioille otsikot.
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        if section == 0 {
            
            return "Arriving"
        }
            
        else if section == 1 {

            return "Departing"
        }
        
        return "-"
    }
    
    
    //Säätää sektioiden otsikoiden värin.
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view:UIView, forSection: Int) {
        if let headerTitle = view as? UITableViewHeaderFooterView {
            if forSection == 0 {
                headerTitle.textLabel?.textColor = UIColor.green
            }
            if forSection == 1 {
                headerTitle.textLabel?.textColor = UIColor.red
            }
            
        }
    }
    
    
    //Valmistelee seguen avulla yksittäisen junan tietojen näyttämisen TrainInfoViewissä.
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        indexRow = indexPath.row
        indexSection = indexPath.section

        performSegue(withIdentifier: "showTrainInfo", sender: Any?.self)
    }
    
    
    //Lähettää tiedot junasta TrainInfoViewille.
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let destination = segue.destination as? TrainInfoViewController {
            
            destination.indexRow = indexRow
            destination.indexSection = indexSection
            
            if indexSection == 0 {
                
                destination.trainType = stationArriveSchedules[indexRow].trainType
                destination.trainNumber = stationArriveSchedules[indexRow].trainNumber
                destination.stationName = stationName
                destination.timeTableRows = stationArriveSchedules[indexRow].timeTableRows
                destination.time = findArriveTime(stationName: stationName, indexSection: indexSection, indexRow: indexRow)
                destination.stations = stations
            }
                
            else if indexSection == 1 {
                
                destination.trainType = stationDepartureSchedules[indexRow].trainType
                destination.trainNumber = stationDepartureSchedules[indexRow].trainNumber
                destination.stationName = stationName
                destination.timeTableRows = stationDepartureSchedules[indexRow].timeTableRows
                destination.time = findDepartureTime(stationName: stationName, indexSection: indexSection, indexRow: indexRow)
                destination.stations = stations
            }
        }
    }

}
