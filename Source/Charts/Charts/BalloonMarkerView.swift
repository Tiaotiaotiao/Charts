//
//  BalloonMarkerView.swift
//  HokManage
//
//  Created by chenjinhua on 2022/8/25.
//

import UIKit

open class BalloonMarkerView: UIView {
    var selPoint: CGPoint = CGPoint()
    var points: [CGPoint]?
    var dataEntrys: [ChartDataEntry]?

    @objc open weak var chartView: ChartViewBase?

    @objc public var typeNames: [String]?
 
    @objc public var textColor: UIColor? {
        didSet {
            valueLbl1.textColor = textColor;
            valueLbl2.textColor = textColor;
        }
    }
    
    @objc public var textFont: UIFont? {
        didSet {
            valueLbl1.font = textFont;
            valueLbl2.font = textFont;
        }
    }
    
    @objc public var color1: UIColor? {
        didSet {
            circleView1.backgroundColor = color1;
        }
    }
    @objc public var color2: UIColor? {
        didSet {
            circleView2.backgroundColor = color2;
        }
    }

    //MARK: - Life circle
    override public init(frame :CGRect) {
        super.init(frame: frame)
        initSubviews()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initSubviews() {
        self.layer.cornerRadius = 4
        self.backgroundColor = UIColor.clear
    
        self.addSubview(circleView1)
        self.addSubview(circleView2)

        self.addSubview(valueLbl1)
        self.addSubview(valueLbl2)
        
        self.arrowView = BalloonMarkerArrowView(frame: CGRect(x: 0, y: 0, width: rate(15), height: rate(8)))
    }
    
    // MARK: - Public
    
    open func updateValues(values: [CGPoint], entrys: [ChartDataEntry])  {
        points = values
        dataEntrys = entrys;
        
        circleView1.alpha = 0;
        circleView2.alpha = 0;
        
        guard entrys.count > 0 else { return }
        
        let typeStr1 = typeNames?.first
        let e1 = entrys[0]
        
        valueLbl1.text = String(format: "%@%.0lf", typeStr1 ?? "", e1.y)
        valueLbl1.sizeToFit();
        circleView1.alpha = 1.0;
        
        guard entrys.count > 1 else { return }

        let typeStr2 = typeNames?.last
        let e2 = entrys[1]
        valueLbl2.text = String(format:  "%@%.0lf", typeStr2 ?? "", e2.y)
        
        valueLbl2.sizeToFit();
        circleView2.alpha = 1.0;
    }
    
    //MARK: Private
    
    func updateFrame() {
        // remove first
        self.arrowView.removeFromSuperview()
        if self.arrowView.superview == nil {
            self.superview?.addSubview(self.arrowView)
        }
        
        let w = valueLbl1.bounds.size.width > valueLbl2.bounds.size.width ? valueLbl1.bounds.size.width : valueLbl2.bounds.size.width
        var h = rate(42)
        
        let eCount = dataEntrys?.count ?? 0
        
        if (eCount <= 1) {
            h = rate(28);
        }
        
        let circleTop = rate(11)
        let circleH = circleH()
        let lblH = h * 0.5;
        
        self.frame = CGRect(x: 0, y: 10, width: w + rate(24), height: h)
        
        let y = self.selPoint.y

        self.arrowView.center.x = self.selPoint.x;
        self.arrowView.center.y = y - self.arrowView.bounds.size.height * 0.5 - 2;
        
        guard let chart: ChartViewBase = chartView else { return }
        
        // 左边最小值多往左一点 因为有圆角
        let left = chart.viewPortHandler.contentLeft - 5
        let right = chart.viewPortHandler.contentRight

        var bubbleX = self.arrowView.center.x - self.bounds.size.width * 0.5
        
        let bubbleMinX = self.arrowView.center.x - self.bounds.size.width * 0.5;
 
        if bubbleMinX < left  {
            bubbleX = left
        }
        
        let bubbleMaxX = self.arrowView.center.x + self.bounds.size.width * 0.5;
        
        if bubbleMaxX > right  {
            bubbleX = right - self.bounds.size.width
        }
        
        self.frame.origin.x = bubbleX;
        self.frame.origin.y = self.arrowView.frame.minY - self.bounds.size.height + 0.5
      
        circleView1.frame = CGRect(x:rate(8), y:circleTop, width:circleH, height:circleH)
        circleView2.frame = CGRect(x:circleView1.frame.origin.x, y:frame.size.height - circleTop - circleView1.bounds.size.height, width:circleView1.bounds.size.width, height:circleView1.bounds.size.height)
        
        valueLbl1.frame = CGRect(x:circleView1.frame.maxX + rate(4), y:circleView1.frame.midY - lblH * 0.5, width:w, height:lblH)
        valueLbl2.frame = CGRect(x:valueLbl1.frame.minX, y:circleView2.frame.midY - lblH * 0.5, width:w, height:lblH)
    }
    
//    func rate(_ x: CGFloat) -> CGFloat {
//        let res = x * min(UIScreen.main.bounds.size.width, UIScreen.main.bounds.size.height) / 375
//
//        return res
//    }
    
    func circleH() -> CGFloat {
        return rate(4)
    }
    
    //MARK: Lazy
    
    @objc open lazy var circleView1: UIView = {
        let circle =  UIView(frame: .zero)
        circle.backgroundColor = UIColor.red
        circle.layer.cornerRadius = circleH() * 0.5;
        
        return circle
    }()
    
    @objc open lazy var circleView2: UIView = {
        let circle =  UIView(frame: .zero)
        circle.backgroundColor = UIColor.red
        circle.layer.cornerRadius = circleH() * 0.5;

        return circle
    }()
    
    @objc open lazy var valueLbl1: UILabel = {
        let lbl =  UILabel(frame: .zero)
        lbl.backgroundColor = UIColor.clear
        lbl.textColor = UIColor.black
        lbl.textAlignment = .left
        lbl.font = UIFont.init(name:"PingFangSC-Regular", size:rate(10))
        
        return lbl
    }()
    
    @objc open lazy var valueLbl2: UILabel = {
        let lbl =  UILabel(frame: .zero)
        lbl.backgroundColor = UIColor.clear
        lbl.textColor = UIColor.black
        lbl.textAlignment = .left
        lbl.font = UIFont.init(name:"PingFangSC-Regular", size:rate(10))

        return lbl
    }()
    
    lazy var arrowView: BalloonMarkerArrowView = {
        let arrow =  BalloonMarkerArrowView(frame: CGRect(x: 0, y: 0, width: rate(15), height: rate(8)))

        return arrow
    }()

    
    //MARK: Super
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        updateFrame()
        
    }
}
