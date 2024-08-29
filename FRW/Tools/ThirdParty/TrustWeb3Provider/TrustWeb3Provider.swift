// Copyright © 2017-2022 Trust Wallet.
//
// This file is part of Trust. The full Trust copyright notice, including
// terms governing use, modification, and redistribution, is contained in the
// file LICENSE at the root of the source code distribution tree.

import Foundation
import WebKit

public struct TrustWeb3Provider {
    public struct Config: Equatable {
        public let ethereum: EthereumConfig

        public init(
            ethereum: EthereumConfig
        ) {
            self.ethereum = ethereum
        }

        public struct EthereumConfig: Equatable {
            public let address: String
            public let chainId: Int
            public let rpcUrl: String

            public init(address: String, chainId: Int, rpcUrl: String) {
                self.address = address
                self.chainId = chainId
                self.rpcUrl = rpcUrl
            }
        }
    }

    private class dummy {}
    private let filename = "trust-min"    
    public static let scriptHandlerName = "_tw_"
    public let config: Config

    public var providerJsUrl: URL {
        return Bundle.main.url(forResource: filename, withExtension: "js")!
    }

    public var providerScript: WKUserScript {
        let source = try! String(contentsOf: providerJsUrl)
        return WKUserScript(source: source, injectionTime: .atDocumentStart, forMainFrameOnly: false)
    }

