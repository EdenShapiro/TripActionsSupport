//
//  PlaceDetailsView.swift
//  TripActionsSupport
//
//  Created by Eden on 2/1/18.
//  Copyright © 2018 Eden. All rights reserved.
//

import UIKit

class PlaceDetailsView: UIView, UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate {
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var tableView: UITableView!
    var initialTouchPoint: CGPoint = CGPoint(x: 0,y: 0)
    var delegate: DrawerDelegate!
    var placeDetails: PlaceDetails?
    var place: Place! {
        didSet {
            setUpUI()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadFromXib()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadFromXib()
    }
    
    func loadFromXib() {
        Bundle.main.loadNibNamed("PlaceDetailsView", owner: self, options: nil)
        contentView.frame = bounds
        addSubview(contentView)
        tableView.delegate = self
//        tableView.dataSource = self
        
        let panDownToDismissGesture = UIPanGestureRecognizer(target: self, action: #selector(panDownToDismiss))
        panDownToDismissGesture.delegate = self
        self.addGestureRecognizer(panDownToDismissGesture)
        
    }
    
    func setUpUI(){
        
        tableView.register(UINib(nibName: "DetailCell", bundle: nil), forCellReuseIdentifier: "DetailCell")
        tableView.isScrollEnabled = false
        tableView.estimatedRowHeight = 80
        tableView.rowHeight = UITableViewAutomaticDimension
        
        let headerView = DetailsHeaderView(frame: CGRect(x: 0, y: 0, width: self.bounds.width, height: 294))
        if let name = place.name {
            headerView.placeNameLabel.text = place.name!
        }
        
        if let types = place.types, types.count > 0 {
            headerView.placeTypeLabel.text = types[0].capitalized
        } else {
            headerView.placeTypeLabel.text = ""
        }
        if let photoRef = place.photoReference {
            PlacesClient.sharedInstance.getPhotoForReference(photoReference: photoRef, maxWidth: Int(self.bounds.width), maxHeight: 215, success: { (image) in
                headerView.placeHeaderImageView.image = image
            }, failure: { (errString, err) in
                print(errString)
            })
            
            tableView.tableHeaderView = headerView
        }
        
        headerView.setRadiusWithShadow()
        
        
        let leadingConstraint = NSLayoutConstraint(item: headerView, attribute: NSLayoutAttribute.leading, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.leading, multiplier: 1, constant: 0)
        
        let trailingConstraint = NSLayoutConstraint(item: headerView, attribute: NSLayoutAttribute.trailing, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.trailing, multiplier: 1, constant: 0)
        
        let topConstraint = NSLayoutConstraint(item: headerView, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.top, multiplier: 1, constant: 0)
        
        
        addConstraints([leadingConstraint, trailingConstraint, topConstraint])
        
        tableView.separatorStyle = .none

        
        tableView.reloadData()
        layoutIfNeeded()

    
    }
    

    
    // MARK: - Table view data source
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: DetailCell!
        
        if var c = tableView.dequeueReusableCell(withIdentifier: "DetailCell", for: indexPath) as? DetailCell {
            cell = c
        } else {
            cell = DetailCell(style: .default, reuseIdentifier: "DetailCell")
        }
        print("Switch called!")
        switch indexPath.row {
        case 0:
            print(indexPath.row)
            cell.iconImageView.image = #imageLiteral(resourceName: "Pin")
            cell.infoTextLabel.text = place.formattedAddress!
            configureCellForNormalText(cell: cell)
        case 1:
            print(indexPath.row)
            cell.iconImageView.image = #imageLiteral(resourceName: "Door")
            cell.infoTextLabel.text = place.openNow ? "Open now":"Now closed" //placeDetails?.openHours
            configureCellForNormalText(cell: cell)

        case 2:
            print(indexPath.row)
            cell.iconImageView.image = #imageLiteral(resourceName: "Pricetag")
            if let price = place.priceLevel {
                cell.infoTextLabel.text = String(repeating: "$", count: price)
            } else {
                cell.infoTextLabel.text = ""
            }
            configureCellForNormalText(cell: cell)

        case 3:
            cell.iconImageView.image = #imageLiteral(resourceName: "Star")
            cell.infoTextLabel.isHidden = true
            cell.yelpRatingImageView.isHidden = false
            cell.yelpReviewsTextLabel.isHidden = false
            cell.accessoryType = .none
        case 4:
            cell.iconImageView.image = #imageLiteral(resourceName: "Membership Card")
            configureCellForNormalText(cell: cell)
            cell.accessoryType = .detailButton
            cell.infoTextLabel.text = "AAA, ABA, AARP, CA Farm Bureau"
            
//        case 5:
//            cell.iconImageView.image =
        default:
            cell.iconImageView.image = UIImage()
        }
        return cell
    }
    
    func configureCellForNormalText(cell: DetailCell){
        cell.infoTextLabel.isHidden = false
        cell.yelpRatingImageView.isHidden = true
        cell.yelpReviewsTextLabel.isHidden = true
        cell.accessoryType = .none
    }
    
//    func numberOfSections(in tableView: UITableView) -> Int {
//        return 2
//    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 7
    }
    
