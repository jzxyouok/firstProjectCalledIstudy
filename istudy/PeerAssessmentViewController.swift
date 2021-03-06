//
//  PeerAssessmentViewController.swift
//  istudy
//
//  Created by hznucai on 16/3/5.
//  Copyright © 2016年 hznucai. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
class PeerAssessmentViewController: UIViewController ,UITableViewDataSource,UITableViewDelegate{
    @IBOutlet weak var tableView:UITableView?
    var items = NSArray()
    var id = NSInteger()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView?.delegate = self
        self.tableView?.dataSource = self
        self.tableView?.tableFooterView = UIView()
        self.tableView?.mj_header = MJRefreshNormalHeader(refreshingTarget: self, refreshingAction: #selector(PeerAssessmentViewController.headerRefresh))
        self.tableView?.mj_header.beginRefreshing()
        self.automaticallyAdjustsScrollViewInsets = false
        // Do any additional setup after loading the view.
        let segmentController = AKSegmentedControl(frame: CGRectMake(20,64 + 10,SCREEN_WIDTH - 40, 37))
        let btnArray =  [["image":"箭头","title":"名称"],
                         ["image":"箭头","title":"老师"],
                         ["image":"箭头","title":"开始时间"],
                         ["image":"箭头","title":"截止时间"],
                         ]
        // Do any additional setup after loading the view.
        segmentController.initButtonWithTitleandImage(btnArray)
        self.view.addSubview(segmentController)

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
        let cell = tableView.dequeueReusableCellWithIdentifier("PeerAssessmentCell") as! PeerAssessmentTableViewCell
        cell.selectionStyle = .None
        cell.title?.text = self.items[indexPath.row].valueForKey("title") as? String
        cell.teacher?.text = self.items[indexPath.row].valueForKey("teacher") as? String
        let tempStartDate = items[indexPath.row].valueForKey("datestart") as! NSString
        let tempEndDate = items[indexPath.row].valueForKey("dateend") as! NSString
        let yearRange = NSMakeRange(0, 4)
        let monthRange = NSMakeRange(4, 2)
        let dateRange = NSMakeRange(6, 2)
        let hourRange = NSMakeRange(8, 2)
        let minuateRange = NSMakeRange(10, 2)
        let secondRange = NSMakeRange(12, 2)
        var  date = "开始时间" + tempStartDate.substringWithRange(yearRange) + "-" + tempStartDate.substringWithRange(monthRange) + "-" + tempStartDate.substringWithRange(dateRange)
        date += "截止时间" + tempEndDate.substringWithRange(yearRange) + "-" + tempEndDate.substringWithRange(monthRange) + "-" + tempEndDate.substringWithRange(dateRange)
        cell.startDateAndEndDate?.text = date
        let yearString = tempEndDate.substringWithRange(yearRange)
        let monthString = tempEndDate.substringWithRange(monthRange)
        let dateString = tempEndDate.substringWithRange(dateRange)
        let hourString = tempEndDate.substringWithRange(hourRange)
        let minuateString = tempEndDate.substringWithRange(minuateRange)
        let secondString = tempEndDate.substringWithRange(secondRange)
        let jsonDateString = yearString + "-" + monthString + "-" + dateString + " " + hourString + ":" + minuateString + ":" + secondString
        //string转化为date
   
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let jsonDate = formatter.dateFromString(jsonDateString)
        let currentDate = NSDate()
        //进行比较
        if(jsonDate != nil){
           
            let result:NSComparisonResult = currentDate.compare(jsonDate!)
            if result == .OrderedAscending{
                cell.peerBtn?.setTitle("评论", forState: .Normal)
            }else{
                cell.peerBtn?.enabled = false
                cell.peerBtn?.setTitle("已结束评论", forState: .Normal)
            }
        }else{
            cell.peerBtn?.setTitle("评论", forState: .Normal)
        }
        cell.peerBtn?.addTarget(self, action: #selector(PeerAssessmentViewController.goToPeer(_:)), forControlEvents: .TouchUpInside)
        cell.peerBtn?.tag = indexPath.row
        return cell
    }
    //随后评论的界面
    func goToPeer(sender:UIButton){
        let detailPeerAssementVC = UIStoryboard(name: "PeerAssessment", bundle: nil).instantiateViewControllerWithIdentifier("DetailPeerAssementVC") as! DetailPeerAssementViewController
        //        detailPeerAssementVC.progress = self.items[sender.tag].valueForKey("progress") as! Float
        detailPeerAssementVC.title = "评论详情"
        self.navigationController?.pushViewController(detailPeerAssementVC, animated: true)
        //把id也得传过去
        detailPeerAssementVC.id = self.items[sender.tag].valueForKey("testid") as! NSInteger
        detailPeerAssementVC.progress = self.items[sender.tag].valueForKey("progress") as! Float
        detailPeerAssementVC.titleString = self.items[sender.tag].valueForKey("title") as! String
        }
    func headerRefresh() {
        let userDefault = NSUserDefaults.standardUserDefaults()
        let dic:[String:AnyObject] = ["authtoken":userDefault.valueForKey("authtoken") as! String,
                                      "courseid":"\(self.id)"]
        Alamofire.request(.POST, "http://dodo.hznu.edu.cn/api/hupingquery", parameters: dic, encoding: ParameterEncoding.URL, headers: nil).responseJSON { (response) in
            switch response.result{
            case .Success(let Value):
                let json = JSON(Value)
                print(json)
                if(json["retcode"].number != 0){
                    ProgressHUD.showError("请求失败")
                }else{
                    
                    dispatch_async(dispatch_get_main_queue(), {
                        self.items = json["items"].arrayObject! as NSArray
                        self.tableView?.mj_header.endRefreshing()
                        self.tableView?.reloadData()
            })
                }
            case .Failure(_):
                ProgressHUD.showError("请求失败")
            }
        }
    }
    override func viewWillDisappear(animated: Bool) {
      
        ProgressHUD.dismiss()
    }
}
