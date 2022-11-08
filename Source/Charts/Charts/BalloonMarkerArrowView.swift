//
//  BalloonMarkerArrowView.swift
//  HokBaseFrameWorks
//
//  Created by chenjinhua on 2022/9/6.
//

import Foundation
import CoreGraphics

open class BalloonMarkerArrowView: UIView {
    @objc open var fillColor: UIColor? {
        didSet {
            self.setNeedsDisplay();
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
        self.backgroundColor = UIColor.clear
    }
    
    //MARK: - Public

    //MARK: Private
    
    //MARK: Lazy
    
    //MARK: Super

    open override func draw(_ rect: CGRect) {
        super.draw(rect)

        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        let size = self.bounds.size
        
        UIGraphicsPushContext(context)
        
        context.beginPath()
        context.move(to: CGPoint(x: 0,y: 00))
        
        context.addLine(to: CGPoint(x: size.width * 0.5, y: size.height))
        
        context.addLine(to: CGPoint(x: size.width, y: 0))
        
        let color = fillColor ?? UIColor.white
 
        context.setFillColor(color.cgColor)
        context.fillPath()
        
        UIGraphicsPopContext()
        
        context.restoreGState()
    }
}
