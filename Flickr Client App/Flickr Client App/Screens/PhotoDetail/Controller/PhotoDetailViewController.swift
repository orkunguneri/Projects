//
//  PhotoDetailViewController.swift
//  Flickr Client App
//
//  Created by ORKUN GÜNERİ on 24.11.2022.
//

import UIKit

class PhotoDetailViewController: UIViewController {
    var photo: Photo?
    

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var ownerNameLabel: UILabel!
    @IBOutlet weak var ownerImageView: UIImageView!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ownerImageView.layer.cornerRadius = 24.0
        
        title = "Photo Detail"
        imageView.backgroundColor = .gray
        ownerNameLabel.text = "Owner Name"
        //ownerImageView.backgroundColor = .darkGray
        descriptionLabel.text = "Description Label Description Label Description Label Description Label Description Label Description Label"
        
        ownerNameLabel.text = photo?.ownername
        
        if let iconserver = photo?.iconserver,
           let iconfarm = photo?.iconfarm,
            let nsid = photo?.owner,
           NSString(string: iconserver).intValue > 0 {
            NetworkManager.shared.fetchImage(with:             "http://farm\(iconfarm).staticflickr.com/\(iconserver)/buddyicons/\(nsid).jpg") { data in
                self.ownerImageView.image = UIImage(data: data)
            }
        } else {
            
            NetworkManager.shared.fetchImage(with: "https://www.flickr.com/images/buddyicon.gif") { data in
                self.ownerImageView.image = UIImage(data: data)
            }
        }
        
        NetworkManager.shared.fetchImage(with: photo?.urlZ) { data in
            self.imageView.image = UIImage(data: data)
        }
        
        title = photo?.title
        descriptionLabel.text = photo?.description?.content
    }
    
}
