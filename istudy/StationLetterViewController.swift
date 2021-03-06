//
//  StationLetterViewController.swift
//  istudy
//
//  Created by hznucai on 16/3/3.
//  Copyright © 2016年 hznucai. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire
class StationLetterViewController: UIViewController,UITableViewDelegate,UITableViewDataSource{
    
    @IBOutlet weak var moreChioice: UIBarButtonItem?
    @IBOutlet weak var stationLetterTableViewToSuperViewLeading: NSLayoutConstraint!
    @IBOutlet weak var bottomTrush:UIButton?
    //三个信箱
    @IBOutlet weak var inBox:UIButton?
    @IBOutlet weak var sentBox:UIButton?
    @IBOutlet weak var recyclingBox:UIButton?
    @IBOutlet weak var stationLetterTableView:UITableView?
    //当前一共选择了几条
    @IBOutlet weak var sumToDeleteLabel:UILabel?
    //顶部的View
    @IBOutlet weak var topView:UIView?
    //底部的垃圾桶
    //该选择哪条url来发送请求
    var url = ""
    //收到的站内信的参数的字典
    //是选择了哪个信箱
    var isIn = true
    var isOut = false
    var isRecycle = false
    var inDic = [String:AnyObject]()
    var outDic = [String:AnyObject]()
    var items = NSArray()
    var toDeleteLetterArray = NSMutableArray()
    override func viewDidLoad() {
        super.viewDidLoad()
        let userDefault = NSUserDefaults.standardUserDefaults()
        let authtoken = userDefault.valueForKey("authtoken") as! String
        self.inDic = ["authtoken":authtoken,
        "count":"100",
        "page":"1",
        "unreadonly":"2"]
        self.outDic = ["authtoken":authtoken,
                        "count":"100",
                        "page":"1"]
        self.navigationController?.navigationBar.barTintColor = RGB(0, g: 153, b: 255)
        self.navigationController?.navigationBar.tintColor = UIColor.blackColor()
        self.topView?.layer.borderColor = UIColor.blueColor().CGColor
        self.topView?.layer.borderWidth = 1.0
        self.inBox?.setImage(UIImage(named: "收件箱选中"), forState: .Normal)
        self.inBox?.setTitleColor(UIColor.blueColor(), forState: .Normal)
        self.stationLetterTableView?.dataSource = self
        self.stationLetterTableView?.delegate = self
        self.stationLetterTableView?.tableFooterView = UIView()
        self.stationLetterTableView?.mj_header = MJRefreshNormalHeader(refreshingTarget: self, refreshingAction: #selector(StationLetterViewController.headerRefresh))
        self.stationLetterTableView?.mj_header.beginRefreshing()
        self.topView?.alpha = 0.0
        self.bottomTrush!.setImage(UIImage(named: "垃圾桶未选中"), forState: .Normal)
        self.bottomTrush!.backgroundColor = UIColor.blueColor()
        self.bottomTrush!.alpha = 0.0
        //这个依据情况而定
            self.bottomTrush!.addTarget(self, action: #selector(StationLetterViewController.toDelete(_:)), forControlEvents: .TouchUpInside)
        self.sentBox?.addTarget(self, action: #selector(StationLetterViewController.selectedSentBox(_:)), forControlEvents: .TouchUpInside)
        self.inBox?.addTarget(self, action: #selector(StationLetterViewController.selectedInBox(_:)), forControlEvents: .TouchUpInside)
        self.recyclingBox?.addTarget(self, action: #selector(StationLetterViewController.selectedRecyclingBox(_:)), forControlEvents: .TouchUpInside)
    }
   override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.items.count
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("stationLetterCell") as! StationLetterCellTableViewCell
        //看接收到的人里面拿出来 随后循环遍历 自己相等 随后判断 赋不同的值
        if(isIn){
       cell.isRead = self.items[indexPath.row].valueForKey("isread") as! NSInteger
        
        //定义cell的属性
        if(cell.isRead == 0){
        cell.kingOfLetterImageView?.image = UIImage(named: "未读")
        }else{
            cell.kingOfLetterImageView?.image = UIImage(named: "已读")
        }
        }
        var senderName = ""
        if(isIn){
      senderName  = (self.items[indexPath.row].valueForKey("sendername") as? String)!
        }
        cell.subjectLabel?.text = self.items[indexPath.row].valueForKey("subject") as! NSString as String
        //时间的切割
        let yearRange = NSMakeRange(0, 4)
        let monthRange = NSMakeRange(4, 2)
        let dateRange = NSMakeRange(6, 2)
        //let hourRange = NSMakeRange(8, 2)
        //let minuateRange = NSMakeRange(10, 2)
        //let secondRange = NSMakeRange(12, 2)
        let  tempDate = items[indexPath.row].valueForKey("date") as! NSString
        let date = "于" + (tempDate.substringWithRange(yearRange) + "年" + tempDate.substringWithRange(monthRange) + "月" + tempDate.substringWithRange(dateRange)  + "日 " + "发表")
        let totalString = senderName + date
        cell.sendLetterPersonNameAndDateLabel?.text = totalString
        cell.clickBtn?.setImage(UIImage(named: "未选择信件"), forState: .Normal)
        cell.clickBtn?.tag = indexPath.row
        cell.clickBtn?.addTarget(self, action: #selector(StationLetterViewController.showTopViewAndBottomTrush(_:)), forControlEvents: .TouchUpInside)
        return cell
    }
    //每行选择cell的时候该干什么
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        let cell = tableView.cellForRowAtIndexPath(indexPath) as! StationLetterCellTableViewCell
     
       
     //随后推到一个页面中进行详细的说明
    let readEmailVC = UIStoryboard(name: "StationLetter", bundle: nil).instantiateViewControllerWithIdentifier("ReadEmailVC") as! ReadEmailViewController
        readEmailVC.string = self.items[indexPath.row].valueForKey("content") as! String
      
        readEmailVC.subject = self.items[indexPath.row].valueForKey("subject") as! String
       
        readEmailVC.title = "读邮件"
        if(isIn){
            readEmailVC.code = self.items[indexPath.row].valueForKey("code") as! String
            readEmailVC.senderName = (self.items[indexPath.row].valueForKey("sendername") as? String)!
            readEmailVC.senderId = (self.items[indexPath.row].valueForKey("senderid") as? NSInteger)!
            readEmailVC.subject = (self.items[indexPath.row].valueForKey("subject") as! String)
            cell.isRead = 1
        }
        if(isOut){
            readEmailVC.isOut = true
        }
        self.navigationController?.pushViewController(readEmailVC, animated: true)
        
        tableView.reloadData()
    }
   //当点击全选的时候
 @IBAction   func allSelectedToDelete(sender:UIButton){

        for i in 0 ..< self.toDeleteLetterArray.count {
            let indexPath = NSIndexPath(forRow: i, inSection: 0)
            let cell = self.stationLetterTableView?.cellForRowAtIndexPath(indexPath) as! StationLetterCellTableViewCell
            cell.clickBtn?.setImage(UIImage(named: "选择信件"), forState: .Normal)
            self.toDeleteLetterArray[i] = 1
        }
        self.refreshSumLabel()
    }
    //当点击取消的时候
    @IBAction func cancelDelete(sender:UIButton){
        self.tabBarController!.tabBar.hidden = false
       UIView.animateWithDuration(0.3) { 
        self.topView?.alpha = 0.0
        self.bottomTrush?.alpha = 0.0
        }
        for i in 0 ..< self.toDeleteLetterArray.count{
        let indexPath = NSIndexPath(forRow: i, inSection: 0)
        let cell = self.stationLetterTableView?.cellForRowAtIndexPath(indexPath) as! StationLetterCellTableViewCell
            cell.clickBtn?.setImage(UIImage(named: "未选择信件"), forState: .Normal)
            self.toDeleteLetterArray[i] = 0
        }
        
    }
//跟换tableView的内容
    var isShow = false
    @IBAction func selectDifferentStation(sender:UIBarButtonItem) {
        //跟新tableView的界面
       
        if(!isShow){
            isShow = true
        UIView.animateWithDuration(0.3, animations: {
           self.stationLetterTableView?.frame.origin.x += 100
            }, completion: { (Bool) in
                 sender.image = UIImage(named: "更多选择")
                
        })
        }else{
            isShow = false
            UIView.animateWithDuration(0.3, animations: {
                self.stationLetterTableView?.frame.origin.x = 0
                }, completion: { (Bool) in
                    sender.image = UIImage(named: "更多选择")
                    
            })
        }
        self.stationLetterTableView?.userInteractionEnabled = !isShow
        
    }
    @IBAction func reFresh(sender:UIBarButtonItem) {
        //刷新界面 根据获取到的值多少
        self.stationLetterTableView?.mj_header.beginRefreshing()
           }
    @IBAction func writeLetter(sender:UIBarButtonItem) {
        //跳转到写信的界面
        let writeLetterVC = UIStoryboard(name: "StationLetter", bundle: nil).instantiateViewControllerWithIdentifier("writeLetterVC")
        as! WriteLetterViewController
        writeLetterVC.title = "写邮件"
        self.navigationController?.pushViewController(writeLetterVC, animated: true)
    }
    //当点击选择的时候出现的上半部分View和底部的垃圾桶
    func showTopViewAndBottomTrush(sender:UIButton) {
        UIView.animateWithDuration(0.3) { 
            self.topView?.alpha = 1.0
            self.bottomTrush?.alpha = 1.0
        }
        self.topView?.hidden = false
        self.bottomTrush!.hidden = false
        self.tabBarController?.tabBar.hidden = true
        if(self.toDeleteLetterArray[sender.tag] as! NSObject == 0){
           self.toDeleteLetterArray[sender.tag] = 1
           sender.setImage(UIImage(named: "选择信件"), forState: .Normal)
        }else{
        sender.setImage(UIImage(named: "未选择信件"), forState: .Normal)
           self.toDeleteLetterArray[sender.tag] = 0
        }
        self.refreshSumLabel()
    }
    //当点击垃圾桶的时候 该把该邮件删除
    func toDelete(sender:UIButton){
        sender.setImage(UIImage(named: "垃圾桶选中"), forState: .Selected)
        var i = 0
        while (i < self.toDeleteLetterArray.count) {
            
            if(self.toDeleteLetterArray[i] as! Int == 1){
               self.toDeleteLetterArray.removeObjectAtIndex(i)
               i = 0
            }else{
                i += 1
            }
        }
        self.stationLetterTableView?.reloadData()

    }
    func refreshSumLabel() {
        var sum = 0
       for i in 0 ..< self.toDeleteLetterArray.count{
            if(self.toDeleteLetterArray[i] as! Int == 1){
                sum += 1
            }
        }
     self.sumToDeleteLabel?.text = "已选" + "\(sum)" + "条"
    }
    //三个按钮选择的状态
    func selectedSentBox(sender:UIButton){
        isOut = true
        isIn = false
        isRecycle = false
         isShow = false
      self.stationLetterTableView?.userInteractionEnabled = !isShow
      self.stationLetterTableView?.mj_header.beginRefreshing()
      
        //跟新是发件箱将stationArray改掉 随后跟新tableView,将其他按钮变为黑色 自己变为蓝色
        self.inBox?.setImage(UIImage(named: "收件箱未选中"), forState: .Normal)
        self.inBox?.setTitleColor(UIColor.blackColor(), forState: .Normal)
        self.recyclingBox?.setImage(UIImage(named: "垃圾桶未选中"), forState: .Normal)
        self.recyclingBox?.setTitleColor(UIColor.blackColor(), forState: .Normal)
        sender.setImage(UIImage(named: "发件箱选中"), forState: .Normal)
        sender.setTitleColor(UIColor.blueColor(), forState: .Normal)
    }
    func selectedInBox(sender:UIButton){
        isOut = false
        isIn = true
        isRecycle = false
           isShow = false
        self.stationLetterTableView?.userInteractionEnabled = !isShow
        self.stationLetterTableView?.mj_header.beginRefreshing()
     
        //跟新是发件箱将stationArray改掉 随后跟新tableView,将其他按钮变为黑色 自己变为蓝色
       
        self.sentBox?.setImage(UIImage(named: "收件箱未选中"), forState: .Normal)
        self.sentBox?.setTitleColor(UIColor.blackColor(), forState: .Normal)
        self.recyclingBox?.setImage(UIImage(named: "垃圾桶未选中"), forState: .Normal)
        self.recyclingBox?.setTitleColor(UIColor.blackColor(), forState: .Normal)
        sender.setImage(UIImage(named: "收件箱选中"), forState: .Normal)
        sender.setTitleColor(UIColor.blueColor(), forState: .Normal)
    }
    func selectedRecyclingBox(sender:UIButton){
        isOut = false
        isIn = false
        isRecycle = true
          isShow = false
        self.stationLetterTableView?.mj_header.beginRefreshing()
        self.stationLetterTableView?.userInteractionEnabled = !isShow
       
        //跟新是发件箱将stationArray改掉 随后跟新tableView,将其他按钮变为黑色 自己变为蓝色
       
        self.sentBox?.setImage(UIImage(named: "收件箱未选中"), forState: .Normal)
        self.sentBox?.setTitleColor(UIColor.blackColor(), forState: .Normal)
        self.inBox?.setImage(UIImage(named: "收件箱未选中"), forState: .Normal)
        self.inBox?.setTitleColor(UIColor.blackColor(), forState: .Normal)
        sender.setImage(UIImage(named: "垃圾桶选中"), forState: .Normal)
        sender.setTitleColor(UIColor.blueColor(), forState: .Normal)
    }
//头部刷新
    func headerRefresh() {
        self.toDeleteLetterArray = [0,0,0,0,0]
        //参数的数组
        var paramDic = [String:AnyObject]()
        if(isIn){
            paramDic = self.inDic
            url = "http://dodo.hznu.edu.cn/api/messagereceivequery"
        }
        if(isOut){
            paramDic = self.outDic
         url = "http://dodo.hznu.edu.cn/api/messagesendquery"
        }
        Alamofire.request(.POST, url, parameters: paramDic, encoding: ParameterEncoding.URL, headers: nil).responseJSON { (response) in
            switch response.result{
            case .Failure(_):
                ProgressHUD.showError("请求失败")
                self.items = NSArray()
               dispatch_async(dispatch_get_main_queue(), {
                self.stationLetterTableView?.mj_header.endRefreshing()
                self.stationLetterTableView?.reloadData()
               })
               
            case .Success(let Value):
                let json = JSON(Value)
                print(json)
                if(json["retcode"].number != 0){
                    ProgressHUD.showError("请求失败")
                    self.items = NSArray()
                    dispatch_async(dispatch_get_main_queue(), {
                        self.stationLetterTableView?.mj_header.endRefreshing()
                        self.stationLetterTableView?.reloadData()
                    })

                }else{
                    self.items = json["items"].arrayObject! as NSArray
                    dispatch_async(dispatch_get_main_queue(), {
                        self.stationLetterTableView?.mj_header.endRefreshing()
                        self.stationLetterTableView?.reloadData()
                    })
                }
            
        }
          }
    }
    override func viewWillAppear(animated: Bool) {
      
        self.isShow = false
          self.stationLetterTableView?.userInteractionEnabled = !isShow
    }
    override func viewWillDisappear(animated: Bool) {
        self.isShow = false
        self.stationLetterTableView?.userInteractionEnabled = !isShow
        self.stationLetterTableViewToSuperViewLeading.constant = 0
       
        ProgressHUD.dismiss()
   self.view.setNeedsLayout()
    }
}
