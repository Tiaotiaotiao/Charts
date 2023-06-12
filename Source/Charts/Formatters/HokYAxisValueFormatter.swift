//
//  HokYAxisValueFormatter.swift
//  HokManage
//
//  Created by chenjinhua on 2023/5/24.
//

import Foundation

@objc(ChartHokYAxisValueFormatter)
open class HokYAxisValueFormatter: NSObject, AxisValueFormatter
{
    public typealias Block = (
        _ value: Double,
        _ axis: AxisBase?) -> String
    
    @objc open var block: Block?
    
    @objc open var hasAutoDecimals: Bool = false
    
    private var _formatter: NumberFormatter?
    @objc open var formatter: NumberFormatter?
    {
        get { return _formatter }
        set
        {
            hasAutoDecimals = false
            _formatter = newValue
        }
    }

    // TODO: Documentation. Especially the nil case
    private var _decimals: Int?
    open var decimals: Int?
    {
        get { return _decimals }
        set
        {
            _decimals = newValue
            
            if let digits = newValue
            {
                self.formatter?.minimumFractionDigits = digits
                self.formatter?.maximumFractionDigits = digits
                self.formatter?.usesGroupingSeparator = true
            }
        }
    }
    
    public override init()
    {
        super.init()
        
        self.formatter = NumberFormatter()
        self.formatter?.numberStyle = .decimal
        // 最少0位小数点
        self.formatter?.minimumFractionDigits = 0;
        // 最多2位小数点
        self.formatter?.maximumFractionDigits = 2;
        
        hasAutoDecimals = true
    }
    
    @objc public init(formatter: NumberFormatter)
    {
        super.init()
        
        self.formatter = formatter
    }
    
    @objc public init(decimals: Int)
    {
        super.init()
        
        self.formatter = NumberFormatter()
        self.formatter?.usesGroupingSeparator = true
        
        self.decimals = decimals
        hasAutoDecimals = true
    }
    
    @objc public init(block: @escaping Block)
    {
        super.init()
        
        self.block = block
    }
    
    @objc public static func with(block: @escaping Block) -> HokYAxisValueFormatter?
    {
        return HokYAxisValueFormatter(block: block)
    }
    
    open func stringForValue(_ value: Double,
                               axis: AxisBase?) -> String
    {
        if let block = block {
            return block(value, axis)
        } else {
            var showValue = value
            var unit = ""
            if (showValue >= 10000 && showValue < 100000000) {
                showValue = showValue / 10000
                unit = "万"
            } else if (showValue >= 100000000) {
                showValue = showValue / 100000000
                unit = "亿"
            }
            
            return String(format: "%@%@", formatter?.string(from: NSNumber(floatLiteral: showValue)) ?? "", unit)
            
            //return formatter?.string(from: NSNumber(floatLiteral: showValue)) ?? ""
        }
    }
}
