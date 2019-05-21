//
//  LoginViewController.swift
//  COMPASSMOBILE
//
//  Created by Andrew Harper on 11/01/2016.
//  Copyright © 2016 HYDOP E.C.S. All rights reserved.
//

import UIKit
import AEXML

class LoginViewController: UIViewController, UITextFieldDelegate {

    // MARK: - Properties
    let gradientLayer = CAGradientLayer()
    @IBOutlet var VersionNumber: UILabel!
    @IBOutlet weak var ServerTextField: UITextField!
    @IBOutlet weak var UsernameTextField: UITextField!
    @IBOutlet weak var PasswordTextField: UITextField!
    @IBOutlet weak var ValidationLabel: UILabel!
    @IBOutlet weak var MessageLabel: UILabel!
    @IBOutlet var LoginButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Utility.lockOrientation(.portrait, andRotateTo: .portrait)
        
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        {
            VersionNumber.text = version
        }
        
        ServerTextField.delegate = self
        UsernameTextField.delegate = self
        PasswordTextField.delegate = self

        // Do any additional setup after loading the view.
        ServerTextField.text = Session.Server
        
        let defaults = UserDefaults.standard
        UsernameTextField.text = defaults.object(forKey: "Username") as? String
        
        if !Session.DatabasePresent
        {
            Utility.invokeAlertMethod(self, title: "Fatal Exception", message: Session.DatabaseMessage)
            Session.OperativeId = nil

            ValidationLabel.text = "Database not present - contact support"
            ValidationLabel.isHidden = false
            LoginButton.isEnabled = false
            ServerTextField.isEnabled = false
            UsernameTextField.isEnabled = false
            PasswordTextField.isEnabled = false
        }
        // 1
        self.view.backgroundColor = UIColor.white
        gradientLayer.frame = self.view.bounds
        let color1 = UIColor(red:0.00, green:0.60, blue:0.85, alpha:1.0).cgColor as CGColor
        let color3 = UIColor.clear.cgColor as CGColor
        gradientLayer.colors = [color1, color3]
        gradientLayer.locations = [0.355,0.355]
        self.view.layer.insertSublayer(gradientLayer, at: 0)
       
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Reset when view is being removed
        Utility.lockOrientation(.all)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
   
    //MARK: - UITextFieldDelegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        ValidationLabel.isHidden = true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.resignFirstResponder()
    }
    
   
    //MARK: - Actions
    
    @IBAction func LoginButton(_ sender: UIButton) {
        
        ValidationLabel.text = "Invalid username or password"
        ValidationLabel.isHidden = true
        
        if (ServerTextField.text == "")
        {
            ValidationLabel.text = "Please enter the server details"
            ValidationLabel.isHidden = false
            return
        }

        Session.Server = ServerTextField.text!
        
        if (UsernameTextField.text == "" || UsernameTextField.text == "")
        {
            ValidationLabel.isHidden = false
            return
        }

        let username: String = UsernameTextField.text!
        let password: String = PasswordTextField.text!
        
        var remoteValidation: Bool = false
        let isRemoteAvailable: Bool = (Bool)(Reachability().connectedToNetwork())
       
        if isRemoteAvailable {
            let data: Data? = WebService.validateOperative(username, password: password)
            
            if data == nil{
                ValidationLabel.isHidden = false
                ValidationLabel.text = "error with web service"
                //return
            }
            else
            {
                let response: AEXMLElement = Utility.openSoapEnvelope(data)!
            
                if response.name == "soap:Fault"
                {
                    //fault code here
                    let errorText: String = response.value!
                    ValidationLabel.text = errorText
                    ValidationLabel.isHidden = false
                }
                else
                {
                    let operativeId = response["ValidateOperativeResult"].value
                
                    if operativeId == nil || operativeId!.contains("not found")
                    {
                        ValidationLabel.isHidden = false
                        //return
                    }
                    else
                    {
                        remoteValidation = true
                        Session.OperativeId = operativeId!
                    }
                }
            }
        }
        
        //initialise local database connection
        var localValidation: Bool = false
        var newOperative: Bool = false
        
        var criteria: Dictionary<String,AnyObject> = Dictionary<String,AnyObject>()
        criteria["Username"] = username as AnyObject?
        criteria["Password"] = password as AnyObject?
        
        var operatives: [Operative] = [Operative]()
        var count: Int32 = 0
        (operatives, count) = ModelManager.getInstance().findOperativeList(criteria, pageSize: 1, pageNumber: 1)
        
        if count == 1
        {
            localValidation = true
            let operative: Operative = operatives[0]
            Session.OperativeId = operative.RowId
            Session.OrganisationId = operative.OrganisationId
            
            if (!isRemoteAvailable || !remoteValidation)
            {
                Session.LocalLoginOnly = true
            }
        }
        else
        {
           newOperative = true
        }
        
        if (!(remoteValidation || localValidation) || Session.OperativeId == nil)
        {
            ValidationLabel.isHidden = false
            return
        }

        //if the newOperative flag is set, the operative is present on COMPASS but not in the local database
        //therefore we must bring down the operative synchronisation package to ensure operatives are updated
        if newOperative {
            let synchronisationDate: Date = BaseDate as Date
            var lastRowId: String = EmptyGuid
            let stage: Int32 = 9
            var count: Int32 = 0
        
            while (lastRowId != EmptyGuid || count == 0) {
                count += 1
                //get the Operative data from the web service
                let data: Data? = WebService.getSynchronisationPackageSync(Session.OperativeId!, synchronisationDate: synchronisationDate, lastRowId: lastRowId, stage: stage)

                if data == nil{
                    ValidationLabel.isHidden = false
                    ValidationLabel.text = "error with web service"
                    return
                }
                
                let response: AEXMLElement = Utility.openSoapEnvelope(data)!
                
                if response.name == "soap:Fault"
                {
                    let errorText: String = response.children[1].value!
                    ValidationLabel.text = errorText
                    ValidationLabel.isHidden = false
                    return
                }
                
                let SynchronisationPackageData: Data = (response["GetSynchronisationPackageResult"].value! as NSString).data(using: String.Encoding.utf8.rawValue)!
                
                var SynchronisationPackageDocument: AEXMLDocument?
                do {
                    SynchronisationPackageDocument = try AEXMLDocument(xml: SynchronisationPackageData)
                }
                catch {
                    SynchronisationPackageDocument = nil
                }
                
                //import the data
                (lastRowId, _, _, _) = Utility.importData(SynchronisationPackageDocument!.children[0], entityType: .operative)
            }
        
            let operative: Operative? = ModelManager.getInstance().getOperative(Session.OperativeId!)
            
            if Session.OperativeId == nil
            {
                ValidationLabel.isHidden = false
                return
            }
        
            Session.OrganisationId = operative?.OrganisationId
        
        }
        
        Session.CheckDatabase = true;
 
        //set the package defaults
        let defaults = UserDefaults.standard
        defaults.set(Session.Server, forKey: "Server")
        defaults.set(username, forKey: "Username")
        
        //close te login view
        self.dismiss(animated: true, completion: nil)
     }
    func draw(_ rect: CGRect) {
        let bottomRect = CGRect(
            origin: CGPoint(x: rect.origin.x, y: rect.height / 2),
            size: CGSize(width: rect.size.width, height: rect.size.height / 2)
        )
        UIColor.red.set()
        guard let context = UIGraphicsGetCurrentContext() else { return }
        context.fill(bottomRect)
    }
    
}