    public var injectScript: WKUserScript {
        let source = """
        (function() {
            const config = {
                ethereum: {
                    address: "\(config.ethereum.address)",
                    chainId: \(config.ethereum.chainId),
                    rpcUrl: "\(config.ethereum.rpcUrl)"
                }
            };

            const strategy = 'CALLBACK';

            try {
                const core = flowwallet.core(strategy, (params) => {
                     // Disabled methods
                    if (params.name === 'wallet_requestPermissions') {
                        core.sendResponse(params.id, null);
                        return;
                    }

                  webkit.messageHandlers._tw_.postMessage(params);
                });

                // Generate instances
                const ethereum = flowwallet.ethereum(config.ethereum);

                core.registerProviders([ethereum].map(provider => {
                  provider.sendResponse = core.sendResponse.bind(core);
                  provider.sendError = core.sendError.bind(core);
                  return provider;
                }));

                // Custom methods
                ethereum.emitChainChanged = (chainId) => {
                  ethereum.setChainId('0x' + parseInt(chainId || '1').toString(16));
                  ethereum.emit('chainChanged', ethereum.getChainId());
                  ethereum.emit('networkChanged', parseInt(chainId || '1'));
                };

                ethereum.setConfig = (config) => {
                  ethereum.setChainId('0x' + parseInt(config.ethereum.chainId || '1').toString(16));
                  ethereum.setAddress(config.ethereum.address);
                    if (config.ethereum.rpcUrl) {
                      ethereum.setRPCUrl(config.ethereum.rpcUrl);
                    }
                };
                // End custom methods

                cosmos.mode = 'extension';
                cosmos.providerNetwork = 'cosmos';
                cosmos.isKeplr = true;
                cosmos.version = "0.12.106";

                cosmos.enable = (chainIds)  => {
                  console.log(`==> enabled for ${chainIds}`);
                };

                // Attach to window
                flowwallet.ethereum = ethereum;

                window.ethereum = flowwallet.ethereum;

                const getDefaultCosmosProvider = (chainId) => {
                  return flowwallet.cosmos.getOfflineSigner(chainId);
                };

                window.getOfflineSigner = getDefaultCosmosProvider;
                window.getOfflineSignerOnlyAmino = getDefaultCosmosProvider;
                window.getOfflineSignerAuto = getDefaultCosmosProvider;

                Object.assign(window.flowwallet, {
                  isFlow: true,
                  isflowwallet: true,
                  request: ethereum.request.bind(ethereum),
                  send: ethereum.send.bind(ethereum),
                  on: (...params) => ethereum.on(...params),
                  off: (...params) => ethereum.off(...params),
                });

                const provider = ethereum;
                const proxyMethods = ['chainId', 'networkVersion', 'address', 'enable', 'send'];

                // Attach properties to flowwallet object (legacy props)
                const proxy = new Proxy(window.flowwallet, {
                  get(target, prop, receiver) {
                    if (proxyMethods.includes(prop)) {
                      switch (prop) {
                        case 'chainId':
                          return ethereum.getChainId.bind(provider);
                        case 'networkVersion':
                          return ethereum.getNetworkVersion.bind(provider);
                        case 'address':
                          return ethereum.getAddress.bind(provider);
                        case 'enable':
                          return ethereum.enable.bind(provider);
                        case 'send':
                          return ethereum.send.bind(provider);
                      }
                    }

                    return Reflect.get(target, prop, receiver);
                  },
                });

                window.flowwallet = proxy;

                const EIP6963Icon =
                'data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iMjUwIiBoZWlnaHQ9IjI1MCIgdmlld0JveD0iMCAwIDI1MCAyNTAiIGZpbGw9Im5vbmUiIHhtbG5zPSJodHRwOi8vd3d3LnczLm9yZy8yMDAwL3N2ZyI+CjxnIGNsaXAtcGF0aD0idXJsKCNjbGlwMF8xMzc2MV8zNTIxKSI+CjxyZWN0IHdpZHRoPSIyNTAiIGhlaWdodD0iMjUwIiByeD0iNDYuODc1IiBmaWxsPSJ3aGl0ZSIvPgo8ZyBjbGlwLXBhdGg9InVybCgjY2xpcDFfMTM3NjFfMzUyMSkiPgo8cmVjdCB3aWR0aD0iMjUwIiBoZWlnaHQ9IjI1MCIgZmlsbD0idXJsKCNwYWludDBfbGluZWFyXzEzNzYxXzM1MjEpIi8+CjxwYXRoIGQ9Ik0xMjUgMjE3LjUyOUMxNzYuMTAyIDIxNy41MjkgMjE3LjUyOSAxNzYuMTAyIDIxNy41MjkgMTI1QzIxNy41MjkgNzMuODk3NSAxNzYuMTAyIDMyLjQ3MDcgMTI1IDMyLjQ3MDdDNzMuODk3NSAzMi40NzA3IDMyLjQ3MDcgNzMuODk3NSAzMi40NzA3IDEyNUMzMi40NzA3IDE3Ni4xMDIgNzMuODk3NSAyMTcuNTI5IDEyNSAyMTcuNTI5WiIgZmlsbD0id2hpdGUiLz4KPHBhdGggZD0iTTE2NS4zODIgMTEwLjQyMkgxMzkuNTg1VjEzNi43OEgxNjUuMzgyVjExMC40MjJaIiBmaWxsPSJibGFjayIvPgo8cGF0aCBkPSJNMTEzLjIyNyAxMzYuNzhIMTM5LjU4NVYxMTAuNDIySDExMy4yMjdWMTM2Ljc4WiIgZmlsbD0iIzQxQ0M1RCIvPgo8L2c+CjwvZz4KPGRlZnM+CjxsaW5lYXJHcmFkaWVudCBpZD0icGFpbnQwX2xpbmVhcl8xMzc2MV8zNTIxIiB4MT0iMCIgeTE9IjAiIHgyPSIyNTAiIHkyPSIyNTAiIGdyYWRpZW50VW5pdHM9InVzZXJTcGFjZU9uVXNlIj4KPHN0b3Agc3RvcC1jb2xvcj0iIzFDRUI4QSIvPgo8c3RvcCBvZmZzZXQ9IjEiIHN0b3AtY29sb3I9IiM0MUNDNUQiLz4KPC9saW5lYXJHcmFkaWVudD4KPGNsaXBQYXRoIGlkPSJjbGlwMF8xMzc2MV8zNTIxIj4KPHJlY3Qgd2lkdGg9IjI1MCIgaGVpZ2h0PSIyNTAiIHJ4PSI0Ni44NzUiIGZpbGw9IndoaXRlIi8+CjwvY2xpcFBhdGg+CjxjbGlwUGF0aCBpZD0iY2xpcDFfMTM3NjFfMzUyMSI+CjxyZWN0IHdpZHRoPSIyNTAiIGhlaWdodD0iMjUwIiBmaWxsPSJ3aGl0ZSIvPgo8L2NsaXBQYXRoPgo8L2RlZnM+Cjwvc3ZnPgo=';

                const info = {
                  uuid: crypto.randomUUID(),
                  name: 'Flow Wallet',
                  icon: EIP6963Icon,
                  rdns: 'com.flowfoundation.wallet',
                };

                const announceEvent = new CustomEvent('eip6963:announceProvider', {
                  detail: Object.freeze({ info, provider: ethereum }),
                });

                window.dispatchEvent(announceEvent);

                window.addEventListener('eip6963:requestProvider', () => {
                   window.dispatchEvent(announceEvent);
                });
            } catch (e) {
              console.error(e)
            }
        })();
        """
        return WKUserScript(source: source, injectionTime: .atDocumentStart, forMainFrameOnly: false)
    }

    public init(config: Config) {
        self.config = config
    }
}
