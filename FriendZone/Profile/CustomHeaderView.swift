//
//  CustomHeader.swift
//  FriendZone
//
//  Created by ROMAN VRONSKY on 23.05.2023.
//

import UIKit

class CustomHeaderView: UIView {
    
    static let identifire = "HeaderView"
    
     func reload() {
        self.collectionView.reloadData()
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
//         collectionView.backgroundColor = .white
         collectionView.showsHorizontalScrollIndicator = false
         collectionView.register(PhotosCollectionViewCell.self, forCellWithReuseIdentifier: PhotosCollectionViewCell.identifire)
        collectionView.dataSource = self
        collectionView.delegate = self
         return collectionView
     }()
    
    var label = CustomLabel(inform: "Header", size: 20, weight: .bold, color: .black)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
      
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        self.addSubview(collectionView)
//        self.addSubview(label)
        
        NSLayoutConstraint.activate([
        
            self.collectionView.topAnchor.constraint(equalTo: self.topAnchor),
            self.collectionView.leftAnchor.constraint(equalTo: self.leftAnchor),
            self.collectionView.rightAnchor.constraint(equalTo: self.rightAnchor),
            self.collectionView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            self.collectionView.heightAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.3)
            
//            self.label.centerXAnchor.constraint(equalTo: self.centerXAnchor),
//            self.label.centerYAnchor.constraint(equalTo: self.centerYAnchor)
            
        ])
    }
}
extension CustomHeaderView: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
   
//    func numberOfSections(in collectionView: UICollectionView) -> Int {
//        1
//    }
//
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        posts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotosCollectionViewCell.identifire, for: indexPath) as! PhotosCollectionViewCell
        cell.setup(model: posts[indexPath.row])
        
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let itemWidth = (collectionView.frame.width - 50) / 4
       
        
        return CGSize(width: itemWidth, height: itemWidth)
        
    }
    
    
}
