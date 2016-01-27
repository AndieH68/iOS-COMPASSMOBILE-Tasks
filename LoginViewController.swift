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
    
    @IBOutlet weak var UsernameTextField: UITextField!
    @IBOutlet weak var PasswordTextField: UITextField!
    @IBOutlet weak var ValidationLabel: UILabel!
    @IBOutlet weak var MessageLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UsernameTextField.delegate = self
        PasswordTextField.delegate = self

        // Do any additional setup after loading the view.
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
        
        let username = UsernameTextField.text
        let password = PasswordTextField.text
        
        if username == "" || password == ""
        {
            MessageLabel.text = ""
            ValidationLabel.hidden = false
            return
        }
        
        MessageLabel.text = "Connecting to Server..."
        
        isRemoteAvailable = Reachability().connectedToNetwork()
 
       
        if isRemoteAvailable {
            let data: NSData? = WebService.validateOperative(username!, password: password!)
            
            if data == nil{
                MessageLabel.text = ""
                ValidationLabel.hidden = false
                ValidationLabel.text = "error with web service"
                return
            }
           
            let response: AEXMLElement = Utility.openSoapEnvelope(data)!
        
            if response.name == "soap:Fault"
            {
                //fault code here
            }
        
            let operativeId = response["ValidateOperativeResult"].value
        
            if operativeId == nil || operativeId!.containsString("not found")
            {
                MessageLabel.text = ""
                ValidationLabel.hidden = false
                return
            }
            else
            {
                Session.OperativeId = operativeId!
            }
        }
        
        
        MessageLabel.text = "Connecting to Client...."
                
        //initialise local database connection
        
        var newOperative: Bool = false
        
        var criteria: Dictionary<String,AnyObject> = Dictionary<String,AnyObject>()
        criteria["Username"] = username!
        criteria["Password"] = password!
        
        let operatives: NSMutableArray = ModelManager.getInstance().findOperatives(criteria)
        
        if operatives.count == 1
        {
            let operative: Operative = operatives[0] as! Operative
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
            MessageLabel.text = ""
            ValidationLabel.hidden = false
            return
        }
        
        //Send any tasks which are marked as closed on this device since the last synchronisation of this device
        //Session.SendTasks()
        
        //if the newOperative flag is set, the operative is present on COMPASS but not in the local database
        //therefore we must bring down the operative synchronisation package to ensure operatives are updated
        if newOperative {
            let synchronisationDate: NSDate = BaseDate
            var lastRowId: String = EmptyGuid
            let stage: Int32 = 9
            var count: Int32 = 0
        
            while (lastRowId != EmptyGuid || count == 0) {
                count += 1
                let data: NSData? = WebService.getSynchronisationPackage(Session.OperativeId!, synchronisationDate: synchronisationDate, lastRowId: lastRowId, stage: stage)

                if data == nil{
                    MessageLabel.text = ""
                    ValidationLabel.hidden = false
                    ValidationLabel.text = "error with web service"
                    return
                }
                
                let response: AEXMLElement = Utility.openSoapEnvelope(data)!
                
                if response.name == "soap:Fault"
                {
                    //fault code here
                }
                
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
                MessageLabel.text = ""
                ValidationLabel.hidden = false
                return
            }
        
            Session.OrganisationId = operative?.OrganisationId
        
        }
        
        //Synchronous call, but this may be skipped is we are fetching data in the back ground
        let synchronisationDate: NSDate = BaseDate
        Utility.synchroniseData(synchronisationDate)
        
        //Code to dismiss the login screen and go to the main taks screen
        Utility.invokeAlertMethod("Logged in", strBody: "User details found", delegate: nil)
        
        self.dismissViewControllerAnimated(true, completion: nil)
     }

    
}
