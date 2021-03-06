//
//  WritePeerAssessmentViewController.swift
//  istudy
//
//  Created by hznucai on 16/3/22.
//  Copyright © 2016年 hznucai. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
//闭包来传值
typealias send_index = (index:NSInteger) -> Void
class WritePeerAssessmentViewController: UIViewController,UIWebViewDelegate,UIPickerViewDelegate,UIPickerViewDataSource,UITextViewDelegate,UIGestureRecognizerDelegate{
    //键盘出现时的操作
    var tap = UITapGestureRecognizer()
    var aboveCommentTextHeight = CGFloat()
    var commentTextView = JVFloatLabeledTextView()
    //scrollView
    @IBOutlet weak var scrollView:UIScrollView!
    @IBOutlet weak var pickerView:UIPickerView!
    @IBOutlet weak var topView:UIView!
    @IBOutlet weak var currentQusLabel:UILabel!
    var leftSwipe = UISwipeGestureRecognizer()
    var rightSwipe = UISwipeGestureRecognizer()
    var contentWebView = UIWebView()
    var totalHeight = CGFloat()
var questions = NSMutableArray()
  //评论的是第几个
    var items = NSArray()
    var usertestid = NSInteger()
    var index = 0 
    //var callBack:send_index?
    override func viewDidLoad() {
        super.viewDidLoad()
        //键盘出现的时候
        XKeyBoard.registerKeyBoardHide(self)
        XKeyBoard.registerKeyBoardShow(self)
        self.scrollView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(WritePeerAssessmentViewController.resign)))
        //设置阴影效果
        self.topView?.layer.shadowOffset = CGSizeMake(2.0, 1.0)
        self.topView?.layer.shadowColor = UIColor.blueColor().CGColor
        self.topView?.layer.shadowOpacity = 0.5

       self.pickerView.hidden = true
        leftSwipe.direction = .Left
        rightSwipe.direction = .Right
        leftSwipe.addTarget(self, action: #selector(WritePeerAssessmentViewController.addNewQus(_:)))
        rightSwipe.addTarget(self, action: #selector(WritePeerAssessmentViewController.addNewQus(_:)))
        self.view.addGestureRecognizer(leftSwipe)
        self.view.addGestureRecognizer(rightSwipe)
        self.scrollView.addGestureRecognizer(self.leftSwipe)
        self.scrollView.addGestureRecognizer(rightSwipe)
        // Do any additional setup after loading the view.
 //self.automaticallyAdjustsScrollViewInsets = false
        }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
 //提交评论的结果
    @IBAction func savePeer(sender:UIButton){
     //   self.callBack!(index:self.index)
        //进行保存
        let userDefault = NSUserDefaults.standardUserDefaults()
     
      
        //进行base64字符串解码
        let paramDic:[String:AnyObject] = ["usertestid":"\(self.usertestid)",
                                           "questions":self.questions]
        var result = String()
        do { let parameterData = try NSJSONSerialization.dataWithJSONObject(paramDic, options: NSJSONWritingOptions.PrettyPrinted)
            
            result = parameterData.base64EncodedStringWithOptions(.Encoding64CharacterLineLength)
        }catch{
            ProgressHUD.showError("保存失败")
        }
        let parameter:[String:AnyObject] = ["authtoken":userDefault.valueForKey("authtoken") as! String,"data":result]
       
        
        Alamofire.request(.POST, "http://dodo.hznu.edu.cn/api/submithuping", parameters: parameter, encoding: ParameterEncoding.URL, headers: nil).responseJSON { (response) in
            switch response.result{
            case .Success(let Value):
                let json = JSON(Value)
                print(json)
                              if(json["retcode"].number != 0){
                    print(json["retcode"].number)
                ProgressHUD.showError("评论失败")
                }else{
                    ProgressHUD.showSuccess("评论成功")
                self.navigationController?.popViewControllerAnimated(true)

}
            case .Failure(_):ProgressHUD.showError("评论失败")
            }
        }

        
    }
    override func viewWillAppear(animated: Bool) {
        ProgressHUD.show("请稍候")
        let userDefault = NSUserDefaults.standardUserDefaults()
        let authtoken = userDefault.valueForKey("authtoken") as! String
        //写请求时间等等
        let dic:[String:AnyObject] = ["usertestid":"\(self.usertestid)",
                                      "authtoken":authtoken]
  
    Alamofire.request(.POST, "http://dodo.hznu.edu.cn/api/hupingusertest", parameters: dic, encoding: ParameterEncoding.URL, headers: nil).responseJSON { (response) in
        switch response.result{
            case .Failure(_):
                ProgressHUD.showError("请求失败")
            case .Success(let Value):
                let json = JSON(Value)
                if(json["retcode"].number != 0){
                    
                    ProgressHUD.showError("请求失败")
                    
                }else{
                    print(json)
                    dispatch_async(dispatch_get_main_queue(), {
                        ProgressHUD.dismiss()
                        self.items = json["items"].arrayObject! as NSArray
                        for tempOut in 0 ..< self.items.count{
                            let dic1 = NSMutableDictionary()
                            dic1.setObject(self.items[tempOut].valueForKey("id") as! NSNumber, forKey: "questionid")
                            if(self.items[tempOut].valueForKey("comments") as? String != nil &&
                                self.items[tempOut].valueForKey("comments") as! String != ""){
                                    dic1.setObject(self.items[tempOut].valueForKey("comments") as! String, forKey: "comments")
                            }else{
                                   dic1.setObject("", forKey: "comments")
                            }
                        dic1.setObject(0, forKey: "isauthorvisible")
                            let rules = self.items[tempOut].valueForKey("rules") as! NSMutableArray
                            let arr1 = NSMutableArray()
                            for tempIn in 0 ..< rules.count{
                                let dic2 = NSMutableDictionary()
                            dic2.setObject(rules[tempIn].valueForKey("ruleid") as! NSNumber, forKey: "ruleid")
                             if(rules[tempIn].valueForKey("score") as? NSNumber != nil &&
                                rules[tempIn].valueForKey("score") as! NSNumber != 0){
                                dic2.setObject(rules[tempIn].valueForKey("score") as! NSNumber, forKey: "score")
                             }else{
                                dic2.setObject(0, forKey: "score")
                                }
                            arr1.addObject(dic2)
                            }
                        dic1.setObject(arr1, forKey: "rules")
                        self.questions.addObject(dic1)
                        }
                                   self.initView()
                    })
                }
            }
        }
    }
    override func viewWillDisappear(animated: Bool) {
        ProgressHUD.dismiss()
    }
    func webViewDidStartLoad(webView: UIWebView) {
        webView.frame = CGRectMake(0, 0, SCREEN_WIDTH, 1)
    }
    func webViewDidFinishLoad(webView: UIWebView) {
        let height = NSInteger(webView.stringByEvaluatingJavaScriptFromString("document.body.offsetHeight")!)
        var frame = webView.frame
        frame.size.height = CGFloat(height!) + 5
        totalHeight = frame.size.height + 2
        webView.frame = frame
        self.scrollView.addSubview(webView)
        tap.delegate = self
        tap.addTarget(self, action: #selector(WritePeerAssessmentViewController.showBig(_:)))
        webView.addGestureRecognizer(tap)
        let peerAssermentLabel = UILabel(frame: CGRectMake(0,totalHeight,SCREEN_WIDTH,21))
        peerAssermentLabel.text = "我的评论:"
        peerAssermentLabel.tag = 100000
        self.scrollView.addSubview(peerAssermentLabel)
        self.totalHeight += 22
        let rules = self.items[index].valueForKey("rules") as! NSMutableArray
        //循环加载rules
        let scores = self.questions[index].valueForKey("rules") as! NSMutableArray
        for i in 0 ..< rules.count{
            let ruleContentLabel = UILabel(frame: CGRectMake(0,self.totalHeight,SCREEN_WIDTH,1))
            ruleContentLabel.text = rules[i].valueForKey("contents") as? String
            ruleContentLabel.numberOfLines = 0
            ruleContentLabel.lineBreakMode = .ByWordWrapping
            let size = ruleContentLabel.sizeThatFits(CGSizeMake(SCREEN_WIDTH, 100))
            var ruleContentLabelSize = ruleContentLabel.frame
            ruleContentLabelSize.size = size
            ruleContentLabel.frame = ruleContentLabelSize
            self.scrollView.addSubview(ruleContentLabel)
            self.totalHeight += size.height + 2
            //评论的分数显示
            ruleContentLabel.tag = 1000000
            
            let assermentLabel = UILabel(frame: CGRectMake(0,self.totalHeight,100,21))
            assermentLabel.text = "评论分数:" + "\(scores[i].valueForKey("score") as! NSNumber)"
            assermentLabel.tag = i
            self.scrollView.addSubview(assermentLabel)
            let assermentBtn = UIButton(frame: CGRectMake(120,self.totalHeight,100,21))
            assermentBtn.tag = i + 100
            assermentBtn.setTitle("评论", forState: .Normal)
            assermentBtn.backgroundColor = RGB(0, g: 153, b: 255)
            assermentBtn.setTitleColor(UIColor.whiteColor(), forState: .Normal)
            assermentBtn.addTarget(self, action: #selector(WritePeerAssessmentViewController.gotoPeer(_:)), forControlEvents: .TouchUpInside)
            self.scrollView.addSubview(assermentBtn)
            self.totalHeight += 22
        }
        aboveCommentTextHeight = self.totalHeight
        let commentTextLabel = UILabel(frame: CGRectMake(0,self.totalHeight,SCREEN_WIDTH,21))
        commentTextLabel.tag = 10000000
        commentTextLabel.text = "评论区:"
        self.scrollView.addSubview(commentTextLabel)
        self.totalHeight += 22
        //加评论的文本框
         commentTextView = JVFloatLabeledTextView(frame: CGRectMake(0,self.totalHeight,SCREEN_WIDTH,100))
        if(self.questions[index].valueForKey("comments") as? String != nil && self.questions[index].valueForKey("comments") as! String != ""){
            commentTextView.text = self.questions[index].valueForKey("comments") as! String
        }else{
              commentTextView.placeholder = "在此处输入评论..."
        }
        commentTextView.delegate = self
        commentTextView.keyboardDismissMode = .OnDrag
        self.totalHeight += 100
        self.scrollView.addSubview(commentTextView)
        self.scrollView.contentSize = CGSizeMake(SCREEN_WIDTH, self.totalHeight)
    }
    //加载新题目
    func addNewQus(sender:UISwipeGestureRecognizer){
        if sender.direction == .Left{
            if(self.index != self.items.count - 1){
                self.index += 1
                self.initView()
            }else{
                ProgressHUD.showError("已完成评论")
            }
        }
        if sender.direction == .Right{
            if(self.index != 0){
                self.index -= 1
                self.initView()
            }else{
                ProgressHUD.showError("开头")
            }
        }
    }
    func initView() {
        for view in self.scrollView.subviews{
            view.removeFromSuperview()
        }
        var totalString = self.items[index].valueForKey("content") as! String + "学生答案:" + "<br>"
        if(self.items[index].valueForKey("answer") as? String != nil && self.items[index].valueForKey("answer") as! String != ""){
            totalString += self.items[index].valueForKey("answer") as! String
        }else{
            totalString += "无学生答案"
        }
        self.currentQusLabel.text = "\(self.index + 1)" + "/"  +  "\(self.items.count)"
        self.contentWebView.loadHTMLString(totalString, baseURL: nil)
        
        self.contentWebView.delegate = self
        self.totalHeight = 0
          }
    func gotoPeer(sender:UIButton){
        self.pickerView.delegate = self
        self.pickerView.dataSource = self
        let tag = sender.tag - 100
        self.pickerView.tag = 1000 + tag
        self.pickerView.hidden = false
        
    }
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        let rules = self.items[index].valueForKey("rules") as! NSMutableArray
        let tempIndex = pickerView.tag - 1000
       let totalscore =  rules[tempIndex].valueForKey("totalscore") as! NSInteger
        return totalscore + 1
    }
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
      return "\(row)" + "分"
        }
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
              let tag = pickerView.tag - 1000
       
        for view in self.scrollView.subviews{
            if view.isKindOfClass(UILabel.classForCoder()){
                if(view.tag == tag){
        let label =  view as! UILabel
           label.text =  "评论分数:" + "\(row)"
            let arr1 = self.questions[index].valueForKey("rules") as! NSMutableArray
                      let dic1 = arr1[tag] as! NSMutableDictionary
                    dic1.setObject(row, forKey: "score")
                    arr1.replaceObjectAtIndex(tag, withObject: dic1)
                self.questions[index].setObject(arr1, forKey: "rules")
                }
            }
        }
      
    }
    func resign(){
      commentTextView.resignFirstResponder()
        self.pickerView.hidden = true
    }
    func textViewDidEndEditing(textView: UITextView) {
        //改变评论的文本
        self.questions[index].setObject(textView.text, forKey: "comments")
    }
    //键盘出现时的代理
    func keyboardWillHideNotification(notifacition:NSNotification) {
        self.scrollView.addGestureRecognizer(self.leftSwipe)
        self.scrollView.addGestureRecognizer(self.rightSwipe)
        UIView.animateWithDuration(0.3) { () -> Void in
            self.scrollView.contentOffset = CGPointMake(0, 0)
                 }
    }
    func keyboardWillShowNotification(notifacition:NSNotification) {
        //做一个动画
        self.scrollView.removeGestureRecognizer(self.leftSwipe)
        self.scrollView.removeGestureRecognizer(self.rightSwipe)
        UIView.animateWithDuration(0.3) { () -> Void in
        self.scrollView.contentOffset = CGPointMake(0, self.aboveCommentTextHeight)
        }
    }
//显示图片放大
    //图片放大的效果
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
    func showBig(sender:UITapGestureRecognizer){
        var pt = CGPoint()
        var urlToSave = ""
        pt = sender.locationInView(self.contentWebView)
        let imgUrl = String(format: "document.elementFromPoint(%f, %f).src",pt.x, pt.y);
        urlToSave = self.contentWebView.stringByEvaluatingJavaScriptFromString(imgUrl)!
        
        
        let data = NSData(contentsOfURL: NSURL(string: urlToSave)!)
        if(data != nil){
            let image = UIImage(data: data!)
            let previewPhotoVC = UIStoryboard(name: "Problem", bundle: nil).instantiateViewControllerWithIdentifier("previewPhotoVC") as! previewPhotoViewController
            previewPhotoVC.toShowBigImageArray = [image!]
            previewPhotoVC.contentOffsetX = 0
            self.navigationController?.pushViewController(previewPhotoVC, animated: true)
        }
    }
    
}
