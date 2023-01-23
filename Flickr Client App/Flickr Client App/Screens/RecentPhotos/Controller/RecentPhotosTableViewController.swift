//
//  ViewController.swift
//  Flickr Client App
//
//  Created by ORKUN GÜNERİ on 24.11.2022.
//

import UIKit

class RecentPhotosTableViewController: UITableViewController, UISearchResultsUpdating {
    
    private var response: PhotosResponse?{
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    private var selectedPhoto: Photo?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSearchController()
        fetchRecentPhotos()
        
    }
    
    private func setupSearchController(){
        let search = UISearchController(searchResultsController: nil)
        search.searchResultsUpdater = self
        search.obscuresBackgroundDuringPresentation = false
        search.searchBar.placeholder = "Type Something Here To Search"
        navigationItem.searchController = search
    }
    
    private func fetchRecentPhotos(){
        guard let url = URL(string: "https://www.flickr.com/services/rest/?method=flickr.photos.getRecent&api_key=1861f4df4553700d3a1ca440ec8053c1&format=json&nojsoncallback=1&extras=description,owner_name,icon_server,url_n,url_z") else {return}
        let request = URLRequest(url: url)
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error{
                debugPrint(error)
                return
            }
            if let data = data ,let response = try? JSONDecoder().decode(PhotosResponse.self, from: data){
                self.response = response
                
            }
        }.resume()
    }
    
    private func searchPhotos(with text: String){
        guard let url = URL(string: "https://www.flickr.com/services/rest/?method=flickr.photos.search&api_key=1861f4df4553700d3a1ca440ec8053c1&text=flower&format=json&nojsoncallback=1&extras=description,owner_name,icon_server,url_n,url_z") else {return}
        let request = URLRequest(url: url)
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                debugPrint(error)
                return
            }
            if let data = data ,let response = try? JSONDecoder().decode(PhotosResponse.self, from: data){
                self.response = response
            }
        }.resume()
    }
    
    
    // MARK: - UITableViewDataSource & UITableViewDelegate
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return response?.photos?.photo?.count ?? .zero
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let photo = response?.photos?.photo?[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! PhotoTableViewCell
        cell.ownerImageView.backgroundColor = .darkGray
        cell.ownerNameLabel.text = photo?.ownername
        
        
        //KULLLANICI RESMİ ÇEKMENİN 1.YOLU
        //NetworkManager.shared.fetchImage(with: photo?.urlN) { data in
        //cell.ownerImageView.image = UIImage(data: data) }
        
        //KULLLANICI RESMİ ÇEKMENİN 2.YOLU
        
        if let iconserver = photo?.iconserver,
           let iconfarm = photo?.iconfarm,
            let nsid = photo?.owner,
           NSString(string: iconserver).intValue > 0 {
               NetworkManager.shared.fetchImage(with:             "http://farm\(iconfarm).staticflickr.com/\(iconserver)/buddyicons/\(nsid).jpg") { data in
                cell.ownerImageView.image = UIImage(data: data)
            }
        } else{
            NetworkManager.shared.fetchImage(with: "https://www.flickr.com/images/buddyicon.gif") { data in
                cell.ownerImageView.image = UIImage(data: data)
            }
        }
        /*NetworkManager.shared.fetchImage(with: photo?.urlZ) { data in
            cell.ownerImageView.image = UIImage(data: data)
        }*/
        
        NetworkManager.shared.fetchImage(with: photo?.urlN) { data in
            cell.photoImageView.image = UIImage(data: data)
        }
        
        cell.titleLabel.text = photo?.title
        return cell
    }



    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedPhoto = response?.photos?.photo?[indexPath.row]
        performSegue(withIdentifier: "detailSegue", sender: nil)
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if let viewController = segue.destination as? PhotoDetailViewController {
            // TODO: - SEÇİLEN FOTOĞRAFI DETAY EKRANINA GÖNDER
            viewController.photo = selectedPhoto
        }
    }
    // MARK: - SEARCHBAR
    func updateSearchResults(for searchController: UISearchController) {
        guard let text = searchController.searchBar.text else { return }
        if text.count > 2 {
            searchPhotos(with: text)
            
        }
    }
}

