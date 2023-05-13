//
//  ProfileView.swift
//  FriendZone
//
//  Created by ROMAN VRONSKY on 14.05.2023.
//

import UIKit

protocol ProfileViewDelegate: AnyObject {
    func changeLayout()
    func pushMapView()
}

final class ProfileView: UIView {
    
    private lazy var headerView: UIView = {
        let headerView = UIView()
        headerView.translatesAutoresizingMaskIntoConstraints = false
        headerView.backgroundColor = .systemGray5
        return headerView
    }()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 50
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 50, right: 0)
        tableView.dragInteractionEnabled = true
        return tableView
    }()
    
    private lazy var mapButton: UIButton = {
        let button  = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(tapMapButton), for: .touchUpInside)
        button.setImage(UIImage(named: "buttonGeo"), for: .normal)
        return button
    }()
    
    lazy var avatarImage: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = .orange
        imageView.contentMode = .scaleToFill
        imageView.layer.borderWidth = 3
        imageView.layer.borderColor = UIColor.white.cgColor
        imageView.clipsToBounds = true
        imageView.isUserInteractionEnabled = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.zPosition = .greatestFiniteMagnitude
        return imageView
    }()
    
    lazy var nameLabel: UILabel = {
        let nameLabel = UILabel(frame: CGRect(x: 152, y: 27, width: 100, height: 21.5))
        nameLabel.font = UIFont(name: "bold", size: 18)
        nameLabel.textColor = .createColor(light: .black, dark: .white)
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        return nameLabel
    }()
    
    lazy var disctiptionLabel: UILabel = {
        let discriptionLabel = UILabel(frame: CGRect(x: 152 , y: 58.5, width: 100, height: 21.5))
        discriptionLabel.font = UIFont(name: "regular", size: 14)
        discriptionLabel.textColor = .createColor(light: .gray, dark: .white)
        discriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        return discriptionLabel
    }()
    
    lazy var stackView: UIStackView = {
        let stackView = UIStackView(frame: CGRect(x: 152, y: 27, width: 100, height: 73))
        stackView.distribution = .fillEqually
        stackView.spacing = 20
        stackView.axis = .vertical
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    
    lazy var setStatusButton: UIButton = {
        let button = UIButton(frame: CGRect(x: 16, y: 166, width: 100, height: 50))
        button.layer.cornerRadius = 10
        button.backgroundColor = .systemBlue
        button.setTitle("Показать статус", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.layer.shadowOffset = CGSize(width: 4, height: 4)
        button.layer.shadowRadius = 4
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOpacity = 0.7
        button.addTarget(self, action: #selector(buttonPressed), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    lazy var statusTextField: UITextField = {
        let status = UITextField(frame: CGRect(x: 152, y: 110, width: 100, height: 40))
        status.textColor = .black
        status.layer.cornerRadius = 12
        status.layer.borderWidth = 1
        status.layer.borderColor = UIColor.black.cgColor
        status.font = UIFont(name: "regular", size: 15)
        status.backgroundColor = .white
        status.attributedPlaceholder = NSAttributedString(string: " ", attributes: [NSAttributedString.Key.foregroundColor: UIColor.gray ])
        status.addTarget(self, action: #selector(self.statusTextChanged), for: .editingChanged)
        status.textAlignment = .center
        status.clearsOnBeginEditing = true
        //        status.becomeFirstResponder()
        status.translatesAutoresizingMaskIntoConstraints = false
        return status
    }()
    
    weak var delegate: ProfileViewDelegate?
    var statusText: String = " "
    
    @objc func statusTextChanged(_ textField: UITextField) {
        
        statusText = textField.text ?? "No text"
        
    }
    @objc func buttonPressed() {
        
        disctiptionLabel.text = statusText
        statusTextField.resignFirstResponder()
        statusTextField.placeholder = ""
        statusTextField.text = ""
        
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.setupView()
        self.setupGesture()
        self.gestureAvatar()
        Timer.scheduledTimer(withTimeInterval: 5, repeats: false) { [weak self] timer  in
            self?.flashStatusTextField()
            timer.invalidate()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        self.avatarImage.layer.cornerRadius = self.avatarImage.frame.height/2
    }
    
    private func headerViewConstraints() -> [NSLayoutConstraint] {
        let topConstraint = self.headerView.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor)
        let leftConstraint = self.headerView.leftAnchor.constraint(equalTo: self.safeAreaLayoutGuide.leftAnchor)
        let rightConstraint = self.headerView.rightAnchor.constraint(equalTo: self.safeAreaLayoutGuide.rightAnchor)
        let heightConsraint = self.headerView.heightAnchor.constraint(equalToConstant: 220)
        
        return [topConstraint, leftConstraint, rightConstraint, heightConsraint]
    }
    
    func avatarViewConstraint() -> [NSLayoutConstraint] {
        let topConstraint = self.avatarImage.topAnchor.constraint(equalTo: self.headerView.topAnchor, constant: 16)
        let leadingConstraint = self.avatarImage.leadingAnchor.constraint(equalTo: self.headerView.leadingAnchor, constant: 16)
        let widthConstraint = self.avatarImage.widthAnchor.constraint(lessThanOrEqualTo: self.headerView.widthAnchor, multiplier: 0.2415)
        let heightAnchor = self.avatarImage.heightAnchor.constraint(equalTo: self.avatarImage.widthAnchor)
        
        return [topConstraint,leadingConstraint, widthConstraint, heightAnchor ]
    }
    
    private func stackViewConstraint() -> [NSLayoutConstraint] {
        let topConstraint = self.stackView.topAnchor.constraint(equalTo: self.headerView.topAnchor, constant:27)
        let widthConstraint = self.stackView.widthAnchor.constraint(equalTo: self.headerView.widthAnchor, multiplier: 0.57)
        let leadingConstraint = self.stackView.leadingAnchor.constraint(equalTo: self.avatarImage.trailingAnchor, constant: 20)
        return [topConstraint, widthConstraint, leadingConstraint]
    }
    
    private func statusTextFieldConstraints() -> [NSLayoutConstraint] {
        let topConstraint = self.statusTextField.topAnchor.constraint(equalTo: self.stackView.bottomAnchor, constant: 16)
        let leadingConstraint = self.statusTextField.leadingAnchor.constraint(equalTo: self.stackView.leadingAnchor)
        let heightConstraint = self.statusTextField.heightAnchor.constraint(equalToConstant: 40)
        let widthConstraint = self.statusTextField.widthAnchor.constraint(equalTo: self.headerView.widthAnchor, multiplier: 0.57)
        return [topConstraint, leadingConstraint, heightConstraint, widthConstraint]
    }
    private func buttonConstraints() -> [NSLayoutConstraint] {
        let topConstraint = self.setStatusButton.topAnchor.constraint(greaterThanOrEqualTo: self.statusTextField.bottomAnchor, constant: 16)
        let leadingConstraint = self.setStatusButton.leadingAnchor.constraint(equalTo: self.headerView.leadingAnchor, constant: 16)
        let centerConstraint = self.setStatusButton.centerXAnchor.constraint(equalTo: self.headerView.centerXAnchor)
        let bottomConstraint = self.setStatusButton.bottomAnchor.constraint(equalTo: self.headerView.bottomAnchor, constant: -5)
        let heightConstraint = self.setStatusButton.heightAnchor.constraint(equalToConstant: 50)
        return [topConstraint, leadingConstraint, heightConstraint, bottomConstraint, centerConstraint ]
    }
    
    private func mapButtonConstraints() -> [NSLayoutConstraint] {
        let topConstraint = self.mapButton.topAnchor.constraint(equalTo: self.headerView.topAnchor,constant: 16)
        let trailingConstraint = self.mapButton.trailingAnchor.constraint(equalTo: self.headerView.trailingAnchor, constant: -16)
        let widthConstraint = self.mapButton.widthAnchor.constraint(equalTo: self.headerView.widthAnchor, multiplier: 0.1)
        let heightConstraint = self.mapButton.heightAnchor.constraint(equalTo: self.mapButton.widthAnchor)
        
        return [topConstraint, trailingConstraint, widthConstraint, heightConstraint]
    }
    
    private func tableViewConstaints() -> [NSLayoutConstraint] {
        let topConstraint = self.tableView.topAnchor.constraint(equalTo: self.headerView.bottomAnchor)
        let leftConsraint = self.tableView.leftAnchor.constraint(equalTo: self.leftAnchor)
        let rightConsraint = self.tableView.rightAnchor.constraint(equalTo: self.rightAnchor)
        let bottomConstraint = self.tableView.bottomAnchor.constraint(equalTo: self.safeAreaLayoutGuide.bottomAnchor)
        
        return [topConstraint, leftConsraint, rightConsraint, bottomConstraint ]
    }
    
    private func setupView() {
        self.addSubview(self.headerView)
        self.addSubview(self.tableView)
        self.headerView.addSubview(self.avatarImage)
        self.headerView.addSubview(self.stackView)
        self.headerView.addSubview(self.setStatusButton)
        self.headerView.addSubview(self.mapButton)
        self.headerView.addSubview(statusTextField)
        self.stackView.addArrangedSubview(self.nameLabel)
        self.stackView.addArrangedSubview(self.disctiptionLabel)
        
        let mapButtonConstraints = self.mapButtonConstraints()
        let hederViewConsraints = self.headerViewConstraints()
        let tableViewConstaints = self.tableViewConstaints()
        let avatarViewConstraints = self.avatarViewConstraint()
        let stackViewConstraints = self.stackViewConstraint()
        let statusTextFieldConstraints = self.statusTextFieldConstraints()
        let buttonConstraints = self.buttonConstraints()
        
        
        NSLayoutConstraint.activate(hederViewConsraints + tableViewConstaints + avatarViewConstraints + stackViewConstraints + statusTextFieldConstraints + buttonConstraints + mapButtonConstraints )
    }
    
    
    
    func reload() {
        self.tableView.reloadData()
    }
    
    func configureTableView(dataSource: UITableViewDataSource,
                            delegate: UITableViewDelegate) {
        tableView.dataSource = dataSource
        tableView.delegate = delegate
        tableView.register(PostTableViewCell.self, forCellReuseIdentifier: "PostCell")
        tableView.register(PhotosTableViewCell.self, forCellReuseIdentifier: "PhotosCell")
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "DefaultCell")
    }
    
    private func gestureAvatar() {
        let gestureAvatar = UITapGestureRecognizer(target: self, action: #selector(tapAvatar))
        self.avatarImage.addGestureRecognizer(gestureAvatar)
    }
    @objc func tapAvatar() {
        self.delegate?.changeLayout()
    }
    private func setupGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        self.addGestureRecognizer(tapGesture)
    }
    @objc private func hideKeyboard() {
        self.endEditing(true)
        
    }
    
     private func flashStatusTextField() {
        self.statusTextField.layer.borderWidth = 2
        self.statusTextField.layer.borderColor = UIColor.systemPink.cgColor
        greetingStatus()
    }
    
    @objc private func tapMapButton() {
        self.delegate?.pushMapView()
    }
    
    private func greetingStatus() {
        let greeting = "Напишите статус"
             var count = 0
             var ind = greeting.startIndex
             let times = greeting.count
             Timer.scheduledTimer(
                withTimeInterval: 0.1,
                repeats: true
             ) { [weak self] timer in
                 if count == times {
                     timer.invalidate()
                     self?.statusTextField.layer.borderWidth = 1
                     self?.statusTextField.layer.borderColor = UIColor.black.cgColor
                 } else {
                     let char = greeting[ind]
                     ind = greeting.index(after: ind)
                     self?.statusTextField.placeholder?.append(char)
                 }
                 count += 1
             }
        }
}
