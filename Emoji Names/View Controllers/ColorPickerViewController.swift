//
//  ColorPickerViewController.swift
//  Emoji Names
//
//  Created by Cal Stephens on 11/24/17.
//  Copyright © 2017 Cal Stephens. All rights reserved.
//

import UIKit

// MARK: ColorPickerViewControllerDelegate

protocol ColorPickerViewControllerDelegate: class {
    func colorPicker(_ viewController: ColorPickerViewController, didSelectColor color: UIColor)
    func colorPickerDidSelectReset(_ viewController: ColorPickerViewController)
}

// MARK: ColorPickerViewController

class ColorPickerViewController: UIViewController {
    
    let colors: [UIColor] = [#colorLiteral(red: 1, green: 0.5411764706, blue: 0.5019607843, alpha: 1), #colorLiteral(red: 1, green: 0.09019607843, blue: 0.2666666667, alpha: 1), #colorLiteral(red: 0.8352941176, green: 0, blue: 0, alpha: 1),
                             #colorLiteral(red: 1, green: 0.8196078431, blue: 0.5019607843, alpha: 1), #colorLiteral(red: 1, green: 0.568627451, blue: 0, alpha: 1), #colorLiteral(red: 1, green: 0.4274509804, blue: 0, alpha: 1),
                             #colorLiteral(red: 1, green: 1, blue: 0.5529411765, alpha: 1), #colorLiteral(red: 1, green: 0.9176470588, blue: 0, alpha: 1), #colorLiteral(red: 1, green: 0.8392156863, blue: 0, alpha: 1),
                             #colorLiteral(red: 0.7254901961, green: 0.9647058824, blue: 0.7921568627, alpha: 1), #colorLiteral(red: 0, green: 0.9019607843, blue: 0.462745098, alpha: 1), #colorLiteral(red: 0, green: 0.7843137255, blue: 0.3254901961, alpha: 1),
                             #colorLiteral(red: 0.9176470588, green: 0.5019607843, blue: 0.9882352941, alpha: 1), #colorLiteral(red: 0.8352941176, green: 0, blue: 0.9764705882, alpha: 1), #colorLiteral(red: 0.6666666667, green: 0, blue: 1, alpha: 1),
                             #colorLiteral(red: 0.7019607843, green: 0.5333333333, blue: 1, alpha: 1), #colorLiteral(red: 0.3960784314, green: 0.1215686275, blue: 1, alpha: 1), #colorLiteral(red: 0.3843137255, green: 0, blue: 0.9176470588, alpha: 1),
                             #colorLiteral(red: 0.5019607843, green: 0.8470588235, blue: 1, alpha: 1), #colorLiteral(red: 0, green: 0.6901960784, blue: 1, alpha: 1), #colorLiteral(red: 0, green: 0.568627451, blue: 0.9176470588, alpha: 1),
                             #colorLiteral(red: 0.5176470588, green: 1, blue: 1, alpha: 1), #colorLiteral(red: 0, green: 0.8980392157, blue: 1, alpha: 1), #colorLiteral(red: 0, green: 0.7215686275, blue: 0.831372549, alpha: 1),
                             #colorLiteral(red: 0.737254902, green: 0.6666666667, blue: 0.6431372549, alpha: 1), #colorLiteral(red: 0.4745098039, green: 0.3333333333, blue: 0.2823529412, alpha: 1), #colorLiteral(red: 0.3058823529, green: 0.2039215686, blue: 0.1803921569, alpha: 1),
                             #colorLiteral(red: 0.7411764706, green: 0.7411764706, blue: 0.7411764706, alpha: 1), #colorLiteral(red: 0.3803921569, green: 0.3803921569, blue: 0.3803921569, alpha: 1), #colorLiteral(red: 0.1294117647, green: 0.1294117647, blue: 0.1294117647, alpha: 1),
                             #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)]
    
    var defaultColor: UIColor?
    weak var delegate: ColorPickerViewControllerDelegate?
    
    // MARK: Setup
    
    override func viewDidLoad() {
        view.backgroundColor = UIColor(white: 1.0, alpha: 0.5)
    }
    
}

// MARK: UICollectionViewDataSource

extension ColorPickerViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return colors.count + (self.defaultColor != nil ? 1 : 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let color: UIColor
        if indexPath.item >= colors.count {
            color = defaultColor ?? .white
        } else {
            color = colors[indexPath.item]
        }
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "swatch", for: indexPath) as! SwatchCell
        cell.decorate(with: color)
        return cell
    }
    
}

// MARK: UICollectionViewDelegateFlowLayout

extension ColorPickerViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        if indexPath.item >= colors.count {
            return CGSize(width: 43 + 10 + 43, height: 43)
        } else {
            return CGSize(width: 43, height: 43)
        }
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath)
    {
        if indexPath.item >= colors.count {
            delegate?.colorPickerDidSelectReset(self)
        } else {
            delegate?.colorPicker(self, didSelectColor: colors[indexPath.item])
        }
    }
    
}

// MARK: SwatchCell

class SwatchCell: UICollectionViewCell {
    
    @IBOutlet weak var swatchView: UIView!
    
    func decorate(with color: UIColor) {
        swatchView.backgroundColor = color
        swatchView.layer.cornerRadius = bounds.height / 2
    }
    
}
