import PlaygroundSupport
import Foundation
import AudioToolbox
import AVFoundation
import CoreAudio
import UIKit

/* Notes and tag values
A  : 57
Bf : 58
B  : 59
C  : 60
Cs : 61
D  : 62
Ef : 63
E  : 64
F  : 65
Fs : 66
G  : 67
Gs : 68
 */

class ViewController: UIViewController {
    var instrumentView = InstrumentView(frame:.zero)
    
    class InstrumentView : UIView {
        var buttons = [UIView]()
        var soundGenerator = SoundGenerator()
        var buttonsOn = Set<UIView>()
        
        override init(frame: CGRect) {
            super.init(frame:frame)
            isMultipleTouchEnabled = true
        }

        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
            isMultipleTouchEnabled = true
        }
        
        func note(forButton button: UIView, turnOn: Bool) {
            let note = UInt32(button.tag)
            if turnOn {
                if (buttonsOn.contains(button) == false) {
                    button.backgroundColor = UIColor.darkGray
                    let velocity = UInt32(100)
                    soundGenerator.playNoteOn(note, velocity: velocity)
                    buttonsOn.insert(button)
                }
            } else {
                button.backgroundColor = UIColor.white
                let note = UInt32(button.tag)
                soundGenerator.playNoteOff(note)
                buttonsOn.remove(button)
            }
        }
        
        func cancelAllPlayingNotes() {
            for button in buttonsOn {
                note(forButton: button, turnOn: false)
            }
        }
        
        override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
            for button in buttons {
                for touch in touches {
                    if button.frame.contains(touch.location(in: self)) {
                        note(forButton: button, turnOn: true)
                        break
                    }
                }
            }
        }
        
        override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
            for button in buttons {
                for touch in touches {
                    let loc = touch.location(in: self)
                    if button.frame.contains(loc) {
                        note(forButton: button, turnOn: false)
                        break
                    }
                }
            }
        }
        
        override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
            var playButtons = Set<UIView>()
            for button in buttons {
                let buttonFrame = button.frame
                for touch in (event?.allTouches)! {
                    let loc = touch.location(in: self)
                    if button.frame.contains(loc) {
                        playButtons.insert(button)
                        break
                    }
                }
            }
            
            for offButton in buttonsOn.subtracting(playButtons) {
                note(forButton: offButton, turnOn: false)
            }
            for playButton in playButtons {
                note(forButton: playButton, turnOn: true)
            }
            buttonsOn = Set(playButtons)
        }
        
        override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
            cancelAllPlayingNotes()
        }
        
    }
    
    override func loadView() {
        view = instrumentView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        instrumentView.isMultipleTouchEnabled = true
        setupUI()
    }
    
    private func setupUI() {
        view.backgroundColor = UIColor.lightGray
        
        let key1 = addKey("A♭", tag:57)
        let key2 = addKey("A", tag:58)
        let key3 = addKey("B♭", tag: 59)
        let key4 = addKey("C", tag:60)
        let key5 = addKey("C#", tag:61)
        let key6 = addKey("D", tag:62)
        let key7 = addKey("E", tag:64)
        let key8 = addKey("F", tag:65)
        let key9 = addKey("F#", tag:66)
        let key10 = addKey("G", tag:67)
        let key11 = addKey("G#", tag:68)
        
        var stackView : UIStackView = UIStackView(arrangedSubviews: [key1,key2,key3,key4,key5,key6,key7,key8,key9,key10,key11])
        view.addSubview(stackView)
        stackView.isMultipleTouchEnabled = true
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.distribution = .fillProportionally
        var viewsDict : [String:Any] = ["stackView":stackView]
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[stackView]-0-|", options: [], metrics: nil, views: viewsDict))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[stackView]-0-|", options: [], metrics: nil, views: viewsDict))
    }
    
    private func addKey(_ title:String, tag:Int) -> UIView {
        let key = UILabel(frame:.zero)
        key.isMultipleTouchEnabled = true
        key.textAlignment = .center
        key.tag = tag
        key.text = title //"\(title) (\(tag))" 
        key.textColor = UIColor.black
        key.backgroundColor = UIColor.white
        key.layer.cornerRadius = 3.0
        key.layer.borderColor = UIColor.darkGray.cgColor
        key.layer.borderWidth = 0.5
        
        key.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(key)
        var viewsDict : [String:Any] = ["key":key]
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[key(200)]-8-|", options: [], metrics: nil, views: viewsDict))
        
        instrumentView.buttons.append(key)
        return key
    }
    
}

