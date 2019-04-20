import UIKit

extension UIAlertController {
    
    /// Add a Color Picker
    ///
    /// - Parameters:
    ///   - color: input color
    ///   - action: for selected color
    
    func addColorPicker(color: UIColor = .black, selection: ColorPickerViewController.Selection?) {
        let selection: ColorPickerViewController.Selection? = selection
        var color: UIColor = color
        
        let buttonSelection = UIAlertAction(title: "Select", style: .default) { action in
            selection?(color)
        }
        buttonSelection.isEnabled = true

        guard let objsFromNib = Bundle.main.loadNibNamed("ColorPickerViewController", owner: self, options: nil),
            let vc = objsFromNib.last as? ColorPickerViewController else {
                return
        }
        set(vc: vc)
        
        set(title: color.hexString, font: .systemFont(ofSize: 17), color: color)
        vc.set(color: color) { new in
            color = new
            self.set(title: color.hexString, font: .systemFont(ofSize: 17), color: color)
        }
        addAction(buttonSelection)
    }
}

class ColorPickerViewController: UIViewController {
    
    public typealias Selection = (UIColor) -> Swift.Void
    
    fileprivate var selection: Selection?
    
    @IBOutlet weak var colorView: UIView!{
        didSet {
            colorView.circleCorner = true
            colorView.shadowOffset = CGSize(width: 1, height: 5)
            colorView.shadowOpacity = 0.4
            colorView.shadowShouldRasterize = true
            colorView.shadowRadius = 14
            colorView.shadowColor = UIColor.black
        }
    }
    
    @IBOutlet weak var saturationSlider: GradientSlider! {
        didSet {
            saturationSlider.thickness = 3
            saturationSlider.minColor = UIColor(hue: 0, saturation: 0, brightness: 0, alpha: 1)
            saturationSlider.maxColor = UIColor(hue: 1, saturation: 1, brightness: 1, alpha: 1)
        }
    }
    @IBOutlet weak var brightnessSlider: GradientSlider! {
        didSet {
            brightnessSlider.thickness = 3
            brightnessSlider.minColor = UIColor(hue: 0, saturation: 0, brightness: 0, alpha: 1)
            brightnessSlider.maxColor = UIColor(hue: 1, saturation: 1, brightness: 1, alpha: 1)
            brightnessSlider.hasRainbow = false
        }
    }
    @IBOutlet weak var hueSlider: GradientSlider! {
        didSet {
            hueSlider.thickness = 3
            hueSlider.minColor = UIColor(hue: 1, saturation: 1, brightness: 0, alpha: 1)
            hueSlider.hasRainbow = true
        }
    }
    
    @IBOutlet weak var mainStackView: UIStackView!
    
    public var color: UIColor {
        return UIColor(hue: hue, saturation: saturation, brightness: brightness, alpha: alpha)
    }
    
    public var hue: CGFloat = 0.5
    public var saturation: CGFloat = 0.5
    public var brightness: CGFloat = 0.5
    public var alpha: CGFloat = 1
    
    fileprivate var preferredHeight: CGFloat = 0
    
    func set(color: UIColor, selection: Selection?) {
        let components = color.hsbaComponents
        
        hue = components.hue
        saturation = components.saturation
        brightness = components.brightness
        alpha = components.alpha
        
        let mainColor: UIColor = UIColor(
            hue: hue,
            saturation: 1.0,
            brightness: 1.0,
            alpha: 1.0)
        
        hueSlider.minColor = mainColor
        hueSlider.thumbColor = mainColor
        brightnessSlider.maxColor = mainColor
        saturationSlider.maxColor = mainColor
        
        hueSlider.value = hue
        saturationSlider.value = saturation
        brightnessSlider.value = brightness
        
        updateColorView()
        
        self.selection = selection
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Log("preferredHeight = \(preferredHeight)")
        
        saturationSlider.minColor = .white
        brightnessSlider.minColor = .black
        hueSlider.hasRainbow = true
        
        hueSlider.actionBlock = { [unowned self] slider, newValue in
            CATransaction.begin()
            CATransaction.setValue(true, forKey: kCATransactionDisableActions)
            
            self.hue = newValue
            let mainColor: UIColor = UIColor(
                hue: newValue,
                saturation: 1.0,
                brightness: 1.0,
                alpha: 1.0)
            
            self.hueSlider.thumbColor = mainColor
            self.brightnessSlider.maxColor = mainColor
            self.saturationSlider.maxColor = mainColor
            
            self.updateColorView()
            
            CATransaction.commit()
        }
        
        brightnessSlider.actionBlock = { [unowned self] slider, newValue in
            CATransaction.begin()
            CATransaction.setValue(true, forKey: kCATransactionDisableActions)
            
            self.brightness = newValue
            self.updateColorView()
            
            CATransaction.commit()
        }
        
        saturationSlider.actionBlock = { [unowned self] slider, newValue in
            CATransaction.begin()
            CATransaction.setValue(true, forKey: kCATransactionDisableActions)
            
            self.saturation = newValue
            self.updateColorView()
            
            CATransaction.commit()
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        preferredHeight = mainStackView.frame.maxY
    }
    
    func updateColorView() {
        colorView.backgroundColor = color
        selection?(color)
        Log("set color = \(color.hexString)")
    }
}

