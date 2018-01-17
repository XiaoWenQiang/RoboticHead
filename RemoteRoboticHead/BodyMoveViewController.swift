//
//  BodyMoveViewController.swift
//  RemoteRoboticHead
//
//  Created by QiaoWu on 2018/1/16.
//  Copyright © 2018年 EXdoll. All rights reserved.
//

import UIKit

class BodyMoveViewController: UIViewController {

    @IBOutlet weak var showText: UILabel!
    @IBOutlet weak var backGroundPic: UIImageView!
    
    
    
    var bkArea1:UIView?
    var bkArea2:UIView?
    var mvPoint1:UIView?
    var mvPoint2:UIView?
    var limitRect:LimitArea?
    
    var penDrag1:UIPanGestureRecognizer?
    var penDrag2:UIPanGestureRecognizer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        makebackgroundFroDrag()
        mvPoint1 = makePointForDrag(bg: self.bkArea1!)
        self.view.addSubview(mvPoint1!)
        

        penDrag1 = UIPanGestureRecognizer(target: self, action: #selector(BodyMoveViewController.drage_head(_:)))
        mvPoint1?.addGestureRecognizer(penDrag1!)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    //绘制背景图框和拖拽点 未完成
    func makePointForDrag(bg:UIView) -> UIView {
        let pt = UIView(frame: CGRect(x: bg.frame.origin.x+(VIEW_WIDTH(view: bg)/2)-20, y: bg.frame.origin.y+(VIEW_HEIGHT(view: bg)/2-20), width: 40, height: 40))
        pt.layer.cornerRadius = 20
        pt.layer.backgroundColor = UIColor.blue.cgColor
        return pt
    }
    func makebackgroundFroDrag() ->(){
        bkArea1 = UIView(frame: CGRect(x: SCREEN_WIDTH*0.2, y: SCREEN_HEIGHT*0.15, width: SCREEN_WIDTH*0.6, height: SCREEN_WIDTH*0.5))
        bkArea1?.layer.backgroundColor = UIColor.cyan.cgColor
        bkArea1?.layer.borderWidth = 2
        bkArea1?.layer.borderColor = UIColor.brown.cgColor
        bkArea1?.alpha = 0.3
        self.view.addSubview(bkArea1!)
        
        bkArea2 = UIView(frame: CGRect(x: SCREEN_WIDTH*0.2, y: SCREEN_HEIGHT*0.3, width: SCREEN_WIDTH*0.6, height: SCREEN_WIDTH*0.5))
        bkArea2?.layer.backgroundColor = UIColor.cyan.cgColor
        bkArea2?.layer.borderWidth = 2
        bkArea2?.layer.borderColor = UIColor.brown.cgColor
        bkArea2?.alpha = 0.3
        self.view.addSubview(bkArea2!)
        
        limitRect = LimitArea(minW: (self.bkArea1?.frame.origin.x)!, maxW: (self.bkArea1?.frame.origin.y)!, minH: (self.bkArea1?.frame.width)!, maxH: (self.bkArea1?.frame.height)!, centerX: (self.bkArea1?.center.x)!, centerY: (self.bkArea1?.center.y)!)
    }
    
    
    
    //拖拽动作
    @objc func drage_head(_ sender: UIPanGestureRecognizer) {
        if(sender.state == .began){
            self.showText.text="动作操作开始"
        }
        let point = sender.translation(in: view) //移动了的距离
        sender.view?.center = CGPoint(x: sender.view!.center.x + point.x, y: sender.view!.center.y + point.y)
        sender.setTranslation(.zero, in: view)
        if(sender.state == .ended){
            //回弹
            UIView.animate(withDuration: 0.4, delay: 0.2, options: .curveEaseInOut, animations: {
                () -> Void in
                sender.view?.center = CGPoint(x: (sender.view?.superview?.center.x)!-20, y: (sender.view?.superview?.center.y)!-20)
            }, completion: { (success) -> Void in
                if success {
                    //回弹动画结束后恢复默认约束值
                    self.showText.text="动作操作结束"
                }
            })
            return
        }
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
