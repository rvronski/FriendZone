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
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 10
        layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
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
        return collectionView
    }()

    private lazy var closeButton = ButtonWithSystemImage(background: nil, image: "arrow.backward.to.line", imageSize: 14, symbolScale: .small, tintcolor: .buttonColor)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        closeButton.tapButton = { [weak self] in
            self?.view.backgroundColor = .clear
            self?.navigationController?.dismiss(animated: true)
            
        }

    }
    private func setupView() {
        self.view.backgroundColor = .white
        self.view.addSubview(collectionView)
        self.collectionView.addSubview(closeButton)
        NSLayoutConstraint.activate([
        
            self.closeButton.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 16),
            self.closeButton.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: -16),
            
            self.collectionView.topAnchor.constraint(equalTo: self.view.topAnchor),
            self.collectionView.leftAnchor.constraint(equalTo: self.view.leftAnchor),
            self.collectionView.rightAnchor.constraint(equalTo: self.view.rightAnchor),
            self.collectionView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            
        ])
    }

}
extension PhotosDetailViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
        func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            posts.count
        }
        
        func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotosCollectionViewCell.identifire, for: indexPath) as! PhotosCollectionViewCell
            cell.setup(model: posts[self.indexPath.row])
            return cell
        }
        
        func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
            
            let itemWidth = (collectionView.frame.width - 20)
            
            return CGSize(width: itemWidth, height: itemWidth)
            
        }
}
