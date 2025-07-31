---
title: Web3-React 构建以太坊 DApp 的 React 框架
date: 2024-04-21 23:07:02
categories:
  - Blockchain Development
  - Smart Contracts
tags:
  - Blockchain
  - Smart Contracts
  - web3-react
---

## Web3-React

Web3-React 是由 Uniswap 团队开发的一个简洁、可扩展的 React 框架，专门用于构建现代以太坊去中心化应用（DApp）。

## 特性

### 1. 广泛的钱包支持

Web3-React 支持几乎所有主流的 Web3 钱包和连接方式：

- **浏览器钱包**: MetaMask、Trust Wallet、Tokenary
- **硬件钱包**: Trezor、Ledger
- **基础设施提供商**: Infura、QuickNode
- **钱包连接协议**: WalletConnect

### 2. 模块化架构

框架采用连接器（Connector）模式，每个钱包类型都有对应的连接器。这种设计使得添加新的钱包类型变得非常简单，同时保持了代码的整洁性。

### 3. TypeScript 原生支持

Web3-React 从底层就支持 TypeScript，提供了完整的类型定义，让开发过程更加安全和高效。

## 快速上手

### 安装

```bash
npm install @web3-react/core @web3-react/injected-connector @web3-react/walletconnect-connector
```

### 基础配置

```jsx
import { Web3ReactProvider } from "@web3-react/core";
import { Web3Provider } from "@ethersproject/providers";

function getLibrary(provider) {
  const library = new Web3Provider(provider);
  library.pollingInterval = 12000;
  return library;
}

function MyApp({ Component, pageProps }) {
  return (
    <Web3ReactProvider getLibrary={getLibrary}>
      <Component {...pageProps} />
    </Web3ReactProvider>
  );
}
```

### 连接 MetaMask

```jsx
import { useWeb3React } from "@web3-react/core";
import { InjectedConnector } from "@web3-react/injected-connector";

const injected = new InjectedConnector({
  supportedChainIds: [1, 3, 4, 5, 42, 137], // 支持的链ID
});

function WalletConnection() {
  const { active, account, library, connector, activate, deactivate } =
    useWeb3React();

  const connect = async () => {
    try {
      await activate(injected);
    } catch (ex) {
      console.log(ex);
    }
  };

  const disconnect = () => {
    try {
      deactivate();
    } catch (ex) {
      console.log(ex);
    }
  };

  return (
    <div>
      {active ? (
        <div>
          <p>连接地址: {account}</p>
          <button onClick={disconnect}>断开连接</button>
        </div>
      ) : (
        <button onClick={connect}>连接MetaMask</button>
      )}
    </div>
  );
}
```

## 高级特性与最佳实践

### 1. 多钱包支持

在实际项目中，我们通常需要支持多种钱包。这里是一个完整的多钱包连接器配置：

```jsx
import { InjectedConnector } from "@web3-react/injected-connector";
import { WalletConnectConnector } from "@web3-react/walletconnect-connector";
import { WalletLinkConnector } from "@web3-react/walletlink-connector";

const POLLING_INTERVAL = 12000;
const RPC_URLS = {
  1: process.env.REACT_APP_MAINNET_RPC_URL,
  4: process.env.REACT_APP_RINKEBY_RPC_URL,
};

export const injected = new InjectedConnector({
  supportedChainIds: [1, 3, 4, 5, 42, 137],
});

export const walletconnect = new WalletConnectConnector({
  rpc: { 1: RPC_URLS[1] },
  qrcode: true,
  pollingInterval: POLLING_INTERVAL,
});

export const walletlink = new WalletLinkConnector({
  url: RPC_URLS[1],
  appName: "Your DApp Name",
  appLogoUrl: "https://your-logo-url.com",
});
```

### 2. 错误处理

