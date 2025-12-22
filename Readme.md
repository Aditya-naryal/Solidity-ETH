🏦 Community Wallet (DAO-Style Smart Contract)

A decentralized community treasury smart contract built on Ethereum that allows contributors to collectively manage funds through on-chain governance.
Spending requests require community approvals before execution, ensuring transparency, security, and decentralization.

✨ Features

✅ ETH deposits into a shared community treasury

📝 Owner can create spending requests

🗳️ Contributors can approve spending requests (one vote per user per request)

🔐 Approval threshold required before execution

💸 Secure ETH transfer using call

🛡️ Reentrancy-safe execution (Checks–Effects–Interactions pattern)

🌐 Fully on-chain governance (no off-chain MPC or backend required)

🧠 Core Concepts Used

Solidity struct, mapping, and nested mappings

msg.sender and Ethereum execution context

DAO-style approval & execution separation

Approval tracking to prevent double voting

Secure ETH transfers using low-level call

Testnet-ready (Sepolia compatible)

📜 Smart Contract Overview
Key State Variables

owner — Deployer of the contract

spendingRequestId — Counter to track spending requests

approveThreshold — Minimum approvals required to execute a request

addressToBalance — Tracks ETH deposited by contributors

Spending Request Structure

Each spending request contains:

Description

Amount of ETH to send

Recipient address

Execution status

Approval count

🔁 Contract Workflow

Deposit ETH
Contributors deposit ETH into the contract.

Create Spending Request (Owner only)
The owner creates a request specifying:

Description

Amount

Recipient

Approve Spending Request
Contributors approve requests they support.

One approval per address per request.

Execute Spending Request
Anyone can trigger execution after approval threshold is met.

ETH is transferred securely to the recipient.

Request is marked as executed.

🔐 Security Design

✔ Approval tracking via nested mappings

✔ Prevents double approvals

✔ Prevents double execution

✔ Uses address(this).balance as source of truth

✔ Follows Checks → Effects → Interactions pattern

✔ Reverts fully on failed ETH transfer
