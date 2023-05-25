//
//  PhotosDetailViewController.swift
//  FriendZone
//
//  Created by ROMAN VRONSKY on 24.05.2023.
//

import UIKit

class PhotosDetailViewController: UIViewController {
    
    var indexPath: IndexPath
    
    init(indexPath: IndexPath) {
        self.indexPath = indexPath
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private lazy var layout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        return layout
    }()
    
    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.register(PhotosCollectionViewCell.self, forCellWithReuseIdentifier: PhotosCollectionViewCell.identifire)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.isPagingEnabled = true
       
        return collectionView
    }()

    private lazy var closeButton = ButtonWithSystemImage(background: nil, image: "arrow.backward.to.line", imageSize: 14, symbolScale: .small, tintcolor: .buttonColor)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        closeButton.tapButton = { [weak self] in
            self?.navigationController?.dismiss(animated: true)
        }
       
        //performBatchUpdates() { _ in
//            self.collectionView.scrollToItem(at: self.indexPath, at: .centeredHorizontally, animated: false)
//        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        collectionView.performBatchUpdates(nil) { _ in  self.collectionView.scrollToItem(at: self.indexPath, at: .right, animated: false)
        }
    }
    private func setupView() {
        self.view.backgroundColor = .white
        self.view.addSubview(collectionView)
        self.view.addSubview(closeButton)
        NSLayoutConstraint.activate([
        
            self.closeButton.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 16),
            self.closeButton.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 16),
            
            self.collectionView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
            self.collectionView.leftAnchor.constraint(equalTo: self.view.leftAnchor),
            self.collectionView.rightAnchor.constraint(equalTo: self.view.rightAnchor),
            self.collectionView.heightAnchor.constraint(equalTo: self.collectionView.widthAnchor),
            
        ])
    }

}
extension PhotosDetailViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
        func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            posts.count
        }
        
        func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotosCollectionViewCell.identifire, for: indexPath) as! PhotosCollectionViewCell
//            collectionView.scrollToItem(at: self.indexPath, at: .centeredHorizontally, animated: false)
            cell.setup(model: posts[indexPath.row])
            return cell
        }
        
        func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
            
            let itemWidth = (collectionView.frame.width)
            return CGSize(width: itemWidth, height: itemWidth)
        }

}
