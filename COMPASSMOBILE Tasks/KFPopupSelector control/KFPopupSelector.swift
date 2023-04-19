//
//  KFPopupSelector.swift
//  KFPopupSelector
//
//  Created by acb on 27/05/2015.
//  Copyright (c) 2015 Kineticfactory. All rights reserved.
//

import UIKit

class KFPopupSelector: UIControl, UIPopoverPresentationControllerDelegate {
    
    enum Option {
        case text(text:String)
        
        func intrinsicWidthWithFont(_ font: UIFont) -> CGFloat {
            switch(self) {
            case .text(let t): return NSString(string:t).boundingRect(with: CGSize(width:1000, height:1000), options:[], attributes:[NSAttributedString.Key.font: font], context:nil).width
            }
        }
     }
    
    /** The options the user has to choose from */
    var options: [Option] = [] {
        didSet {
            updateButtonState()
        }
    }
    
    /** The currently selected value */
    var selectedIndex: Int? = nil {
        didSet {
            updateLabel()
            sendActions(for: .valueChanged)
            if let index = selectedIndex {
                itemSelected?(index)
            }
        }
    }
    
    /** The text to display on the button if no option is selected */
    var unselectedLabelText:String = "--" {
        didSet {
            updateLabel()
        }
    }
    
    /** if true, replace the button's text with the currently selected item */
    var displaySelectedValueInLabel: Bool = true
    
    /** the horizontal alignment for the button text */
    var buttonContentHorizontalAlignment: UIControl.ContentHorizontalAlignment = UIControl.ContentHorizontalAlignment.left
    
    /** the size of font for th etable to use*/
    fileprivate var tableFont: UIFont = UIFont.systemFont(ofSize: 15.0)
    
    
    /** How the button title is displayed */
    enum LabelDecoration {
    case none
    case downwardTriangle        
        func apply(_ str:String) ->String {
            switch(self) {
            case .none: return str
            case .downwardTriangle: return str + " ▾"
            }
        }
    }
    var labelDecoration: LabelDecoration = .none {
        didSet {
            updateLabel()
        }
    }
    
    /** The behaviour when the list of options is empty */
    enum EmptyBehaviour {
        /** Leave the button enabled; this allows willOpenPopup to be used to dynamically fill the options */
        case enabled
        /** Disable the button, but display it in a disabled state */
        case disabled
        /** Hide the button */
        case hidden
    }
    var emptyBehaviour: EmptyBehaviour = .disabled {
        didSet {
            updateButtonState()
        }
    }
    
    func setLabelFont(_ font: UIFont) {
        button.titleLabel?.font = font
    }

    func setTableFont(_ font: UIFont) {
        tableFont = font
    }
    
    /** Optional callback called when the user has selected an item */
    var itemSelected: ((Int)->())? = nil
    
    /** Optional function to call before the popup is opened; this may be used to update the options list. */
    var willOpenPopup: (()->())? = nil
    
    func updateButtonState() {
        let empty = options.isEmpty
        button.isEnabled = !(empty && emptyBehaviour == .disabled)
        button.isHidden = empty && emptyBehaviour == .hidden
        invalidateIntrinsicContentSize()
    }
    
    func updateLabel() {
        if selectedIndex != nil && displaySelectedValueInLabel {
            switch (options[selectedIndex!]) {
            case .text(let text): buttonText = text
            }
        } else {
            buttonText = unselectedLabelText
        }
    }
    
    // -------- The TableViewController used internally in the popover
    
    class PopupViewController: UITableViewController {
        var minWidth: CGFloat = 160.0
        var optionsWidth: CGFloat = 40.0

        var tableViewFont: UIFont = UIFont.systemFont(ofSize: 15.0)

        var options: [Option] = [] {
            didSet {
                optionsWidth = options.map { $0.intrinsicWidthWithFont(self.tableViewFont) }.reduce(minWidth) { max($0, $1) }
            }
        }
        
        var itemSelected: ((Int)->())? = nil
        
        let KFPopupSelectorCellReuseId = "KFPopupSelectorCell"
                
        override var preferredContentSize: CGSize { 
            get {
                tableView.layoutIfNeeded()
                return CGSize(width:optionsWidth+32, height:tableView.contentSize.height)
            }
            set {
                print("Cannot set preferredContentSize of this view controller!")
            }
        }
        
