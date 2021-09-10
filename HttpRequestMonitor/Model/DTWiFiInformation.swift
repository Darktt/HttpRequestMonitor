//
//  DTWiFiInformation.swift
//
//  Created by Darktt on 17/3/13.
//  Copyright © 2017 Darktt. All rights reserved.
//

import Foundation
import SystemConfiguration.CaptiveNetwork

/**
 Query WiFi information, like SSID or BSSID

 The requesting app must meet one of the following requirements:
 * The app uses Core Location, and has the user’s authorization to use location information.
 * The app uses the NEHotspotConfiguration API to configure the current Wi-Fi network.
 * The app has active VPN configurations installed.

 An app that fails to meet any of the above requirements receives the following return value:
 * An app linked against iOS 12 or earlier receives a dictionary with pseudo-values. In this case, the SSID is Wi-Fi (or WLAN in the China region), and the BSSID is 00:00:00:00:00:00.
 * An app linked against iOS 13 or later receives NULL.

 - Important:
 To use this function, an app linked against iOS 12 or later must enable the Access WiFi Information capability in Xcode. For more information, see Access WiFi Information Entitlement. Calling this function without the entitlement always returns NULL when linked against iOS 12 or later.
*/
public final class DTWiFiInformation
{
    // MARK: - Properties -
    
    public var SSID: String?
    
    public var BSSID: String?
    
    public var ipAddresses: [String] {
        
        var ifaddr: UnsafeMutablePointer<ifaddrs>?
        
        guard getifaddrs(&ifaddr) == 0,
          let firstAddr = ifaddr else {
            
            return []
        }
        
        defer {
            
            freeifaddrs(ifaddr)
        }
        
        let ipAddresses: [String] = {
            
            sequence(first: firstAddr, next: { $0.pointee.ifa_next })
                .lazy.map({ $0.pointee })
                .filter(self.isIPv4OrIPv6)
                .sorted(by: self.wifiThenCellularThenOther)
                .compactMap(self.readableString)
        }()
        
        return ipAddresses
    }
    
    public static let current: DTWiFiInformation = DTWiFiInformation()
    
    // MARK: - Methods -
    // MARK: Initial Method
    
    private init()
    {
        guard let SSIDInfo: Dictionary<String, Any> = self.fetchInformation() else {
            
            return
        }
        
        let SSID = SSIDInfo[kCNNetworkInfoKeySSID as String] as? String
        let BSSID = SSIDInfo[kCNNetworkInfoKeyBSSID as String] as? String
        
        self.SSID = SSID
        self.BSSID = BSSID
    }
}
    
// MARK: - Private Method -
 
private extension DTWiFiInformation
{
    func fetchInformation() -> Dictionary<String, Any>?
    {
        guard let interfaceNames: Array<String> = CNCopySupportedInterfaces() as? Array<String> else {
            
            return nil
        }
        
        var SSIDInfo: Dictionary<String, Any>? = nil
        for interfaceName in interfaceNames {
            
            SSIDInfo = CNCopyCurrentNetworkInfo(interfaceName as CFString) as? Dictionary<String, Any>
            
            let isNotEmpty: Bool = {
                
                guard let SSIDInfo = SSIDInfo else {
                    
                    return false
                }
                
                return SSIDInfo.count > 0
            }()
            
            if isNotEmpty {
                
                break
            }
        }
        
        return SSIDInfo
    }
    
    /// IPv4 or IPv6
    ///
    /// - Returns: true if interface pointee's sa_family matches id for ipv4 or ipv6, otherwise false
    func isIPv4OrIPv6(interface: ifaddrs) -> Bool
    {
        let familyname: UInt8 = interface.ifa_addr.pointee.sa_family
        let result: Bool = (familyname == UInt8(AF_INET) || familyname == UInt8(AF_INET6))
        
        return result
    }
    
    /// isWifiOrCellular
    ///
    /// - Parameter interface: ifaddrs
    /// - Returns: a bool if interfacename matches identifier for wifi or cellular
    func wifiThenCellularThenOther(interfaceOne one: ifaddrs, interfaceTwo two: ifaddrs) -> Bool
    {
        let name = String(cString: one.ifa_name)
        let familyname: UInt8 = one.ifa_addr.pointee.sa_family
        
        var result: Bool = (name == IPAddress.wifi || name == IPAddress.cellular)
        
        // Prefer IPv4 then IPv6
        result = result && (familyname == UInt8(AF_INET))
        
        return result
    }
    
    /// readable string from interface
    ///
    /// - Parameter interface: ifaddrs
    /// - Returns: optional string, nil if operation fails
    func readableString(fromInterface interface: ifaddrs) -> String?
    {
        var address: sockaddr = interface.ifa_addr.pointee
        var hostname: [CChar] = Array(repeating: 0, count: Int(NI_MAXHOST))
        
        getnameinfo(&address, socklen_t(interface.ifa_addr.pointee.sa_len), &hostname, socklen_t(hostname.count), nil, socklen_t(0), NI_NUMERICHOST)
        
        let ipAddress = String(cString: hostname)
        guard !ipAddress.isEmpty else {
            
            return nil
        }
        
        return ipAddress
    }
}

private struct IPAddress
{
    static let cellular: String = "pdp_ip0"
    
    static let wifi: String = "en0"
    
    static let ipv4: String = "ipv4"
    
    static let ipv6: String = "ipv6"
}
