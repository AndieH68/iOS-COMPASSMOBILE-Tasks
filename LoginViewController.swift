//
//  LoginViewController.swift
//  COMPASSMOBILE
//
//  Created by Andrew Harper on 11/01/2016.
//  Copyright © 2016 HYDOP E.C.S. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate {

    // MARK: - Properties
   
    @IBOutlet weak var ServerTextField: UITextField!
    @IBOutlet weak var UsernameTextField: UITextField!
    @IBOutlet weak var PasswordTextField: UITextField!
    @IBOutlet weak var ValidationLabel: UILabel!
    @IBOutlet weak var MessageLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ServerTextField.delegate = self
        UsernameTextField.delegate = self
        PasswordTextField.delegate = self

        // Do any additional setup after loading the view.
        ServerTextField.text = Session.Server
        
        let defaults = NSUserDefaults.standardUserDefaults()
        UsernameTextField.text = defaults.objectForKey("Username") as? String
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    //MARK: - UITextFieldDelegate
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        ValidationLabel.hidden = true
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        textField.resignFirstResponder()
    }
    
   
    //MARK: - Actions
    
    @IBAction func LoginButton(sender: UIButton) {
        
        var isRemoteAvailable: Bool = true
        
        ValidationLabel.text = "Invalid username or password"
        ValidationLabel.hidden = true
        
        if (ServerTextField.text == "")
        {
            ValidationLabel.text = "Please enter the server details"
            ValidationLabel.hidden = false
            return
        }

        Session.Server = ServerTextField.text!
        
        if (UsernameTextField.text == "" || UsernameTextField.text == "")
        {
            ValidationLabel.hidden = false
            return
        }

        let username: String = UsernameTextField.text!
        let password: String = PasswordTextField.text!
        
        isRemoteAvailable = Reachability().connectedToNetwork()
 
       
        if isRemoteAvailable {
            let data: NSData? = WebService.validateOperative(username, password: password)
            
            if data == nil{
                ValidationLabel.hidden = false
                ValidationLabel.text = "error with web service"
                return
            }
           
            let response: AEXMLElement = Utility.openSoapEnvelope(data)!
        
            if response.name == "soap:Fault"
            {
                //fault code here
                ValidationLabel.text = "Network error"
                ValidationLabel.hidden = false
                return
            }
        
            let operativeId = response["ValidateOperativeResult"].value
        
            if operativeId == nil || operativeId!.containsString("not found")
            {
                ValidationLabel.hidden = false
                return
            }
            else
            {
                Session.OperativeId = operativeId!
            }
        }
        
        //initialise local database connection
        
        var newOperative: Bool = false
        
        var criteria: Dictionary<String,AnyObject> = Dictionary<String,AnyObject>()
        criteria["Username"] = username
        criteria["Password"] = password
        
        var operatives: [Operative] = [Operative]()
        var count: Int32 = 0
        (operatives, count) = ModelManager.getInstance().findOperativeList(criteria, pageSize: 1, pageNumber: 1)
        
        if count == 1
        {
            let operative: Operative = operatives[0]
            Session.OperativeId = operative.RowId
            Session.OrganisationId = operative.OrganisationId
            
            if !isRemoteAvailable
            {
                Utility.invokeAlertMethod("No remote", strBody: "Logged in locally", delegate: nil)
            }
        }
        else
        {
           newOperative = true
        }
        
        if Session.OperativeId == nil
        {
            ValidationLabel.hidden = false
            return
        }

        //if the newOperative flag is set, the operative is present on COMPASS but not in the local database
        //therefore we must bring down the operative synchronisation package to ensure operatives are updated
        if newOperative {
            let synchronisationDate: NSDate = BaseDate
            var lastRowId: String = EmptyGuid
            let stage: Int32 = 9
            var count: Int32 = 0
        
            while (lastRowId != EmptyGuid || count == 0) {
                count += 1
                let data: NSData? = WebService.getSynchronisationPackageSync(Session.OperativeId!, synchronisationDate: synchronisationDate, lastRowId: lastRowId, stage: stage)

                if data == nil{
                    ValidationLabel.hidden = false
                    ValidationLabel.text = "error with web service"
                    return
                }
                
                let response: AEXMLElement = Utility.openSoapEnvelope(data)!
                
                if response.name == "soap:Fault"
                {
                    ValidationLabel.text = "Network error"
                    ValidationLabel.hidden = false
                    return                }
                
                let SynchronisationPackageData: NSData = (response["GetSynchronisationPackageResult"].value! as NSString).dataUsingEncoding(NSUTF8StringEncoding)!
                
                var SynchronisationPackageDocument: AEXMLDocument?
                do {
                    SynchronisationPackageDocument = try AEXMLDocument(xmlData: SynchronisationPackageData)
                }
                catch {
                    SynchronisationPackageDocument = nil
                }
                
                //check for empty pacakage
               
                lastRowId = Utility.importData(SynchronisationPackageDocument!.children[0], entityType: .Operative)
            }
        
            let operative: Operative? = ModelManager.getInstance().getOperative(Session.OperativeId!)
            
            if Session.OperativeId == nil
            {
                ValidationLabel.hidden = false
                return
            }
        
            Session.OrganisationId = operative?.OrganisationId
        
        }
        
        Session.CheckDatabase = true;
 
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setObject(Session.Server, forKey: "Server")
        defaults.setObject(username, forKey: "Username")
        
        self.dismissViewControllerAnimated(true, completion: nil)
     }

    
}
