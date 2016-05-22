//
//  ChoiceQusViewController.swift
//  istudy
//
//  Created by hznucai on 16/3/16.
//  Copyright © 2016年 hznucai. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
class ChoiceQusViewController: UIViewController,UIWebViewDelegate,UITableViewDelegate,UITableViewDataSource,UIGestureRecognizerDelegate{
    //有没有超过指定的日期
    var isOver = false
    var tap = UITapGestureRecognizer()
    //记录date和阅卷是否开启 和阅卷的时候答案是否可见等等
    var endDate = NSDate()
    //是否可以阅卷
    var  enableClientJudge = Bool()
    var keyVisible = Bool()
    var viewOneWithAnswerKey = Bool()
    //每个cell的高度
    var cellHeight = NSMutableArray()
    //记录当前是第几个题型 还有总共有几个题型
    var kindOfQusIndex = NSInteger()
    var totalKindOfQus = NSInteger()
//记录试卷的id
    var testid = NSInteger()
    //显示批阅的信息的数组
    //显示批阅的textView
    //每次增加的高度
    var totalItems = NSArray()
    @IBOutlet weak var displayMarkingTextView:UITextView?
    var disPlayMarkingArray = NSMutableArray()
     var tempArray = ["a","b","c","d","e","f","g","h","i","j"]
   var queDes = UIWebView()
       @IBOutlet weak var kindOfQuesLabel:UILabel?

    @IBOutlet weak var currentQus:UILabel?
    @IBOutlet weak var gooverBtn:UIButton?
    @IBOutlet weak var resetBtn:UIButton?
    @IBOutlet weak var tableView:UITableView?
    @IBOutlet weak var topView:UIView?
    //总共有几题的collectionView
    var answers = NSMutableArray()
    var index = 0
    var items = NSArray()
    