func CheckError(_ error: OSStatus) {
    if error == 0 {return}
    
    switch error {
    // AudioToolbox
    case kAUGraphErr_NodeNotFound:
        print("Error:kAUGraphErr_NodeNotFound")
        
    case kAUGraphErr_OutputNodeErr:
        print( "Error:kAUGraphErr_OutputNodeErr")
        
    case kAUGraphErr_InvalidConnection:
        print("Error:kAUGraphErr_InvalidConnection")
        
    case kAUGraphErr_CannotDoInCurrentContext:
        print( "Error:kAUGraphErr_CannotDoInCurrentContext")
        
    case kAUGraphErr_InvalidAudioUnit:
        print( "Error:kAUGraphErr_InvalidAudioUnit")
        
        //    case kMIDIInvalidClient :
        //        print( "kMIDIInvalidClient ")
        //
        //
        //    case kMIDIInvalidPort :
        //        print( "kMIDIInvalidPort ")
        //
        //
        //    case kMIDIWrongEndpointType :
        //        print( "kMIDIWrongEndpointType")
        //
        //
        //    case kMIDINoConnection :
        //        print( "kMIDINoConnection ")
        //
        //
        //    case kMIDIUnknownEndpoint :
        //        print( "kMIDIUnknownEndpoint ")
        //
        //
        //    case kMIDIUnknownProperty :
        //        print( "kMIDIUnknownProperty ")
        //
        //
        //    case kMIDIWrongPropertyType :
        //        print( "kMIDIWrongPropertyType ")
        //
        //
        //    case kMIDINoCurrentSetup :
        //        print( "kMIDINoCurrentSetup ")
        //
        //
        //    case kMIDIMessageSendErr :
        //        print( "kMIDIMessageSendErr ")
        //
        //
        //    case kMIDIServerStartErr :
        //        print( "kMIDIServerStartErr ")
        //
        //
        //    case kMIDISetupFormatErr :
        //        print( "kMIDISetupFormatErr ")
        //
        //
        //    case kMIDIWrongThread :
        //        print( "kMIDIWrongThread ")
        //
        //
        //    case kMIDIObjectNotFound :
        //        print( "kMIDIObjectNotFound ")
        //
        //
        //    case kMIDIIDNotUnique :
        //        print( "kMIDIIDNotUnique ")
        
        
    case kAudioToolboxErr_InvalidSequenceType :
        print( " kAudioToolboxErr_InvalidSequenceType")
        
    case kAudioToolboxErr_TrackIndexError :
        print( " kAudioToolboxErr_TrackIndexError")
        
    case kAudioToolboxErr_TrackNotFound :
        print( " kAudioToolboxErr_TrackNotFound")
        
    case kAudioToolboxErr_EndOfTrack :
        print( " kAudioToolboxErr_EndOfTrack")
        
    case kAudioToolboxErr_StartOfTrack :
        print( " kAudioToolboxErr_StartOfTrack")
        
    case kAudioToolboxErr_IllegalTrackDestination    :
        print( " kAudioToolboxErr_IllegalTrackDestination")
        
    case kAudioToolboxErr_NoSequence         :
        print( " kAudioToolboxErr_NoSequence")
        
    case kAudioToolboxErr_InvalidEventType        :
        print( " kAudioToolboxErr_InvalidEventType")
        
    case kAudioToolboxErr_InvalidPlayerState    :
        print( " kAudioToolboxErr_InvalidPlayerState")
        
    case kAudioUnitErr_InvalidProperty        :
        print( " kAudioUnitErr_InvalidProperty")
        
    case kAudioUnitErr_InvalidParameter        :
        print( " kAudioUnitErr_InvalidParameter")
        
    case kAudioUnitErr_InvalidElement        :
        print( " kAudioUnitErr_InvalidElement")
        
    case kAudioUnitErr_NoConnection            :
        print( " kAudioUnitErr_NoConnection")
        
    case kAudioUnitErr_FailedInitialization        :
        print( " kAudioUnitErr_FailedInitialization")
        
    case kAudioUnitErr_TooManyFramesToProcess    :
        print( " kAudioUnitErr_TooManyFramesToProcess")
        
    case kAudioUnitErr_InvalidFile            :
        print( " kAudioUnitErr_InvalidFile")
        
    case kAudioUnitErr_FormatNotSupported        :
        print( " kAudioUnitErr_FormatNotSupported")
        
    case kAudioUnitErr_Uninitialized        :
        print( " kAudioUnitErr_Uninitialized")
        
    case kAudioUnitErr_InvalidScope            :
        print( " kAudioUnitErr_InvalidScope")
        
    case kAudioUnitErr_PropertyNotWritable        :
        print( " kAudioUnitErr_PropertyNotWritable")
        
    case kAudioUnitErr_InvalidPropertyValue        :
        print( " kAudioUnitErr_InvalidPropertyValue")
        
    case kAudioUnitErr_PropertyNotInUse        :
        print( " kAudioUnitErr_PropertyNotInUse")
        
    case kAudioUnitErr_Initialized            :
        print( " kAudioUnitErr_Initialized")
        
    case kAudioUnitErr_InvalidOfflineRender        :
        print( " kAudioUnitErr_InvalidOfflineRender")
        
    case kAudioUnitErr_Unauthorized            :
        print( " kAudioUnitErr_Unauthorized")
        
    default:
        print("huh?")
    }
}

