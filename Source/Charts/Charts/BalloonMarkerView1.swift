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
    var name: String?
    var value: String?
    var unit: String?
    var dash: Bool
    var isBar: Bool
}

open class BalloonMarkerView1: UIView {
    var selPoint: CGPoint = CGPoint()
    var dataEntrys: [ChartDataEntry]?
    var datas: Array<MarkerData>?
    
    var dayValue: String? {
        willSet
        {
            
        }
        didSet
        {
            
        }
    }
    
    var circleDayValue: String? {
        willSet
        {
            
        }
        didSet
        {

        }
    }
    
    var withBar = false
    var contentLeft = 0.0
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
        
        let itemH = tbCellH()
        
        var array = Array<MarkerData>()
        
        var showWidth = rate(130)
        var nameWidth = 0.0
        var valueWidth = 0.0
        
        let font: UIFont! = UIFont.init(name:"PingFangSC-Regular", size:rate(10))
        
        var circleIndex = NSNotFound
        var index = 0
        
        contentLeft = rate(22)
        
        for index in 0..<entrys.count {
            let entry = entrys[index]
            var itemName: String = entry.typeName ?? ""
            let len = itemName.count ?? 0
            
            if entry.isBar {
                contentLeft = rate(26)
                withBar = true
            }
            
            itemName.append("：")
            
            let unit = entry.unit ?? ""
            var value = String(format: "%@%@", String.hok_formatMoney(money: entry.y), unit)
            
            var data = MarkerData(circleColor: entry.color, textCor:textColor, name: itemName, value: value, unit:entry.unit, dash:entry.dash, isBar: entry.isBar)
            
            if circleIndex == NSNotFound && entry.dash {
                circleIndex = index
            }
            
            array.append(data)
            
            let rect: CGRect = itemName.boundingRect(with: CGSizeMake(1000, itemH), options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font : font],context:nil)
            
            let rect1: CGRect = value.boundingRect(with: CGSizeMake(1000, itemH), options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font : font],context:nil)
            
            let w = ceil(rect.size.width)
            
            let w1 = ceil(rect1.size.width)
            
            nameWidth = nameWidth < w ? w : nameWidth
            valueWidth = valueWidth < w1 ? w1 : valueWidth
        }
        
        let firstEntry = entrys.first
        
        if circleIndex != NSNotFound && circleDayValue != nil {
            let circleData = MarkerData(circleColor: nil, textCor:textColor, name: circleDayValue, value: nil, unit:nil, dash:false, isBar: false)
            array.insert(circleData, at: circleIndex)
        }
        
        var titleData = MarkerData(circleColor: nil, textCor:textColor, name: dayValue, value: nil, unit:nil, dash:false, isBar: false)
        array.insert(titleData, at: circleIndex > 0 ? 0 : circleIndex + 2)
        
        nameW = nameWidth
        valueW = valueWidth
        
        let allW = contentLeft + nameWidth + valueWidth + rate(10)
        let allH = tbTop() + Double(itemH * CGFloat(array.count)) + tbBottom()
        
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
    
    func tbTop() -> CGFloat {
        return rate(5)
    }
    
    func tbBottom() -> CGFloat {
        return rate(8)
    }
    
    func tbCellH() -> CGFloat {
        return rate(20)
    }
    
    func updateFrame() {
        tb.frame = CGRect(x: 0, y: tbTop(), width: self.bounds.size.width, height: self.bounds.size.height - tbTop() - tbBottom())
    }
    
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
            cell?.withBar = withBar;
            cell?.contentLeft = contentLeft;
            
            cell?.updateUI(nameW: nameW!, valueW: valueW!)
            
            cell?.updateData(data: item)
        }
        
        return cell!
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tbCellH()
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(indexPath.row)
        
    }
}

class BalloonMarkerCell: UITableViewCell {
    open var contentLeft = 0.0
    open var withBar = false

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        initSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
        
