//
//  BalloonMarkerView1.swift
//  HokBaseFrameWorks
//
//  Created by chenjinhua on 2023/4/11.
//

import Foundation

protocol UIViewFrameAutoProtocol : AnyObject {
    func rate(_ x: CGFloat) -> CGFloat
}

struct MarkerData {
    var circleColor: UIColor?
    var textCor: UIColor?
    var name: String
    var value: String
    var dash: Bool
}

open class BalloonMarkerView1: UIView {
    var selPoint: CGPoint = CGPoint()
    //var points: [CGPoint]?
    var dataEntrys: [ChartDataEntry]?
    var datas: Array<MarkerData>?
    
    var dayValue: String? {
        willSet
        {
            
        }
        didSet
        {
            dayLbl.text = dayValue
        }
    }
    
    var nameW: CGFloat? = 0
    var valueW: CGFloat? = 0

    @objc open weak var chartView: ChartViewBase?
    @objc public var textColor: UIColor? = UIColor(red: 119/255.0, green: 119/255.0, blue: 119/255.0, alpha: 1.0)

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
        
        self.addSubview(dayLbl)
        
        self.addSubview(tb)
    }
    
    // MARK: - Public
    
    open func updateValues(entrys: [ChartDataEntry])  {
        dataEntrys = entrys
        guard entrys.count > 0 else {
            datas = []
            tb.reloadData()
            return
        }
        
        var y = rate(13)
        let itemH = rate(20)
        
        var array = Array<MarkerData>()
        
        var showWidth = rate(130)
        var nameWidth = 0.0

        var valueWidth = 0.0
        
        let font: UIFont! = UIFont.init(name:"PingFangSC-Regular", size:rate(10))
        
        for entry in entrys {
            var itemName: String = entry.typeName ?? ""
            let len = itemName.count ?? 0
            itemName = String(itemName.prefix(6))
 
            if len > 6 {
                itemName.append("…")
            }
            
            itemName.append("：")
            
            var value = String.hok_formatMoney(money: entry.y)
            
            var data = MarkerData(circleColor: entry.color, textCor:textColor, name: itemName, value: value, dash:entry.dash)
            
            array.append(data)
            
            let rect: CGRect = itemName.boundingRect(with: CGSizeMake(1000, itemH), options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font : font],context:nil)
            
            let rect1: CGRect = value.boundingRect(with: CGSizeMake(1000, itemH), options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font : font],context:nil)

            let w = ceil(rect.size.width)

            let w1 = ceil(rect1.size.width)
            
            nameWidth = nameWidth < w ? w : nameWidth
            valueWidth = valueWidth < w1 ? w1 : valueWidth
        }
        
        let firstEntry = entrys.first
        
        nameW = nameWidth
        valueW = valueWidth
        
        let allW = rate(22) + nameWidth + valueWidth + rate(10)
        let allH = CGRectGetMaxY(dayLbl.frame) + Double(itemH * CGFloat(entrys.count)) + tbBottom()
        
        let selX = self.selPoint.x
        let selY = self.selPoint.y
        
        let xAdd = rate(8)
        var showX = selX + xAdd
        var showY = selY - rate(15)
        
        if firstEntry != nil && firstEntry?.position != nil {
            showY = firstEntry!.position!.y - rate(15)
        }
        
        self.frame = CGRect(x: showX, y: showY, width: allW, height: allH)
        
        guard let chart: ChartViewBase = chartView else { return }
        
        // 左边最小值多往左一点 因为有圆角
        let left = chart.viewPortHandler.contentLeft
        let right = chart.viewPortHandler.contentRight
        let bottom = chart.viewPortHandler.contentBottom - rate(15)
        let contentH = chart.viewPortHandler.contentHeight
        
        let showMaxX = selX + self.bounds.size.width

        if showMaxX > right  {
            showX = selX - xAdd - self.bounds.size.width
        }
        
        if self.bounds.size.height > contentH {
            showY = contentH * 0.5 - self.bounds.size.height * 0.5
        }
        
        let showMaxY = showY + self.bounds.size.height
        if showMaxY > bottom {
            showY = bottom - self.bounds.size.height
        }
        
        self.frame.origin.x = showX
        self.frame.origin.y = showY
        
        datas = array
        
        tb.reloadData()
    }
    
    //MARK: Private
    
    func tbBottom() -> CGFloat {
        return rate(5)
    }
    
    func updateFrame() {
        let y = CGRectGetMaxY(dayLbl.frame)
        dayLbl.frame.size.width = self.bounds.size.width - dayLbl.frame.origin.x * 2;
        tb.frame = CGRect(x: 0, y: y, width: self.bounds.size.width, height: self.bounds.size.height - y - tbBottom())
    }
    
    lazy var dayLbl: UILabel = {
        let lbl =  UILabel(frame: CGRect(x: rate(10), y: rate(5), width: rate(50), height: rate(16)))
        lbl.backgroundColor = UIColor.clear
        lbl.textColor = textColor
        lbl.textAlignment = .left
        lbl.font = UIFont.init(name:"PingFangSC-Regular", size:rate(10))
        
        return lbl
    }()
    
    lazy var tb: UITableView = {
        let tb = UITableView(frame: self.bounds, style: .plain)
        tb.backgroundColor = UIColor.clear
        tb.separatorStyle = .none
        tb.showsVerticalScrollIndicator = false
        tb.delegate = self
        tb.dataSource = self
        
        if #available(iOS 15.0, *) {
            tb.sectionHeaderTopPadding = 0
        }
        
        if #available(iOS 11.0, *) {
            tb.contentInsetAdjustmentBehavior = .never
        }
        
        tb.register(BalloonMarkerCell.self, forCellReuseIdentifier: NSStringFromClass(BalloonMarkerCell.self))
        
        return tb
    }()

    
    //MARK: Super
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        updateFrame()
    }
}