    //每道题目选择的答案
    var selectedAnswer = NSMutableArray()
    //当在初始化的时候

    
      override func viewDidLoad() {
        super.viewDidLoad()
        //顶部加条线
        //设置阴影效果
        self.topView?.layer.shadowOffset = CGSizeMake(2.0, 1.0)
        self.topView?.layer.shadowColor = UIColor.blueColor().CGColor
        self.topView?.layer.shadowOpacity = 0.5

        self.tap = UITapGestureRecognizer(target: self, action: #selector(ChoiceQusViewController.webViewShowBig(_:)))
        self.tap.delegate = self
        //加线
        
        //注册通知
        NSNotificationCenter.defaultCenter().addObserver(self, selector:#selector(ChoiceQusViewController.reloadCellHeight(_:)), name: "ChoiceWebViewHeight", object: nil)
          NSNotificationCenter.defaultCenter().addObserver(self, selector:#selector(ChoiceQusViewController.tap(_:)), name: "choiceTapBtn", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ChoiceQusViewController.showImage(_:)), name: "ChoiceShowBigImage", object: nil)
        //用tableView来呈现题目和选项
        self.tableView?.delegate = self
        self.tableView?.dataSource = self
        //contentView添加手势
        let backBtn = UIButton(frame: CGRectMake(0,0,43,43))
        
        backBtn.contentHorizontalAlignment = .Left
        backBtn.tag = 1
        backBtn.setTitle("返回", forState: .Normal)
        backBtn.setTitleColor(UIColor.blackColor(), forState: .Normal)
        backBtn.addTarget(self, action: #selector(ChoiceQusViewController.back(_:)), forControlEvents: .TouchUpInside)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backBtn)
        let actBtn = UIButton(frame: CGRectMake(0,0,43,43))
        //查看的btn
        actBtn.contentHorizontalAlignment = .Left
        actBtn.setTitle("查看", forState: .Normal)
        actBtn.setTitleColor(UIColor.blackColor(), forState: .Normal)
        actBtn.addTarget(self, action:#selector(ChoiceQusViewController.showAct), forControlEvents: .TouchUpInside)
        //还有提交作业的btn 
        let submitBtn = UIButton(frame: CGRectMake(0,0,43,43))
        submitBtn.contentHorizontalAlignment = .Right
        submitBtn.setTitle("提交", forState: .Normal)
        submitBtn.tag = 2
        submitBtn.setTitleColor(UIColor.blackColor(), forState: .Normal)
        submitBtn.addTarget(self, action: #selector(ChoiceQusViewController.back(_:)), forControlEvents: .TouchUpInside)
        let submitBtnItem = UIBarButtonItem(customView: submitBtn)
        let actBtnItem = UIBarButtonItem(customView: actBtn)
        self.navigationItem.rightBarButtonItems = [submitBtnItem,actBtnItem]
             self.queDes = UIWebView(frame: CGRectMake(0,0,SCREEN_WIDTH,1))
        self.queDes.delegate = self
            self.automaticallyAdjustsScrollViewInsets = false
        
        for i in 0 ..< self.items.count{
            
           
            self.disPlayMarkingArray.addObject("")
            if(self.items[i].valueForKey("answer") as? String != nil){
            self.answers.addObject(self.items[i].valueForKey("answer")!)
            }else{
            self.answers.addObject("")
            }
        }
    self.displayMarkingTextView?.backgroundColor = UIColor.whiteColor()
       
     self.initView()
     

//    //随后这个view加载左滑右滑的手势 来滑动到下一道题目
    let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(ChoiceQusViewController.addNewQus(_:)))
        rightSwipe.direction = .Right
         let leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(ChoiceQusViewController.addNewQus(_:)))
        leftSwipe.direction = .Left
    self.view.addGestureRecognizer(rightSwipe)
    self.view.addGestureRecognizer(leftSwipe)
    self.tableView?.addGestureRecognizer(leftSwipe)
    self.tableView?.addGestureRecognizer(rightSwipe)
    self.view.userInteractionEnabled = true
    self.view.multipleTouchEnabled = true
       
  }
   //移除所有通知
    deinit{
    print("ChoiceDeinit")
          NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    @IBAction func resign(sender: AnyObject) {
  
    
    }
   
       func showAct(){
     let vc = UIStoryboard(name: "Problem", bundle: nil).instantiateViewControllerWithIdentifier("AchVC") as! AchViewController
        vc.title = self.title
        vc.totalItems = self.totalItems
        vc.testid = self.testid
        vc.enableClientJudge = self.enableClientJudge
        vc.keyVisible = self.keyVisible
         vc.endDate = self.endDate
        
        vc.viewOneWithAnswerKey = self.viewOneWithAnswerKey
        self.navigationController?.pushViewController(vc, animated: true)
    }
  
    //返回试卷列表或者根视图
    func back(sender:UIButton) {
        
        if(sender.tag == 1) {
            let vc = UIStoryboard(name: "OneCourse", bundle: nil).instantiateViewControllerWithIdentifier("MyHomeWorkVC") as! MyHomeWorkViewController
            
            for temp in (self.navigationController?.viewControllers)!{
                if(temp .isKindOfClass(vc.classForCoder)){
                    self.navigationController?.popToViewController(temp, animated: true)
                }
            }
        }else{
            let alertView = UIAlertController(title: nil, message: "确认提交吗？", preferredStyle: UIAlertControllerStyle.Alert)
            let cancelAction = UIAlertAction(title: "取消", style: UIAlertActionStyle.Destructive, handler: nil)
            let submitAction = UIAlertAction(title: "确定", style: UIAlertActionStyle.Default, handler: { (alert) in
                self.navigationController?.popToRootViewControllerAnimated(true)
            })
            alertView.addAction(submitAction)
            alertView.addAction(cancelAction)
            self.presentViewController(alertView, animated: true, completion: nil)
        }
        
        
    }
    
    @IBAction func goOver(sender:UIButton){
        if(self.enableClientJudge == false) {
            ProgressHUD.showError("未开启阅卷功能")
        }
        else{
            self.Over(self.index)
        }
        }
    func Over(index:NSInteger) {
     
        //没有超过指定日期且没有开放阅卷功能的
        if(!self.isOver && !self.enableClientJudge){
            ProgressHUD.showError("没有开启阅卷功能")
        }
            //如果没有超过指定日期且可以阅卷或者已经超过日期的
        if(!self.isOver && self.enableClientJudge || (self.isOver)){

            //阅卷的功能
            let knowledge = ("知识点:" + (self.items[index].valueForKey("knowledge") as! String) ) + "\n"
            var result = "结果:"
            var score = "得分:"
            var answerString = ""
            //没有超过日期并且可以查看标准答案的 或者超过日期了 但是可以查看标准答案的
            if((self.keyVisible && !self.isOver) || (self.isOver && self.viewOneWithAnswerKey)){

             answerString = "参考答案:" + (self.items[index].valueForKey("strandanswer") as! String) + "\n"
            }else{
                answerString = "标准答案未开放"
            }
            var totalString = ""
            let strandanswer = self.items[index].valueForKey("strandanswer") as! String
            let answer = self.answers[index]
            if(strandanswer == answer as! String){
                result += "正确" + "\n"
                score += "\(self.items[index].valueForKey("totalscore") as! NSNumber)" + "\n"
                totalString = knowledge + result + score + answerString
                self.displayMarkingTextView?.text = totalString
                self.displayMarkingTextView?.textColor = UIColor.greenColor()
            }else{
                result += "错误" + "\n"
                score += "0" + "\n"
                totalString = knowledge + result + score + answerString
                self.displayMarkingTextView?.text = totalString
                self.displayMarkingTextView?.textColor = UIColor.redColor()

        }

        self.disPlayMarkingArray.replaceObjectAtIndex(index, withObject: totalString)
            self.tableView?.reloadData()
        }
    }
    
    @IBAction func reset(sender:UIButton){
        let resetAlertView = UIAlertController(title: nil, message: "确定重置吗", preferredStyle: UIAlertControllerStyle.Alert)
        let resetAction = UIAlertAction(title: "确定", style: UIAlertActionStyle.Default) { (UIAlertAction) in
            
        
        self.disPlayMarkingArray.replaceObjectAtIndex(self.index, withObject: "")
        self.displayMarkingTextView?.text = ""
        self.tableView?.userInteractionEnabled = true
    self.answers.replaceObjectAtIndex(self.index, withObject: "")
   self.tableView?.reloadData()
    self.postAnswer()

    }
        let cancelAction = UIAlertAction(title: "取消", style: UIAlertActionStyle.Destructive, handler: nil)
        resetAlertView.addAction(resetAction)
        resetAlertView.addAction(cancelAction)
     
        self.presentViewController(resetAlertView, animated: true, completion: nil)
    }
    func addNewQus(sender:UISwipeGestureRecognizer){
        let temp = index
    if sender.direction == .Left{
        if self.index != self.items.count - 1{
             self.index += 1
        }
        else if(self.kindOfQusIndex == self.totalKindOfQus - 1){
            ProgressHUD.showSuccess("已完成全部试题")
        }
        else{
            
            let vc = UIStoryboard(name: "Problem", bundle: nil)
            .instantiateViewControllerWithIdentifier("TranslateVC") as!
                TranslateViewController
            vc.kindOfQusIndex = self.kindOfQusIndex + 1
            vc.title = self.title
            vc.testid = self.testid
             vc.endDate = self.endDate
            vc.enableClientJudge = self.enableClientJudge
            vc.keyVisible = self.keyVisible
            vc.viewOneWithAnswerKey = self.viewOneWithAnswerKey
                       self.navigationController?.pushViewController(vc, animated: false)
        }
        }
        if sender.direction == .Right{
            if self.index != 0{
                (self.index) -= 1
            }else{
                
                let vc = UIStoryboard(name: "Problem", bundle: nil)
                    .instantiateViewControllerWithIdentifier("TranslateVC") as!
                TranslateViewController
                vc.title = self.title
             vc.kindOfQusIndex = self.kindOfQusIndex
                vc.testid = self.testid
                 vc.endDate = self.endDate
                vc.enableClientJudge = self.enableClientJudge
                vc.keyVisible = self.keyVisible
                vc.viewOneWithAnswerKey = self.viewOneWithAnswerKey
                                self.navigationController?.pushViewController(vc, animated: false)
              }
        }
    //说明发生了滑动 选择题的按钮都要变色
if temp != index{
         self.initView()
        }
        if(self.disPlayMarkingArray[index] as! String != ""){
       self.Over(self.index)
        }else{
            self.displayMarkingTextView?.text = ""
        }
    }

    func initView() {
        //比较日期 若是已经过了期限 就把阅卷的结果拿出来
        //进行比较
        let currentDate = NSDate()
        let result:NSComparisonResult = currentDate.compare(endDate)
        if result == .OrderedAscending{
            
        }else{
            self.isOver = true
            //每道题目进行阅卷
         self.Over(self.index)
        }
        self.kindOfQuesLabel?.text = self.totalItems[kindOfQusIndex].valueForKey("title") as! String + "(" + "\(self.items[index].valueForKey("totalscore") as! NSNumber)" + "分/题)"
        self.currentQus?.text = "\(index + 1)" + "/" + "\(self.items.count)"
     queDes.loadHTMLString(self.items[index].valueForKey("content") as! String, baseURL: nil)
     self.tableView?.tableHeaderView = queDes
    self.tableView?.tableFooterView = UIView()
        self.queDes.delegate = self
        
        self.cellHeight.removeAllObjects()
            for i in 0 ..< 8 {
                   let dic = self.items[index]
                let tempKey = "option" + (tempArray[i])
                if ((dic.valueForKey(tempKey) as? String) != nil && dic.valueForKey(tempKey) as? String != ""){
                       cellHeight.addObject(50)
                }
            }
    self.tableView?.reloadData()
    }
    func tap(sender:NSNotification){
        let cell = sender.object as! ChoiceTableViewCell
             self.answers.replaceObjectAtIndex(index, withObject: self.tempArray[cell.Custag].uppercaseString)
       
        self.tableView?.reloadData()
        self.postAnswer()
        }
    //向服务器传送答案
    func postAnswer() {
        let answer = ["testid":"\(testid)",
                      "questionid":"\(self.items[index].valueForKey("id") as! NSNumber)",
                      "answer":self.answers.objectAtIndex(index)]
        let userDefault = NSUserDefaults.standardUserDefaults()
        let authtoken = userDefault.valueForKey("authtoken") as! String
        
        var result = String()
        do { let parameterData = try NSJSONSerialization.dataWithJSONObject(answer, options: NSJSONWritingOptions.PrettyPrinted)
            
            result = parameterData.base64EncodedStringWithOptions(.Encoding64CharacterLineLength)
        }catch{
            ProgressHUD.showError("保存失败")
        }
        
        
        let parameter:[String:AnyObject] = ["authtoken":authtoken,"data":result]
        
        Alamofire.request(.POST, "http://dodo.hznu.edu.cn/api/submitquestion", parameters: parameter, encoding: ParameterEncoding.URL, headers: nil).responseJSON { (response) in
            switch response.result{
            case .Failure(_):
                print(1)
                ProgressHUD.showError("保存失败")
            case .Success(let Value):
                let json = JSON(Value)
                if(json["retcode"].number! != 0){
                    ProgressHUD.showError("保存失败")
                    print(json["retcode"].number)
                }else{
                    ProgressHUD.showSuccess("保存成功")
                }
            }
        }

    }
    func webViewDidStartLoad(webView: UIWebView) {
        webView.frame = CGRectMake(0, 0, SCREEN_WIDTH, 1)
    }
    func webViewDidFinishLoad(webView: UIWebView) {
        let height = NSInteger(webView.stringByEvaluatingJavaScriptFromString("document.body.offsetHeight")!)
            var frame = webView.frame
        frame.size.height = CGFloat(height!) + 5
        webView.frame = frame
        //左右滑动和上下滑动
        let scrollView = webView.subviews[0] as! UIScrollView
        let width = NSInteger(webView.stringByEvaluatingJavaScriptFromString("document.body.scrollWidth")!)
        
        scrollView.contentSize = CGSizeMake(CGFloat(width!), 0)
        scrollView.showsVerticalScrollIndicator = false
        self.tableView?.tableHeaderView = webView
        webView.addGestureRecognizer(tap)
        self.tableView?.reloadData()
        }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cellHeight.count
    }
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if(indexPath.row < cellHeight.count){
            return cellHeight[indexPath.row] as! CGFloat
        }else{
            return 0
        }
    }
    func reloadCellHeight(sender:NSNotification){
        let cell = sender.object as! ChoiceTableViewCell
        if(self.cellHeight[cell.Custag] as! CGFloat != cell.cellHeight){
            self.cellHeight.replaceObjectAtIndex(cell.Custag, withObject: cell.cellHeight)
            self.tableView?.reloadData()
        }
        
        
}
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = ChoiceTableViewCell(style: .Default, reuseIdentifier: "ChoiceTableViewCell")
        if(indexPath.row < cellHeight.count){
            let key = "option" + tempArray[indexPath.row]
            cell.optionWebView?.loadHTMLString(self.items[index].valueForKey(key) as! String, baseURL: nil)
            cell.selectionStyle = .None
            cell.contentView.userInteractionEnabled = true
            cell.Custag = indexPath.row
            cell.btn?.setTitle(tempArray[indexPath.row].uppercaseString, forState: .Normal)
            let oneSelfAnswer = self.answers[index] as! String
            cell.btn?.backgroundColor = UIColor.whiteColor()
            cell.btn?.setTitleColor(UIColor.blueColor(), forState: .Normal)
            cell.view?.userInteractionEnabled = true
            cell.canTap = true
            if(self.disPlayMarkingArray[index] as! String != ""){
                cell.canTap = false
            }
            if(oneSelfAnswer == tempArray[indexPath.row].uppercaseString){
                cell.btn?.backgroundColor = RGB(0, g: 153, b: 255)
               
                cell.btn?.setTitleColor(UIColor.whiteColor(), forState: .Normal)
            }
            
            }
    return cell
    }
    func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
        
        return true
        
    }
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if(gestureRecognizer == self.tap){
            return true
        }else{
            return false
        }
    }
    