    @objc func panDownToDismiss(sender: UIPanGestureRecognizer){
        let touchPoint = sender.location(in: self.window)

        if sender.state == UIGestureRecognizerState.began {
            initialTouchPoint = touchPoint
        } else if sender.state == UIGestureRecognizerState.changed {
            if touchPoint.y - initialTouchPoint.y > 0 {
                self.frame = CGRect(x: 0, y: touchPoint.y - initialTouchPoint.y, width: self.frame.size.width, height: self.frame.size.height)
            }
        } else if sender.state == UIGestureRecognizerState.ended || sender.state == UIGestureRecognizerState.cancelled {
            if touchPoint.y - initialTouchPoint.y > 100 {
//                FIXME
//                self.dismiss(animated: true, completion: nil)
//                self.isHidden = true
                self.delegate.closeDrawer(completion: nil)
            } else {
                UIView.animate(withDuration: 0.3, animations: {
                    self.frame = CGRect(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height)
                })
            }
        }
    }
    
    
}

//        private var userList = [User1]()
//        private var activityList = [Activity]()
    
//        fileprivate var tableViewData = [SectionWithItems]()
//        private var userSection: SectionWithItems!
//        private var activitySection: SectionWithItems!
//        var initialTouchPoint: CGPoint = CGPoint(x: 0,y: 0)
//        private var closeButton: UIButton!

//        var
//        var chatroom: ChatRoom1!
    

    
//        override func viewDidLoad() {
//            super.viewDidLoad()
//
//            tableView.delegate = self
//            tableView.dataSource = self
//            tableView.register(UINib(nibName: "UserCell", bundle: nil), forCellReuseIdentifier: "userCell")
//            tableView.register(UINib(nibName: "MapCell", bundle: nil), forCellReuseIdentifier: "mapCell")
//            tableView.register(UINib(nibName: "ActivityCell", bundle: nil), forCellReuseIdentifier: "activityCell")
//            tableView.estimatedRowHeight = 56
//            tableView.rowHeight = UITableViewAutomaticDimension
//
//            setupUsers()
//
//            setupActivities()
//
//            setupUI()
//
//
//            if (self.parent as? BottomDrawerVC) == nil  {
//                print("Parent is a chatroom")
//                let panDownToDismissGesture = UIPanGestureRecognizer(target: self, action: #selector(panDownToDismiss))
//                panDownToDismissGesture.delegate = self
//                view.addGestureRecognizer(panDownToDismissGesture)
//            }
//        }
//




