//
//  TemperatureProfile.swift
//  COMPASSMOBILE Tasks
//
//  Created by Andrew Harper on 20/01/2017.
//  Copyright © 2017 HYDOP E.C.S. All rights reserved.
//

import UIKit

class TemperatureProfile
{
    fileprivate var _Count: Int = 0
    fileprivate var _Temperatures: [String] = []
    fileprivate var _Times: [String] = []
    
    
    init ()
    {
    }
    
    internal func Reset()
    {
        _Count = 0
        _Temperatures = []
        _Times = []
    }
    
    var BaseTemperature: String
    {
        get
        {
            return _Temperatures[0]
        }
    }
    
    var Count: Int
    {
        get
        {
            return _Count
        }
    }
    
    internal func AddNextTemperature(_ temperature: String, time: String)
    {
        if Count < 5
        {
            _Temperatures.append(temperature)
            _Times.append(time)
            _Count += 1
        }
    }
    
    internal func ToString()-> String
    {
        var returnValue: String = String()
        if(_Count > 0)
        {
            for loop: Int in 0..._Count-1
            {
                returnValue += loop > 0 ? ":" : ""
                returnValue += _Temperatures[loop] + "[" + _Times[loop] + "]"
            }
        }
        return returnValue
    }
    
    internal func ToStringForDisplay()-> String
    {
        var returnValue: String = String()
        if(_Count > 0)
        {
            for loop: Int in 0..._Count-1
            {
                returnValue += loop > 0 ? ", " : ""
                returnValue += _Temperatures[loop] + " @ " + _Times[loop] + "mins"
            }
        }
        return returnValue
    }
    
}
