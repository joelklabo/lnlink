//
//  QR.swift
//  lightninglink
//
//  Created by William Casarin on 2022-03-12.
//

import Foundation

public struct LNUrl {
    let encoded: Bech32
}

public enum LNScanResult {
    case lightning(DecodeType)
    case lnlink(LNLink)
    case lnurl(LNUrl)
}


func handle_qrcode(_ qr: String) -> Either<String, LNScanResult> {
    var invstr = qr.trimmingCharacters(in: .whitespacesAndNewlines)
    let lowered = invstr.lowercased()

    if lowered.starts(with: "lnlink:") {
        switch parse_auth_qr(invstr) {
        case .left(let err):
            return .left(err)
        case .right(let lnlink):
            return .right(.lnlink(lnlink))
        }
    }

    if lowered.starts(with: "lnurl") {
        guard let bech32 = decode_bech32(lowered) else {
            return .left("Invalid lnurl bech32 encoding")
        }

        return .right(.lnurl(LNUrl(encoded: bech32)))
    }

    if lowered.starts(with: "lightning:") {
        let index = invstr.index(invstr.startIndex, offsetBy: 10)
        invstr = String(lowered[index...])
    }

    guard let parsed = parseInvoiceString(invstr) else {
        return .left("Failed to parse invoice")
    }

    return .right(.lightning(parsed))
}

