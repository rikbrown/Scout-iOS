//
//  ViewController.swift
//  Scout
//
//  Created by Brown, Rik on 2017-02-06.
//  Copyright © 2017 Scout. All rights reserved.
//

import UIKit
import Speech

class ViewController: UIViewController, SFSpeechRecognizerDelegate {

    @IBOutlet weak var outputLabel: UILabel!
    
    private let scoutRequester = ScoutRequester()
    private let scoutAudioHelper = ScoutAudioHelper()
    
    private let audioEngine = AVAudioEngine()
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))!
    
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    
    private var timer: Timer?
    private var timeSinceText: Double = 0
    private var processing: Bool = false

    
    // MARK: UIViewController
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        speechRecognizer.delegate = self
        
        self.outputLabel.text = ""

    }
    
    override public func viewDidAppear(_ animated: Bool) {
        self.outputLabel.text = "(Just a moment...)"
        
        SFSpeechRecognizer.requestAuthorization { authStatus in
            /*
             The callback may not be called on the main thread. Add an
             operation to the main queue to update the record button's state.
             */
            OperationQueue.main.addOperation {
                switch authStatus {
                case .authorized:
                    try! self.startRecording()
                    
                case .denied:
                    fatalError("User denied access to speech recognition")
                    
                case .restricted:
                    fatalError("Speech recognition restricted on this device")
                    
                case .notDetermined:
                    fatalError("Speech recognition not yet authorized")
                }
            }
        }
    }
    
    private func startRecording() throws {
        self.timeSinceText = 0
        timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.updateTimeAndStopRecordingIfNoSpeech), userInfo: nil, repeats: true);
        
        // Cancel the previous task if it's running.
        if let recognitionTask = recognitionTask {
            recognitionTask.cancel()
            self.recognitionTask = nil
        }
        
        // Setup audio session
        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(AVAudioSessionCategoryRecord)
        try audioSession.setMode(AVAudioSessionModeMeasurement)
        try audioSession.setActive(true, with: .notifyOthersOnDeactivation)
        
        // Create recognition request
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let inputNode = audioEngine.inputNode else { fatalError("Audio engine has no input node") }
        guard let recognitionRequest = recognitionRequest else { fatalError("Unable to created a SFSpeechAudioBufferRecognitionRequest object") }
        
        // Configure request so that results are returned before audio recording is finished
        recognitionRequest.shouldReportPartialResults = true
        
        // A recognition task represents a speech recognition session.
        // We keep a reference to the task so that it can be cancelled.
        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest) { result, error in
            var isFinal = false
            
            if let result = result {
                self.outputLabel.text = result.bestTranscription.formattedString
                isFinal = result.isFinal
                self.processAction(text: result.bestTranscription.formattedString)
                //self.timeSinceText = 0
            }
        
            
            
            /*if error != nil || isFinal {
                //self.timer!.invalidate()
                self.audioEngine.stop()
                inputNode.removeTap(onBus: 0)
                
                self.recognitionRequest = nil
                self.recognitionTask = nil
                
                if (error != nil) {
                    self.outputLabel.text = "(An error occurred: " + error.debugDescription + ")"
                }
                else if (isFinal) {
                    self.outputLabel.text = result!.bestTranscription.formattedString + "..."
                    self.processAction(text: result!.bestTranscription.formattedString)
                }
                
                try! self.startRecording()
            }*/
        }
        
        // Start listening
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer: AVAudioPCMBuffer, when: AVAudioTime) in
            self.recognitionRequest?.append(buffer)
        }
        audioEngine.prepare()
        try audioEngine.start()
        
        outputLabel.text = "(Go ahead, I'm listening)"
    }
    
    private func stopRecording() {
        audioEngine.stop()
        recognitionRequest?.endAudio()
        self.dismiss(animated: true)
    }
    
    func updateTimeAndStopRecordingIfNoSpeech() {
        self.timeSinceText = self.timeSinceText + 0.1
        if (self.timeSinceText >= 1.5) {
            stopRecording()
        }
    }
    
    func processAction(text: String) {
        if (processing) {
            return
        }
        
        let lcText = text.lowercased()
        
        print("heard: " + lcText)
        
        processing = true;
        
        if (lcText.contains("take off") || lcText.contains("takeoff")) {
            scoutRequester.takeoff()
            stopRecording()
        }
        else if (lcText.contains("return") || lcText.contains("land") || lcText.contains("bye")) {
            scoutRequester.land()
            scoutRequester.lightsOff()
            stopRecording()
        }
        else if (lcText.contains("hello")) {
            scoutRequester.sayHello()
            stopRecording()
        }
        else if (lcText.contains("siren on")) {
            scoutRequester.lightsOn()
            scoutAudioHelper.playSiren()
            stopRecording()
        }
        else if (lcText.contains("beyonc")) {
            scoutAudioHelper.playBeyonce()
            stopRecording()
        }
        else if (lcText.contains("lights on")) {
            scoutRequester.lightsOn()
            stopRecording()
        }
        else if (lcText.contains("lights off")) {
            scoutRequester.lightsOff()
            stopRecording()
        }
        else {
            processing = false
            print("Unknown: " + lcText)
        }
    }
    
    
    // MARK: SFSpeechRecognizerDelegate
    
    public func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        if available {
            outputLabel.text = "(Ready)"
        } else {
            outputLabel.text = "(Recognition unavailable)"
        }
    }


}

