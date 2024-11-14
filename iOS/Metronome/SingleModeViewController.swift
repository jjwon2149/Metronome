//
//  SingleModeViewController.swift
//  Metronome
//
//  Created by 정종원 on 11/13/24.
//

import UIKit
import Kronos

extension UIView {
    func addSubviews(_ views: UIView...) {
        for view in views {
            addSubview(view)
        }
    }
}

class SingleModeViewController: UIViewController {
    
    // MARK: - Properties
    let mockData = Array(1...100)
    let rotationAngle: CGFloat! = -90  * (.pi/180)
    
    // MARK: - UIComponents
    
    /// notes 스택뷰
    private lazy var notesStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.distribution = .equalSpacing
        return stackView
    }()
    
    /// note 개수 추가 버튼
    private lazy var addNoteButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.title = "+"
        config.baseForegroundColor = .black
        config.baseBackgroundColor = .systemGray
        let button = UIButton(configuration: config)
        button.addTarget(self, action: #selector(tappedAddNote), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    /// note 개수 삭제 버튼
    private lazy var removeNoteButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.title = "-"
        config.baseForegroundColor = .black
        config.baseBackgroundColor = .systemGray
        let button = UIButton(configuration: config)
        button.addTarget(self, action: #selector(tappedRemoveNote), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
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
    
    /// 시작 버튼
    private lazy var playButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.image = UIImage(systemName: "play.fill")
        config.baseForegroundColor = .black
        config.baseBackgroundColor = .systemGray
        let button = UIButton(configuration: config)
        button.addTarget(self, action: #selector(tappedPlay), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    /// 노트 시각효과 on/off 버튼
    private lazy var flashButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.image = UIImage(systemName: "flashlight.off.fill")
        config.baseForegroundColor = .black
        config.baseBackgroundColor = .systemGray
        let button = UIButton(configuration: config)
        button.addTarget(self, action: #selector(tappedFlash), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    /// 노트 소리 설정 버튼
    private lazy var settingButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.image = UIImage(systemName: "gearshape.fill")
        config.baseForegroundColor = .black
        config.baseBackgroundColor = .systemGray
        let button = UIButton(configuration: config)
        button.addTarget(self, action: #selector(tappedSetting), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    /// bpm 저장 테이블뷰
    private lazy var savedBpmTableView: UITableView = {
        let table = UITableView()
        table.translatesAutoresizingMaskIntoConstraints = false
        table.delegate = self
        table.dataSource = self
        return table
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
    
    // MARK: - UI & Layouts
    
    func setupUI() {
        view.addSubviews(
            notesStackView,
            addNoteButton,
            removeNoteButton,
            bpmPickerView,
            minusTenBpmButton,
            plusTenBpmButton,
            playButton,
            flashButton,
            settingButton,
            savedBpmTableView
        )
        
        NSLayoutConstraint.activate([
            notesStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            notesStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            notesStackView.heightAnchor.constraint(equalToConstant: 60),
            
            addNoteButton.centerYAnchor.constraint(equalTo: notesStackView.centerYAnchor),
            addNoteButton.trailingAnchor.constraint(equalTo: notesStackView.leadingAnchor, constant: -10),
            addNoteButton.widthAnchor.constraint(equalToConstant: 44),
            addNoteButton.heightAnchor.constraint(equalToConstant: 44),
            
            removeNoteButton.centerYAnchor.constraint(equalTo: notesStackView.centerYAnchor),
            removeNoteButton.leadingAnchor.constraint(equalTo: notesStackView.trailingAnchor, constant: 10),
            removeNoteButton.widthAnchor.constraint(equalToConstant: 44),
            removeNoteButton.heightAnchor.constraint(equalToConstant: 44),
            
            bpmPickerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            bpmPickerView.topAnchor.constraint(equalTo: notesStackView.bottomAnchor, constant: 20),
            bpmPickerView.widthAnchor.constraint(equalToConstant: 100),
            bpmPickerView.heightAnchor.constraint(equalToConstant: 200),
            
            minusTenBpmButton.centerYAnchor.constraint(equalTo: bpmPickerView.centerYAnchor),
            minusTenBpmButton.trailingAnchor.constraint(equalTo: bpmPickerView.leadingAnchor, constant: -10),
            minusTenBpmButton.widthAnchor.constraint(equalToConstant: 60),
            minusTenBpmButton.heightAnchor.constraint(equalToConstant: 44),
            
            plusTenBpmButton.centerYAnchor.constraint(equalTo: bpmPickerView.centerYAnchor),
            plusTenBpmButton.leadingAnchor.constraint(equalTo: bpmPickerView.trailingAnchor, constant: 10),
            plusTenBpmButton.widthAnchor.constraint(equalToConstant: 60),
            plusTenBpmButton.heightAnchor.constraint(equalToConstant: 44),
            
            flashButton.topAnchor.constraint(equalTo: bpmPickerView.bottomAnchor, constant: 20),
            flashButton.trailingAnchor.constraint(equalTo: playButton.leadingAnchor, constant: -10),
            flashButton.widthAnchor.constraint(equalToConstant: 44),
            flashButton.heightAnchor.constraint(equalToConstant: 44),
            
            playButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            playButton.topAnchor.constraint(equalTo: bpmPickerView.bottomAnchor, constant: 20),
            playButton.widthAnchor.constraint(equalToConstant: 44),
            playButton.heightAnchor.constraint(equalToConstant: 44),
            
            settingButton.topAnchor.constraint(equalTo: bpmPickerView.bottomAnchor, constant: 20),
            settingButton.leadingAnchor.constraint(equalTo: playButton.trailingAnchor, constant: 10),
            settingButton.widthAnchor.constraint(equalToConstant: 44),
            settingButton.heightAnchor.constraint(equalToConstant: 44),
            
            savedBpmTableView.topAnchor.constraint(equalTo: playButton.bottomAnchor, constant: 20),
            savedBpmTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            savedBpmTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant:  -10),
            savedBpmTableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10)
        ])
    }
    
    // MARK: - Actions
    
    @objc func tappedMinusTen() {
        
    }
    
    @objc func tappedPlusTen() {
        
    }
    
    @objc func tappedAddNote() {
        
    }
    
    @objc func tappedRemoveNote() {
        
    }
    
    @objc func tappedPlay() {
        
    }
    
    @objc func tappedFlash() {
        
    }
    
    @objc func tappedSetting() {
        
    }
}

// MARK: - UIPickerView Extension
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
        let rotateView = UIView()
        rotateView.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        let modeLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        modeLabel.textColor = .black
        modeLabel.text = String(mockData[row])
        modeLabel.textAlignment = .center
        modeLabel.font = UIFont.systemFont(ofSize: 28, weight: .bold)
        rotateView.addSubview(modeLabel)
        rotateView.transform = CGAffineTransform(rotationAngle: 90 * (.pi/180))
        
        return rotateView
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return self.view.bounds.height / 10
    }
    
}

extension SingleModeViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
}
