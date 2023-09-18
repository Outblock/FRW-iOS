//
//  CadenceTemplate+ChildAccount.swift
//  Flow Reference Wallet
//
//  Created by cat on 2023/8/3.
//

import Foundation

extension CadenceTemplate {
    //
    static let accessibleCollection = """
    import HybridCustody from 0xHybridCustody
    import MetadataViews from 0xMetadataViews
    import FungibleToken from 0xFungibleToken
    import NonFungibleToken from 0xNonFungibleToken

    pub struct CollectionDisplay {
      pub let name: String
      pub let squareImage: String
      pub let mediaType: String

      init(name: String, squareImage: String, mediaType: String) {
        self.name = name
        self.squareImage = squareImage
        self.mediaType = mediaType
      }
    }

    pub struct NFTCollection {
      pub let id: String
      pub let path: String
      pub let display: CollectionDisplay?
      pub let idList: [UInt64]

      init(id:String, path: String, display: CollectionDisplay?, idList: [UInt64]) {
        self.id = id
        self.path = path
        self.display = display
        self.idList = idList
      }
    }

    pub fun getDisplay(address: Address, path: StoragePath): CollectionDisplay? {
      let account = getAuthAccount(address)
      let resourceType = Type<@AnyResource>()
      let vaultType = Type<@FungibleToken.Vault>()
      let collectionType = Type<@NonFungibleToken.Collection>()
      let metadataViewType = Type<@AnyResource{MetadataViews.ResolverCollection}>()
      var item: CollectionDisplay? =  nil

        if let type = account.type(at: path) {
          let isResource = type.isSubtype(of: resourceType)
          let isNFTCollection = type.isSubtype(of: collectionType)
          let conformedMetadataViews = type.isSubtype(of: metadataViewType)

          var tokenIDs: [UInt64] = []
          if isNFTCollection && conformedMetadataViews {
            if let collectionRef = account.borrow<&{MetadataViews.ResolverCollection, NonFungibleToken.CollectionPublic}>(from: path) {
              tokenIDs = collectionRef.getIDs()

              // TODO: move to a list
              if tokenIDs.length > 0
              && path != /storage/RaribleNFTCollection
              && path != /storage/ARTIFACTPackV3Collection
              && path != /storage/ArleeScene {
                let resolver = collectionRef.borrowViewResolver(id: tokenIDs[0])
                if let display = MetadataViews.getNFTCollectionDisplay(resolver) {
                  item = CollectionDisplay(
                    name: display.name,
                    squareImage: display.squareImage.file.uri(),
                    mediaType: display.squareImage.mediaType
                  )
                }
              }
            }
          }
        }

      return item
    }

    pub fun main(parent: Address, childAccount: Address): [NFTCollection] {
        let manager = getAuthAccount(parent).borrow<&HybridCustody.Manager>(from: HybridCustody.ManagerStoragePath) ?? panic ("manager does not exist")

        // Address -> Collection Type -> ownedNFTs

        let providerType = Type<Capability<&{NonFungibleToken.Provider}>>()
        let collectionType: Type = Type<@{NonFungibleToken.CollectionPublic}>()

        // Iterate through child accounts

        let acct = getAuthAccount(childAccount)
        let foundTypes: [Type] = []
        let nfts: {String: [UInt64]} = {}
        let collectionList: [NFTCollection] = []
        let childAcct = manager.borrowAccount(addr: childAccount) ?? panic("child account not found")
        
        // get all private paths
        acct.forEachPrivate(fun (path: PrivatePath, type: Type): Bool {
            // Check which private paths have NFT Provider AND can be borrowed
            if !type.isSubtype(of: providerType){
                return true
            }
            if let cap = childAcct.getCapability(path: path, type: Type<&{NonFungibleToken.Provider}>()) {
                let providerCap = cap as! Capability<&{NonFungibleToken.Provider}>

                if !providerCap.check(){
                    // if this isn't a provider capability, exit the account iteration function for this path
                    return true
                }
                foundTypes.append(cap.borrow<&AnyResource>()!.getType())
            }
            return true
        })

        // iterate storage, check if typeIdsWithProvider contains the typeId, if so, add to nfts
        acct.forEachStored(fun (path: StoragePath, type: Type): Bool {

            if foundTypes == nil {
                return true
            }

            for idx, value in foundTypes {
                let value = foundTypes!

                if value[idx] != type {
                    continue
                } else {
                    if type.isInstance(collectionType) {
                        continue
                    }
                    if let collection = acct.borrow<&{NonFungibleToken.CollectionPublic}>(from: path) {
                        nfts.insert(key: type.identifier, collection.getIDs())
                        collectionList.append(
                          NFTCollection(
                            id: type.identifier,
                            path: path.toString(),
                            display: getDisplay(address: childAccount, path: path),
                            idList: collection.getIDs()
                          )
                        )
                    }
                    continue
                }
            }
            return true
        })

        return collectionList
    }
    """
}

