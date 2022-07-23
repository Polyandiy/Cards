//
//  Cards.swift
//  Cards
//
//  Created by Поляндий on 12.07.2022.
//

import Foundation
import UIKit

//создаем представление карточек (с помощью дженерика)

protocol FlippableView: UIView {
    var isFlipped: Bool { get set }
    var flipCompletionHandler: ((FlippableView) -> Void)? { get set }
    func flip()
}


class CardView<ShapeType: ShapeLayerProtocol>: UIView, FlippableView {
    // цвет фигуры
    var color: UIColor!
    // радиус закругления
    var cornerRadius = 20

    init(frame: CGRect, color: UIColor) {
        super.init(frame: frame)
        self.color = color
        
        setupBorders()
    }
    
//Свойство isFlipped будет использоваться для того, чтобы определить, расположена ли игральная карточка лицевой стороной вверх или нет.
    var isFlipped: Bool = false {
        didSet {
            self.setNeedsDisplay()
        }
    }
    //Замыкание, хранящееся в свойстве flipCompletionHandler, позволит выполнить произвольный код после того, как карточка будет перевернута.
    var flipCompletionHandler: ((FlippableView) -> Void)?
    //Метод flip в дальнейшем будет использоваться для анимированного переворота карточки
    ///переворот карточки с использованием сложной анимации
    func flip() {
        let fromView = isFlipped ? frontSideView : backSideView
        let toView = isFlipped ? backSideView : frontSideView
        UIView.transition(from: fromView, to: toView, duration: 0.5, options: [.transitionFlipFromTop], completion: { _ in
            // обработчик переворота
            self.flipCompletionHandler?(self)
        })
        isFlipped.toggle()
    }
    
    override func draw(_ rect: CGRect) {
        //инициализатор, чтобы в представлении начали отображаться дочерние вью.
        if isFlipped {
                self.addSubview(backSideView)
                self.addSubview(frontSideView)
            } else {
                self.addSubview(frontSideView)
                self.addSubview(backSideView)
            }
    }
    
///ЛИЦЕВАЯ И ОБРАТНАЯ СТОРОНА КАРТОЧЕК
    
    //внутренний отступ представления
        private let margin: Int = 10
    
        // представление с лицевой стороной карты
        lazy var frontSideView: UIView = self.getFrontSideView()
        // представление с обратной стороной карты
        lazy var backSideView: UIView = self.getBackSideView()
    
        // возвращает представление для лицевой стороны карточки
        private func getFrontSideView() -> UIView {
            let view = UIView(frame: self.bounds)
            view.backgroundColor = .white
            let shapeView = UIView(frame: CGRect(x: margin, y: margin, width: Int(self.bounds.width)-margin*2, height: Int(self.bounds.height)-margin*2))
            view.addSubview(shapeView)
    
            // создание слоя с фигурой
            let shapeLayer = ShapeType(size: shapeView.frame.size, fillColor: color.cgColor)
            shapeView.layer.addSublayer(shapeLayer)
            
            // скругляем углы корневого слоя
                view.layer.masksToBounds = true
                view.layer.cornerRadius = CGFloat(cornerRadius)
    
            return view
        }
        
        // возвращает вью для обратной стороны карточки
        private func getBackSideView() -> UIView {
            let view = UIView(frame: self.bounds)
            view.backgroundColor = .white
            //выбор случайного узора для рубашки
            switch ["circle", "line"].randomElement()! {
            case "circle":
                let layer = BackSideCircle(size: self.bounds.size, fillColor: UIColor.black.cgColor)
                view.layer.addSublayer(layer)
            case "line":
                let layer = BackSideLine(size: self.bounds.size, fillColor: UIColor.black.cgColor)
                view.layer.addSublayer(layer)
            default:
                break
                        }
            // скругляем углы корневого слоя
                view.layer.masksToBounds = true
                view.layer.cornerRadius = CGFloat(cornerRadius)
            
                        return view
                    }
    
    // настройка границ карточки
        private func setupBorders(){
          self.clipsToBounds = true
          self.layer.cornerRadius = CGFloat(cornerRadius)
          self.layer.borderWidth = 2
          self.layer.borderColor = UIColor.black.cgColor
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    
    // MARK: - Table view data source
    ///ОБРАБОТКА КАСАНИЙ (СОБЫТИЯ И АНИМАЦИЯ)

    // точка привязки
    private var anchorPoint: CGPoint = CGPoint(x: 0, y: 0)
    //В данное свойство будут записываться исходные координаты игральной карточки.
    private var startTouchPoint: CGPoint!
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // изменяем координаты точки привязки
        anchorPoint.x = touches.first!.location(in: window).x - frame.minX
        anchorPoint.y = touches.first!.location(in: window).y - frame.minY
        
        // сохраняем исходные координаты
        startTouchPoint = frame.origin
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.frame.origin.x = touches.first!.location(in: window).x - anchorPoint.x
        self.frame.origin.y = touches.first!.location(in: window).y - anchorPoint.y
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if self.frame.origin == startTouchPoint {
            flip()
        }
        
    }
}
