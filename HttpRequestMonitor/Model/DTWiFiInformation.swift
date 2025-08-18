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
 * The app uses Core Location, and has the user's authorization to use location information.
 * The app uses the NEHotspotConfiguration API to configure the current Wi-Fi network.
 * The app has active VPN configurations installed.

 An app that fails to meet any of the above requirements receives the following return value:
 * An app linked against iOS 12 or earlier receives a dictionary with pseudo-values. In this case, the SSID is Wi-Fi (or WLAN in the China region), and the BSSID is 00:00:00:00:00:00.
 * An app linked against iOS 13 or later receives NULL.

 - Important:
 To use this function, an app linked against iOS 12 or later must enable the Access WiFi Information capability in Xcode. For more information, see Access WiFi Information Entitlement. Calling this function without the entitlement always returns NULL when linked against iOS 12 or later.
*/
@MainActor
public final
class DTWiFiInformation
{
    // MARK: - Properties -
    
    public
    var SSID: String?
    
    public
    var BSSID: String?
    
    /// 取得所有 IP 地址（包含版本和介面資訊）
    public
    var detailedIPAddresses: [IPAddressInfo] {
        
        var ifaddr: UnsafeMutablePointer<ifaddrs>?
        
        guard getifaddrs(&ifaddr) == 0,
          let firstAddr = ifaddr else {
            
            return []
        }
        
        defer {
            
            freeifaddrs(ifaddr)
        }
        
        let ipAddresses: [IPAddressInfo] = {
            
            sequence(first: firstAddr, next: { $0.pointee.ifa_next })
                .lazy.map({ $0.pointee })
                .filter(self.isIPv4OrIPv6)
                .sorted(by: self.wifiThenCellularThenOther)
                .compactMap(self.createIPAddressInfo)
        }()
        
        return ipAddresses
    }
    
    /// 向後相容：僅返回 IP 地址字串陣列
    public
    var ipAddresses: [String] {
        
        return self.detailedIPAddresses.map({ $0.address })
    }
    
    /// 取得 WiFi 的 IP 地址資訊
    public
    var wifiIPAddresses: [IPAddressInfo] {
        
        return self.detailedIPAddresses.filter({ $0.interface == .wifi })
    }
    
    /// 取得行動網路的 IP 地址資訊
    public
    var cellularIPAddresses: [IPAddressInfo] {
        
        return self.detailedIPAddresses.filter({ $0.interface == .cellular })
    }
    
    /// 取得 IPv4 地址
    public
    var ipv4Addresses: [IPAddressInfo] {
        
        return self.detailedIPAddresses.filter({ $0.version == .ipv4 })
    }
    
    /// 取得 IPv6 地址
    public
    var ipv6Addresses: [IPAddressInfo] {
        
        return self.detailedIPAddresses.filter({ $0.version == .ipv6 })
    }
    
    public static
    let current: DTWiFiInformation = DTWiFiInformation()
    
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
    
    /// 取得指定介面類型的 IP 地址
    /// - Parameter interfaceType: 介面類型
    /// - Returns: 符合條件的 IP 地址陣列
    public
    func getIPAddresses(for interfaceType: IPAddressInfo.Interface) -> [IPAddressInfo]
    {
        return self.detailedIPAddresses.filter({ $0.interface == interfaceType })
    }
    
    /// 取得指定 IP 版本的地址
    /// - Parameter version: IP 版本
    /// - Returns: 符合條件的 IP 地址陣列
    public
    func getIPAddresses(for version: IPAddressInfo.Version) -> [IPAddressInfo]
    {
        return self.detailedIPAddresses.filter({ $0.version == version })
    }
    
    /// 取得主要的 IP 地址（優先順序：WiFi IPv4 > Cellular IPv4 > WiFi IPv6 > Cellular IPv6）
    public
    var primaryIPAddress: IPAddressInfo? {
        
        let sortedAddresses: [IPAddressInfo] = self.detailedIPAddresses.sorted {
            
            lhs, rhs in
            
            // WiFi 優先於 Cellular
            if lhs.interface != rhs.interface {
                
                if lhs.interface == .wifi { return true }
                if rhs.interface == .wifi { return false }
                if lhs.interface == .cellular { return true }
                if rhs.interface == .cellular { return false }
            }
            
            // IPv4 優先於 IPv6
            if lhs.version != rhs.version {
                
                return lhs.version == .ipv4
            }
            
            return false
        }
        
        return sortedAddresses.first
    }
}
    
// MARK: - Private Method -
 
private
extension DTWiFiInformation
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
        
        let ipAddress = hostname.withUnsafeBufferPointer {
            
            String(cString: $0.baseAddress!)
        }
        guard !ipAddress.isEmpty else {
            
            return nil
        }
        
        return ipAddress
    }
    
    /// 建立完整的 IP 地址資訊
    /// - Parameter interface: ifaddrs 結構
    /// - Returns: IPAddressInfo 或 nil
    func createIPAddressInfo(fromInterface interface: ifaddrs) -> IPAddressInfo?
    {
        guard let address: String = self.readableString(fromInterface: interface) else {
            
            return nil
        }
        
        let familyName: UInt8 = interface.ifa_addr.pointee.sa_family
        let interfaceName: String = String(cString: interface.ifa_name)
        
        let version: IPAddressInfo.Version = {
            
            switch familyName {
                
                case UInt8(AF_INET):
                    return .ipv4
                    
                case UInt8(AF_INET6):
                    return .ipv6
                    
                default:
                    return .ipv4 // 預設值，雖然理論上不會到達這裡
            }
        }()
        
        let networkInterface: IPAddressInfo.Interface = IPAddressInfo.Interface.from(interfaceName: interfaceName)
        
        let ipAddressInfo = IPAddressInfo(address: address, version: version, interface: networkInterface, interfaceName: interfaceName)
        
        return ipAddressInfo
    }
}

private
struct IPAddress
{
    static
    let cellular: String = "pdp_ip0"
    
    static
    let wifi: String = "en0"
    
    static
    let loopback: String = "lo0"
    
    static
    let ipv4: String = "ipv4"
    
    static
    let ipv6: String = "ipv6"
}

public
extension DTWiFiInformation
{
    struct IPAddressInfo
    {
        // MARK: - Properties -
        
        public
        let address: String
        
        public
        let version: Version
        
        public
        let interface: Interface
        
        public
        let interfaceName: String
        
        public
        var displayDescription: String {
            
            return "\(self.address) (\(self.version.description) - \(self.interface.description))"
        }
    }
}

public
extension DTWiFiInformation.IPAddressInfo
{
    enum Version: String, CaseIterable
    {
        case ipv4 = "IPv4"
        case ipv6 = "IPv6"
        
        public
        var description: String {
            
            return self.rawValue
        }
    }
    
    enum Interface: String, CaseIterable
    {
        case wifi = "WiFi"
        
        case cellular = "Cellular"
        
        case ethernet = "Ethernet"
        
        case loopback = "Loopback"
        
        case other = "Other"
        
        public
        var description: String {
            
            return self.rawValue
        }
        
        static
        func from(interfaceName: String) -> Interface
        {
            switch interfaceName {
                
            case IPAddress.wifi:
                return .wifi
                
            case IPAddress.cellular:
                return .cellular
                
            case IPAddress.loopback:
                return .loopback
                
            case let name where name.hasPrefix("en") && name != "en0":
                return .ethernet
                
            default:
                return .other
            }
        }
    }
}