    func initSubviews() {
        contentLeft = rate(22)
        
        self.contentView.addSubview(titleLbl)
        
        self.contentView.addSubview(circleImgView)
        self.contentView.addSubview(nameLbl)
        self.contentView.addSubview(valueLbl)
    }
    
    func updateUI(nameW: CGFloat, valueW: CGFloat) {
        nameLbl.frame.origin.x = contentLeft
        nameLbl.frame.size.width = nameW
        
        valueLbl.frame.size.width = valueW
        valueLbl.frame.origin.x = CGRectGetMaxX(nameLbl.frame)
    }
    
    func updateData(data: MarkerData) {
        let bgColor = data.dash ? .white : data.circleColor
        circleImgView.backgroundColor = bgColor
 
        if data.isBar == false {
            circleImgView.frame.origin.x = withBar == false ? rate(10) : rate(11)
            circleImgView.frame.size.width = rate(8)
            circleImgView.frame.size.height = circleImgView.frame.size.width
            
            circleImgView.layer.borderColor = data.circleColor?.cgColor
            circleImgView.layer.borderWidth = 0.75
            circleImgView.layer.cornerRadius = circleImgView.frame.size.width * 0.5
        } else {
            circleImgView.frame.origin.x =  rate(10)
            circleImgView.frame.size.width = rate(10)
            circleImgView.frame.size.height = rate(6)

            circleImgView.layer.borderColor = nil
            circleImgView.layer.borderWidth = 0
            circleImgView.layer.cornerRadius = 1
        }
        circleImgView.center.y = self.bounds.height * 0.5
        
        titleLbl.text = data.name
        nameLbl.text = data.name
        valueLbl.text = data.value
        
        titleLbl.textColor = data.textCor
        nameLbl.textColor = data.textCor
        valueLbl.textColor = data.textCor
        
        let isTitle: Bool = data.circleColor == nil || data.value == nil
        
        titleLbl.isHidden = !isTitle
        circleImgView.isHidden = isTitle
        nameLbl.isHidden = isTitle
        valueLbl.isHidden = isTitle
    }
    
    @objc open lazy var circleImgView: UIImageView = {
        let imgView = UIImageView(frame: CGRect.init(x: rate(10), y: rate(6), width: rate(8), height: rate(8)))
        imgView.backgroundColor = .red
        imgView.layer.cornerRadius = imgView.frame.size.width * 0.5
        imgView.layer.masksToBounds = true
        imgView.layer.borderWidth = 0.75
        
        return imgView
    }()
    
    @objc open lazy var titleLbl: UILabel = {
        let lbl =  UILabel(frame: .zero)
        lbl.textAlignment = .left
        lbl.font = UIFont.init(name:"PingFangSC-Regular", size:rate(10))
        lbl.frame = CGRect(x:  rate(10), y: rate(2), width:rate(50), height: self.bounds.height)
        return lbl
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
        
        titleLbl.frame.size.height = self.bounds.height - titleLbl.frame.origin.y
        titleLbl.frame.size.width = self.bounds.width - titleLbl.frame.origin.x
        
        nameLbl.frame.size.height = self.bounds.height
        
        valueLbl.frame.size.height = self.bounds.height
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
        var showMoney = fabs(money)
        var unit = ""
        
        if (showMoney >= 10000 && showMoney < 100000000) {
            showMoney = showMoney / 10000
            unit = "万"
        } else if (showMoney >= 100000000) {
            showMoney = showMoney / 100000000
            unit = "亿"
        }
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        // 最少展示两位小数
        formatter.minimumFractionDigits = 0
        // 最多两位小数点
        formatter.maximumFractionDigits = 2
        
        let resValue = (money < 0 ? -1 : 1) * showMoney
        
        let resStr = String(format: "%@%@",  formatter.string(from: NSNumber(value: resValue)) ?? "0", unit)
        
        return resStr
    }
}