//
//        func setupUsers(){
//            let users = chatroom.isAroundMe ? chatroom.localUsers : chatroom.users
//            users?.keys.forEach({ (userGuid) in
//
//                ChatSpotClient.getUserProfile(userGuid: userGuid, success: { (user) in
//
//                    if (self.userSection == nil) {
//                        let seeAll = User1()
//                        seeAll.name = "See All Members"
//                        self.userList.append(seeAll)
//                        self.userSection = SectionWithItems("Members", self.userList)
//                        if self.tableViewData.count > 0 {
//                            self.tableViewData.insert(self.userSection, at: self.tableViewData.count - 1)
//                        } else {
//                            self.tableViewData.insert(self.userSection, at: self.tableViewData.count)
//                        }
//
//                    }
//                    self.userList.insert(user, at: self.userList.count - 1)
//
//                    if (self.userList.count <= 3) {
//                        self.userSection.sectionItems = self.userList
//                        self.tableView.reloadData()
//                    }
//
//                }, failure: {})
//            })
//        }
//
//        func setupActivities(){
//            ChatSpotClient.getActivities(roomGuid: chatroom.guid, success: { (activities) in
//
//                if (activities.count == 0) {
//                    return
//                }
//
//                self.activitySection = SectionWithItems("Activities", Array(activities.prefix(2)))
//                let seeAll = Activity()
//                seeAll.activityName = "See All Activities"
//                self.activitySection.sectionItems.append(seeAll)
//                let position = self.chatroom.isAroundMe ? 0 : 1
//                self.tableViewData.insert(self.activitySection, at: position)
//                self.tableView.reloadData()
//            }) {}
//
//            if chatroom.users?.index(forKey: ChatSpotClient.userGuid) != nil {
//                tableViewData.append(SectionWithItems(" ", ["Leave \(chatroom.name!)"]))
//            } else {//if user doesn't belong to chatspot
//                // TODO: add join button
//            }
//        }
//
//
//
//
//
//
//        func close() {
//            if let parentVC = self.parent as? BottomDrawerVC {
//                parentVC.closeDrawer(completion: nil)
//            } else {
//                self.dismiss(animated: true, completion: nil)
//            }
//        }
//
//        private func setupUI() { //gray color: 247, 247, 247
//            tableView.backgroundColor = UIColor.ChatSpotColors.LighterGray
//            tableView.separatorColor = UIColor.lightGray
//            tableView.tableFooterView = UIView()
//
//            let headerView = UIImageView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 200))
//            headerView.image = #imageLiteral(resourceName: "image-placeholder")
//            headerView.contentMode = .scaleAspectFill
//            headerView.clipsToBounds = true
//            DispatchQueue.global(qos: .userInitiated).async {
//                if let urlString = self.chatroom.fullSizeBanner, let url = URL(string: urlString), let data = try? Data(contentsOf: url), let image = UIImage(data: data) {
//                    print("Banner height - \(image.size.height)")
//                    DispatchQueue.main.async {
//                        headerView.image = image
//
//                    }
//                }
//            }
//
//            let chatroomTitleLabel = UILabel(frame: CGRect(x: 16, y: 16, width: 150, height: 130))
//            chatroomTitleLabel.attributedText = NSAttributedString(string: "\(self.chatroom.name!)", attributes: [NSForegroundColorAttributeName: UIColor.white, NSFontAttributeName: UIFont.Chatspot.extraLarge])
//            chatroomTitleLabel.numberOfLines = 3
//            chatroomTitleLabel.sizeToFit()
//
//
//
//
//            // Add a gradient
//            let gradient: CAGradientLayer = CAGradientLayer()
//            gradient.frame = headerView.frame
//            gradient.colors = [UIColor.clear.cgColor, UIColor.black.cgColor]
//            gradient.locations = [0.2, 1]
//            headerView.layer.insertSublayer(gradient, at: 0)
//            chatroomTitleLabel.frame.origin.y = headerView.frame.maxY - (16 + chatroomTitleLabel.frame.height)
//
//            closeButton = UIButton(frame: CGRect(x: headerView.frame.origin.x + 24, y: headerView.frame.origin.y + 28, width: 24, height: 24))
//            closeButton.setImage(#imageLiteral(resourceName: "xIcon"), for: .normal)
//            closeButton.changeImageViewTo(color: .white)
//            closeButton.sizeToFit()
//            closeButton.addTarget(self, action: #selector(close), for: .touchUpInside)
//
//            headerView.addSubview(chatroomTitleLabel)
//            headerView.insertSubview(closeButton, at: 0)
//
//            self.tableView.tableHeaderView = headerView
//            headerView.isUserInteractionEnabled = true
//            self.tableView.tableHeaderView?.isUserInteractionEnabled = true
//
//
//            self.tableView.tableHeaderView!.transform = self.tableView.transform
//
//
//            self.view.layoutIfNeeded()
//
//            if !chatroom.isAroundMe,
//                let latitude = chatroom.latitude,
//                let longitude = chatroom.longitude {
//
//                tableViewData.insert(SectionWithItems("Location", [CLLocationCoordinate2D(latitude: latitude, longitude: longitude)]), at: 0)
//            }
//        }
//
//
//
//    extension ChatRoomDetailVC: UITableViewDelegate, UITableViewDataSource {
//
//
//        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//            return tableViewData[section].sectionItems.count
//        }
//
//        func numberOfSections(in tableView: UITableView) -> Int {
//            return tableViewData.count
//        }
//
//        func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//            return tableViewData[section].sectionTitle
//        }
//
//        // TODO: allow cells to be clicked and show the extended lists
//        func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//            let dataItem = tableViewData[indexPath.section]
//            if let rows = dataItem.sectionItems as? [String],
//                rows.first == "Leave \(chatroom.name!)" {
//                leaveRoom()
//            } else if let rows = dataItem.sectionItems as? [User1] {
//                //            let cell = tableView.cellForRow(at: indexPath) as! UserCell
//                let user = rows[indexPath.row]
//                let storyboard = UIStoryboard(name: "Main", bundle: nil)
//                //            performSegue(withIdentifier: "ChatroomDetailToProfileSegue", sender: cell)
//                let profileVC = storyboard.instantiateViewController(withIdentifier: "ProfileVC") as! ProfileVC
//                profileVC.otherUserGuid = user.guid
//                profileVC.user = user
//                profileVC.pushed = true
//                self.navigationController?.pushViewController(profileVC, animated: true)
//                //                print("there is a nav")
//                //                self.navigationController?.pushViewController(profileVC, animated: true)
//                //            } else {
//                //                print("there isn't a nav")
//                //                if let parentVC = self.parent as? BottomDrawerVC {
//                //                    parentVC.navigationController?.pushViewController(profileVC, animated: true)
//                //                } else if let parentVC = self.parent as? ChatRoomVC {
//                //                    parentVC.navigationController?.pushViewController(profileVC, animated: true)
//                //
//                //                }
//                //            }
//
//            } else if let rows = dataItem.sectionItems as? [Activity] {
//
//            }
//
//            tableView.deselectRow(at: indexPath, animated:true)
//        }
//
//        func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//            let dataItem = tableViewData[indexPath.section]
//            if (dataItem.sectionTitle == "Location") {
//                return 125
//            }
//            return UITableViewAutomaticDimension
//        }
//
//        func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//            return 40
//        }
//
//        func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
//            if let headerTitle = view as? UITableViewHeaderFooterView {
//                headerTitle.textLabel?.font = UIFont(name: UIFont.AppFonts.bigRegular, size: UIFont.AppSizes.larger)
//                headerTitle.textLabel?.textColor = UIColor.ChatSpotColors.LightGray
//                headerTitle.tintColor = UIColor.ChatSpotColors.LighterGray
//            }
//        }
//

//
//
//
//}
//
//class SectionWithItems {
//
//    var sectionTitle: String!
//    var sectionItems: [Any]!
//
//    init(_ sectionTitle: String, _ sectionItems: [Any]) {
//        self.sectionTitle = sectionTitle
//        self.sectionItems = sectionItems
//    }
//}