```jsx
import { useWeb3React } from "@web3-react/core";
import { useEffect, useState } from "react";

function useEagerConnect() {
  const { activate, active } = useWeb3React();
  const [tried, setTried] = useState(false);

  useEffect(() => {
    injected.isAuthorized().then((isAuthorized) => {
      if (isAuthorized) {
        activate(injected, undefined, true).catch(() => {
          setTried(true);
        });
      } else {
        setTried(true);
      }
    });
  }, [activate]);

  useEffect(() => {
    if (!tried && active) {
      setTried(true);
    }
  }, [tried, active]);

  return tried;
}

function useInactiveListener(suppress = false) {
  const { active, error, activate } = useWeb3React();

  useEffect(() => {
    const { ethereum } = window;

    if (ethereum && ethereum.on && !active && !error && !suppress) {
      const handleConnect = () => {
        activate(injected);
      };
      const handleChainChanged = (chainId) => {
        activate(injected);
      };
      const handleAccountsChanged = (accounts) => {
        if (accounts.length > 0) {
          activate(injected);
        }
      };

      ethereum.on("connect", handleConnect);
      ethereum.on("chainChanged", handleChainChanged);
      ethereum.on("accountsChanged", handleAccountsChanged);

      return () => {
        ethereum.removeListener("connect", handleConnect);
        ethereum.removeListener("chainChanged", handleChainChanged);
        ethereum.removeListener("accountsChanged", handleAccountsChanged);
      };
    }
  }, [active, error, suppress, activate]);
}
```

### 3. 智能合约交互

```jsx
import { useWeb3React } from "@web3-react/core";
import { Contract } from "@ethersproject/contracts";
import { useEffect, useState } from "react";

const ERC20_ABI = [
  "function balanceOf(address owner) view returns (uint256)",
  "function transfer(address to, uint256 amount) returns (bool)",
];

function TokenBalance({ tokenAddress }) {
  const { library, account } = useWeb3React();
  const [balance, setBalance] = useState();

  useEffect(() => {
    if (library && account && tokenAddress) {
      const contract = new Contract(tokenAddress, ERC20_ABI, library);

      contract
        .balanceOf(account)
        .then((balance) => {
          setBalance(balance.toString());
        })
        .catch((err) => {
          console.error(err);
        });
    }
  }, [library, account, tokenAddress]);

  return <div>{balance ? `余额: ${balance}` : "加载中..."}</div>;
}
```

## 实际项目应用案例

### DeFi 协议集成

```jsx
import { useWeb3React } from "@web3-react/core";
import { parseEther } from "@ethersproject/units";

function DeFiInterface() {
  const { library, account } = useWeb3React();

  const handleStake = async (amount) => {
    if (!library || !account) return;

    const signer = library.getSigner();
    const contract = new Contract(
      STAKING_CONTRACT_ADDRESS,
      STAKING_ABI,
      signer
    );

    try {
      const tx = await contract.stake({
        value: parseEther(amount),
      });
      await tx.wait();
      console.log("质押成功!");
    } catch (error) {
      console.error("质押失败:", error);
    }
  };

  return (
    <div>
      <button onClick={() => handleStake("1.0")}>质押 1 ETH</button>
    </div>
  );
}
```

通常用于：

- 流动性挖矿平台：用户质押代币获得奖励
- 质押协议：以太坊 2.0 质押
- DeFi 收益农场：质押代币或单币获得收益

## 常见问题与解决方案

### 1. 网络切换

```jsx
const switchNetwork = async (chainId) => {
  try {
    await library.provider.request({
      method: "wallet_switchEthereumChain",
      params: [{ chainId: `0x${chainId.toString(16)}` }],
    });
  } catch (switchError) {
    if (switchError.code === 4902) {
      // 网络不存在，需要添加
      await library.provider.request({
        method: "wallet_addEthereumChain",
        params: [networkParams[chainId]],
      });
    }
  }
};
```

### 2. 连接状态管理

使用 React Context 来全局管理连接状态，避免 prop drilling：

```jsx
const Web3Context = createContext();

export const useWeb3Context = () => {
  const context = useContext(Web3Context);
  if (!context) {
    throw new Error("useWeb3Context must be used within Web3Provider");
  }
  return context;
};
```