        override func loadView() {
            super.loadView()
            tableView.rowHeight = 36.0
            tableView.separatorStyle = .none
        }
        
        override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            tableView.isScrollEnabled = (tableView.contentSize.height > tableView.frame.size.height)
        }
        
        override func numberOfSections(in tableView: UITableView) -> Int {
            return 1
        }
        
        override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return options.count
        }
        
        override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = (tableView.dequeueReusableCell(withIdentifier: KFPopupSelectorCellReuseId) ?? UITableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: KFPopupSelectorCellReuseId)) 
            switch options[indexPath.row]  {
            case .text(let text): 
                cell.textLabel?.text = text
                cell.textLabel?.font = tableViewFont
            }
            return cell
        }
        
        override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            itemSelected?(indexPath.row)
        }
    }
    
    // --------------------------------
    
    var currentlyPresentedPopup: PopupViewController? = nil
    
    var selectedValue: String?
    {
        get {
            return buttonText;
        }
    }
    
    fileprivate let button = UIButton(type: .system)
    
    fileprivate var buttonText: String? {
        get {
            return button.title(for: UIControl.State())
        }
        set {
            button.setTitle(newValue.map { self.labelDecoration.apply($0) }, for: UIControl.State())
            invalidateIntrinsicContentSize()
        }
    }
    
    override var intrinsicContentSize : CGSize {
        return (options.isEmpty && emptyBehaviour == .hidden) ? CGSize.zero : button.intrinsicContentSize
    }
    
    fileprivate func setupView() {
        button.setTitle(labelDecoration.apply(unselectedLabelText), for: UIControl.State())
        button.contentHorizontalAlignment = buttonContentHorizontalAlignment
        self.addSubview(button)
        button.frame = self.bounds
        button.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        
        button.addTarget(self, action: #selector(KFPopupSelector.buttonPressed(_:)), for:.touchDown)
        self.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(KFPopupSelector.dragged(_:))))
    }
    
    override init(frame: CGRect) {
        super.init(frame:frame)
        setupView()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder:aDecoder)
        setupView()
    }

    override func awakeFromNib() {
        setupView()
    }
    
    fileprivate var viewController: UIViewController? {
        var next: UIView? = self.superview
        while (next?.superview != nil)
        {
           next = next?.superview
            let responder = next?.next
            if let vc = responder as? UIViewController {
                return vc
            }
       }
       return nil
        
//        for var next: UIView? = self.superview; next != nil; next = next?.superview {
//            let responder = next?.nextResponder()
//            if let vc = responder as? UIViewController {
//                return vc
//            }
//        }
//        return nil
    }
    
    @objc func dragged(_ sender: UIPanGestureRecognizer!) {
        if let tableView = currentlyPresentedPopup?.tableView {
            switch(sender.state) {
            case .changed:
                if tableView.superview != nil {
                    let pos = sender.location(in: tableView)
                    if let ip = tableView.indexPathForRow(at: pos) {
                        tableView.selectRow(at: ip, animated: false, scrollPosition: UITableView.ScrollPosition.none)
                    }
                }
            case .ended:
                if let ip = tableView.indexPathForSelectedRow {
                    currentlyPresentedPopup!.dismiss(animated: true){ 
                        self.currentlyPresentedPopup = nil 
                        self.selectedIndex = ip.row
                    }
                }
            default: break
            }
        }
    }
    
    @objc func buttonPressed(_ sender: AnyObject?) {
        if(!Session.TimerRunning)
        {
            willOpenPopup?()
            if options.count > 0 {
                let pvc = PopupViewController(style: UITableView.Style.plain)
                pvc.tableViewFont = tableFont
                pvc.minWidth = self.bounds.width
                pvc.options = options
                pvc.itemSelected = { (index:Int) -> () in
                    pvc.dismiss(animated: true) { 
                        self.currentlyPresentedPopup = nil 
                        self.selectedIndex = index
                    }
                }
                pvc.modalPresentationStyle = .popover
                currentlyPresentedPopup = pvc
                
                let pc = pvc.popoverPresentationController
                pc?.sourceView = self
                pc?.sourceRect = button.frame
                pc?.permittedArrowDirections = .any 
                pc?.delegate = self
                
                viewController!.present(pvc, animated: true) {}
            }
        }
    }
    
    
    // MARK: UIPopoverPresentationControllerDelegate
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    
    func popoverPresentationControllerDidDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) {
        currentlyPresentedPopup = nil
    }
}
