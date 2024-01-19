//
//  ViewController.swift
//  circleGame
//
//  Created by Nadia on 16.01.2024.
//

import UIKit

final class GameViewController: UIViewController {
    // MARK: - Enum of Constraints
    enum ConstraintsOfGameViewController {
          static let centerX: CGFloat = 0
          static let addButtonHeight: CGFloat = 50
          static let addpButtonWidth: CGFloat = 50
          static let addButtonLeft: CGFloat = 32
          static let addButtonBottom: CGFloat = -20
          static let minusButtonHeight: CGFloat = 50
          static let minusButtonWidth: CGFloat = 50
          static let minusButtonRight: CGFloat = -72
          static let minusButtonBottom: CGFloat = -20
    }
    
    private var gameModel = GameModel()
    private var circleView: UIView!
    private var obstacles = [UIView]()
    private var collisionTracker: [UIView: Bool] = [:]
   
    lazy var addButton: UIButton = {
      let addButton = UIButton(type: .system)
        addButton.setTitle("+", for: .normal)
        addButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 25)
        addButton.tintColor = UIColor.black
        addButton.backgroundColor   = UIColor.yellow
        addButton.layer.cornerRadius = 15
        addButton.translatesAutoresizingMaskIntoConstraints = false
        addButton.addTarget(self, action: #selector(increaseCircleSize), for: .touchUpInside)
        
      return addButton
    }()
    
    lazy var minusButton: UIButton = {
      let minusButton = UIButton(type: .system)
        minusButton.setTitle("-", for: .normal)
        minusButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 25) 
        minusButton.tintColor = UIColor.black
        minusButton.backgroundColor   = UIColor.yellow
        minusButton.layer.cornerRadius = 15
        minusButton.translatesAutoresizingMaskIntoConstraints = false
        minusButton.addTarget(self, action: #selector(decreaseCircleSize), for: .touchUpInside)
        
      return minusButton
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(named: "base")
        setupUI()
        startRotatingCircle()
        view.addSubview(addButton)
        view.addSubview(minusButton)
        startGame()
    }
    
    override func viewWillLayoutSubviews() {
      self.constraintsOfAddButton()
      self.constraintsOfMinusButton()
    }
    
    private func setupUI() {
        let screenSize = UIScreen.main.bounds.size
        // Створення кола
        circleView = UIView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        circleView.center = CGPoint(x: screenSize.width / 2, y: screenSize.height / 2)
        circleView.backgroundColor = UIColor.yellow
        circleView.layer.cornerRadius = circleView.frame.width / 2
        view.addSubview(circleView)
    }
    
    // MARK: - Constraints
    private func constraintsOfAddButton() {
      NSLayoutConstraint.activate([
                                    NSLayoutConstraint(item: addButton, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: ConstraintsOfGameViewController.addButtonHeight),
                                    NSLayoutConstraint(item: addButton, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: ConstraintsOfGameViewController.addpButtonWidth),
                                    NSLayoutConstraint(item: addButton, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: ConstraintsOfGameViewController.addButtonBottom),
                                    NSLayoutConstraint(item: addButton, attribute: .left, relatedBy: .lessThanOrEqual, toItem: view, attribute: .left, multiplier: 1, constant: ConstraintsOfGameViewController.addButtonLeft)])
    }
    
    private func constraintsOfMinusButton() {
      NSLayoutConstraint.activate([
                                    NSLayoutConstraint(item: minusButton, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: ConstraintsOfGameViewController.minusButtonHeight),
                                    NSLayoutConstraint(item: minusButton, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: ConstraintsOfGameViewController.minusButtonWidth),
                                    NSLayoutConstraint(item: minusButton, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: ConstraintsOfGameViewController.minusButtonBottom),
                                    NSLayoutConstraint(item: minusButton, attribute: .left, relatedBy: .lessThanOrEqual, toItem: view, attribute: .right, multiplier: 1, constant: ConstraintsOfGameViewController.minusButtonRight)])
    }
    
    private func startGame() {
        // Додавання таймеру для створення перешкод
        Timer.scheduledTimer(timeInterval: 1.5,
                             target: self,
                             selector: #selector(createObstacle),
                             userInfo: nil,
                             repeats: true)
        Timer.scheduledTimer(timeInterval: 2.0,
                             target: self,
                             selector: #selector(checkCollision),
                             userInfo: nil,
                             repeats: true)
    }
    
