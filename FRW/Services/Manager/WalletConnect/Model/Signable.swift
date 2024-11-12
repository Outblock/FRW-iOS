//
//  Signable.swift
//  Flow Wallet
//
//  Created by Hao Fu on 30/7/2022.
//

import BigInt
import Combine
import Flow
import Foundation

// MARK: - FCLError

public enum FCLError: String, Error, LocalizedError {
    case generic
    case invaildURL
    case invaildService
    case invalidSession
    case declined
    case invalidResponse
    case decodeFailure
    case unauthenticated
    case missingPreAuthz
    case missingPayer
    case encodeFailure
    case convertToTxFailure
    case invaildProposer
    case fetchAccountFailure

    // MARK: Public

    public var errorDescription: String? {
        rawValue
    }
}

// MARK: - SignableMessage

struct SignableMessage: Codable {
    let addr: String
//    let data: [String: String]?
    let message: String
}

// MARK: - Signable

struct Signable: Codable {
    // MARK: Lifecycle

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.fType = try container.decode(String.self, forKey: .fType)
        self.fVsn = try container.decode(String.self, forKey: .fVsn)
        self.data = try? container.decode([String: String].self, forKey: .data)
        self.message = try container.decode(String.self, forKey: .message)
        self.keyId = try? container.decode(Int.self, forKey: .keyId)
        self.addr = try? container.decode(String.self, forKey: .addr)
        self.roles = try container.decode(Role.self, forKey: .roles)
        self.cadence = try? container.decode(String.self, forKey: .cadence)
        self.args = try container.decode([Flow.Argument].self, forKey: .args)

//        voucher = try container.decode(Voucher.self, forKey: .voucher)
//        interaction = try container.decode(Interaction.self, forKey: .interaction)
    }

    // MARK: Internal

    enum CodingKeys: String, CodingKey {
        case fType = "f_type"
        case fVsn = "f_vsn"
        case roles, data, message, keyId, addr, cadence, args
    }

    var fType: String = "Signable"
    var fVsn: String = "1.0.1"
    var data: [String: String]?
    let message: String
    let keyId: Int?
    let addr: String?
    let roles: Role
    let cadence: String?
    let args: [Flow.Argument]
    var interaction = Interaction()

    var voucher: Voucher {
        let insideSigners: [Singature] = interaction.findInsideSigners.compactMap { id in
            guard let account = interaction.accounts[id] else { return nil }
            return Singature(
                address: account.addr?.sansPrefix(),
                keyId: account.keyID,
                sig: account.signature
            )
        }

        let outsideSigners: [Singature] = interaction.findOutsideSigners.compactMap { id in
            guard let account = interaction.accounts[id] else { return nil }
            return Singature(
                address: account.addr?.sansPrefix(),
                keyId: account.keyID,
                sig: account.signature
            )
        }

        return Voucher(
            cadence: interaction.message.cadence,
            refBlock: interaction.message.refBlock,
            computeLimit: interaction.message.computeLimit,
            arguments: interaction.message.arguments.compactMap { tempId in
                interaction.arguments[tempId]?.asArgument
            },
            proposalKey: interaction.createProposalKey(),
            payer: interaction.accounts[interaction.payer ?? ""]?.addr?.sansPrefix(),
            authorizers: interaction.authorizations
                .compactMap { cid in interaction.accounts[cid]?.addr?.sansPrefix() }
                .uniqued(),
            payloadSigs: insideSigners,
            envelopeSigs: outsideSigners
        )
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(fType, forKey: .fType)
        try container.encode(fVsn, forKey: .fVsn)
        try container.encode(data, forKey: .data)
        try container.encode(message, forKey: .message)
        try container.encode(keyId, forKey: .keyId)
        try container.encode(roles, forKey: .roles)
        try container.encode(cadence, forKey: .cadence)
        try container.encode(addr, forKey: .addr)
        try container.encode(args, forKey: .args)
//        try container.encode(interaction, forKey: .interaction)
//        try container.encode(voucher, forKey: .voucher)
    }
}

// MARK: - PreSignable

struct PreSignable: Encodable {
    enum CodingKeys: String, CodingKey {
        case fType = "f_type"
        case fVsn = "f_vsn"
        case roles, cadence, args, interaction
        case voucher
    }

    let fType: String = "PreSignable"
    let fVsn: String = "1.0.1"
    let roles: Role
    let cadence: String
    var args: [Flow.Argument] = []
    let data = [String: String]()
    var interaction = Interaction()

