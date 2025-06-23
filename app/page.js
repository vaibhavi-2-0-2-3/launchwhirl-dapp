"use client";

import { useEffect, useState } from "react";
import { ethers } from "ethers";

// Components
import Header from "./components/Header";
import List from "./components/List";
import Token from "./components/Token";
import Trade from "./components/Trade";

// ABIs & Config
import Factory from "./abis/Factory.json";
import config from "./config.json";
import images from "./images.json";

export default function Home() {
  const [provider, setProvider] = useState(null);
  const [account, setAccount] = useState(null);
  const [factory, setFactory] = useState(null);
  const [fee, setFee] = useState(0);
  const [showCreate, setShowCreate] = useState(false);

  function toggleCreate() {
    showCreate ? setShowCreate(false) : setShowCreate(true);
  }

  async function loadBlockchainData() {
    // Use MetaMask for our connection
    const provider = new ethers.BrowserProvider(window.ethereum);
    setProvider(provider);

    // Get the current network
    const network = await provider.getNetwork();

    // Create reference to Factory contract
    const factory = new ethers.Contract(
      config[network.chainId].factory.address,
      Factory,
      provider
    );
    setFactory(factory);

    // Fetch the fee
    const fee = await factory.fee();
    // console.log("Fee:", fee.toString());
    setFee(fee);
  }

  useEffect(() => {
    loadBlockchainData();
  }, []);

  return (
    <div className="page">
      <Header account={account} setAccount={setAccount} />
      <main>
        <div className="create">
          <button
            onClick={factory && account && toggleCreate}
            className="btn--fancy"
          >
            {!factory
              ? "[ contract not deployed ]"
              : !account
              ? "[ please connect ]"
              : "[ start a new token ]"}
          </button>
        </div>

        {showCreate && (
          <List
            toggleCreate={toggleCreate}
            fee={fee}
            provider={provider}
            factory={factory}
          />
        )}

        {/* {showCreate && (
          <List
            toggleCreate={toggleCreate}
            fee={fee}
            provider={provider}
            factory={factory}
          />
        )}

        {showTrade && (
          <Trade
            toggleTrade={toggleTrade}
            token={token}
            provider={provider}
            factory={factory}
          />
        )} */}
      </main>
    </div>
  );
}