    private func startRotatingCircle() {
        let rotation = CABasicAnimation(keyPath: "transform.rotation")
        rotation.fromValue = 0
        rotation.toValue = 2 * Double.pi
        rotation.duration = 2 
        rotation.repeatCount = Float.infinity // безкінечне повторення

        circleView.layer.add(rotation, forKey: "rotateAnimation")
    }
    
    @objc func createObstacle() {
        let obstacleHeight: CGFloat = 6
        let obstacleWidth: CGFloat = 200
        let topOffset: CGFloat = 50
        let bottomOffset: CGFloat = UIScreen.main.bounds.height - 50
        let yPos: CGFloat
            if Bool.random() {
            yPos = circleView.frame.midY
        } else {
            yPos = CGFloat.random(in: topOffset...bottomOffset)
        }
        let obstacle = UIView(frame: CGRect(x: view.frame.width, y: yPos, width: obstacleWidth, height: obstacleHeight))
        obstacle.backgroundColor = UIColor.red
        view.addSubview(obstacle)
        obstacles.append(obstacle)
        collisionTracker[obstacle] = false // Ініціалізація стану зіткнення для нової перешкоди
        //створення анімації
        UIView.animate(withDuration: 5.0, delay: 0, options: [.curveLinear, .allowUserInteraction], animations: {
            obstacle.frame.origin.x = -obstacleWidth / 2
        }) { [weak self] (_) in
            obstacle.removeFromSuperview()
            self?.obstacles.removeAll(where: { $0 == obstacle })
            self?.collisionTracker.removeValue(forKey: obstacle) // Видаляємо зіткнення зі словника
        }
    }
    
    @objc func increaseCircleSize() -> () {
            guard circleView.bounds.width < 200 else { return }
            circleView.transform = circleView.transform.scaledBy(x: 1.2, y: 1.2)
            circleView.center = view.center
        }
    
    @objc func decreaseCircleSize() {
        guard circleView.bounds.width > 30 else { return }
        circleView.transform = circleView.transform.scaledBy(x: 0.8, y: 0.8)
        circleView.center = view.center
    }
    
    private func showAlert() {
        if !gameModel.isAlertShown {
            let alert = UIAlertController(title: "Попередження", message: "Необхідно перезапустити екран", preferredStyle: .alert)
            let restartAction = UIAlertAction(title: "Перезапустити", style: .default) { (_) in
                self.restartGame()
            }
            alert.addAction(restartAction)
            present(alert, animated: true, completion: nil)
            gameModel.isAlertShown = true  // Встановлюємо прапорець у true, коли показуємо алерт
        }
    }

    private func restartGame() {
        circleView.transform = .identity
        circleView.center = view.center
        gameModel.collisionCount = 0
        obstacles.forEach { $0.removeFromSuperview() }
        obstacles.removeAll()
        collisionTracker.removeAll() // Очищення словника зіткнень
        gameModel.isAlertShown = false
    }

    private func vibrate() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
    }
    
    // Метод для визначення зіткнення
    @objc func checkCollision() {
        let circleFrame = calculateActualFrame(for: circleView)
        for obstacle in obstacles {
            guard let presentationLayer = obstacle.layer.presentation() else { continue }
            let convertedObstacleFrame = CGRect(x: presentationLayer.frame.origin.x, y: presentationLayer.frame.origin.y, width: presentationLayer.frame.size.width, height: presentationLayer.frame.size.height)

            if circleFrame.intersects(convertedObstacleFrame) {
                if collisionTracker[obstacle] != true {
                    collisionTracker[obstacle] = true
                    gameModel.collisionCount += 1
                    print("count \(gameModel.collisionCount)")
                    vibrate()
                    if gameModel.collisionCount >= 5 {
                        showAlert()
                        return
                    }
                }
            } else {
                collisionTracker[obstacle] = false // Ресет, якщо немає зіткнення
            }
        }
    }

    private func calculateActualFrame(for view: UIView) -> CGRect {
        let center = view.center
        let size = view.bounds.size.applying(view.transform)
        let origin = CGPoint(x: center.x - size.width / 2, y: center.y - size.height / 2)
        return CGRect(origin: origin, size: size)
    }
}
   
        


    

