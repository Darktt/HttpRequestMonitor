//
//  IPAddress.swift
//  Fluxo
//
//  Created by Eden on 2025/8/19.
//

import SystemConfiguration

func getIPAddress() -> String?
{
    guard let store = SCDynamicStoreCreate(nil, "IPFetcher" as CFString, nil, nil),
          let global = SCDynamicStoreCopyValue(store, "State:/Network/Global/IPv4" as CFString) as? [String: Any],
          let primary = global["PrimaryInterface"] as? String,
          let ipv4 = SCDynamicStoreCopyValue(store, "State:/Network/Interface/\(primary)/IPv4" as CFString) as? [String: Any],
          let addresses = ipv4["Addresses"] as? [String],
          let address = addresses.first
    else {
        return nil
    }
    
    return address
}
