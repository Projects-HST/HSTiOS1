//
//  Home.swift
//  SkilEx
//
//  Created by Happy Sanz Tech on 28/06/19.
//  Copyright © 2019 Happy Sanz Tech. All rights reserved.
//

import UIKit
import SwiftyJSON
import MBProgressHUD
import Alamofire
import SDWebImage

class Home: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UITextFieldDelegate
{
    var bannerImage = [String]()
    var index = 0
    var inForwardDirection = true
    var timer: Timer?
    var categoeryArr = [Categories]()
    var banner_Image = [BannerImages]()
    var subcategoeryArr = [String]()
    var subcategoeryID = [String]()
    var cat_id = String()
    var toptrendingArr = [TopTrendingServices]()
//  var request: Alamofire.Request?
    
    let queue = DispatchQueue(label: "com.company.app.queue", attributes: .concurrent)
    let group = DispatchGroup()
    
    @IBOutlet var bannerCollectionView: UICollectionView!
    @IBOutlet weak var searchTextfield: UITextField!
    @IBOutlet weak var closeBtnImg: UIImageView!
    @IBOutlet var topTrendingCollectionView: UICollectionView!
    @IBOutlet var categoryCollectionView: UICollectionView!
    @IBOutlet var toptrendingHeadingLabel: UILabel!
    @IBOutlet var popularServiceHeadingLabel: UILabel!
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var collectionViewBaseHeight: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        /*temp hide */
        //self.addrightButton()
        /*temp hide */
        //self.request?.resume()
        NotificationCenter.default.addObserver(self, selector: #selector(willEnterForeground),
                                               name: UIApplication.willEnterForegroundNotification,
                                               object: nil)
        self.topTrendingCollectionView.isPagingEnabled = true
        self.topTrendingCollectionView.delegate = self
        self.topTrendingCollectionView.dataSource = self
    }
    
    @objc func willEnterForeground() {
        // do what's needed
//      self.request?.resume()
        self.closeBtnImg.isHidden = true
        self.searchTextfield.isHidden = true
        self.checkAppVersion(versionCode: "5")
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
//      self.request?.resume()
        self.closeBtnImg.isHidden = true
        self.searchTextfield.isHidden = true
        self.checkAppVersion(versionCode: "5")
    }
        
    func checkAppVersion (versionCode:String)
    {
        let url = AFWrapper.BASE_URL + "version_check"
        let parameters = ["version_code": versionCode]
        MBProgressHUD.showAdded(to: self.view, animated: true)
        DispatchQueue.global().async
            {
                do
                {
                    try AFWrapper.requestPOSTURL(url, params: (parameters), headers: nil, success: {
                        (JSONResponse) -> Void in
                        MBProgressHUD.hide(for: self.view, animated: true)
                        print(JSONResponse)
                        let json = JSON(JSONResponse)
//                      let msg = json["msg"].stringValue
                        let status = json["status"].stringValue
                        if status == "success"
                        {
                            self.loadValues()
                        }
                        else
                        {
                            let alertController = UIAlertController(title: LocalizationSystem.sharedInstance.localizedStringForKey(key: "appname_text", comment: ""), message: "A new version of SkilEx is available!", preferredStyle: UIAlertController.Style.alert)
                            
                            let okAction = UIAlertAction(title: "Get it", style: UIAlertAction.Style.default)
                            {
                                UIAlertAction in
                                self.toAppstore ()
                            }
                            
                            alertController.addAction(okAction)
                            self.present(alertController, animated: true, completion: nil)
                        }
                    }) {
                        (error) -> Void in
                        print(error)
                    }
                }
                catch
                {
                    print("Unable to load data: \(error)")
                }
        }
    }
    
    func toAppstore ()
    {
        MBProgressHUD.showAdded(to: self.view, animated: true)
        let myUrl = "https://apps.apple.com/us/app/skilex/id1484596811?ls=1"
           if let url = URL(string: "\(myUrl)"), !url.absoluteString.isEmpty {
               UIApplication.shared.open(url, options: [:], completionHandler: nil)
           }

           // or outside scope use this
           guard let url = URL(string: "\(myUrl)"), !url.absoluteString.isEmpty else {
              return
           }
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
            MBProgressHUD.hide(for: self.view, animated: true)
    }
    
    
    func loadValues ()
    {
        group.enter()
        self.closeBtnImg.isHidden = false
        self.searchTextfield.isHidden = false
        queue.async {
            print("#1 started")
            self.serviceRemoveFromCart(user_master_id: GlobalVariables.shared.user_master_id)
//            MBProgressHUD.showAdded(to: self.view, animated: true)
            Thread.sleep(forTimeInterval: 1)
            print("#1 finished")
            self.group.leave()
        }

        group.enter()
        queue.async {
            print("#2 started")
            self.viewBanners()
            Thread.sleep(forTimeInterval: 1)
            print("#2 finished")
            self.group.leave()
        }
        
        group.enter()
        queue.async {
            print("#3 started")
            self.viewMainCategoery()
            Thread.sleep(forTimeInterval: 1)
            print("#3 finished")
            self.group.leave()
        }
        
        group.enter()
        queue.async {
            print("#4 started")
            self.topTrendingServices()
            Thread.sleep(forTimeInterval: 1)
            print("#4 finished")
            self.group.leave()
        }

        queue.async {
//            MBProgressHUD.hide(for: self.view, animated: true)
            self.group.wait()
            print("#5 finished")
        }

        self.categoryCollectionView.isUserInteractionEnabled = true
        self.topTrendingCollectionView.isUserInteractionEnabled = true
        self.hideKeyboardWhenTappedAround()
        self.searchTextfield.delegate = self
        self.searchTextfield.addShadowToTextField(cornerRadius: 5.0)
        self.searchTextfield.addShadowToTextField(color: UIColor.gray, cornerRadius: 5.0)
        self.preferedLanguage()
    }
    
    func preferedLanguage()
    {
        self.navigationItem.title = LocalizationSystem.sharedInstance.localizedStringForKey(key: "homenavtitle_text", comment: "")
        let attributes = [
            NSAttributedString.Key.foregroundColor: UIColor.gray,
            NSAttributedString.Key.font : UIFont(name: "Helvetica", size: 10)! // Note the !
        ]
        self.searchTextfield.attributedPlaceholder = NSAttributedString(string: LocalizationSystem.sharedInstance.localizedStringForKey(key: "homesearchbar_text", comment: ""), attributes:attributes)
        self.toptrendingHeadingLabel.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "hometoptrendingheading_text", comment: "")
        self.popularServiceHeadingLabel.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "homemostpopularheading_text", comment: "")
        self.categoryCollectionView.reloadData()
        self.topTrendingCollectionView.reloadData()
    }
    
    @objc public override func rightButtonClick()
    {
        self.performSegue(withIdentifier: "notificationOffers", sender: self)
    }
    
    func viewBanners()
    {
        let url = AFWrapper.BASE_URL + "view_banner_list"
        let parameters = ["user_master_id": GlobalVariables.shared.user_master_id]
//        MBProgressHUD.showAdded(to: self.view, animated: true)
        DispatchQueue.global().async
            {
                do
                {
                    try AFWrapper.requestPOSTURL(url, params: (parameters), headers: nil, success: {
                        (JSONResponse) -> Void in
//                        MBProgressHUD.hide(for: self.view, animated: true)
                        print(JSONResponse)
                        let json = JSON(JSONResponse)
                        let msg = json["msg"].stringValue
                        let status = json["status"].stringValue
                        if msg == "View banner list" && status == "success"
                        {
                            if json["banners"].count > 0 {
                                
                                for i in 0..<json["banners"].count {
                                    let banner = BannerImages.init(json: json["banners"][i])
                                    self.banner_Image.append(banner)
                                    let bannerImg = banner.banner_img
                                    self.bannerImage.append(bannerImg!)
                                }
                                    self.startTimer()
                                    self.bannerCollectionView.reloadData()
                            }
                        }
                    }) {
                        (error) -> Void in
                        print(error)
                    }
                }
                catch
                {
                    print("Unable to load data: \(error)")
                }
        }
    }
    
    func topTrendingServices ()
    {
        let url = AFWrapper.BASE_URL + "top_trending_services"
        let parameters = ["user_master_id": GlobalVariables.shared.user_master_id]
//      MBProgressHUD.showAdded(to: self.view, animated: true)
        DispatchQueue.global().async
            {
                do
                {
                    try AFWrapper.requestPOSTURL(url, params: (parameters), headers: nil, success: {
                        (JSONResponse) -> Void in
//                      MBProgressHUD.hide(for: self.view, animated: true)
                        print(JSONResponse)
                        let json = JSON(JSONResponse)
                        let msg = json["msg"].stringValue
                        let msg_en = json["msg_en"].stringValue
                        let msg_ta = json["msg_ta"].stringValue
                        let status = json["status"].stringValue
                        if msg == "View Services" && status == "success"
                        {
                            self.toptrendingArr.removeAll()
                            if json["services"].count > 0 {
                                for i in 0..<json["services"].count {
                                    
                                    let trending = TopTrendingServices.init(json: json["services"][i])
                                    self.toptrendingArr.append(trending)
                                }
                                    self.topTrendingCollectionView.reloadData()
                            }
                        }
                        else
                        {
                            if LocalizationSystem.sharedInstance.getLanguage() == "en"
                            {
                                Alert.defaultManager.showOkAlert(LocalizationSystem.sharedInstance.localizedStringForKey(key: "appname_text", comment: ""), message: msg_en) { (action) in
                                    //Custom action code

                                }
                            }
                            else
                            {
                                Alert.defaultManager.showOkAlert(LocalizationSystem.sharedInstance.localizedStringForKey(key: "appname_text", comment: ""), message: msg_ta) { (action) in
                                    //Custom action code
                                }
                            }
                        }
                    }) {
                        (error) -> Void in
                        print(error)
                    }
                }
                catch
                {
                    print("Unable to load data: \(error)")
                }
        }
    }
    
    func viewMainCategoery()
    {
        let url = AFWrapper.BASE_URL + "view_maincategory"
        let parameters = ["user_master_id": GlobalVariables.shared.user_master_id,"version_code":"3"]
//      MBProgressHUD.showAdded(to: self.view, animated: true)
        DispatchQueue.global().async
            {
                do
                {
                    try AFWrapper.requestPOSTURL(url, params: (parameters), headers: nil, success: {
                        (JSONResponse) -> Void in
//                      MBProgressHUD.hide(for: self.view, animated: true)
                        print(JSONResponse)
                        let json = JSON(JSONResponse)
                        let msg = json["msg"].stringValue
                        let msg_en = json["msg_en"].stringValue
                        let msg_ta = json["msg_ta"].stringValue
                        let status = json["status"].stringValue
                        if msg == "View Category" && status == "success"
                        {
                            self.categoeryArr.removeAll()
                            if json["categories"].count > 0 {
                                for i in 0..<json["categories"].count {
                                    let categoery = Categories.init(json: json["categories"][i])
                                    self.categoeryArr.append(categoery)
                                }
                                    self.categoryCollectionView.reloadData()
                            }
                        }
                        else if msg == "Sorry you have to update latest App!" && status == "error"
                        {
                            let alertController = UIAlertController(title: LocalizationSystem.sharedInstance.localizedStringForKey(key: "appname_text", comment: ""), message: "A new version of SkilEx is available!", preferredStyle: UIAlertController.Style.alert)
                            
                            
                            let okAction = UIAlertAction(title: "Get it", style: UIAlertAction.Style.default)
                            {
                                UIAlertAction in
                                self.toAppstore ()
                            }
                            
                            alertController.addAction(okAction)
                            self.present(alertController, animated: true, completion: nil)
                        }
                        else
                        {
                            if LocalizationSystem.sharedInstance.getLanguage() == "en"
                            {
                                Alert.defaultManager.showOkAlert(LocalizationSystem.sharedInstance.localizedStringForKey(key: "appname_text", comment: ""), message: msg_en) { (action) in
                                    //Custom action code

                                }
                            }
                            else
                            {
                                Alert.defaultManager.showOkAlert(LocalizationSystem.sharedInstance.localizedStringForKey(key: "appname_text", comment: ""), message: msg_ta) { (action) in
                                    //Custom action code
                                }
                            }
                        }
                    }) {
                        (error) -> Void in
                        print(error)
                    }
                }
                catch
                {
                    print("Unable to load data: \(error)")
                }
        }
    }
    
    func serviceRemoveFromCart(user_master_id: String)
    {
        let url = AFWrapper.BASE_URL + "clear_cart"
        let parameters = ["user_master_id": user_master_id]
        DispatchQueue.global().async
            {
                do
                {
                    try AFWrapper.requestPOSTURL(url, params: (parameters), headers: nil, success: {
                        (JSONResponse) -> Void in
                        print(JSONResponse)
                        let json = JSON(JSONResponse)
                        let msg = json["msg"].stringValue
                        let status = json["status"].stringValue
                        if msg == "All Service removed from cart" && status == "success"
                        {
                            print(msg)
                        }
                    }) {
                        (error) -> Void in
                        print(error)
                    }
                }
                catch
                {
                    print("Unable to load data: \(error)")
                }
        }
    }
    

    
    func startTimer() {
        if timer == nil {
            timer = Timer.scheduledTimer(timeInterval: 6.0, target: self, selector: #selector(scrollToNextCell), userInfo: nil, repeats: true);
        }
    }
    
    @objc func scrollToNextCell()
    {
        //scroll to next cell
        let items = bannerCollectionView.numberOfItems(inSection: 0)
        if (items - 1) == index {
            bannerCollectionView.scrollToItem(at: IndexPath(row: index, section: 0), at: UICollectionView.ScrollPosition.right, animated: true)
        } else if index == 0 {
            bannerCollectionView.scrollToItem(at: IndexPath(row: index, section: 0), at: UICollectionView.ScrollPosition.left, animated: true)
        } else {
            bannerCollectionView.scrollToItem(at: IndexPath(row: index, section: 0), at: UICollectionView.ScrollPosition.centeredHorizontally, animated: true)
        }
        if inForwardDirection {
            if index == (items - 1) {
                index -= 1
                inForwardDirection = false
            } else {
                index += 1
            }
        } else {
            if index == 0 {
                index += 1
                inForwardDirection = true
            } else {
                index -= 1
            }
        }
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        if collectionView == self.bannerCollectionView
        {
             return banner_Image.count 
        }
        else if collectionView == self.categoryCollectionView
        {
            return categoeryArr.count
        }
        else
        {
            return toptrendingArr.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        
        if (collectionView == bannerCollectionView)
        {
            let cellA = bannerCollectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! BannerCollectionViewCell
            let bannerImg = banner_Image[indexPath.row]
            let imgUrl = bannerImg.banner_img
//            if imgUrl!.isEmpty == false
//            {
//                let url = URL(string: imgUrl!)
//                DispatchQueue.global().async {
//                    if let data = try? Data(contentsOf: url!) {
//                        if let image = UIImage(data: data) {
//                            DispatchQueue.main.async {
//                                cellA.bannerImageView.image = image
//                            }
//                        }
//                    }
//                }
//            }
            cellA.bannerImageView.sd_setImage(with: URL(string: imgUrl!), placeholderImage: UIImage(named: ""))
            return cellA
        }
        else if (collectionView == self.categoryCollectionView)
        {
            if LocalizationSystem.sharedInstance.getLanguage() == "en"
            {
                let cellC = categoryCollectionView.dequeueReusableCell(withReuseIdentifier: "Categorycell", for: indexPath) as! CategoryCollectionViewCell
              //  cell.cellView.dropShadow(color: .gray, opacity: 0.2, offSet: CGSize(width: -1, height: -1), radius: 0, scale: true, cornerradius: 0)
                let categoery = categoeryArr[indexPath.row]
                cellC.categoeryName.text =  categoery.cat_name
                let imgUrl = categoery.cat_pic_url
//                if imgUrl!.isEmpty == false
//                {
//                    let url = URL(string: imgUrl!)
//                    DispatchQueue.global().async {
//                        if let data = try? Data(contentsOf: url!) {
//                            if let image = UIImage(data: data) {
//                                DispatchQueue.main.async {
//                                    cellC.categoeryImage.image = image
//                                }
//                            }
//                        }
//                    }
//                }
                cellC.categoeryImage.sd_setImage(with: URL(string: imgUrl!), placeholderImage: UIImage(named: ""))
                cellC.cellView.dropShadow(offsetX: 0, offsetY: 1, color: UIColor.gray, opacity: 0.2, radius: 3)
                return cellC
            }
            else
            {
                let cellC = categoryCollectionView.dequeueReusableCell(withReuseIdentifier: "Categorycell", for: indexPath) as! CategoryCollectionViewCell
                //cell.cellView.dropShadow(color: .gray, opacity: 0.2, offSet: CGSize(width: -1, height: -1), radius: 0, scale: true, cornerradius: 0)
                let categoery = categoeryArr[indexPath.row]
                cellC.categoeryName.text =  categoery.cat_ta_name
                let imgUrl = categoery.cat_pic_url
//                if imgUrl!.isEmpty == false
//                {
//                    let url = URL(string: imgUrl!)
//                    DispatchQueue.global().async {
//                        if let data = try? Data(contentsOf: url!) {
//                            if let image = UIImage(data: data) {
//                                DispatchQueue.main.async {
//                                    cellC.categoeryImage.image = image
//                                }
//                            }
//                        }
//                    }
//                }
                cellC.categoeryImage.sd_setImage(with: URL(string: imgUrl!), placeholderImage: UIImage(named: ""))
                cellC.cellView.dropShadow(offsetX: 0, offsetY: 1, color: UIColor.gray, opacity: 0.3, radius: 3)
                return cellC
            }
        }
        else
        {
            if LocalizationSystem.sharedInstance.getLanguage() == "en"
            {
                let cellB = topTrendingCollectionView.dequeueReusableCell(withReuseIdentifier: "TrendingCell", for: indexPath) as! TopTrendingCollectionViewCell
                let trending = toptrendingArr[indexPath.row]
                cellB.categoeryName.text =  trending.service_name
                let imgUrl = trending.service_pic_url
//                if imgUrl!.isEmpty == false
//                {
//                    let url = URL(string: imgUrl!)
//                    DispatchQueue.global().async {
//                        if let data = try? Data(contentsOf: url!) {
//                            if let image = UIImage(data: data) {
//                                DispatchQueue.main.async {
//                                    cellB.categoeryImage.image = image
//                                }
//                            }
//                        }
//                    }
//                }
                cellB.categoeryImage.sd_setImage(with: URL(string: imgUrl!), placeholderImage: UIImage(named: ""))
                return cellB
             }
             else
             {
                let cellB = topTrendingCollectionView.dequeueReusableCell(withReuseIdentifier: "TrendingCell", for: indexPath) as! TopTrendingCollectionViewCell
                let trending = toptrendingArr[indexPath.row]
                cellB.categoeryName.text =  trending.service_ta_name
                let imgUrl = trending.service_pic_url
//                if imgUrl!.isEmpty == false
//                {
//                    let url = URL(string: imgUrl!)
//                    DispatchQueue.global().async {
//                        if let data = try? Data(contentsOf: url!) {
//                            if let image = UIImage(data: data) {
//                                DispatchQueue.main.async {
//                                    cellB.categoeryImage.image = image
//                                }
//                            }
//                        }
//                    }
//                }
                cellB.categoeryImage.sd_setImage(with: URL(string: imgUrl!), placeholderImage: UIImage(named: ""))
                return cellB
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if collectionView == categoryCollectionView
        {
            guard categoryCollectionView.cellForItem(at: indexPath as IndexPath) != nil else { return }
            let index = categoeryArr[indexPath.row]
            cat_id = index.cat_id!
            print(cat_id)
            self.viewSubCategoery(categoeryId: cat_id)
        }
        else if collectionView == topTrendingCollectionView
        {
            guard topTrendingCollectionView.cellForItem(at: indexPath as IndexPath) != nil else { return }
             let index = toptrendingArr[indexPath.row]
             cat_id = index.service_id!
             print(cat_id)
             self.serviceDiscripition(serviceID: cat_id)
        }
    }
    
    func viewSubCategoery (categoeryId: String)
    {
        let url = AFWrapper.BASE_URL + "view_subcategory"
        let parameters = ["main_cat_id": categoeryId]
        MBProgressHUD.showAdded(to: self.view, animated: true)
        DispatchQueue.global().async
            {
                do
                {
                    try AFWrapper.requestPOSTURL(url, params: (parameters), headers: nil, success: {
                        (JSONResponse) -> Void in
                        MBProgressHUD.hide(for: self.view, animated: true)
                        print(JSONResponse)
                        let json = JSON(JSONResponse)
                        let msg = json["msg"].stringValue
                        let msg_en = json["msg_en"].stringValue
                        let msg_ta = json["msg_ta"].stringValue
                        let status = json["status"].stringValue
                        if msg == "View Sub Category" && status == "success"
                        {
                            if json["sub_categories"].count > 0 {
                                
                                self.subcategoeryArr.removeAll()
                                self.subcategoeryID.removeAll()
                                for i in 0..<json["sub_categories"].count
                                {
                                    
                                    let subCategoery = SubCategories.init(json: json["sub_categories"][i])
                                    let subCategoeryID = subCategoery.sub_cat_id
                                    
                                    self.subcategoeryID.append(subCategoeryID!)
                                    if LocalizationSystem.sharedInstance.getLanguage() == "en"
                                    {
                                        let subCategoeryName = subCategoery.sub_cat_name
                                        self.subcategoeryArr.append(subCategoeryName!)
                                    }
                                    else
                                    {
                                        let subCategoeryName = subCategoery.sub_cat_ta_name
                                        self.subcategoeryArr.append(subCategoeryName!)
                                    }
                                }
                                self.performSegue(withIdentifier: "serviceDetail", sender: self)
                                
                              }
                        }
                        else
                        {
                            if LocalizationSystem.sharedInstance.getLanguage() == "en"
                            {
                                Alert.defaultManager.showOkAlert(LocalizationSystem.sharedInstance.localizedStringForKey(key: "appname_text", comment: ""), message: msg_en) { (action) in
                                    //Custom action code
                                }
                            }
                            else
                            {
                                Alert.defaultManager.showOkAlert(LocalizationSystem.sharedInstance.localizedStringForKey(key: "appname_text", comment: ""), message: msg_ta) { (action) in
                                    //Custom action code
                                }
                            }
                        }
                    }) {
                        (error) -> Void in
                        print(error)
                    }
                }
                catch
                {
                    print("Unable to load data: \(error)")
                }
        }
    }
    
    func serviceDiscripition (serviceID:String)
    {
            let url = AFWrapper.BASE_URL + "service_details"
            let parameters = ["service_id": serviceID]
            MBProgressHUD.showAdded(to: self.view, animated: true)
            DispatchQueue.global().async
                {
                    do
                    {
                        try AFWrapper.requestPOSTURL(url, params: (parameters), headers: nil, success: {
                            (JSONResponse) -> Void in
                            MBProgressHUD.hide(for: self.view, animated: true)
                            print(JSONResponse)
                            let json = JSON(JSONResponse)
                            let msg = json["msg"].stringValue
                            let status = json["status"].stringValue
                            if msg == "Service Details" && status == "success"
                            {
                                let servicesdescripition = ServicesDescripition(json: json["service_details"])
                                UserDefaults.standard.saveServicesDescripition(servicesDescripition: servicesdescripition)
                                GlobalVariables.shared.Service_amount = servicesdescripition.rate_card!
                                GlobalVariables.shared.main_catID = servicesdescripition.main_cat_id!
                                GlobalVariables.shared.sub_catID = servicesdescripition.sub_cat_id!
                                GlobalVariables.shared.serviceId = serviceID
                                GlobalVariables.shared.catServicetID = serviceID
                                self.performSegue(withIdentifier: "serviceDescrption", sender: self)
                            
                            }
                        }) {
                            (error) -> Void in
                            print(error)
                        }
                    }
                    catch
                    {
                        print("Unable to load data: \(error)")
                    }
             }
    }

    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if collectionView == categoryCollectionView
        {
            let yourWidth = categoryCollectionView.bounds.width/3.0
            let yourHeight = yourWidth
            
            return CGSize(width: yourWidth, height: yourHeight)
        }
        else if collectionView == topTrendingCollectionView
        {
            let yourWidth = 250
            let yourHeight = 170
            return CGSize(width: yourWidth, height: yourHeight)
        }
        else
        {
            return CGSize(width:self.bannerCollectionView.bounds.width, height: self.bannerCollectionView.bounds.height)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets
    {
        if collectionView == categoryCollectionView
        {
            return UIEdgeInsets(top: 2,left: 0,bottom: 0,right: 0)
        }
        else if collectionView == topTrendingCollectionView
        {
            return UIEdgeInsets(top: 0,left: 15,bottom: 0,right: 0)

        }
        else
        {
            return UIEdgeInsets(top: 0,left: 0,bottom: 0,right: 0)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat
    {
        if collectionView == categoryCollectionView
         {
             return 0

         }
         else
         {
             return 15.0
         }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat
    {
          if collectionView == categoryCollectionView
         {
             return 0

         }
         else
         {
             return 15.0
         }
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        if textField == searchTextfield
        {
            if searchTextfield.text?.isEmpty == true
            {
                Alert.defaultManager.showOkAlert(LocalizationSystem.sharedInstance.localizedStringForKey(key: "appname_text", comment: ""), message: LocalizationSystem.sharedInstance.localizedStringForKey(key: "searchtextnotempty", comment: "")) { (action) in
                    //Custom action code
                }
            }
            else
            {
                self.performSegue(withIdentifier: "search", sender: self)
            }
        }
        return true
    }
    
    @IBAction func searchFieldCloseButton(_ sender: Any)
    {
        searchTextfield.text = ""
        searchTextfield.resignFirstResponder()
    }
    
    
    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if (segue.identifier == "serviceDetail")
        {
            let vc = segue.destination as! ServiceDetail
            vc.subcategoeryNameArr = self.subcategoeryArr
            vc.subcategoeryIDArr = self.subcategoeryID
            vc.main_cat_id = self.cat_id
        }
        else if (segue.identifier == "search")
        {
            let vc = segue.destination as! SearchResult
            vc.searchText = self.searchTextfield.text!
        }
        else if (segue.identifier == "notificationOffers")
        {
            let _ = segue.destination as! NotificationAndOffers
        }
        else if (segue.identifier == "serviceDescrption") {
            let _ = segue.destination as! ServiceDescripition
        }

    }
}

@IBDesignable
class RoundedCornerView: UIView {

    var cornerRadiusValue : CGFloat = 0
    var corners : UIRectCorner = []

    @IBInspectable public override var cornerRadius : CGFloat {
        get {
            return cornerRadiusValue
        }
        set {
            cornerRadiusValue = newValue
        }
    }

    @IBInspectable public var topLeft : Bool {
        get {
            return corners.contains(.topLeft)
        }
        set {
            setCorner(newValue: newValue, for: .topLeft)
        }
    }

    @IBInspectable public var topRight : Bool {
        get {
            return corners.contains(.topRight)
        }
        set {
            setCorner(newValue: newValue, for: .topRight)
        }
    }

    @IBInspectable public var bottomLeft : Bool {
        get {
            return corners.contains(.bottomLeft)
        }
        set {
            setCorner(newValue: newValue, for: .bottomLeft)
        }
    }

    @IBInspectable public var bottomRight : Bool {
        get {
            return corners.contains(.bottomRight)
        }
        set {
            setCorner(newValue: newValue, for: .bottomRight)
        }
    }

    func setCorner(newValue: Bool, for corner: UIRectCorner) {
        if newValue {
            addRectCorner(corner: corner)
        } else {
            removeRectCorner(corner: corner)
        }
    }

    func addRectCorner(corner: UIRectCorner) {
        corners.insert(corner)
        updateCorners()
    }

    func removeRectCorner(corner: UIRectCorner) {
        if corners.contains(corner) {
            corners.remove(corner)
            updateCorners()
        }
    }

    func updateCorners() {
        let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: cornerRadiusValue, height: cornerRadiusValue))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        self.layer.mask = mask
    }

}
