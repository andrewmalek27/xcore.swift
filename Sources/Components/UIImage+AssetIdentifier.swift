//
// UIImage+AssetIdentifier.swift
//
// Copyright © 2015 Zeeshan Mian
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

import UIKit

extension Bundle {
    // Methods for creating or retrieving bundle instances.
    static var xcore: Bundle {
        return Bundle(for: DynamicTableView.self)
    }
}

/// Extension to get compile time checks for asset identifiers
extension UIImage {
    enum AssetIdentifier: String {
        case DisclosureIndicator
        case CollectionViewCellDeleteIcon
        case ReorderTableViewCellShadowTop
        case ReorderTableViewCellShadowBottom
        case BlueJay
    }

    convenience init(assetIdentifier: AssetIdentifier) {
        self.init(named: assetIdentifier.rawValue, in: .xcore, compatibleWith: nil)!
    }
}

extension UIImageView {
    convenience init(assetIdentifier: UIImage.AssetIdentifier) {
        self.init(image: UIImage(assetIdentifier: assetIdentifier))
    }
}

extension UIButton {
    convenience init(assetIdentifier: UIImage.AssetIdentifier, highlightedImage: UIImage.AssetIdentifier? = nil) {
        self.init(type: .custom)
        setImage(UIImage(assetIdentifier: assetIdentifier), for: .normal)
        if let highlightedImage = highlightedImage {
            setImage(UIImage(assetIdentifier: highlightedImage), for: .highlighted)
        }
        imageView?.contentMode = .scaleAspectFit
        imageView?.tintColor   = tintColor
    }
}

/// A convenience function to get image name from `xcassets`.
func R(_ assetIdentifier: UIImage.AssetIdentifier) -> String {
    return assetIdentifier.rawValue
}
