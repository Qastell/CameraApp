//
//  StartViewController.swift
//  CameraApp
//
//  Created by Кирилл Романенко on 11.11.2020.
//

import UIKit

class StartViewController: UIViewController {
    
    @IBOutlet weak var photo: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()

        startSetup()
    }
    
    func startSetup() {
        photo.image = UIImage()
        photo.backgroundColor = .darkGray
        photo.layer.cornerRadius = photo.frame.width/3
        photo.contentMode = .scaleAspectFill
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if case let controller as PhotoViewController = segue.destination, segue.identifier == "segue" {
                controller.completion = { [unowned self] image in
                    self.photo.image = image
                }
        }
    }

}
