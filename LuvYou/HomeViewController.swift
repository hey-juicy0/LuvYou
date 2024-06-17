//
//  HomeViewController.swift
//  LuvYou
//
//  Created by Jeewoo Yim on 5/24/24.
//

import Foundation
import UIKit
import FirebaseFirestore
import FirebaseStorage
import Photos
import CoreLocation


class DateUtils {
    static func calculateDDay(from startDate: Date) -> Int {
        let calendar = Calendar.current
        let currentDate = Date()
        let components = calendar.dateComponents([.day], from: startDate, to: currentDate)
        return components.day!+1
    }
}

class HomeViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @IBOutlet weak var baseTimeLabel: UILabel!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var imageViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var stackViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var ddayLabel: UILabel!
    @IBOutlet weak var weatherLabel: UILabel!
    @IBOutlet weak var t1hLabel: UILabel!
    @IBOutlet weak var emotionButton: UIButton!
    @IBOutlet weak var popUpView: UIView!
    @IBOutlet weak var tailView: UIImageView!
    @IBOutlet weak var transparentOverlayView: UIView!
    @IBOutlet weak var loversEmotion: UIButton!
    @IBOutlet weak var myImage: UIButton!
    @IBOutlet weak var weatherImage: UIImageView!
    @IBOutlet weak var loversImage: UIButton!
    
    let apiKey = "g4JEH8NwTzCCRB_DcM8wZw" // 본인의 API 키로 교체해야 합니다.
    let locationManager = CLLocationManager()
    
    
    var weatherData: [String: String] = [:]
    var currentElement: String = ""
    var currentCategory: String = ""
    
    
    let prevWeather = UserDefaults.standard.string(forKey: "prevWeather") ?? ""
    let prevTemp = UserDefaults.standard.string(forKey: "prevTemp") ?? ""
    
    var listener: ListenerRegistration?
    var isPopup = true
    let storage = Storage.storage()
    let firestore = Firestore.firestore()
    let myName = UserDefaults.standard.string(forKey: "myName")
    let documentID = UserDefaults.standard.string(forKey: "documentID") ?? ""
    @IBOutlet weak var heart: UIImageView!
    @IBOutlet weak var quit: UIButton!
    let gender = UserDefaults.standard.string(forKey: "myGender") ?? ""

    let loverID = UserDefaults.standard.integer(forKey: "loverID")
    let imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //실시간 관찰

        imagePicker.delegate = self
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        print(documentID)
        print(gender)
        
        t1hLabel.text = "기온: \(prevTemp)º"
        weatherLabel.text = "날씨: \(prevWeather)"
        if let image = UIImage(named: prevWeather) {
            weatherImage.image = image
        } else {
            print("이미지를 찾을 수 없습니다.")
        }
        observeEmotion()
        
        let labelString = NSMutableAttributedString()
        labelString.addAttribute(.kern, value: 10, range: NSRange(location: 0, length: labelString.length))
        ddayLabel.attributedText = labelString
        
        titleLabel.font = UIFont(name: "PretendardVariable-Regular", size: 20)
        ddayLabel.font = UIFont(name: "PretendardVariable-SemiBold", size: 27)
        tailView.isHidden = isPopup
        popUpView.layer.cornerRadius = 24
        popUpView.isHidden = isPopup
        setupImageView()
        transparentOverlayView.isHidden = isPopup
        
        if gender != "여성" {
            emotionButton.tintColor = UIColor.your
            loversEmotion.tintColor = UIColor.my
            myImage.tintColor = UIColor.your
            loversImage.tintColor = UIColor.my
            quit.tintColor = UIColor.your
            heart.tintColor = UIColor.your
        }
        downloadImage()
        startListeningToImageChanges()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        updateDDay()
        let currentDate = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy년 MM월 dd일"
        let dateString = dateFormatter.string(from: currentDate)
        dateLabel.text = dateString
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if let image = imageView.image {
            let aspectRatio = image.size.height / image.size.width
            let imageViewHeight = imageView.frame.width * aspectRatio
            
            // 최대 높이 제한
            let maxHeight = stackView.frame.minY - imageView.frame.minY - stackViewTopConstraint.constant
            
            // 높이 제약 조건을 업데이트합니다.
            let finalHeight = min(imageViewHeight, maxHeight)
            updateImageViewHeightConstraint(height: finalHeight)
        }
    }

    private func updateImageViewHeightConstraint(height: CGFloat) {
        // 이미지 뷰의 높이 제약 조건을 업데이트합니다.
        imageViewHeightConstraint.constant = height
    }

    private func startListeningToImageChanges() {
        let imageName = "\(documentID)_lover\((loverID == 1) ? 2 : 1)"
        let imageRef = Storage.storage().reference().child("images").child(imageName)
        let metadataRef = Firestore.firestore().collection("lovers").document(documentID).collection("images").document("lover\((loverID == 1) ? 2 : 1)")
        
        listener = metadataRef.addSnapshotListener { [weak self] snapshot, error in
            guard let self = self else { return }
            if let error = error {
                print("Error listening to metadata changes: \(error)")
                return
            }
            guard let snapshot = snapshot, let data = snapshot.data(), let timestamp = data["timestamp"] as? String else {
                print("timestamp: No data or invalid data")
                return
            }
            self.checkTimestampAndDownloadImage(imageRef: imageRef, timestamp: timestamp)
        }
    }
    
    private func checkTimestampAndDownloadImage(imageRef: StorageReference, timestamp: String) {
        let userDefaults = UserDefaults.standard
        let lastTimestamp = userDefaults.string(forKey: "timestamp")
        if lastTimestamp != timestamp{
            userDefaults.setValue(timestamp, forKey: "timestamp")
            downloadImage()
        }
    }
    
    private func downloadImage() {
        let imageName = "\(documentID)_lover\((loverID == 1) ? 2 : 1)"
        let imageRef = Storage.storage().reference().child("images").child(imageName)

        imageRef.getData(maxSize: 10 * 1024 * 1024) { [weak self] data, error in
            if let error = error {
                self?.imageView.image = UIImage(named: "imageholder")
                return
            }
            guard let self = self, let data = data, let image = UIImage(data: data) else {
                return
            }
            self.imageView.image = image
        }
    }
    
    func observeEmotion() {
        let loverID = UserDefaults.standard.integer(forKey: "loverID")
        let emotionDocRef = firestore.collection("lovers").document(documentID).collection("lover\(loverID == 1 ? 2 : 1)").document("emotion")
        
        listener = emotionDocRef.addSnapshotListener { [weak self] (snapshot, error) in
            guard let self = self else { return }
            if let error = error {
                print("Error getting document: \(error)")
                return
            }
            
            guard let snapshot = snapshot, snapshot.exists else {
                print("Document does not exist")
                return
            }
            
            if let emotion = snapshot.data()?["emotion"] as? String {
                // emotion 값에 따라 버튼 이미지 설정
                self.setEmotionButtonImage(systemName: emotion)
            }
        }
    }

    func setEmotionButtonImage(systemName: String) {
        var image: UIImage?
        switch systemName {
        case "sun.max.fill":
            image = UIImage(systemName: "sun.max.fill")
        case "cloud.fill":
            image = UIImage(systemName: "cloud.fill")
        case "snow":
            image = UIImage(systemName: "snow")
        case "thermometer.sun.fill":
            image = UIImage(systemName: "thermometer.sun.fill")
        case "cloud.heavyrain.fill":
            image = UIImage(systemName: "cloud.heavyrain.fill")
        case "bolt.fill":
            image = UIImage(systemName: "bolt.fill")
        default:
            break
        }
        DispatchQueue.main.async {
            self.loversEmotion.setImage(image, for: .normal)
        }
    }
    
    private func updateDDay() {
            let defaults = UserDefaults.standard
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            
            if let startDateString = defaults.string(forKey: "startDate"),
               let startDate = dateFormatter.date(from: startDateString) {
                let dDay = DateUtils.calculateDDay(from: startDate)
                defaults.set(dDay, forKey: "dDay")
                ddayLabel.text = "+\(dDay)"
            } else {
                let currentDate = Date()
                let startDateString = dateFormatter.string(from: currentDate)
                defaults.set(startDateString, forKey: "startDate")
                defaults.set(0, forKey: "dDay")
                ddayLabel.text = "+0"
            }
        }
    
    @IBAction func popUp(_ sender: UIButton) {
        isPopup = !isPopup
        if gender != "여성"{
            popUpView.backgroundColor = UIColor.your
            tailView.tintColor = UIColor.your
        }
        else{
            tailView.tintColor = UIColor.my
        }
        popUpView.isHidden = isPopup
        tailView.isHidden = isPopup
        transparentOverlayView.isHidden = isPopup
    }
    
    @IBAction func overlayTapped(_ sender: UITapGestureRecognizer) {
        isPopup = !isPopup
        popUpView.isHidden = isPopup
        tailView.isHidden = isPopup
        transparentOverlayView.isHidden = isPopup
    }
    
    @IBAction func weatherButtonTapped(_ sender: UIButton) {
        var systemName = ""
        switch sender.tag {
        case 1:
            systemName = "sun.max.fill"
        case 2:
            systemName = "cloud.fill"
        case 3:
            systemName = "snow"
        case 4:
            systemName = "thermometer.sun.fill"
        case 5:
            systemName = "cloud.heavyrain.fill"
        case 6:
            systemName = "bolt.fill"
        default:
            break
        }
        
        changeEmotionButtonImage(to: systemName)
        
        isPopup = !isPopup
        popUpView.isHidden = isPopup
        tailView.isHidden = isPopup
        transparentOverlayView.isHidden = isPopup
    }
    
    @IBAction func uploadButtonTapped(_ sender: UIButton) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "사진 찍기", style: .default, handler: { _ in
            self.openCamera()
        }))
        
        alert.addAction(UIAlertAction(title: "보관함에서 선택", style: .default, handler: { _ in
            self.openPhotoLibrary()
        }))
        
        alert.addAction(UIAlertAction(title: "취소", style: .cancel, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func openCamera() {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            imagePicker.sourceType = .camera
            self.present(imagePicker, animated: true, completion: nil)
        } else {
            self.showAlert(message:"카메라에 접근할 수 없습니다")
        }
    }
    
    func openPhotoLibrary() {
        imagePicker.sourceType = .photoLibrary
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let selectedImage = info[.originalImage] as? UIImage {
            self.uploadImageToFirebase(image: selectedImage)
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func uploadImageToFirebase(image: UIImage) {
        let imageName = "\(String(describing: documentID))_lover\(loverID)"
        guard let imageData = image.jpegData(compressionQuality: 1.0) else { return }
        let reference = Storage.storage().reference().child("images").child(imageName)
        
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        
        reference.putData(imageData, metadata: metadata) { (metadata, error) in
            if error != nil {
                self.showAlert(message:"에러 발생! 다시 시도해주세요.")
                return
            }

            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            let uploadTimestamp = dateFormatter.string(from: Date())
            
            self.firestore.collection("lovers").document(self.documentID).collection("images").document("lover\(self.loverID)").setData([
                "timestamp": uploadTimestamp
            ]) { error in
                if error != nil {
                    self.showAlert(message:"에러 발생! 다시 시도해주세요.")
                } else {
                    self.showAlert(message:"사진이 공유되었습니다!")
                }
            }
        }
    }

    deinit {
        listener?.remove()
    }
    @IBAction func downloadTapped(_ sender: UIButton) {
        let imageName = "\(documentID)_lover\((loverID == 1) ? 2 : 1)"
        let imageRef = Storage.storage().reference().child("images").child(imageName)
        
        imageRef.getData(maxSize: 50 * 1024 * 1024) { data, error in
            if let error = error {
                print("Error downloading image: \(error)")
                return
            }
            
            if let data = data, let image = UIImage(data: data) {
                UIImageWriteToSavedPhotosAlbum(image, self, #selector(self.image(_:didFinishSavingWithError:contextInfo:)), nil)
            }
        }
    }

    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            print("Error saving image: \(error)")
            showAlert(message: "사진 저장에 실패했습니다.\n다시 시도해주세요.")
        } else {
            showAlert(message: "기기에 사진이 저장되었습니다!")
        }
    }
    

    func showAlert(message: String) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }


    func changeEmotionButtonImage(to systemName: String) {
        let image = UIImage(systemName: systemName)
        emotionButton.setImage(image, for: .normal)
        firestore.collection("lovers").document(documentID).collection("lover\(loverID)").document("emotion").setData(["emotion": systemName])
    }
    
    func setupImageView() {
        tailView.image = UIImage(named: "tail")?.withRenderingMode(.alwaysTemplate)
        tailView.contentMode = .scaleAspectFit
        tailView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(tailView)
        
        NSLayoutConstraint.activate([
            tailView.widthAnchor.constraint(equalToConstant: 30),
            tailView.heightAnchor.constraint(equalToConstant: 15),
        ])
    }
    
    func getWeatherInfo(for city: String) {
        guard let coordinates = getCoordinates(for: city) else {
            print("Coordinates not found for the city: \(city)")
            return
        }
        let result = getBaseTimeAndDate()
        let baseDate = result.baseDate
        let baseTime = result.baseTime

        baseTimeLabel.text = "\(baseTime) 기준"
        
        getWeatherInfo(x: coordinates.x, y: coordinates.y, baseDate: baseDate, baseTime: baseTime)
    }

    
    func getBaseTimeAndDate() -> (baseTime: String, baseDate: String) {
        // 현재 날짜와 시간을 가져옴
        let now = Date()
        
        // Calendar를 사용하여 현재 시각의 시와 분을 가져옴
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: now)
        let minute = calendar.component(.minute, from: now)
        
        // DateFormatter를 사용하여 날짜를 포맷함
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd" // 원하는 날짜 형식
        
        // baseDate 설정
        let baseDate: String
        if hour == 0 && minute <= 30 {
            // 현재 시각이 00:30 이전이면 전날의 날짜를 반환
            if let yesterday = calendar.date(byAdding: .day, value: -1, to: now) {
                baseDate = dateFormatter.string(from: yesterday)
            } else {
                baseDate = dateFormatter.string(from: now)
            }
        } else {
            // 현재 시각이 00:31 이후면 오늘의 날짜를 반환
            baseDate = dateFormatter.string(from: now)
        }
        
        // 시와 분을 두 자리 숫자로 변환하여 baseTime 생성
        let baseTime: String
        if minute < 30 {
            if hour != 23{
                baseTime = String(format: "%02d30", hour-1)
            }
            else{
                baseTime = String(format: "%02d30", 23)
            }
        } else {
            baseTime = String(format: "%02d30", hour)
        }
        
        return (baseTime, baseDate)
    }
   
    func getWeatherInfo(x: Int, y: Int, baseDate: String, baseTime: String) {
        let apiUrl = "https://apihub.kma.go.kr/api/typ02/openApi/VilageFcstInfoService_2.0/getUltraSrtFcst"
        var urlComponents = URLComponents(string: apiUrl)!
        urlComponents.queryItems = [
            URLQueryItem(name: "pageNo", value: "1"),
            URLQueryItem(name: "numOfRows", value: "500"),
            URLQueryItem(name: "dataType", value: "XML"),
            URLQueryItem(name: "base_date", value: baseDate),
            URLQueryItem(name: "base_time", value: baseTime),
            URLQueryItem(name: "nx", value: "\(x)"),
            URLQueryItem(name: "ny", value: "\(y)"),
            URLQueryItem(name: "authKey", value: apiKey)
        ]
        
        guard let url = urlComponents.url else {
            print("Invalid URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print("Error: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse, !(200...299).contains(httpResponse.statusCode) {
                print("HTTP Response Error: \(httpResponse.statusCode)")
                return
            }
            
            // XML 응답 데이터 로그 출력
//            print("Weather Info: \(String(data: data, encoding: .utf8) ?? "No data")")
            
            self.parseWeatherXML(data: data)
        }.resume()
    }
    
    func parseWeatherXML(data: Data) {
        let parser = XMLParser(data: data)
        parser.delegate = self
        parser.parse()
    }
    
    func getCoordinates(for city: String) -> (x: Int, y: Int)? {
        switch city {
        case "서울특별시":
            return (60, 127)
        case "부산광역시":
            return (98, 76)
        case "대구광역시":
            return (89, 90)
        case "인천광역시":
            return (55, 124)
        case "광주광역시":
            return (58, 74)
        case "대전광역시":
            return (67, 100)
        case "울산광역시":
            return (102, 84)
        case "세종특별자치시":
            return (66, 103)
        case "경기도":
            return (60, 120)
        case "강원도":
            return (73, 134)
        case "충청북도":
            return (69, 107)
        case "충청남도":
            return (68, 100)
        case "전라북도":
            return (63, 89)
        case "전라남도":
            return (51, 67)
        case "경상북도":
            return (89, 91)
        case "경상남도":
            return (91, 77)
        case "제주특별자치도":
            return (52, 38)
        case "이어도":
            return (28, 8)
        default:
            return nil
        }
    }
}

