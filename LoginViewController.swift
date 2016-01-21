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
 
        let urlString = "http://compass2.hydrop.com/services/servicepdautility2.asmx"
        let url = NSURL(string: urlString)

        var soapAction: String = ""
        var soapMessage: String = ""
        var soapBody: String = ""
        let theSession = NSURLSession.sharedSession()
        let theRequest = NSMutableURLRequest(URL: url!)

        let soapHeader: String = "<?xml version=\"1.0\" encoding=\"utf-8\"?><soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">"
        let soapFooter: String = "</soap:Envelope>"

        
        if isRemoteAvailable {
            soapAction = "http://compass.hydrop.com/services/ValidateOperative"
            soapBody = "<soap:Body><ValidateOperative xmlns=\"http://compass.hydrop.com/services/\"><Username>\"" + username! + "\"</Username><Password>\"" + password! + "\"</Password></ValidateOperative></soap:Body>"
        
            soapMessage = soapHeader + soapBody + soapFooter
        
            theRequest.HTTPMethod = "POST"
            theRequest.addValue("compass2.hydrop.com", forHTTPHeaderField: "Host")
            theRequest.addValue("text/xml; charset=utf-8", forHTTPHeaderField: "Content-Type")
            theRequest.addValue(String(soapMessage.characters.count), forHTTPHeaderField: "Content-Length")
            theRequest.addValue(soapAction, forHTTPHeaderField: "SOAPAction")
            theRequest.HTTPBody = soapMessage.dataUsingEncoding(NSUTF8StringEncoding)
        
            var data: NSData? = nil
            let semaphore = dispatch_semaphore_create(0)
        
            theSession.dataTaskWithRequest(theRequest) { (responseData: NSData? , _, _) -> Void in
                data = responseData
                dispatch_semaphore_signal(semaphore)
            }.resume()
        
            dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
        
            if data == nil{
                MessageLabel.text = ""
                ValidationLabel.hidden = false
                ValidationLabel.text = "error with web service"
                return
            }
        
            //let reply = NSString(data: data!, encoding: NSUTF8StringEncoding)
            //print("Body: \(reply)")
       

            var result: AEXMLDocument?
            do {
                result = try AEXMLDocument(xmlData: data!)
            }
            catch {
                result = nil
            }
        
            if result == nil
            {
                MessageLabel.text = ""
                ValidationLabel.hidden = false
                return
            }
            let response: AEXMLElement = result!["soap:Envelope"]["soap:Body"]
        
            if response.children[0].name == "soap:Fault"
            {
                //fault code here
            }
        
            let operativeId = response["ValidateOperativeResponse"]["ValidateOperativeResult"].value
        
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
            Session.OrganistionId = operative.OrganisationId
            
            if !isRemoteAvailable
            {
                /*let alert: UIAlertView = UIAlertView()
                alert.message = "Local login only"
                alert.title = "No remote"
                alert.delegate = delegate
                alert.addButtonWithTitle("Ok")
                alert.show()*/
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
        //therefore we must bring down the operative synchinisation package to ensure operatives are updated
        if newOperative {
            let synchronisationDate: NSDate = NSDate(dateString: "2000-Jan-01 00:00:00")
            let lastRowId: String = "00000000-0000-0000-0000-000000000000"
            let stage: String = "9"
            var count: Int32 = 0
        
            while (lastRowId != "00000000-0000-0000-0000-000000000000" || count == 0) {
                count += 1
                let data: NSData? = Utility.getSynchronisationPackage(Session.OperativeId!, synchronisationDate: synchronisationDate, lastRowId: lastRowId, stage: stage)

                if data == nil{
                    MessageLabel.text = ""
                    ValidationLabel.hidden = false
                    ValidationLabel.text = "error with web service"
                    return
                }
            }
        }
        
        
        
        //Synchronous call, but this may be skipped is we are fetching data in the back ground
        //Session.SynchroniseData()
        
        //Code to dismiss the login screen and go to the main taks screen
        
    }

    
}
