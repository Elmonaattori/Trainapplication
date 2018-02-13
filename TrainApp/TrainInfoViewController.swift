//
//  TrainInfoViewController.swift
//  TrainApp
//
//  Created by Elmo Tiitola on 12.2.2018.
//  Copyright © 2018 Elmo Tiitola. All rights reserved.
//


 //Tässä tiedostossa luokka jolla ohjataan ikkunaa, joka aukeaa kun valitaan jokin tietty juna-aikataulu valitaan.
 

import UIKit

class TrainInfoViewController: UIViewController {
    
    //Linkit UI-komponentteihin.

    @IBOutlet weak var endPointLabel: UILabel!
    @IBOutlet weak var startPointLabel: UILabel!
    @IBOutlet weak var trainTypeImage: UIImageView!
    @IBOutlet weak var trainNumberLabel: UILabel!
    @IBOutlet weak var ArriveDepartureLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var stationsLabel: UILabel!
    
    //Tarvittavien  muuttujien alustus.
    var indexRow = 0
    var indexSection = 0
    var trainType: String = ""
    var trainNumber: Int = 0
    var time: String = ""
    var stationName: String = ""
    var timeTableRows: [ScheduleTableViewController.TimeTableStation] = []
    var stationNameArray: [String] = []
    var stations: [ScheduleTableViewController.Stations] = []
    
    
    //Tämä funktio käynnistää ikkunan kun se avataa ensimmäisen kerran.
    override func viewDidLoad() {
        
        super.viewDidLoad()
        loadTrainData()
    }
    
    
    /*Jos jostain syystä jo ladattu ikkuna avataan uudelleen, tämä funktio lataa UI-komponentit uudelleen.
    Ei pitäisi tapahtua tämän ohjelman kanssa.*/
    override func viewDidAppear(_ animated: Bool) {
        
        loadTrainData()
    }
    
    
    //Lataa UI-komponentit ja asettaa niille arvot.
    func loadTrainData() {
        
        fillStationNameArray()
        
        var stationsText = ""
        for stationName in stationNameArray {
            
            stationsText = stationsText + ", " + stationName
        }
        
        let startindex = stationsText.index(stationsText.startIndex, offsetBy: 2)
        let endindex = stationsText.index(stationsText.endIndex, offsetBy: 0)
        let result = String(stationsText[startindex..<endindex])
        
        startPointLabel.text = stationNameArray[0]
        endPointLabel.text = stationNameArray[stationNameArray.count - 1]
        stationsLabel.text = result
        timeLabel.text = time
        trainTypeImage.image = UIImage(named: trainType + ".png")
        trainNumberLabel.text = String(trainNumber)
        
        if indexSection == 0 {
            
            ArriveDepartureLabel.text = "Arrive time: "
        }
            
        else {
            
            ArriveDepartureLabel.text = "Departure time: "
        }
    }
    
    
    //Täyttää arrayn asemien nimillä jotka ovat junan reitillä
    func fillStationNameArray() {
        
        for station in timeTableRows {
            
            let stationShortCode = station.stationShortCode
            for station in stations {
                
                if station.stationShortCode == stationShortCode {
                    
                    if stationNameArray.contains(station.stationName) {
                        
                    }
                    else {
                        
                        stationNameArray.append(station.stationName)
                    }
                }
            }
        }
    }


    override func didReceiveMemoryWarning() {
        
        super.didReceiveMemoryWarning()
    }
    

}
