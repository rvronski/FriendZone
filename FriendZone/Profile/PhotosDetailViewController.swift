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
    
    var newY:CGFloat = 0
    var oldY:CGFloat = 0
    var oldX: CGFloat = 0
    
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
        collectionView.dragInteractionEnabled = true
       
        return collectionView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupNavigationBar()
    }
    
    private func setupNavigationBar() {
        
        let leftButton = UIBarButtonItem(barButtonSystemItem: .reply, target: self, action: #selector(popVC))
        leftButton.tintColor = .buttonColor
        navigationItem.leftBarButtonItem = leftButton
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        collectionView.performBatchUpdates(nil) { _ in  self.collectionView.scrollToItem(at: self.indexPath, at: .right, animated: false)
        }
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        guard  let touch = touches.first else {return}
        oldY = collectionView.frame.origin.y
        oldX = collectionView.frame.origin.x
        let location = touch.location(in: self.collectionView)
        if collectionView.bounds.contains(location) {
           //
        }
        
    }
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {
            return
        }
        print("touch")
        let location = touch.location(in: view)
        print(location.x)
       
        collectionView.frame.origin.x = location.x - (collectionView.frame.size.width / 2)
        collectionView.frame.origin.y = location.y - (collectionView.frame.size.height / 2)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        newY = collectionView.frame.origin.y
        
        let location = newY - oldY
        if location > 0 {
            if location > 500 {
                self.navigationController?.dismiss(animated: true)
            } else {
                collectionView.frame.origin.y = oldY
                collectionView.frame.origin.x = oldX
            }
        } else if location < 0  {
            if location < 500 {
                self.navigationController?.dismiss(animated: true)
            } else {
                collectionView.frame.origin.y = oldY
                collectionView.frame.origin.x = oldX
            }
        }
       
    }
    
    
    private func setupView() {
        self.view.backgroundColor = .white
        self.view.addSubview(collectionView)

        NSLayoutConstraint.activate([
        
            self.collectionView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
            self.collectionView.leftAnchor.constraint(equalTo: self.view.leftAnchor),
            self.collectionView.rightAnchor.constraint(equalTo: self.view.rightAnchor),
            self.collectionView.heightAnchor.constraint(equalTo: self.collectionView.widthAnchor),
            
        ])
    }
 @objc private func popVC() {
     self.navigationController?.dismiss(animated: true)
    }
}
extension PhotosDetailViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
        func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            posts.count
        }
        
        func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotosCollectionViewCell.identifire, for: indexPath) as! PhotosCollectionViewCell
            cell.setup(model: posts[indexPath.row])
            return cell
        }
        
        func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
            
            let itemWidth = (collectionView.frame.width)
            return CGSize(width: itemWidth, height: itemWidth)
        }

}
