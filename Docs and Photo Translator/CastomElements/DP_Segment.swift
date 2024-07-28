//
//  DP_Segment.swift
//  Docs and Photo Translator
//
//  Created by Aleksandr on 26.07.2024.
//

import UIKit

class DP_SegmentControl: UIControl {

    private var labels: [UILabel] = []
    
    private var items: [String] = [] {
        didSet {
            setupLabels()
        }
    }
    
    var selectedIndex : Int = 0 {
        didSet {
            displayNewSelectedIndex()
        }
    }
    var thumbView: UIView = UIView()
    
    init(frame: CGRect, items: [String]) {
        self.items = items
        super.init(frame: frame)
        
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        setupView()
    }
    
    func setupView() {
        layer.cornerRadius = 9
        layer.borderColor = UIColor.lightGray.withAlphaComponent(0.2).cgColor
        layer.borderWidth = 0.5
        
        backgroundColor = UIColor.white
        setupLabels()
        insertSubview(thumbView, at: 0)
    }
    
    func reloadSegment() {
        selectedIndex = 0
        for index in 1...items.count {
    
            labels[index - 1].textColor = UIColor.black
            if (index - 1) == (selectedIndex) {
                labels[selectedIndex].textColor = UIColor.white
            }
        }
    }
    
    func setupLabels() {
        for label in labels {
            label.removeFromSuperview()
        }
        
        labels.removeAll(keepingCapacity: true)
        
        for index in 1...items.count {
            let label = UILabel(frame: .zero)
            label.text = items[index - 1]
            label.font = UIFont.systemFont(ofSize: 13)
            label.textAlignment = .center
            label.textColor = UIColor.black
            
            if index == (selectedIndex + 1) {
                label.textColor = UIColor.white
            }
            
            self.addSubview(label)
            labels.append(label)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        var selectFrame = self.bounds
        let newWidth = CGRectGetWidth(selectFrame)
        selectFrame.size.width = newWidth
        thumbView.frame = CGRect(x: 0, y: 0, width: bounds.width / CGFloat(labels.count), height: frame.height)
  //      thumbView.backgroundColor = UIColor.white
        thumbView.layer.cornerRadius = 9
        thumbView.layer.masksToBounds = true
        thumbView.setGradient(colorTop: UIColor(hexString: "#0B4EFF"), colorBottom: UIColor(hexString: "#3E73FF"), frame: thumbView.frame)
        
        let labelHeight = self.bounds.height
        let labelWidth = self.bounds.width / CGFloat(labels.count)
        
        for index in 0...labels.count - 1 {
            let label = labels[index]
            let xPosition = CGFloat(index) * labelWidth
            label.frame = CGRect(x: xPosition, y: 0, width: labelWidth, height: labelHeight)
        }
    }
    
    override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        let location = touch.location(in: self)
        var calculatedIndex: Int?
        for(index, item) in labels.enumerated() {
            if item.frame.contains(location) {
                calculatedIndex = index
                
                labels.forEach { label in
                    label.textColor = .black
                }
                labels[index].textColor = .white
            }
        }
        
        if calculatedIndex != nil {
            selectedIndex = calculatedIndex!
            sendActions(for: .valueChanged)
        }
        return false
    }
    
    func displayNewSelectedIndex() {
        let label = labels[selectedIndex]
        self.thumbView.frame = label.frame
    }
}