    var voucher: Voucher {
        let insideSigners: [Singature] = interaction.findInsideSigners.compactMap { id in
            guard let account = interaction.accounts[id] else { return nil }
            return Singature(
                address: account.addr,
                keyId: account.keyID,
                sig: account.signature
            )
        }

        let outsideSigners: [Singature] = interaction.findOutsideSigners.compactMap { id in
            guard let account = interaction.accounts[id] else { return nil }
            return Singature(
                address: account.addr,
                keyId: account.keyID,
                sig: account.signature
            )
        }

        return Voucher(
            cadence: interaction.message.cadence,
            refBlock: interaction.message.refBlock,
            computeLimit: interaction.message.computeLimit,
            arguments: interaction.message.arguments.compactMap { tempId in
                interaction.arguments[tempId]?.asArgument
            },
            proposalKey: interaction.createProposalKey(),
            payer: interaction.payer,
            authorizers: interaction.authorizations
                .compactMap { cid in interaction.accounts[cid]?.addr }
                .uniqued(),
            payloadSigs: insideSigners,
            envelopeSigs: outsideSigners
        )
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(fType, forKey: .fType)
        try container.encode(fVsn, forKey: .fVsn)
        try container.encode(roles, forKey: .roles)
        try container.encode(cadence, forKey: .cadence)
        try container.encode(args, forKey: .args)
        try container.encode(interaction, forKey: .interaction)
        try container.encode(voucher, forKey: .voucher)
    }
}

// MARK: - Argument

struct Argument: Codable {
    var kind: String
    var tempId: String
    var value: Flow.Cadence.FValue
    var asArgument: Flow.Argument
    var xform: Xform
}

// MARK: - Xform

struct Xform: Codable {
    var label: String
}

extension Flow.Argument {
    func toFCLArgument() -> Argument {
        func randomString(length: Int) -> String {
            let letters = "abcdefghijklmnopqrstuvwxyz0123456789"
            return String((0..<length).map { _ in letters.randomElement()! })
        }

        return Argument(
            kind: "ARGUMENT",
            tempId: randomString(length: 10),
            value: value,
            asArgument: self,
            xform: Xform(label: type.rawValue)
        )
    }
}

// MARK: - Interaction

struct Interaction: Codable {
    enum Status: String, CaseIterable, Codable {
        case ok = "OK"
        case bad = "BAD"
    }

    enum Tag: String, CaseIterable, Codable {
        case unknown = "UNKNOWN"
        case script = "SCRIPT"
        case transaction = "TRANSACTION"
        case getTransactionStatus = "GET_TRANSACTION_STATUS"
        case getAccount = "GET_ACCOUNT"
        case getEvents = "GET_EVENTS"
        case getLatestBlock = "GET_LATEST_BLOCK"
        case ping = "PING"
        case getTransaction = "GET_TRANSACTION"
        case getBlockById = "GET_BLOCK_BY_ID"
        case getBlockByHeight = "GET_BLOCK_BY_HEIGHT"
        case getBlock = "GET_BLOCK"
        case getBlockHeader = "GET_BLOCK_HEADER"
        case getCollection = "GET_COLLECTION"
    }

    var tag: Tag = .unknown
    var assigns = [String: String]()
    var status: Status = .ok
    var reason: String?
    var accounts = [String: SignableUser]()
    var params = [String: String]()
    var arguments = [String: Argument]()
    var message = Message()
    var proposer: String?
    var authorizations = [String]()
    var payer: String?
    var events = Events()
    var transaction = Id()
    var block = Block()
    var account = Account()
    var collection = Id()

    var isUnknown: Bool { `is`(.unknown) }
    var isScript: Bool { `is`(.script) }
    var isTransaction: Bool { `is`(.transaction) }

    var findInsideSigners: [String] {
        // Inside Signers Are: (authorizers + proposer) - payer
        var inside = Set(authorizations)
        if let proposer = proposer {
            inside.insert(proposer)
        }
        if let payer = payer {
            inside.remove(payer)
        }
        return Array(inside)
    }

    var findOutsideSigners: [String] {
        // Outside Signers Are: (payer)
        guard let payer = payer else {
            return []
        }
        let outside = Set([payer])
        return Array(outside)
    }

    func `is`(_ tag: Tag) -> Bool {
        self.tag == tag
    }

    @discardableResult
    mutating func setTag(_ tag: Tag) -> Self {
        self.tag = tag
        return self
    }