    func webViewShowBig(sender:UITapGestureRecognizer){
        var pt = CGPoint()
        var urlToSave = ""
   
        pt = sender.locationInView(self.queDes)
        let imgUrl = String(format: "document.elementFromPoint(%f, %f).src",pt.x, pt.y);
        urlToSave = self.queDes.stringByEvaluatingJavaScriptFromString(imgUrl)!
        let data = NSData(contentsOfURL: NSURL(string: urlToSave)!)
        if(data != nil){
            let image = UIImage(data: data!)
            let previewPhotoVC = UIStoryboard(name: "Problem", bundle: nil).instantiateViewControllerWithIdentifier("previewPhotoVC") as! previewPhotoViewController
            previewPhotoVC.toShowBigImageArray = [image!]
            previewPhotoVC.contentOffsetX = 0
            self.navigationController?.pushViewController(previewPhotoVC, animated: true)
        }
    }
    func showImage(sender:NSNotification){
        let cell = sender.object as! ChoiceTableViewCell
        let data = cell.Selfdata
        let image = UIImage(data: data)
        let previewPhotoVC = UIStoryboard(name: "Problem", bundle: nil).instantiateViewControllerWithIdentifier("previewPhotoVC") as! previewPhotoViewController
        previewPhotoVC.toShowBigImageArray = [image!]
        previewPhotoVC.contentOffsetX = 0
        self.navigationController?.pushViewController(previewPhotoVC, animated: true)
    }

}