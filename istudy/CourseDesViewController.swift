    //
    //  CourseDesViewController.swift
    //  istudy
    //
    //  Created by hznucai on 16/3/3.
    //  Copyright © 2016年 hznucai. All rights reserved.
    //

    import UIKit
    import Alamofire
    import SwiftyJSON
    import CoreData
    
    class CourseDesViewController: UIViewController,UITableViewDataSource,UITableViewDelegate,
    UISearchControllerDelegate,UISearchResultsUpdating{
        var managedContext:NSManagedObjectContext?
        var fetchedResults = [PersonalHeadPortrait]()
        var imageHeadData = NSData()

        var items = NSArray()
        var filterItems = NSMutableArray()
        var sc = UISearchController(searchResultsController: nil)
        var isClick = NSMutableArray()
        //每一个cell的高度
        var cellHeight = NSMutableArray()
        @IBOutlet weak var courseDesTableView:mainTableView?
        override func viewDidLoad() {
            super.viewDidLoad()
            self.navigationController?.navigationBar.barTintColor = RGB(0, g: 153, b: 255)
            self.navigationController?.navigationBar.tintColor = UIColor.blackColor()
            
            self.courseDesTableView?.dataSource = self
            self.courseDesTableView?.delegate = self
            //tableView的底部不留东西
            self.courseDesTableView?.tableFooterView = UIView()
            self.courseDesTableView?.mj_header = MJRefreshNormalHeader(refreshingTarget: self, refreshingAction: #selector(CourseDesViewController.headerRefresh))
       
            self.courseDesTableView?.mj_header.beginRefreshing()
            sc.searchResultsUpdater = self
            sc.dimsBackgroundDuringPresentation = false
            sc.hidesNavigationBarDuringPresentation = true
            sc.searchBar.placeholder = "请输入课程名称"
            sc.searchBar.searchBarStyle = .Minimal
            sc.searchBar.sizeToFit()
            self.courseDesTableView?.tableHeaderView = sc.searchBar
            sc.delegate = self
           }
        
        override func didReceiveMemoryWarning() {
            super.didReceiveMemoryWarning()
            // Dispose of any resources that can be recreated.
        }
        //实现协议
        func numberOfSectionsInTableView(tableView: UITableView) -> Int {
            return 1
        }
        func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            //return self.courseDesArray.count
            if(sc.active == true){
                return self.filterItems.count
            }else{

            return self.items.count
            }
        }
        func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
            let webView = UIWebView(frame: CGRectMake(0, 70, SCREEN_WIDTH, 80))
            //webView来进行加载
            let cell = tableView.dequeueReusableCellWithIdentifier("courseDesCell") as! CourseDesTableViewCell
            //随后cell的图片等各种信息根据接受到的数组传值
            if(sc.active == false){
                //判断有没有题目描述
            if(self.items[indexPath.row].valueForKey("memo") as? String != nil &&
                self.items[indexPath.row].valueForKey("memo") as! String != ""){
            webView.loadHTMLString(self.items[indexPath.row].valueForKey("memo")
                as! String, baseURL: nil)
                }
            cell.courseImageBtn?.addTarget(self, action: #selector(CourseDesViewController.click(_:)),
                                           forControlEvents: .TouchUpInside)
            cell.courseImageBtn?.tag = indexPath.row
            cell.courseName?.text = self.items[indexPath.row].valueForKey("title") as? String
            cell.courseTea?.text = self.items[indexPath.row].valueForKey("teacher") as? String
            cell.contentView.userInteractionEnabled = true
            cell.courseImageBtn?.enabled = true
            //要防止rgb为空的情况的出现
                if(self.items[indexPath.row].valueForKey("pic") as? String != nil && self.items[indexPath.row].valueForKey("pic") as! String != ""){
                    let url = self.items[indexPath.row].valueForKey("pic") as! String
                    let data = NSData(contentsOfURL: NSURL(string: url)!)
                    let image = UIImage(data: data!)
                    cell.courseImageBtn?.setBackgroundImage(image, forState: .Normal)
                   

                }else{
        cell.courseImageBtn?.setTitle(self.items[indexPath.row].valueForKey("pictit") as? String, forState: .Normal)
            if(self.items[indexPath.row].valueForKey("picbg") != nil) {
            let rgb:[Float] = self.items[indexPath.row].valueForKey("picbg") as! NSArray as! [Float]
            cell.courseImageBtn?.backgroundColor = RGB(rgb[0], g: rgb[1], b: rgb[2])
            }else{
                cell.courseImageBtn?.backgroundColor = UIColor.blueColor()
              //  cell.courseImageBtn?.tintColor = UIColor.whiteColor()
            
            }
                }
            cell.contentView.addSubview(webView)
            cell.studyCourse?.layer.cornerRadius = 5.0
            cell.studyCourse?.layer.masksToBounds = true
            cell.studyCourse?.tag = indexPath.row
          cell.studyCourse?.addTarget(self, action: #selector(CourseDesViewController.pushNewVC(_:)), forControlEvents: .TouchUpInside)
            }else{
                if(self.filterItems[indexPath.row].valueForKey("memo") as? String != nil &&
                    self.filterItems[indexPath.row].valueForKey("memo") as! String != ""){
                    webView.loadHTMLString(self.filterItems[indexPath.row].valueForKey("memo")
                        as! String, baseURL: nil)
                }

                cell.courseImageBtn?.addTarget(self, action: #selector(CourseDesViewController.click(_:)),
                                               forControlEvents: .TouchUpInside)
             
                cell.courseImageBtn?.tag = indexPath.row
                cell.courseName?.text = self.filterItems[indexPath.row].valueForKey("title") as? String
                cell.courseTea?.text = self.filterItems[indexPath.row].valueForKey("teacher") as? String
                cell.contentView.userInteractionEnabled = true
                cell.courseImageBtn?.enabled = true
                //要防止rgb为空的情况的出现
                if(self.filterItems[indexPath.row].valueForKey("pic") as? String != nil && self.filterItems[indexPath.row].valueForKey("pic") as! String != ""){
                    let url = self.items[indexPath.row].valueForKey("pic") as! String
                  let data = NSData(contentsOfURL: NSURL(string:url)!)
                    let image = UIImage(data: data!)
                    cell.courseImageBtn?.setBackgroundImage(image, forState: .Normal)
                }else{
                    cell.courseImageBtn?.setTitle(self.filterItems[indexPath.row].valueForKey("pictit") as? String, forState: .Normal)
                if(self.filterItems[indexPath.row].valueForKey("picbg") != nil) {
                    let rgb:[Float] = self.filterItems[indexPath.row].valueForKey("picbg") as! NSArray as! [Float]
                    cell.courseImageBtn?.backgroundColor = RGB(rgb[0], g: rgb[1], b: rgb[2])
                }else{
                    cell.courseImageBtn?.backgroundColor = UIColor.blueColor()
                    //cell.courseImageBtn?.tintColor = UIColor.whiteColor()
                }
                }
                cell.contentView.addSubview(webView)
                cell.studyCourse?.layer.cornerRadius = 5.0
                cell.studyCourse?.layer.masksToBounds = true
                cell.studyCourse?.tag = indexPath.row
                cell.studyCourse?.addTarget(self, action: #selector(CourseDesViewController.pushNewVC(_:)), forControlEvents: .TouchUpInside)

            }
            cell.courseImageBtn?.tag = indexPath.row
            cell.courseImageBtn?.setTitleColor(UIColor.whiteColor(), forState:.Normal)
            cell.selectionStyle = .None
            return cell
            
        }
        
        func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
            return self.cellHeight[indexPath.row] as! CGFloat
        }
        
           //当点击立即学习的时候
        func pushNewVC(sender:UIButton){
            //都是推入到相同的立即学习的界面
            let oneCureseVC = UIStoryboard(name: "MyCourse", bundle: nil).instantiateViewControllerWithIdentifier("oneCourse") as! OneCourseDesViewController
            oneCureseVC.title = "立即学习"
            if(sc.active == false) {
                
            oneCureseVC.id = self.items[sender.tag].valueForKey("id") as! NSInteger
            oneCureseVC.courseNameString = self.items[sender.tag].valueForKey("title") as! String
            if(self.items[sender.tag].valueForKey("picbg") != nil){
            oneCureseVC.rgbArray = self.items[sender.tag].valueForKey("picbg") as! NSArray
             self.navigationController?.pushViewController(oneCureseVC, animated: true)
                }
                if(self.items[sender.tag].valueForKey("memo") as? String != nil &&
                    self.items[sender.tag].valueForKey("memo") as! String != ""){
                    oneCureseVC.courseDesString = self.items[sender.tag].valueForKey("memo") as! String

                }

                
            }else{
                oneCureseVC.id = self.filterItems[sender.tag].valueForKey("id") as! NSInteger
                oneCureseVC.courseNameString = self.filterItems[sender.tag].valueForKey("title") as! String
                if(self.filterItems[sender.tag].valueForKey("picbg") != nil){
                    oneCureseVC.rgbArray = self.filterItems[sender.tag].valueForKey("picbg") as! NSArray
                }
                oneCureseVC.courseDesString = self.filterItems[sender.tag].valueForKey("memo") as! String
                sc.active = false
                self.navigationController?.pushViewController(oneCureseVC, animated: true)
                
          }
        
        }
        //点击图片的时候
        func click(sender:UIButton) {
            sender.setTitleColor(UIColor.whiteColor(), forState: .Normal)
            if(sc.active){
      sender.setTitle(self.filterItems[sender.tag].valueForKey("pictit") as? String, forState: .Normal)
            }else{
                sender.setTitle(self.items[sender.tag].valueForKey("pictit") as? String, forState: .Normal)

            }
          if(self.isClick[sender.tag] as! NSObject == false){
                self.isClick[sender.tag] = true
                self.cellHeight[sender.tag] = 150
            }else{
              self.isClick[sender.tag] = false
                sender.selected = false
                self.cellHeight[sender.tag] = 80
            }
            self.courseDesTableView?.beginUpdates()
            self.courseDesTableView?.endUpdates()
        }
        func updateSearchResultsForSearchController(searchController: UISearchController) {
            self.filterItems.removeAllObjects()
          
            let scopePredicate = NSPredicate(format: "SELF CONTAINS[c] %@", searchController.searchBar.text!)
                for i in 0 ..< self.items.count{
                if(scopePredicate.evaluateWithObject(self.items[i].valueForKey("title")) == true){
                self.filterItems.addObject(self.items[i])
                }
            }
            self.courseDesTableView?.reloadData()
        }

          //顶部刷新
        func headerRefresh() {
            //每次都是登录
            
            let userDefault = NSUserDefaults.standardUserDefaults()
         
                let userName = userDefault.valueForKey("userName") as! String
                let passWord = userDefault.valueForKey("passWord") as! String
                let id = CFUUIDCreate(nil)
                let string = CFUUIDCreateString(nil, id)
                let resultString = CFStringCreateCopy(nil, string)
                let dic = [
                    "username":userName,
                    "password":passWord,
                    "devicetoken":resultString,
                    "number":"",
                    "os":"",
                    "clienttype":"1"
                ]
    Alamofire.request(.POST, "http://dodo.hznu.edu.cn/api/login", parameters: dic, encoding: ParameterEncoding.URL, headers: nil).responseJSON(completionHandler: { (response) -> Void in
                    switch response.result{
                    case .Success(let data):
                        let json = JSON(data)
                        if(json["retcode"].number != 0){
                            if(json["retcode"].number == 12){
                                ProgressHUD.showError("请重新登录")
                            }else{
                            ProgressHUD.showError("请求失败")
                            }
                            self.courseDesTableView?.mj_header.endRefreshing()
                            self.items = NSArray()
                            self.courseDesTableView?.reloadData()
                        }else{
                            userDefault.setValue(json["authtoken"].string, forKey: "authtoken")
                      
                            //设置名字 名字和账号是不一样的
                            userDefault.setValue(json["info"]["name"].string, forKey: "name")
                            userDefault.setValue(json["info"]["gender"].string, forKey: "gender")
                            userDefault.setValue(json["info"]["cls"].string, forKey: "cls")
                            userDefault.setValue(json["info"]["phone"].string, forKey: "phone")
                            userDefault.setValue(json["info"]["email"].string, forKey: "email")
                            let authDic :[String:AnyObject] = ["authtoken":userDefault.valueForKey("authtoken") as! String]
                            //设置头像
                            userDefault.setValue(json["info"]["avtarurl"].string, forKey: "avtarurl")
                           //进行头像的保存
                                            Alamofire.request(.POST, "http://dodo.hznu.edu.cn/api/coursequery", parameters: authDic, encoding: ParameterEncoding.URL, headers: nil).responseJSON { (response) in
                                switch response.result{
                                case .Success(let value):
                                    let json = JSON(value)
                                    if(json["retcode"].number == 0){
                                       
                                        self.items = json["items"].arrayObject! as NSArray
                                        
                                        for _ in  0 ..< self.items.count{
                                            self.cellHeight.addObject(80)
                                            self.isClick.addObject(false)
                                        }
                                        self.courseDesTableView?.mj_header.endRefreshing()
                                        self.courseDesTableView?.reloadData()
                                        //})
                                    }else{
                                        print(json["retcode"].number)
                                        ProgressHUD.showError("请求失败")
                                        self.items = NSArray()
                                        dispatch_async(dispatch_get_main_queue(), {
                                            self.courseDesTableView?.mj_header.endRefreshing()
                                            self.courseDesTableView?.reloadData()
                                        })
                                        
                                    }
                                case .Failure(_):
                                    ProgressHUD.showError("请求失败")
                                    self.items = NSArray()
                                    dispatch_async(dispatch_get_main_queue(), {
                                        self.courseDesTableView?.mj_header.endRefreshing()
                                        self.courseDesTableView?.reloadData()
                                    })
                                    
                                }
                            }

                        }
                    case .Failure(_):
                    ProgressHUD.showError("请求失败")
                    self.courseDesTableView?.mj_header.endRefreshing()
                    self.items = NSArray()
                    self.courseDesTableView?.reloadData()
 
                }
    })}
        
        func willPresentSearchController(searchController: UISearchController) {
            self.courseDesTableView?.mj_header.hidden = true
        }
        func willDismissSearchController(searchController: UISearchController) {
            self.courseDesTableView?.mj_header.hidden = false
        }
       
          deinit{
            print("CourseDesDeinit")
            self.sc.view.removeFromSuperview()
        }
        
           override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
                self.sc.active = false
            self.sc.searchBar.text = ""
            self.tabBarController?.tabBar.hidden = false
            
        }
    //当该界面消失的时候 应该progress.dismiss
        override func viewWillDisappear(animated: Bool) {
            ProgressHUD.dismiss()
        }
    
    
    }