    func createProposalKey() -> ProposalKey {
        guard let proposer = proposer,
              let account = accounts[proposer]
        else {
            return ProposalKey()
        }

        return ProposalKey(
            address: account.addr?.sansPrefix(),
            keyID: account.keyID,
            sequenceNum: account.sequenceNum
        )
    }

    func createFlowProposalKey() async throws -> Flow.TransactionProposalKey {
        guard let proposer = proposer,
              var account = accounts[proposer],
              let address = account.addr,
              let keyID = account.keyID
        else {
            throw FCLError.invaildProposer
        }

        let flowAddress = Flow.Address(hex: address)

        if account.sequenceNum == nil {
            let accountData = try await flow.accessAPI.getAccountAtLatestBlock(address: flowAddress)
            account.sequenceNum = Int(accountData.keys[keyID].sequenceNumber)
            return Flow.TransactionProposalKey(
                address: Flow.Address(hex: address),
                keyIndex: keyID,
                sequenceNumber: Int64(account.sequenceNum ?? 0)
            )
        }

        return Flow.TransactionProposalKey(
            address: Flow.Address(hex: address),
            keyIndex: keyID,
            sequenceNumber: Int64(account.sequenceNum ?? 0)
        )
    }

    func buildPreSignable(role: Role) -> PreSignable {
        PreSignable(
            roles: role,
            cadence: message.cadence ?? "",
            args: message.arguments
                .compactMap { tempId in arguments[tempId]?.asArgument },
            interaction: self
        )
    }
}

extension Interaction {
    func toFlowTransaction() async throws -> Flow.Transaction {
        let proposalKey = try await createFlowProposalKey()

        guard let payerAccount = payer,
              let payerAddress = accounts[payerAccount]?.addr
        else {
            throw FCLError.missingPayer
        }

        var tx = Flow.Transaction(
            script: Flow.Script(text: message.cadence ?? ""),
            arguments: message.arguments
                .compactMap { tempId in arguments[tempId]?.asArgument },
            referenceBlockId: Flow.ID(hex: message.refBlock ?? ""),
            gasLimit: BigUInt(message.computeLimit ?? 100),
            proposalKey: proposalKey,
            payer: Flow.Address(hex: payerAddress),
            authorizers: authorizations
                .compactMap { cid in accounts[cid]?.addr }
                .uniqued()
                .compactMap { Flow.Address(hex: $0) }
        )

        let insideSigners = findInsideSigners
        for address in insideSigners {
            if let account = accounts[address],
               let address = account.addr,
               let keyId = account.keyID,
               let signature = account.signature {
                tx.addPayloadSignature(
                    address: Flow.Address(hex: address),
                    keyIndex: keyId,
                    signature: Data(signature.hexValue)
                )
            }
        }

        let outsideSigners = findOutsideSigners

        for address in outsideSigners {
            if let account = accounts[address],
               let address = account.addr,
               let keyId = account.keyID,
               let signature = account.signature {
                tx.addEnvelopeSignature(
                    address: Flow.Address(hex: address),
                    keyIndex: keyId,
                    signature: Data(signature.hexValue)
                )
            }
        }
        return tx
    }
}

// MARK: - Block

struct Block: Codable {
    var id: String?
    var height: Int64?
    var isSealed: Bool?
}

// MARK: - Account

struct Account: Codable {
    var addr: String?
}

// MARK: - Id

struct Id: Codable {
    var id: String?
}

// MARK: - Events

struct Events: Codable {
    enum CodingKeys: String, CodingKey {
        case eventType, start, end
        case blockIDS = "blockIds"
    }

    var eventType: String?
    var start: String?
    var end: String?
    var blockIDS: [String] = []
}

// MARK: - Message

struct Message: Codable {
    var cadence: String?
    var refBlock: String?
    var computeLimit: Int?
    var proposer: String?
    var payer: String?
    var authorizations: [String] = []
    var params: [String] = []
    var arguments: [String] = []
}

// MARK: - Voucher

struct Voucher: Codable {
    let cadence: String?
    let refBlock: String?
    let computeLimit: Int?
    let arguments: [Flow.Argument]
    let proposalKey: ProposalKey
    var payer: String?
    let authorizers: [String]?
    let payloadSigs: [Singature]?
    let envelopeSigs: [Singature]?

