//
//  RegisterSliderView.swift
//  PanningMan
//
//  Created by 喜汇-Lee on 2017/3/9.
//  Copyright © 2017年 喜汇. All rights reserved.
//

import UIKit

protocol RegisterSliderViewDelegate {
    func sliderViewShouldRecovered() -> (Bool)  //滑到终点松开手指时是否应该还原
    func sliderViewDidDragToEndPoint()          //滑条已经被滑到终点
}

class RegisterSliderView: UIView {
    
    var delegate: RegisterSliderViewDelegate?
    // MARK:- 懒加载属性
    
    fileprivate lazy var sliderImgV: UIImageView = {
        let sliderImgV = UIImageView(image: #imageLiteral(resourceName: "slider"))
        sliderImgV.isUserInteractionEnabled = true
        let pan = UIPanGestureRecognizer(target: self, action: #selector(self.pan(pan:)))
        sliderImgV.addGestureRecognizer(pan)
        return sliderImgV
    }()
    
    fileprivate var imgCenter = CGPoint.zero
    
    fileprivate lazy var tipsLabel: UILabel = {
        let tipsLabel = UILabel()
        tipsLabel.text = "请按住滑块，拖动到最右边"
        tipsLabel.textAlignment = .center
        tipsLabel.textColor = UIColor(hexString: "666666")
        tipsLabel.font = UIFont.systemFont(ofSize: 14.0)
        return tipsLabel
    }()
    
    fileprivate let successImgV = UIImageView(image: #imageLiteral(resourceName: "finish"))
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubviews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupSubviews()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        sliderImgV.frame = CGRect(x: 0, y: 0, width: bounds.height, height: bounds.height)
        tipsLabel.frame = CGRect(x: (bounds.width - 200) * 0.5, y: (bounds.height - 20) * 0.5, width: 200, height: 20)
        successImgV.frame = CGRect(x: bounds.width - bounds.height, y: 0, width: bounds.height, height: bounds.height)
    }
    
    
    fileprivate func setupSubviews() {
        clipsToBounds = true
        backgroundColor = UIColor(hexString: "E5E6EA")
        addSubview(tipsLabel)
        addSubview(sliderImgV)
        
        successImgV.isHidden = true
        addSubview(successImgV)
    }
    
    func pan(pan: UIPanGestureRecognizer) {
        
        let halfWidth = sliderImgV.frame.width * 0.5
        let point = pan.translation(in: self)
        if pan.state == .began {
            imgCenter = pan.view!.center
        }
        
        sliderImgV.center.x = imgCenter.x + point.x
        if sliderImgV.center.x < halfWidth {
            sliderImgV.center.x = halfWidth
        }
        
        if sliderImgV.center.x > self.bounds.width - halfWidth {
            sliderImgV.center.x = self.bounds.width - halfWidth
        }
        
        if pan.state == .ended {
            print("停止了拖动")
            
            //如果未滑到终点,复原
            if sliderImgV.center.x < self.bounds.width - halfWidth {
                
                UIView.animate(withDuration: 0.25, animations: {
                    print(self.sliderImgV.center.x)
                    self.sliderImgV.center.x = halfWidth
                })
            }else{
                
                //判断是否需要复原
                let shouldRecovered = delegate?.sliderViewShouldRecovered() ?? false
                if shouldRecovered {
                    UIView.animate(withDuration: 0.25, animations: {
                        print(self.sliderImgV.center.x)
                        self.sliderImgV.center.x = halfWidth
                    })
                    self.setNeedsDisplay()
                    return
                }
                tipsLabel.text = "通过验证"
                tipsLabel.textColor = UIColor.white
                sliderImgV.isHidden = true
                successImgV.isHidden = false
                //通知代理
                perform(#selector(self.noticeDelegate), with: 0.5)
            }
        }
        setNeedsDisplay()
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        //获取当前图形上下文,填充颜色
        let context = UIGraphicsGetCurrentContext()
        context?.setFillColor(UIColor(hexString: "79c247").cgColor)
        context?.fill(CGRect(x: 0, y: 0, width: sliderImgV.frame.maxX, height: bounds.height))
        
    }
    
    func noticeDelegate() {
        delegate?.sliderViewDidDragToEndPoint()
    }
    
    // MARK:- 对外暴露的方法
    //被拖动到终点后,还原到起点
    func recoverToOrigin() {
        tipsLabel.text = "请按住滑块，拖动到最右边"
        tipsLabel.textColor = UIColor(hexString: "666666")
        sliderImgV.isHidden = false
        successImgV.isHidden = true
        
        UIView.animate(withDuration: 0.25) {
            self.sliderImgV.frame.origin = CGPoint.zero
        }
        self.setNeedsDisplay()
    }
}

extension UIColor{
    convenience init(hexString: String) {
        let hex = hexString.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int = UInt32()
        Scanner(string: hex).scanHexInt32(&int)
        let a, r, g, b: UInt32
        switch hex.characters.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
    }
}


