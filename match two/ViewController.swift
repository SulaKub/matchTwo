//
//  ViewController.swift
//  match two
//
//  Created by Sultan Kubentayev on 02/09/2024.
//

import UIKit

class ViewController: UIViewController {
     
    
    @IBOutlet weak var stepCountLabel: UILabel!
    @IBOutlet var bestTimeLabel: [UILabel]!
    
//    var state = [Int] (repeating: 0, count: 16)
//    var click = 1
//    var counter = 0
//    var firstClick : Int = 0
//    var secondClick : Int = 0
//    var cardImages : [String] = []
//    
    var imageNames : [String] = []
    var timer : Timer?
    var secondsElapsed: Int = 0
    var isOpened = false
    var previousButtonTag = 0
    var isTimerEnabled = false
    var isTimerRunning = false
    var count = 0
    var bestTime: Int {
        get {
            let storedTime = UserDefaults.standard.integer(forKey: "BestTime")
            // Возвращаем сохраненное время, если оно существует, иначе возвращаем Int.max
            return storedTime == 0 ? Int.max : storedTime
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "BestTime")
        }
    }
    var steps = 0{
        didSet{
            stepCountLabel.text = "Steps : \(steps)"
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        clear()
        updateBestTimeLabel()
        UserDefaults.standard.removeObject(forKey: "BestTime")
    }
    
    func updateBestTimeLabel() {
        guard let firstLabel = bestTimeLabel.first else { return }
        
        if bestTime == Int.max {
            firstLabel.text = "Лучшее время: Нет записей"
        } else {
            firstLabel.text = "Лучшее время: \(bestTime) сек"
        }
        
    }
    
    //MARK: - Загружаю картинки
    func clear() {
         let images = [
            "image1", "image2",
            "image3", "image4",
            "image5", "image6",
            "image7", "image8"
         ]
        //MARK: - делаю дубликаты и перемешиваю
        imageNames = images + images
        imageNames.shuffle()
        steps = 0
        count = 0
        
        //MARK: - Все картинки делаю перевернутыми
        for i in 1...16 {
            let button = view.viewWithTag(i) as! UIButton
            button.setBackgroundImage(UIImage(named: "backicon"), for: .normal)
        }
        secondsElapsed = 0
        startTimer()
        timer?.invalidate()
     }
    
    func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            self.secondsElapsed += 1
            print("Время: \(self.secondsElapsed) секунд")
        }
    }
    
    func showAlert() {
        var message = "Ваше время: \(secondsElapsed) секунд, \(steps) шагов"
        
        // Проверка и обновление рекордного времени
        if bestTime == Int.max || secondsElapsed < bestTime {
            bestTime = secondsElapsed
            message += "\nНовый рекорд!"
            updateBestTimeLabel()
        } else {
            message += "\nРекордное время: \(bestTime) секунд"
        }
        
        let alert = UIAlertController(title: "You won!", message: "Ваше время: \(secondsElapsed) секунд, \(steps) шагов", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
            self.clear()
        }))
        present(alert, animated: true, completion: nil)
        
        timer?.invalidate()
        isTimerRunning = false
    }
    
    func flipCard(button: UIButton, imageName: String) {
        UIView.transition(with: button, duration: 0.5, options: [.transitionFlipFromLeft], animations: {
            button.setBackgroundImage(UIImage(named: imageName), for: .normal)
        }, completion: nil)
    }
    
    @IBAction func game(_ sender: UIButton) {
        print(sender.tag)
        
        if !isTimerRunning {
            startTimer()
            isTimerRunning = true
        }
        
        if isTimerEnabled == true {
            return
        }
        
        if sender.backgroundImage(for: .normal) != UIImage(named: "backicon"){
            return
        }
        
        let imageName = imageNames[sender.tag - 1]
        
        // Анимация переворачивания при открытии карты
        flipCard(button: sender, imageName: imageName)
//        sender.setBackgroundImage(UIImage(named: imageNames[sender.tag - 1]), for: .normal)
        
        if isOpened == true {
            steps += 1
            
            if imageNames [sender.tag - 1] == imageNames[previousButtonTag - 1] {
                count += 1
            } else {
                isTimerEnabled = true
                
                Timer.scheduledTimer(withTimeInterval: 1, repeats: false) { _ in
                    sender.setBackgroundImage(UIImage(named: "backicon"), for: .normal)
                    
                    self.flipCard(button: sender, imageName: "backicon")
                    let previousButton = self.view.viewWithTag(self.previousButtonTag) as! UIButton
                    previousButton.setBackgroundImage(UIImage(named: "backicon"), for: .normal)
                    self.flipCard(button: previousButton, imageName: "backicon")
                    
                    self.isTimerEnabled = false
                }
            }
        } else {
            previousButtonTag = sender.tag
        }
        
        isOpened.toggle()
        
        if count == 8 {
            showAlert()
        }

    }
  
}