class SoundGenerator: NSObject {
    var processingGraph: AUGraph?
    var samplerNode: AUNode
    var ioNode: AUNode
    var samplerUnit: AudioUnit?
    var ioUnit: AudioUnit?
    var isPlaying: Bool
    
    override init() {
        self.processingGraph = nil
        self.samplerNode     = AUNode()
        self.ioNode          = AUNode()
        self.samplerUnit     = nil
        self.ioUnit          = nil
        self.isPlaying       = false
        super.init()
        
        augraphSetup()
        graphStart()
    }
    
    
    func augraphSetup() {
        var status = OSStatus(noErr)
        status = NewAUGraph(&processingGraph)
        CheckError(status)
        
        // create the sampler
        // for now, just have it play the default sine tone
        //https://developer.apple.com/library/prerelease/ios/documentation/AudioUnit/Reference/AudioComponentServicesReference/index.html#//apple_ref/swift/struct/AudioComponentDescription
        
        
        var cd = AudioComponentDescription(
            componentType: OSType(kAudioUnitType_MusicDevice),
            componentSubType: OSType(kAudioUnitSubType_Sampler),
            componentManufacturer: OSType(kAudioUnitManufacturer_Apple),
            componentFlags: 0,
            componentFlagsMask: 0)
        status = AUGraphAddNode(self.processingGraph!, &cd, &samplerNode)
        CheckError(status)
        
        var ioUnitDescription = AudioComponentDescription(
            componentType: OSType(kAudioUnitType_Output),
            componentSubType: OSType(kAudioUnitSubType_RemoteIO),
            componentManufacturer: OSType(kAudioUnitManufacturer_Apple),
            componentFlags: 0,
            componentFlagsMask: 0)
        status = AUGraphAddNode(self.processingGraph!, &ioUnitDescription, &ioNode)
        CheckError(status)
        
        // now do the wiring. The graph needs to be open before you call AUGraphNodeInfo
        status = AUGraphOpen(self.processingGraph!)
        CheckError(status)
        status = AUGraphNodeInfo(self.processingGraph!, self.samplerNode, nil, &samplerUnit)
        CheckError(status)
        status = AUGraphNodeInfo(self.processingGraph!, self.ioNode, nil, &ioUnit)
        CheckError(status)
        
        let ioUnitOutputElement = AudioUnitElement(0)
        let samplerOutputElement = AudioUnitElement(0)
        status = AUGraphConnectNodeInput(self.processingGraph!,
                                         self.samplerNode, samplerOutputElement, // srcnode, inSourceOutputNumber
            self.ioNode, ioUnitOutputElement) // destnode, inDestInputNumber
        CheckError(status)
        
        // print info to stdout for debugging
        CAShow(UnsafeMutablePointer<AUGraph>(self.processingGraph!))
        
    }
    
    func graphStart() {
        //https://developer.apple.com/library/prerelease/ios/documentation/AudioToolbox/Reference/AUGraphServicesReference/index.html#//apple_ref/c/func/AUGraphIsInitialized
        
        var status = OSStatus(noErr)
        var outIsInitialized = DarwinBoolean(false)
        status = AUGraphIsInitialized(self.processingGraph!, &outIsInitialized)
        print("isinit status is \(status)")
        print("bool is \(outIsInitialized)")
        if !outIsInitialized.boolValue {
            status = AUGraphInitialize(self.processingGraph!)
            CheckError(status)
        }
        
        var isRunning = DarwinBoolean(false)
        AUGraphIsRunning(self.processingGraph!, &isRunning)
        print("running bool is \(isRunning)")
        if !isRunning.boolValue {
            status = AUGraphStart(self.processingGraph!)
            CheckError(status)
        }
        
        self.isPlaying = true
    }
    
    func playNoteOn(_ noteNum: UInt32, velocity: UInt32) {
        // note on command on channel 0
        let noteCommand = UInt32(0x90 | 0)
        var status = OSStatus(noErr)
        status = MusicDeviceMIDIEvent(self.samplerUnit!, noteCommand, noteNum, velocity, 0)
        CheckError(status)
        print("noteon status is \(status)")
    }
    
    func playNoteOff(_ noteNum: UInt32) {
        // note off command on channel 0
        let noteCommand = UInt32(0x80 | 0)
        var status = OSStatus(noErr)
        status = MusicDeviceMIDIEvent(self.samplerUnit!, noteCommand, noteNum, 0, 0)
        CheckError(status)
        print("noteoff status is \(status)")
    }
}

PlaygroundPage.current.liveView = ViewController()
