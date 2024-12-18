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
    let mockData = Array(1...300)
    var currentBPM = 0
    let rotationAngle: CGFloat! = -90  * (.pi/180)
    var noteCount = 4 // default 4분음표
    
    var timer: Timer?
    var currentNoteIndex = 0
    var isPlaying = false
    
    var savedBpmList: [BpmModel] = [] // 저장된 BPM

    
    // MARK: - UIComponents
    
    /// notes 스택뷰
    private lazy var notesStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.distribution = .equalCentering
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
    private lazy var togglePlayButton: UIButton = {
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
    private lazy var toggleFlashButton: UIButton = {
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
    
    /// 방 추가 버튼
    private lazy var openRoomButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.image = UIImage(systemName: "rectangle.portrait.badge.plus")
        config.baseForegroundColor = .black
        config.baseBackgroundColor = .systemGray
        let button = UIButton(configuration: config)
        button.addTarget(self, action: #selector(tappedOpenRoom), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    /// 방 입장 버튼
    private lazy var joinRoomButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.image = UIImage(systemName: "rectangle.portrait.and.arrow.right")
        config.baseForegroundColor = .black
        config.baseBackgroundColor = .systemGray
        let button = UIButton(configuration: config)
        button.addTarget(self, action: #selector(tappedJoinRoom), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    /// 현재 BPM 저장 버튼
    private lazy var saveBpmButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.image = UIImage(systemName: "tray.and.arrow.down")
        config.baseForegroundColor = .black
        config.baseBackgroundColor = .systemGray
        let button = UIButton(configuration: config)
        button.addTarget(self, action: #selector(tappedSaveBpm), for: .touchUpInside)
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
        loadBpmListFromUserDefaults()
        setupUI()
        setupNotesStackView(with: noteCount)
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
            togglePlayButton,
            toggleFlashButton,
            settingButton,
            openRoomButton,
            saveBpmButton,
            joinRoomButton,
            savedBpmTableView
        )
        
        NSLayoutConstraint.activate([
            notesStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            notesStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            notesStackView.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor, multiplier: 0.5),
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
            
            toggleFlashButton.topAnchor.constraint(equalTo: bpmPickerView.bottomAnchor, constant: 20),
            toggleFlashButton.trailingAnchor.constraint(equalTo: togglePlayButton.leadingAnchor, constant: -10),
            toggleFlashButton.widthAnchor.constraint(equalToConstant: 44),
            toggleFlashButton.heightAnchor.constraint(equalToConstant: 44),
            
            togglePlayButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            togglePlayButton.topAnchor.constraint(equalTo: bpmPickerView.bottomAnchor, constant: 20),
            togglePlayButton.widthAnchor.constraint(equalToConstant: 44),
            togglePlayButton.heightAnchor.constraint(equalToConstant: 44),
            
            settingButton.topAnchor.constraint(equalTo: bpmPickerView.bottomAnchor, constant: 20),
            settingButton.leadingAnchor.constraint(equalTo: togglePlayButton.trailingAnchor, constant: 10),
            settingButton.widthAnchor.constraint(equalToConstant: 44),
            settingButton.heightAnchor.constraint(equalToConstant: 44),
            
            openRoomButton.topAnchor.constraint(equalTo: togglePlayButton.bottomAnchor, constant: 20),
            openRoomButton.trailingAnchor.constraint(equalTo: saveBpmButton.leadingAnchor, constant: -10),
            openRoomButton.widthAnchor.constraint(equalToConstant: 44),
            openRoomButton.heightAnchor.constraint(equalToConstant: 44),
            
            saveBpmButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            saveBpmButton.topAnchor.constraint(equalTo: togglePlayButton.bottomAnchor, constant: 20),
            saveBpmButton.widthAnchor.constraint(equalToConstant: 44),
            saveBpmButton.heightAnchor.constraint(equalToConstant: 44),
            
            joinRoomButton.topAnchor.constraint(equalTo: togglePlayButton.bottomAnchor, constant: 20),
            joinRoomButton.leadingAnchor.constraint(equalTo: saveBpmButton.trailingAnchor, constant: 10),
            joinRoomButton.widthAnchor.constraint(equalToConstant: 44),
            joinRoomButton.heightAnchor.constraint(equalToConstant: 44),
            
            savedBpmTableView.topAnchor.constraint(equalTo: saveBpmButton.bottomAnchor, constant: 20),
            savedBpmTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            savedBpmTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant:  -10),
            savedBpmTableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10)
        ])
    }
    
    /// BPM 업데이트
    func updateBPMUI() {
        bpmPickerView.selectRow(currentBPM - 1, inComponent: 0, animated: true)
    }
    
    /// 노트 컬러 업데이트
    @objc func updateNoteColors() {
        for (index, view) in notesStackView.arrangedSubviews.enumerated() {
            if let note = view as? UIImageView {
                note.tintColor = (index == currentNoteIndex) ? .red : .black
            }
        }
        
        currentNoteIndex = (currentNoteIndex + 1) % notesStackView.arrangedSubviews.count
    }
    
    /// 노트 개수 업데이트
    func setupNotesStackView(with noteCount: Int) {
        notesStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        for _ in 1...noteCount {
            let note = UIImageView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
            note.translatesAutoresizingMaskIntoConstraints = false
            note.image = UIImage(systemName: "circle.fill")
            note.tintColor = .black
            note.contentMode = .scaleAspectFit
            notesStackView.addArrangedSubview(note)
        }
        
        if isPlaying {
            resetTimer()
        }
    }
    
    // MARK: - Actions
    
    @objc func tappedMinusTen() {
        if currentBPM > 10 {
            currentBPM -= 10
            print("Current BPM = \(currentBPM)")
            updateBPMUI()
        } else {
            print("💥 BPM은 0 이하로 설정할 수 없습니다.")
        }
        
    }
    
    @objc func tappedPlusTen() {
        if currentBPM < 300 {
            currentBPM += 10
            print("Current BPM = \(currentBPM)")
            updateBPMUI()
        } else {
            print("BPM은 300 이상으로 설정할 수 없습니다.")
        }
    }
    
    @objc func tappedAddNote() {
        if noteCount < 8 {
            noteCount += 1
            setupNotesStackView(with: noteCount)
        } else {
            print("💥 노트 개수는 최대 8개까지 설정할 수 있습니다.")
        }
    }
    
    @objc func tappedRemoveNote() {
        if noteCount > 4 {
            noteCount -= 1
            setupNotesStackView(with: noteCount)
        } else {
            print("💥 노트 개수는 최소 4개까지 설정할 수 있습니다.")
        }
    }
    
    @objc func tappedPlay() {
        if isPlaying {
            timer?.invalidate()
            timer = nil
            isPlaying = false
            togglePlayButton.configuration?.image = UIImage(systemName: "play.fill")
            
            notesStackView.arrangedSubviews.forEach { view in
                if let note = view as? UIImageView {
                    note.tintColor = .black
                }
            }
        } else {
            isPlaying = true
            togglePlayButton.configuration?.image = UIImage(systemName: "pause.fill")
            
            // 노트 초기화
            currentNoteIndex = 0
            notesStackView.arrangedSubviews.forEach { view in
                if let note = view as? UIImageView {
                    note.tintColor = .black
                }
            }
            
            resetTimer()
        }
    }
    
    @objc func tappedFlash() {
        
    }
    
    @objc func tappedSetting() {
        
    }
    
    @objc func tappedOpenRoom() {
        
    }
    
    @objc func tappedJoinRoom() {
        
    }
    
    @objc func tappedSaveBpm() {
        let alert = UIAlertController(title: "Save BPM", message: "Enter a title and BPM", preferredStyle: .alert)

        alert.addTextField { textField in
            textField.placeholder = "Enter title"
        }
        alert.addTextField { textField in
            textField.placeholder = "Enter BPM"
            textField.keyboardType = .numberPad
        }

        let saveAction = UIAlertAction(title: "Save", style: .default) { _ in
            guard let title = alert.textFields?[0].text, !title.isEmpty,
                  let bpmText = alert.textFields?[1].text, let bpm = Int(bpmText), bpm > 0 else {
                print("💥 잘못된 입력 (tappedSaveBpm())")
                return
            }
            
            self.savedBpmList.append(BpmModel(title: title, bpm: bpm))
            self.savedBpmTableView.reloadData()
            self.saveBpmListToUserDefaults()
            print("✅ Saved: \(title) with BPM \(bpm)")
        }

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)

        alert.addAction(saveAction)
        alert.addAction(cancelAction)

        present(alert, animated: true, completion: nil)
    }
    
    // MARK: - Methods
    /// 노트 간의 재생 간격 계산
    func calculateInterval() -> Double {
        return 240.0 / (Double(currentBPM) * Double(noteCount))
    }
    
    /// 타이머 리셋
    func resetTimer() {
        timer?.invalidate() // 기존 타이머 종료
        let interval = calculateInterval()
        timer = Timer.scheduledTimer(timeInterval: interval, target: self, selector: #selector(updateNoteColors), userInfo: nil, repeats: true)
    }
    
    /// BPM UserDefaults에 저장
    func saveBpmListToUserDefaults() {
        let encoder = JSONEncoder()
        if let encodedData = try? encoder.encode(savedBpmList) {
            UserDefaults.standard.set(encodedData, forKey: "savedBpmList")
            print("✅ Saved BPM list to UserDefaults")
        } else {
            print("💥 Failed to save BPM list")
        }
    }
    
    /// UserDefaults에 저장된 BPM 불러오기
    func loadBpmListFromUserDefaults() {
        let decoder = JSONDecoder()
        if let savedData = UserDefaults.standard.data(forKey: "savedBpmList"),
           let decodedList = try? decoder.decode([BpmModel].self, from: savedData) {
            savedBpmList = decodedList
            savedBpmTableView.reloadData()
            print("Loaded BPM list from UserDefaults")
        } else {
            print("No saved BPM list found")
        }
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
        currentBPM = mockData[row]
        print("Current BPM = \(currentBPM)")
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

// MARK: - UITableView Delegate, Datasource
extension SingleModeViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return savedBpmList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        let savedBpm = savedBpmList[indexPath.row]
        cell.textLabel?.text = "\(savedBpm.title) - BPM: \(savedBpm.bpm)"
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            savedBpmList.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedBpm = savedBpmList[indexPath.row]
        currentBPM = selectedBpm.bpm
        
        bpmPickerView.selectRow(currentBPM - 1, inComponent: 0, animated: true)
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        updateBPMUI()
        
    }
}
