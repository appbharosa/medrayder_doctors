import UIKit
import Flutter
import AVFoundation

@main
@objc class AppDelegate: FlutterAppDelegate {

    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {

        GeneratedPluginRegistrant.register(with: self)

        DispatchQueue.main.async {

            do {

                try AVAudioSession.sharedInstance().setCategory(
                    .playAndRecord,
                    mode: .videoChat,
                    options: [
                        .defaultToSpeaker,
                        .allowBluetooth,
                        .allowBluetoothA2DP
                    ]
                )

                try AVAudioSession.sharedInstance().setActive(true)

            } catch {
                print("Audio Session Error: \(error)")
            }
        }

        return super.application(
            application,
            didFinishLaunchingWithOptions: launchOptions
        )
    }
}