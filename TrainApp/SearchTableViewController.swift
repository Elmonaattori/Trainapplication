 //
//  SearchTableViewController.swift
//  TrainApp
//
//  Created by Elmo Tiitola on 11.2.2018.
//  Copyright © 2018 Elmo Tiitola. All rights reserved.
//

//Tämä luokka ohjaa ikkunaa, josta valitaan haluttu asema aikataulutarkasteluun.
 
import UIKit

 class SearchTableViewController: UITableViewController, UISearchBarDelegate{
    
    var searchController: UISearchController!
    var resultsController = UITableViewController()
    
    //Tarvittavien muuttujien alustus.
    var indexRow = 0
    var stationName = ""
    var FilteredStations: [ScheduleTableViewController.Stations] = []
    var stations: [ScheduleTableViewController.Stations] = []

    //Hakupalkki linkitetään tässä.
    @IBOutlet weak var SearchBarStations: UISearchBar!
    
    
    //Lataa näkymän kun se aukaistaan ensimmäisen kerran.
    override func viewDidLoad() {
        
        super.viewDidLoad()

        SearchBarStations.delegate = self
       
        loadStationsData( completionHandler: {(success) in self.updateUserInterface()})
        FilteredStations = stations
        
        updateUserInterface()
    }
    
    //Piilottaa näppäimistön kun etsi-nappia painetaan.
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        searchBar.resignFirstResponder()
    }

    
    /*Nappaa tiedon kun hakupalkin teksti muuttuu ja tekee tarvittavat toimenpiteet.
    Miellyttävämpi haku kun hakutuloksia päivitetään jokaisen näppäinpainalluksen jälkee*/
    func searchBar(_ searchBarStations: UISearchBar, textDidChange searchText: String) {
        
        guard !searchText.isEmpty else {
            
            FilteredStations = stations //FilteredStations on muuttuja johon tallennetaan aina hakutuloksia vastaavat asemat
            updateUserInterface()
            return
        }
        
        FilteredStations = stations.filter({station-> Bool in guard let text = searchBarStations.text
                else {
                    return false
            }
            
            return station.stationName.contains(text)
        })
        updateUserInterface()
    }
    
    
    /*Lataa asemien tiedot API:n kautta stations-muuttujaan.
    completionHandler hoitaa että koodi odottaa latauksen loppuun ennen seuraavien funktioiden suorittamista.*/
    func loadStationsData(completionHandler: @escaping (Bool) -> ()) {
        
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
                
                self.stations = try JSONDecoder().decode([ScheduleTableViewController.Stations].self, from:data)
                completionHandler(true) //saatiin ladattua tiedot onnistuneesti muuttujaan.
                self.FilteredStations = self.stations
            }
            catch let jsonError {
                print("Error", jsonError)
            }
            }.resume()
    }
    
    
    //Päivittää UI:n
    func updateUserInterface() {
        
        DispatchQueue.main.async{
            self.tableView.reloadData()
        }
    }

    
    override func didReceiveMemoryWarning() {
        
        super.didReceiveMemoryWarning()
    }

    
    override func numberOfSections(in tableView: UITableView) -> Int {

        return 1
    }
    
    
    //Scrollattavien rivien määrä on aina vastaavien hakutulosten määrä.
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return FilteredStations.count
    }

    
    //Palauttaa rivin näkymään kunhan on muokannut sen sopivaksi. Oikeat tiedot löydetään indexPathin avulla.
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell2", for: indexPath) //Cell2 laitettu id:ksi storyboardissa.
        
        let scheduleObject = self.FilteredStations[indexPath.row]
        cell.textLabel!.text = String(scheduleObject.stationName)
        
        return cell
    }
    
    
    /*Tekee tarvittavat toimenpiteet kun käyttäjät valitsee jonkin riveistä.
    Lähettää seguen avulla tiedon ScheduleTableView-luokalle ja avaa sen avulla aikataulu-ikkunan.
     Avataan siis ikään kuin uusi ScheduleTableView-ikkuna.*/
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        indexRow = indexPath.row
        stationName = FilteredStations[indexRow].stationName
        performSegue(withIdentifier: "send", sender: Any?.self)
    }
    
    
    //Tässä kerrotaan ScheduleTableViewControllerille haluttu asema
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let destination = segue.destination as? ScheduleTableViewController {
            
            destination.stationName = stationName
        }
    }

}
