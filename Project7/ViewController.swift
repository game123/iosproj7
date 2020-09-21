//
//  ViewController.swift
//  Project7
//
//  Created by Kevin Chan on 9/16/20.
//  Copyright © 2020 Visionary. All rights reserved.
//

import UIKit

class ViewController: UITableViewController {
    var petitions = [Petition]()
    var petitionsFiltered = [[String]]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let urlString: String
        
//        Show right bar item
        navigationItem.rightBarButtonItem =
            UIBarButtonItem(title: "Credits", style: .plain, target: self, action: #selector(showInfo))
        
        navigationItem.leftBarButtonItem =
            UIBarButtonItem(title: "Filter", style: .plain, target: self, action: #selector(filterContent))
        
        if navigationController?.tabBarItem.tag == 0 {
            urlString = "https://api.whitehouse.gov/v1/petitions.json?limit=100"
//            urlString = "https://www.hackingwithswift.com/samples/petitions-1.json"
        } else {
            urlString = "https://api.whitehouse.gov/v1/petitions.json?signatureCountFloor=10000&limit=100"
//            urlString = "https://www.hackingwithswift.com/samples/petitions-2.json"
        }
        
        if let url = URL(string: urlString) {
            if let data = try? Data(contentsOf: url) {
                parse(json: data)
                return
            }
        }
        showError()
        
        // Do any additional setup after loading the view.
    }
    
    @objc func filterContent() {

        let ac = UIAlertController(title: "Filter with...", message: nil, preferredStyle: .alert)
        ac.addTextField()
        let submitAction = UIAlertAction(title: "Submit", style: .default) {
            [weak self, weak ac] _ in
            guard let filteredBy = ac?.textFields?[0].text else { return }
            self?.submit(filteredBy)
        }
        ac.addAction(submitAction)
        present(ac, animated: true)

    }
    

    
    
    

    func submit(_ filteredBy: String) {
        petitionsFiltered.removeAll()
        for petition in petitions {
            let titleLower = petition.title.lowercased()
            let bodyLower = petition.body.lowercased()
            if titleLower.contains(filteredBy) || bodyLower.contains(filteredBy) {
                let title = petition.title
                let body = petition.body
                let group = [title, body]
                petitionsFiltered.append(group)
            }
        }
        tableView.reloadData()
    }
    
//    func showAll(answer: String) {
//        filteredPetitions = petitions
//        tableView.reloadData()
//    }
    
    @objc func showInfo() {
        var infoStr: String
        infoStr = "The content here is from The People API of the Whitehouse"
        
        let qc = UIAlertController(title: "Content Source", message: infoStr, preferredStyle: .alert)
        qc.addAction(UIAlertAction(title: "Ok", style: .default ))
        present(qc, animated: true)
    }
    
    
    func showError() {
        let ac = UIAlertController(title: "Loading error", message: "There was a problem load the feed; please check your connection and try again.", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
    }
    
    func parse(json: Data) {
        let decoder = JSONDecoder()
        
        if let jsonPetitions = try? decoder.decode(Petitions.self, from: json) {
            petitions = jsonPetitions.results
            tableView.reloadData()
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if petitionsFiltered.isEmpty {
            return petitions.count
        } else {
            return petitionsFiltered.count
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        if petitionsFiltered.isEmpty {
            let petition = petitions[indexPath.row]
            cell.textLabel?.text = petition.title
            cell.detailTextLabel?.text = petition.body
        } else {
            let petition = petitionsFiltered[indexPath.row]
            cell.textLabel?.text = petition[0]
            cell.detailTextLabel?.text = petition[1]
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = DetailViewController()
        vc.detailItem = petitions[indexPath.row]
        navigationController?.pushViewController(vc, animated: true)
    }

}

