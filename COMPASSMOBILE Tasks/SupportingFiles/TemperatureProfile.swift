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
    private var _Count: Int = 0
    private var _Temperatures: [String] = []
    private var _Times: [String] = []
    
    
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
    
    internal func AddnextTemperature(temperature: String, time: String) throws
    {
        if Count < 5
        {
            _Temperatures[Count] = temperature
            _Times[Count] = time
            _Count += 1
        }
    }
    
    internal func ToString()-> String
    {
        var returnValue: String = String()
        for loop: Int in 0..._Count
        {
            returnValue += loop > 0 ? ":" : ""
            returnValue += _Temperatures[loop] + "[" + _Times[loop] + "]"
        }
        return returnValue
    }
}