extension HomeViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        // 위치에서 도시 이름 가져오기
        CLGeocoder().reverseGeocodeLocation(location) { (placemarks, error) in
            guard let placemark = placemarks?.first, error == nil else {
                print("Reverse geocoding failed. Error: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            if let city = placemark.locality {
                self.getWeatherInfo(for: city)
            } else {
                print("City not found for the current location.")
            }
        }
        // 위치 업데이트 중지 (필요한 경우)
        locationManager.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location manager failed with error: \(error.localizedDescription)")
    }
}

extension HomeViewController: XMLParserDelegate {
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        currentElement = elementName
        if elementName == "item" {
            currentCategory = ""
        }
    }

    func parser(_ parser: XMLParser, foundCharacters string: String) {
        switch currentElement {
        case "category":
            currentCategory += string.trimmingCharacters(in: .whitespacesAndNewlines)
        case "fcstValue":
            if currentCategory == "PTY" || currentCategory == "SKY" || currentCategory == "T1H" {
                weatherData[currentCategory] = string.trimmingCharacters(in: .whitespacesAndNewlines)
            }
        default:
            break
        }
    }

    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if elementName == "item" {
            currentCategory = ""
        }
    }

    func parserDidEndDocument(_ parser: XMLParser) {
        DispatchQueue.main.async {
            let temp = self.weatherData["T1H"] ?? "N/A"
            let weather = self.weatherText(sky: self.weatherData["SKY"], pty: self.weatherData["PTY"])
            UserDefaults.standard.setValue(temp, forKey: "prevTemp")
            UserDefaults.standard.setValue(weather, forKey: "prevWeather")
            self.t1hLabel.text = "기온: \(temp)º"
            self.weatherLabel.text = "날씨: \(weather)"
            if let image = UIImage(named: weather) {
                self.weatherImage.image = image
            } else {
                print("이미지를 찾을 수 없습니다.")
            }
        }
    }
    
    func weatherText(sky: String?, pty: String?) -> String{
        var weather = ""
        if rainCode(for: pty) == "맑음" && skyCode(for: sky) == "맑음"{
            weather = "맑음"
        }
        else if rainCode(for: pty) == "맑음" && skyCode(for: sky) == "흐림"{
            weather = "흐림"
        }
        else if rainCode(for: pty) == "비" {
            weather = "비"
        }
        else if rainCode(for: pty) == "눈"{
            weather = "눈"
        }
        return weather
    }
    
    func rainCode(for pty: String?) -> String{
        switch pty{
        case "0":
            return "맑음"
        case "1", "2", "5", "6":
            return "비"
        case "3", "7":
            return "눈"
        default:
            return ""
        }
    }
    func skyCode(for sky: String?) -> String{
        switch sky{
        case "1":
            return "맑음"
        case "3", "4":
            return "흐림"
        default:
            return ""
        }
    }
}
