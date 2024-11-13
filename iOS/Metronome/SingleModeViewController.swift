//
//  SingleModeViewController.swift
//  Metronome
//
//  Created by 정종원 on 11/13/24.
//

import UIKit
import Kronos

class SingleModeViewController: UIViewController {
    
    // MARK: - Properties
    let mockData = Array(1...100)
    let rotationAngle: CGFloat! = -90  * (.pi/180)
    
    // MARK: - UIComponents
    
    /// bpm 설정 피커뷰
    private lazy var bpmPickerView: UIPickerView = {
        let picker = UIPickerView()
        picker.delegate = self
        picker.dataSource = self
        picker.translatesAutoresizingMaskIntoConstraints = false
        picker.transform = CGAffineTransform(rotationAngle: rotationAngle) // picker 회전
        return picker
    }()
    
    /// bpm -10 버튼
    private lazy var minusTenBpmButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.title = "-10"
        config.baseForegroundColor = .black
        config.baseBackgroundColor = .systemGray
        let button = UIButton(configuration: config)
        button.addTarget(self, action: #selector(tappedMinusTen), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    /// bpm +10 버튼
    private lazy var plusTenBpmButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.title = "+10"
        config.baseForegroundColor = .black
        config.baseBackgroundColor = .systemGray
        let button = UIButton(configuration: config)
        button.addTarget(self, action: #selector(tappedPlusTen), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.view.backgroundColor = .white
        setupUI()
//
//        Clock.sync(completion:  { date, offset in
//            guard let date = date, let offset = offset else {
//                print("NTP 동기화 실패")
//                return
//            }
//            print("동기화된 시간: \(date)")
//            print("시계 오프셋: \(offset)초")
//            
//            // 로컬 타임존에 맞춘 시간 형식화
//            let localDateFormatter = DateFormatter()
//            localDateFormatter.calendar = Calendar.current
//            localDateFormatter.timeZone = TimeZone.current // 한국 UTC+9
//            localDateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
//            
//            let localDateString = localDateFormatter.string(from: date)
//            print("로컬 시간: \(localDateString)")
//            
//            // UTC 시간 형식화
//            let utcDateFormatter = DateFormatter()
//            utcDateFormatter.calendar = Calendar.current
//            utcDateFormatter.timeZone = TimeZone(abbreviation: "UTC")
//            utcDateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
//            
//            let utcDateString = utcDateFormatter.string(from: date)
//            print("UTC 시간: \(utcDateString)")
//        })
        
        
    }
    
    // MARK: - Methods
    
    func setupUI() {
        view.addSubview(bpmPickerView)
        view.addSubview(minusTenBpmButton)
        view.addSubview(plusTenBpmButton)
        
        NSLayoutConstraint.activate([
            bpmPickerView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            bpmPickerView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
            bpmPickerView.widthAnchor.constraint(equalToConstant: 100),
            bpmPickerView.heightAnchor.constraint(equalToConstant: 200),
            
            minusTenBpmButton.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 10),
            minusTenBpmButton.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
            minusTenBpmButton.widthAnchor.constraint(equalToConstant: 60),
            minusTenBpmButton.heightAnchor.constraint(equalToConstant: 44),
            
            plusTenBpmButton.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -10),
            plusTenBpmButton.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
            plusTenBpmButton.widthAnchor.constraint(equalToConstant: 60),
            plusTenBpmButton.heightAnchor.constraint(equalToConstant: 44),
            
        ])
    }
    
    @objc func tappedMinusTen() {
        
    }
    
    @objc func tappedPlusTen() {
        
    }
}

extension SingleModeViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        mockData.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return String(mockData[row])
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        print(mockData[row])
        pickerView.reloadAllComponents()
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        // text 회전
        let modeView = UIView()
        modeView.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        let modeLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        modeLabel.textColor = .black
        modeLabel.text = String(mockData[row])
        modeLabel.textAlignment = .center
        modeView.addSubview(modeLabel)
        modeView.transform = CGAffineTransform(rotationAngle: 90 * (.pi/180))
        return modeView
    }
}
