//
//  LikeViewController.swift
//  FriendZone
//
//  Created by ROMAN VRONSKY on 13.05.2023.
//

import UIKit
import CoreData

class LikeViewController: UIViewController {
    let fetchResultController: NSFetchedResultsController = {
        let fetchRequest = Like.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "tag", ascending: false)]
        let frc = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: CoreDataManager.shared.persistentContainer.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        return frc
    }()
    
   
    
    
    let coreManager = CoreDataManager.shared
    var post = [Like]()
    private lazy var searchController = UISearchController(searchResultsController: nil)
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 50
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 50, right: 0)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(LikeTableViewCell.self, forCellReuseIdentifier: "LikeCell")
        return tableView
    }()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupNavigationBar()
        searchController.searchResultsUpdater = self
        fetchResultController.delegate = self
        try? self.fetchResultController.performFetch()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        post = coreManager.likes
        self.tableView.reloadData()
        
    }
    private func setupNavigationBar() {
        self.navigationItem.searchController = searchController
        self.navigationController?.navigationBar.isHidden = false
        self.navigationController?.navigationBar.prefersLargeTitles = false
        self.navigationItem.title = "Нравится"
    }
    
    private func setupView() {
        self.view.backgroundColor = .white
        self.view.addSubview(self.tableView)
        
        NSLayoutConstraint.activate([
            self.tableView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            self.tableView.leftAnchor.constraint(equalTo: self.view.leftAnchor),
            self.tableView.rightAnchor.constraint(equalTo: self.view.rightAnchor),
            self.tableView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor),
        
        ])
    }
  
}
extension LikeViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchResultController.sections?[section].numberOfObjects ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
         let cell = tableView.dequeueReusableCell(withIdentifier: "LikeCell", for: indexPath) as! LikeTableViewCell
      
        cell.setup(with: self.fetchResultController.object(at: indexPath))
        
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let likeForDel = self.fetchResultController.object(at: indexPath)
            post.remove(at: indexPath.row)
            guard let tag = likeForDel.tag else { return }
            coreManager.deleteLike(like: likeForDel)
            UserDefaults.standard.set(false, forKey: "isLike" + tag)
            
        } else if editingStyle == .insert {
               //
        }
    }
}

extension LikeViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        post = coreManager.searchLike(searchName: searchController.searchBar.text)
        self.tableView.reloadData()
    }
}

extension LikeViewController: NSFetchedResultsControllerDelegate {
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            self.tableView.insertRows(at: [newIndexPath!], with: .automatic)
        case .delete:
            self.tableView.deleteRows(at: [indexPath!], with: .automatic)
        case .move:
            self.tableView.moveRow(at: indexPath!, to: newIndexPath!)
        case .update:
            self.tableView.reloadRows(at: [indexPath!], with: .automatic)
        @unknown default:
            self.tableView.reloadData()
        }
    }
}

