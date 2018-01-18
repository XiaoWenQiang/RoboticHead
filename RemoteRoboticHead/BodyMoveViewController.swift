//
//  BodyMoveViewController.swift
//  RemoteRoboticHead
//
//  Created by QiaoWu on 2018/1/16.
//  Copyright © 2018年 EXdoll. All rights reserved.
//

import UIKit

//UICollectionViewDelegateFlowLayout

class BodyMoveViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    
    @IBOutlet weak var BtnsListView: UICollectionView!
    
    @IBOutlet weak var showText: UILabel!
    @IBOutlet weak var backGroundPic: UIImageView!
    
    
    
    var bkArea1:UIView?
    var bkArea2:UIView?
    var mvPoint1:UIView?
    var mvPoint2:UIView?
    var limitRect:LimitArea?
    
    var penDrag1:UIPanGestureRecognizer?
    var penDrag2:UIPanGestureRecognizer?
    
    var currentSelectServo:[Int] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //绘制背景框和拖拽点
        makebackgroundFroDrag()
        mvPoint1 = makePointForDrag(bg: self.bkArea1!)
        self.view.addSubview(mvPoint1!)

        //监听拖拽
        penDrag1 = UIPanGestureRecognizer(target: self, action: #selector(BodyMoveViewController.drage_head(_:)))
        mvPoint1?.addGestureRecognizer(penDrag1!)
        
        //列表尺寸布局
        let layout = UICollectionViewFlowLayout.init()
        layout.itemSize = CGSize.init(width: SCREEN_WIDTH/5, height: 20)
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        BtnsListView.collectionViewLayout = layout
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    //绘制背景图框和拖拽点 未完成
    func makePointForDrag(bg:UIView) -> UIView {
        let pt = UIView(frame: CGRect(x: bg.center.x - 20, y: bg.center.y - 20, width: 40, height: 40))
        pt.layer.cornerRadius = 20
        pt.layer.backgroundColor = UIColor.blue.cgColor
        return pt
    }
    func makebackgroundFroDrag() ->(){
        bkArea1 = UIView(frame: CGRect(x: backGroundPic.frame.width*0.2, y: backGroundPic.frame.midX+backGroundPic.frame.height*0.2, width: backGroundPic.frame.maxX*0.6, height: backGroundPic.frame.maxX*0.6))
        bkArea1?.layer.backgroundColor = UIColor.cyan.cgColor
        bkArea1?.layer.borderWidth = 2
        bkArea1?.layer.borderColor = UIColor.brown.cgColor
        bkArea1?.alpha = 0.1
        self.view.addSubview(bkArea1!)
        
        /*bkArea2 = UIView(frame: CGRect(x: SCREEN_WIDTH*0.2, y: SCREEN_HEIGHT*0.3, width: SCREEN_WIDTH*0.6, height: SCREEN_WIDTH*0.5))
        bkArea2?.layer.backgroundColor = UIColor.cyan.cgColor
        bkArea2?.layer.borderWidth = 2
        bkArea2?.layer.borderColor = UIColor.brown.cgColor
        bkArea2?.alpha = 0.3
        self.view.addSubview(bkArea2!)*/
        limitRect = LimitArea(minW: (self.bkArea1?.frame.origin.x)!, maxW: (self.bkArea1?.frame.maxX)!,
                              minH: (self.bkArea1?.frame.origin.y)!, maxH: (self.bkArea1?.frame.maxY)!,
                              centerX: (self.bkArea1?.center.x)!, centerY: (self.bkArea1?.center.y)!)
    }
    
    
    
    //拖拽动作
    @objc func drage_head(_ sender: UIPanGestureRecognizer) {
        if(sender.state == .began){
            self.showText.text="动作操作开始"
            self.bkArea1?.alpha = 0.5
            self.mvPoint1?.layer.backgroundColor = UIColor.red.cgColor
            self.mvPoint1?.alpha = 0.7
        }
        //保持拖拽点在边缘
        var point = sender.translation(in: view) //移动了的距离
        if((sender.view!.center.x + point.x)>(limitRect?.maxW)! || (sender.view!.center.x + point.x)<(limitRect?.minW)!){
            point.x = 0
        }
        if((sender.view!.center.y + point.y)>(limitRect?.maxH)! || (sender.view!.center.y + point.y)<(limitRect?.minH)!){
            point.y = 0
        }
        sender.view?.center = CGPoint(x: sender.view!.center.x + point.x, y: sender.view!.center.y + point.y)
        sender.setTranslation(.zero, in: view)
        //计算并输出坐标点
        self.checkAngleOnPage()
        self.showText.text = "移动坐标点 x:\(String(Int((sender.view?.center.x)!))) | y:\(String(Int((sender.view?.center.y)!)))"
        if(sender.state == .ended){
            //拖拽点回弹到起始位置
            UIView.animate(withDuration: 0.3, delay: 0.2, options: .curveEaseInOut, animations: {
                () -> Void in
                sender.view?.center = CGPoint(x: (self.bkArea1?.center.x)!, y: (self.bkArea1?.center.y)!)
            }, completion: { (success) -> Void in
                if success {
                    //回弹动画结束后恢复默认约束值
                    self.bkArea1?.alpha = 0.1
                    self.mvPoint1?.layer.backgroundColor = UIColor.blue.cgColor
                    self.mvPoint1?.alpha = 1
                    self.showText.text="动作操作结束"
                    self.checkAngleOnPage()
                }
            })
            return
        }
    }
    
    //角度计算并输出 按单双数
    func checkAngleOnPage() -> () {
        var outdatas:[UInt8] = []
        if(currentSelectServo.count>0){
            for i in 0..<currentSelectServo.count {
                outdatas.append(UInt8(ServoOneAccount + currentSelectServo[i]))
                if(i%2 == 0){
                    outdatas.append(map(x: (mvPoint1?.center.x)!, in_min: (bkArea1?.frame.minX)!, in_max: (bkArea1?.frame.maxX)!, out_min: CGFloat(servosData[currentSelectServo[i]].minA), out_max: CGFloat(servosData[currentSelectServo[i]].maxA)))
                }else{
                    outdatas.append(map(x: (mvPoint1?.center.y)!, in_min: (bkArea1?.frame.minY)!, in_max: (bkArea1?.frame.maxY)!, out_min: CGFloat(servosData[currentSelectServo[i]].minA), out_max: CGFloat(servosData[currentSelectServo[i]].maxA)))
                }
            }
            //self.showText.text = "移动坐标点\(outdatas)"
            print("测试点:\(outdatas)")
            writeToPeripheral(bytes: outdatas)
        }
    }
    
    
    //MARK: - Btns list
    
    //返回列表数量
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 20 //servoData.count
    }
    //生成列表 按钮
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = BtnsListView.dequeueReusableCell(withReuseIdentifier: "CheckBtnCells", for: indexPath) as! BtnCollectionViewCell
        cell.nameBtn.setTitle(servosData[indexPath.row].name, for: .normal)
        //按钮tag赋值为index
        cell.nameBtn.tag = indexPath.row
        //按钮点击事件
        cell.nameBtn.addTarget(self, action: #selector(BodyMoveViewController.selectBtnInList(_:)), for: .touchUpInside)
        if(currentSelectServo.contains(indexPath.row)){
            cell.nameBtn.backgroundColor = UIColor.red
            cell.nameBtn.isSelected = true
        }else{
            cell.nameBtn.backgroundColor = UIColor.darkGray
            cell.nameBtn.isSelected = false
        }
        return cell
    }
    //列表按钮点击事件， 点击后加入激活数组
    @objc func selectBtnInList(_ sender: UIButton) {
        if(currentSelectServo.contains(sender.tag)){
            sender.backgroundColor = UIColor.darkGray
            for i in 0..<currentSelectServo.count {
                if (currentSelectServo[i] == sender.tag){
                    currentSelectServo.remove(at: i)
                    return
                }
            }
        }else{
            currentSelectServo.append(sender.tag)
            sender.backgroundColor = UIColor.red
        }
        self.showText.text = "当前选择了:\(currentSelectServo)"
    }
    
    
    
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
