//
//  LNUrl.swift
//  lightninglink
//
//  Created by William Casarin on 2022-03-12.
//

import Foundation

public enum Bech32Type {
    case bech32
    case bech32m
}

public struct Bech32 {
    let hrp: String
    let dat: Data
    let type: Bech32Type
}

func decode_bech32(_ str: String) -> Bech32? {
    let hrp_buf = UnsafeMutableBufferPointer<CChar>.allocate(capacity: str.count)
    let bits_buf = UnsafeMutableBufferPointer<UInt8>.allocate(capacity: str.count)
    let data_buf = UnsafeMutableBufferPointer<UInt8>.allocate(capacity: str.count)
    var bitslen: Int = 0
    var datalen: Int = 0
    var m_hrp_str: String? = nil
    var m_data: Data? = nil
    var typ: bech32_encoding = BECH32_ENCODING_NONE

    hrp_buf.withMemoryRebound(to: UInt8.self) { hrp_ptr in
    str.withCString { input in
        typ = bech32_decode(hrp_ptr.baseAddress, bits_buf.baseAddress, &bitslen, input, str.count)
        bech32_convert_bits(data_buf.baseAddress, &datalen, 8, bits_buf.baseAddress, bitslen, 5, 0)
        m_data = Data(buffer: data_buf)[...(datalen-1)]
        m_hrp_str = String(cString: hrp_ptr.baseAddress!)
    }
    }

    guard let hrp = m_hrp_str else {
        return nil
    }

    guard let data = m_data else {
        return nil
    }

    var m_type: Bech32Type? = nil
    if typ == BECH32_ENCODING_BECH32 {
        m_type = .bech32
    } else if typ == BECH32_ENCODING_BECH32M {
        m_type = .bech32m
    }

    guard let type = m_type else {
        return nil
    }

    return Bech32(hrp: hrp, dat: data, type: type)
}
