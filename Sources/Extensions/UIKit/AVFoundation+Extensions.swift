//
// AVFoundation+Extensions.swift
//
// Copyright © 2014 Zeeshan Mian
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//

import AVFoundation
import ObjectiveC

// Current Playback Time monitoring

extension AVPlayer {
    public var isPlaying: Bool {
        return rate != 0 && error == nil
    }

    public func currentTime(_ block: @escaping (_ seconds: Int, _ formattedTime: String) -> Void) -> Any {
        let interval = CMTime(value: 1, timescale: 1)
        return addPeriodicTimeObserver(forInterval: interval, queue: DispatchQueue.main) { [weak self] time in
            if let strongSelf = self {
                let normalizedTime = Double(strongSelf.currentTime().value) / Double(strongSelf.currentTime().timescale)
                block(Int(normalizedTime), strongSelf.format(seconds: Int(normalizedTime)))
            }
        }
    }

    fileprivate func format(seconds: Int) -> String {
        let sec = seconds % 60
        let min = seconds / 60
        let hrs = seconds / 3600

        if hrs == 0 {
            return String(format: "%02d:%02d", min, sec)
        }

        return String(format: "%02d:%02d:%02d", hrs, min, sec)
    }
}

extension AVPlayer {
    fileprivate struct AssociatedKey {
        static var playerRepeat = "XcoreAVPlayerRepeat"
    }

    /// Indicates whether to repeat playback of the current item.
    public var `repeat`: Bool {
        get { return objc_getAssociatedObject(self, &AssociatedKey.playerRepeat) as? Bool ?? false }
        set {
            guard newValue != `repeat` else { return }
            objc_setAssociatedObject(self, &AssociatedKey.playerRepeat, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)

            if newValue {
                NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: currentItem, queue: nil) { [weak self] notification in
                    if let currentItem = notification.object as? AVPlayerItem {
                        self?.actionAtItemEnd = .none
                        currentItem.seek(to: kCMTimeZero)
                        self?.play()
                    }
                }
            } else {
                NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: currentItem)
            }
        }
    }
}

extension AVPlayerItem {
    public var hasValidDuration: Bool {
        return status == .readyToPlay && duration.isValid
    }
}

extension CMTime {
    public var isValid: Bool { return flags.contains(.valid) }

    public func offset(by: TimeInterval) -> CMTime {
        let seconds = CMTimeGetSeconds(self)
        let secondsWithOffset = seconds + by
        return CMTime(seconds: secondsWithOffset, preferredTimescale: timescale)
    }
}

// MARK: RemoteOrLocalInstantiable

// Convenience methods for initializing videos

extension AVPlayer {
    /// Initializes an AVPlayer that automatically detect and load the asset from local or a remote url.
    ///
    /// Implicitly creates an AVPlayerItem. Clients can obtain the AVPlayerItem as it becomes the player's currentItem.
    ///
    /// - parameter remoteOrLocalName: The local file name from `NSBundle.mainBundle()` or remote url
    ///
    /// - returns:            An instance of AVPlayer
    public convenience init?(remoteOrLocalName: String) {
        if let playerItem = AVPlayerItem(remoteOrLocalName: remoteOrLocalName) {
            self.init(playerItem: playerItem)
        } else {
            return nil
        }
    }
}

extension AVPlayerItem {
    /// Initializes an AVPlayerItem with local resource referenced file name.
    ///
    /// - parameter filename: The local file name.
    /// - parameter bundle:   The bundle containing the specified file name. If you specify nil,
    ///   this method looks in the main bundle of the current application. The default value is `nil`.
    ///
    /// - returns:            An instance of AVPlayerItem.
    public convenience init?(filename: String, bundle: Bundle? = nil) {
        let name   = ((filename as NSString).lastPathComponent as NSString).deletingPathExtension
        let ext    = (filename as NSString).pathExtension
        let bundle = bundle ?? Bundle.main

        if let url = bundle.url(forResource: name, withExtension: ext) {
            self.init(url: url)
        } else {
            return nil
        }
    }

    /// Automatically detect and load the asset from local or a remote url.
    public convenience init?(remoteOrLocalName: String) {
        if let url = URL(string: remoteOrLocalName), url.host != nil {
            self.init(url: url)
        } else {
            self.init(filename: remoteOrLocalName)
        }
    }
}

extension AVAsset {
    /// Initializes an AVAsset with local resource referenced file name.
    ///
    /// - parameter filename: The local file name.
    /// - parameter bundle:   The bundle containing the specified file name. If you specify nil,
    ///   this method looks in the main bundle of the current application. The default value is `nil`.
    ///
    /// - returns:            An instance of AVAsset.
    public convenience init?(filename: String, bundle: Bundle? = nil) {
        let name   = ((filename as NSString).lastPathComponent as NSString).deletingPathExtension
        let ext    = (filename as NSString).pathExtension
        let bundle = bundle ?? Bundle.main

        if let url = bundle.url(forResource: name, withExtension: ext) {
            self.init(url: url)
        } else {
            return nil
        }
    }

    /// Automatically detect and load the asset from local or a remote url.
    public convenience init?(remoteOrLocalName: String) {
        if let url = URL(string: remoteOrLocalName), url.host != nil {
            self.init(url: url)
        } else {
            self.init(filename: remoteOrLocalName)
        }
    }
}
