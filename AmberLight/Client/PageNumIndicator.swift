//
//  pageNumIndicator.swift
//  AmberLight
//
//  Created by Pete Bennett on 29/04/2017.
//  Copyright © 2017 Pete Bennett. All rights reserved.
//

import Foundation
import UIKit
class PageNumIndicator {
    private var mView: UIStackView
    private var mViews: [UIView]
    private var mSubViews: [UIView]
    private var mSelected: Int = 0
    private var mRadius: CGFloat
    private var mSelRect: CGRect
    init(stackView parentView: UIStackView, initStatus: [Bool]) {
        mView = parentView
        mViews = []
        mSubViews = []
        let dim = parentView.frame.height * 0.9
        let margin = dim / 9
        let size = CGRect(x: 0, y: margin, width: dim, height: dim)
        mSelRect = size
        let dim2 = dim - 2 * margin
        let size2 = CGRect(x: margin, y: margin, width: dim2, height: dim2)
        mRadius = dim2 / 2
        mView.translatesAutoresizingMaskIntoConstraints = false
        
        var view1 = UIView()
        view1.widthAnchor.constraint(equalToConstant: dim).isActive = true
        view1.backgroundColor = .clear
        mView.addArrangedSubview(view1) // Add dummy view as a spacer at front
        for i in 0...(initStatus.count-1) {
            let view = UIView()
            view.widthAnchor.constraint(equalToConstant: dim).isActive = true
            let subView = UIView(frame: size2)
            view.addSubview(subView)
            view.backgroundColor = .clear
            subView.backgroundColor = .clear
            mViews.append(view)
            mSubViews.append(subView)
            setStatus(number: i, status: initStatus[i])
            mView.addArrangedSubview(view)
        }
        view1 = UIView()
        view1.widthAnchor.constraint(equalToConstant: dim).isActive = true
        view1.backgroundColor = .clear
        mView.addArrangedSubview(view1)  // and another spacer at back
    }
    public func setStatus(number: Int, status: Bool) {
        mSubViews[number].layer.sublayers?.forEach { $0.removeFromSuperlayer() }
        if status {
            mSubViews[number].layer.addSublayer(getLayer(colour: .green))
        } else {
            mSubViews[number].layer.addSublayer(getLayer(colour: .red))
        }
    }
    public func setSelected(number: Int) {

        mViews[mSelected].backgroundColor = .clear
        mViews[number].backgroundColor = .white
        mSelected = number
        
    }
    private func getLayer(colour: UIColor) -> CAShapeLayer{
        let circlePath = UIBezierPath(arcCenter: CGPoint(x: mRadius,y: mRadius), radius: mRadius, startAngle: CGFloat(0), endAngle:CGFloat(Double.pi * 2), clockwise: true)
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = circlePath.cgPath
        
        //change the fill color
        shapeLayer.fillColor = colour.cgColor
        //you can change the stroke color
        shapeLayer.strokeColor = colour.cgColor
        //you can change the line width
//        shapeLayer.lineWidth = 3.0
        return shapeLayer
        
    }
}