    func toFCLVoucher() -> FCLVoucher {
        let pkey = FCLVoucher.ProposalKey(
            address: Flow.Address(hex: proposalKey.address ?? ""),
            keyId: proposalKey.keyID ?? 0,
            sequenceNum: UInt64(proposalKey.sequenceNum ?? 0)
        )
        let authorArray = authorizers?.map { Flow.Address(hex: $0) } ?? [Flow.Address]()
        let payloadSigsArray = payloadSigs?.map { FCLVoucher.Signature(
            address: Flow.Address(hex: $0.address ?? ""),
            keyId: $0.keyId ?? 0,
            sig: $0.sig ?? ""
        ) } ?? [FCLVoucher.Signature]()

        let v = FCLVoucher(
            cadence: Flow.Script(text: cadence ?? ""),
            payer: Flow.Address(hex: payer ?? ""),
            refBlock: Flow.ID(hex: refBlock ?? ""),
            arguments: arguments,
            proposalKey: pkey,
            computeLimit: UInt64(computeLimit ?? 0),
            authorizers: authorArray,
            payloadSigs: payloadSigsArray
        )
        return v
    }
}

// MARK: - Accounts

struct Accounts: Codable {
    enum CodingKeys: String, CodingKey {
        case currentUser = "CURRENT_USER"
    }

    let currentUser: SignableUser
}

// MARK: - Singature

struct Singature: Codable {
    let address: String?
    let keyId: Int?
    let sig: String?
}

// MARK: - SignableUser

struct SignableUser: Codable {
    // MARK: Lifecycle

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.kind = try? container.decode(String.self, forKey: .kind)
        self.tempID = try? container.decode(String.self, forKey: .tempID)
        self.addr = try? container.decode(String.self, forKey: .addr)
        self.signature = try? container.decode(String.self, forKey: .signature)
        self.keyID = try? container.decode(Int.self, forKey: .keyID)
        self.sequenceNum = try? container.decode(Int.self, forKey: .sequenceNum)
        self.role = try container.decode(Role.self, forKey: .role)
    }

    // MARK: Internal

    enum CodingKeys: String, CodingKey {
        case kind
        case tempID = "tempId"
        case addr
        case keyID = "keyId"
        case sequenceNum, signature, role
    }

    var kind: String?
    var tempID: String?
    var addr: String?
    var signature: String?
    var keyID: Int?
    var sequenceNum: Int?
    var role: Role

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(kind, forKey: .kind)
        try container.encode(tempID, forKey: .tempID)
        try container.encode(addr, forKey: .addr)
        try container.encode(signature, forKey: .signature)
        try container.encode(keyID, forKey: .keyID)
        try container.encode(sequenceNum, forKey: .sequenceNum)
        try container.encode(role, forKey: .role)
    }
}

// MARK: - ProposalKey

struct ProposalKey: Codable {
    enum CodingKeys: String, CodingKey {
        case address
        case keyID = "keyId"
        case sequenceNum
    }

    var address: String?
    var keyID: Int?
    var sequenceNum: Int?
}

// MARK: - Role

struct Role: Codable {
    var proposer: Bool = false
    var authorizer: Bool = false
    var payer: Bool = false
    var param: Bool?

    mutating func merge(role: Role) {
        proposer = proposer || role.proposer
        authorizer = authorizer || role.authorizer
        payer = payer || role.payer
    }
}

// MARK: - NullDecodable

@propertyWrapper
struct NullDecodable<T>: Decodable where T: Decodable {
    // MARK: Lifecycle

    init(wrappedValue: T?) {
        self.wrappedValue = wrappedValue
    }

//    func encode(to encoder: Encoder) throws {
//        var container = encoder.singleValueContainer()
//        switch wrappedValue {
//        case let .some(value): try container.encode(value)
//        case .none: try container.encodeNil()
//        }
//    }

    // MARK: Internal

    var wrappedValue: T?
}

extension String {
    func sansPrefix() -> String {
        if hasPrefix("0x") || hasPrefix("Fx") {
            return String(dropFirst(2))
        }
        return self
    }

    func withPrefix() -> String {
        "0x" + sansPrefix()
    }
}

extension Array where Element: Hashable {
    func uniqued() -> [Element] {
        var seen = Set<Element>()
        return filter { seen.insert($0).inserted }
    }
}

// MARK: - BaseConfigRequest

public struct BaseConfigRequest: Codable {
    var app: [String: String]?
    var service: [String: String]?
    var client: ClientInfo?

    var appIdentifier: String?
    var accountProofNonce: String?
    var nonce: String?
}

// MARK: - ClientInfo

public struct ClientInfo: Codable {
    var fclVersion: String?
    var fclLibrary: URL?
    var hostname: String?
}