extension BalloonMarkerView1: UITableViewDelegate, UITableViewDataSource {
    public func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return datas?.count ?? 0
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(BalloonMarkerCell.self)) as? BalloonMarkerCell
        
        let cout = datas?.count ?? 0
        if cout > 0 && indexPath.row < cout {
            let item = datas![indexPath.row]
            cell?.updateUI(nameW: nameW!, valueW: valueW!)
            cell?.updateData(data: item)
        }
        
        return cell!
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return rate(20)
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(indexPath.row)
        
    }
}

class BalloonMarkerCell: UITableViewCell {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        initSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initSubviews() {
        self.contentView.addSubview(circleImgView)
        self.contentView.addSubview(nameLbl)
        self.contentView.addSubview(valueLbl)
    }
    
    func updateUI(nameW: CGFloat, valueW: CGFloat) {
        nameLbl.frame.size.width = nameW
        valueLbl.frame.size.width = valueW
        valueLbl.frame.origin.x = CGRectGetMaxX(nameLbl.frame)
    }
    
    func updateData(data: MarkerData) {
        let bgColor = data.dash ? .white : data.circleColor
        circleImgView.layer.borderColor = data.circleColor?.cgColor
        circleImgView.backgroundColor = bgColor
        
        nameLbl.text = data.name
        valueLbl.text = data.value
        
        nameLbl.textColor = data.textCor
        valueLbl.textColor = data.textCor
    }
    
    @objc open lazy var circleImgView: UIImageView = {
        let imgView = UIImageView(frame: CGRect.init(x: rate(10), y: rate(6), width: rate(8), height: rate(8)))
        imgView.backgroundColor = .red
        imgView.layer.cornerRadius = imgView.frame.size.width * 0.5
        imgView.layer.masksToBounds = true
        imgView.layer.borderWidth = 0.75
        
        return imgView
    }()
    
    @objc open lazy var nameLbl: UILabel = {
        let lbl =  UILabel(frame: .zero)
        lbl.textAlignment = .left
        lbl.font = UIFont.init(name:"PingFangSC-Regular", size:rate(10))
        lbl.frame = CGRect(x: CGRectGetMaxX(circleImgView.frame) + rate(4), y:0, width:rate(50), height: self.bounds.height)
        return lbl
    }()
    
    @objc open lazy var valueLbl: UILabel = {
        let lbl =  UILabel(frame: .zero)
        lbl.textColor = .black
        lbl.textAlignment = .left
        lbl.font = UIFont.init(name:"PingFangSC-Regular", size:rate(10))
        lbl.frame = CGRect(x: CGRectGetMaxX(nameLbl.frame), y: 0, width: rate(50), height: self.bounds.height)
        return lbl
    }()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        circleImgView.center.y = self.bounds.height * 0.5
        nameLbl.frame.size.height = self.bounds.height
        valueLbl.frame.size.height = self.bounds.height
        //circleImgView.center.y = self.bounds.height * 0.5
    }
}

extension UIView: UIViewFrameAutoProtocol {
    func rate(_ x: CGFloat) -> CGFloat {
        let res = x * min(UIScreen.main.bounds.size.width, UIScreen.main.bounds.size.height) / 375
        
        return res
    }
}

extension String {
    static func hok_formatMoney(money: CGFloat) -> String {
        var showMoney = money
        var unit = ""
        
        if (showMoney >= 100000 && showMoney < 100000000) {
            showMoney = showMoney / 10000
            unit = "万"
        } else if (showMoney >= 100000000) {
            showMoney = showMoney / 100000000
            unit = "亿"
        }
        
        let resStr = String(format: "%.2lf%@", showMoney, unit)
        
        return resStr
    }
}