//MARK: Query Single ChildAcccount  Accessible FT collection
extension CadenceTemplate {
    static let accessibleFT = """
    import HybridCustody from 0xHybridCustody
    import MetadataViews from 0xMetadataViews
    import FungibleToken from 0xFungibleToken
    import NonFungibleToken from 0xNonFungibleToken

    pub struct TokenInfo {
      pub let id: String
      pub let balance: UFix64

      init(id: String, balance: UFix64) {
        self.id = id
        self.balance = balance
      }
    }

    pub fun main(parent: Address, childAddress: Address): [TokenInfo] {
        let manager = getAuthAccount(parent).borrow<&HybridCustody.Manager>(from: HybridCustody.ManagerStoragePath) ?? panic ("manager does not exist")

        var typeIdsWithProvider: {Address: [Type]} = {}

        var coinInfoList: [TokenInfo] = []
        let providerType = Type<Capability<&{FungibleToken.Provider}>>()
        let vaultType: Type = Type<@FungibleToken.Vault>()

        // Iterate through child accounts

            let acct = getAuthAccount(childAddress)
            let foundTypes: [Type] = []
            let vaultBalances: {String: UFix64} = {}
            let childAcct = manager.borrowAccount(addr: childAddress) ?? panic("child account not found")
            // get all private paths
            acct.forEachPrivate(fun (path: PrivatePath, type: Type): Bool {
                // Check which private paths have NFT Provider AND can be borrowed
                if !type.isSubtype(of: providerType){
                    return true
                }
                if let cap = childAcct.getCapability(path: path, type: Type<&{FungibleToken.Provider}>()) {
                    let providerCap = cap as! Capability<&{FungibleToken.Provider}>

                    if !providerCap.check(){
                        // if this isn't a provider capability, exit the account iteration function for this path
                        return true
                    }
                    foundTypes.append(cap.borrow<&AnyResource>()!.getType())
                }
                return true
            })
            typeIdsWithProvider[childAddress] = foundTypes

            // iterate storage, check if typeIdsWithProvider contains the typeId, if so, add to vaultBalances
            acct.forEachStored(fun (path: StoragePath, type: Type): Bool {

                if typeIdsWithProvider[childAddress] == nil {
                    return true
                }

                for key in typeIdsWithProvider.keys {
                    for idx, value in typeIdsWithProvider[key]! {
                        let value = typeIdsWithProvider[key]!

                        if value[idx] != type {
                            continue
                        } else {
                            if type.isInstance(vaultType) {
                                continue
                            }
                            if let vault = acct.borrow<&FungibleToken.Vault>(from: path) {
                                coinInfoList.append(
                                  TokenInfo(id: type.identifier, balance: vault.balance)
                                )
                            }
                            continue
                        }
                    }
                }
                return true
            })
        
        return coinInfoList
    }
    """
}
