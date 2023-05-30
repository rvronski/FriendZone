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
    var viewTranslation = CGPoint(x: 0, y: 0)
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
        gestureCollectionView()
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
    
    private func gestureCollectionView() {
        let swipeGesture = UIPanGestureRecognizer(target: self, action: #selector(handleDismiss))
//        swipeGesture.direction = .up
        self.collectionView.addGestureRecognizer(swipeGesture)
    }
    
    private func removeGestureCollectionView() {
        let swipeGesture = UIPanGestureRecognizer()
        //        swipeGesture.direction = .up
        self.collectionView.removeGestureRecognizer(swipeGesture)
    }
    @objc private func handleDismiss(sender: UIPanGestureRecognizer) {
        switch sender.state {
        case .changed:
            viewTranslation = sender.translation(in: self.collectionView)
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1,options: .curveEaseOut) {
                self.collectionView.transform = CGAffineTransform(translationX: self.viewTranslation.x, y: self.viewTranslation.y)
                print(self.viewTranslation)
            }
        case .ended:
            if viewTranslation.y > -150 {
                UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1,options: .curveEaseOut) {
                    self.collectionView.transform = .identity
                }
            } else {
                self.popVC()
            }

        default:
//            self.collectionView.dragInteractionEnabled = false
            self.collectionView.scrollToItem(at: self.indexPath.dropLast(), at: .right, animated: true)
        }
        
//        case .changed:
//            viewTranslation = sender.location(in: collectionView)
//        case .ended:
//            <#code#>
//        case .cancelled:
//            <#code#>
//        case .failed:
//            <#code#>
//        @unknown default:
//            <#code#>
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
