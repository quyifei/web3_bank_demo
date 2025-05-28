<script setup>
import { ref } from 'vue';
import { ethers } from 'ethers';

const account = ref('');
const ethBalance = ref('');
const bankBalance = ref('');
const approveAmount = ref('');
const approveContract = ref('');
const depositAmount = ref('');
const withdrawAmount = ref('');
const transferAmount = ref('');
const transferTo = ref('');

const BANK_CONTRACT_ADDRESS = import.meta.env.VUE_APP_BANK_CONTRACT_ADDRESS;
const TOKEN_CONTRACT_ADDRESS = import.meta.env.VUE_APP_TOKEN_CONTRACT_ADDRESS;

import BANK_ABI from '../contracts/bank.abi.json';
import TOKEN_ABI from '../contracts/token.abi.json';

let bankContract;
let provider;
let signer;

async function connectWallet() {
  if (window.ethereum) {
    try {
      const accounts = await window.ethereum.request({ method: 'eth_requestAccounts' });
      account.value = accounts[0];
      
      provider = new ethers.BrowserProvider(window.ethereum);
      signer = await provider.getSigner();
      bankContract = new ethers.Contract(BANK_CONTRACT_ADDRESS, BANK_ABI, signer);
      
      await getEthBalance();
      await getBankBalance();
    } catch (error) {
      console.error(error);
    }
  } else {
    alert('Please install MetaMask!');
  }
}

async function getEthBalance() {
  if (account.value) {
    try {
      const balanceWei = await provider.getBalance(account.value);
      ethBalance.value = ethers.formatEther(balanceWei);
    } catch (error) {
      console.error('Error getting ETH balance:', error);
      ethBalance.value = 'Error';
    }
  }
}

async function getBankBalance() {
  if (account.value && bankContract) {
    const balanceWei = await bankContract.balanceOf(account.value);
    bankBalance.value = ethers.formatEther(balanceWei);
  }
}

async function approve() {
  if (!account.value || !approveAmount.value || !approveContract.value) return;
  
  try {
    const tokenContract = new ethers.Contract(TOKEN_CONTRACT_ADDRESS, TOKEN_ABI, signer);
    const tx = await tokenContract.approve(
      BANK_CONTRACT_ADDRESS,
      ethers.parseEther(String(approveAmount.value))
    );
    await tx.wait();
    approveAmount.value = '';
    approveContract.value = '';
  } catch (error) {
    console.error('Approve error:', error);
  }
}

async function deposit() {
  if (!account.value || !depositAmount.value) return;
  
  try {
    const amount = ethers.parseEther(String(depositAmount.value));
    const tx = await bankContract.deposit(amount);
    await tx.wait();
    await getBankBalance();
    depositAmount.value = '';
  } catch (error) {
    console.error('Deposit error:', error);
  }
}

async function withdraw() {
  if (!withdrawAmount.value) return;
  try {
    const amount = ethers.parseEther(String(withdrawAmount.value));
    const tx = await bankContract.withdraw(amount);
    await tx.wait();
    await getBankBalance();
    withdrawAmount.value = '';
  } catch (error) {
    console.error('Withdraw error:', error);
  }
}

async function transfer() {
  if (!transferAmount.value || !transferTo.value) return;
  try {
    const amount = ethers.parseEther(String(transferAmount.value));
    const tx = await bankContract.transfer(transferTo.value, amount);
    await tx.wait();
    await getBankBalance();
    transferAmount.value = '';
    transferTo.value = '';
  } catch (error) {
    console.error('Transfer error:', error);
  }
}
</script>

<template>
  <div class="container">
    <button @click="connectWallet" style="width: 100%">Connect Wallet</button>
    <div class="account-info" v-if="account">
      <p>Account: {{ account }}</p>
      <p class="balance">ETH Balance: {{ parseFloat(ethBalance).toFixed(8) }}</p>
      <p class="balance">Bank Balance: {{ parseFloat(bankBalance).toFixed(8) }}</p>
    </div>
    
    <div class="operation-section">
      <h3>Approve</h3>
      <div class="input-group">
        <input v-model="approveAmount" placeholder="Approve Amount" type="number" />
        <input v-model="approveContract" placeholder="Contract Address" />
        <button @click="approve">Approve</button>
      </div>
    </div>
    
    <div class="operation-section">
      <h3>Deposit</h3>
      <div class="input-group">
        <input v-model="depositAmount" placeholder="Deposit Amount" type="number" />
        <button @click="deposit">Deposit</button>
      </div>
    </div>
    
    <div class="operation-section">
      <h3>Withdraw</h3>
      <div class="input-group">
        <input v-model="withdrawAmount" placeholder="Withdraw Amount" type="number" />
        <button @click="withdraw">Withdraw</button>
      </div>
    </div>
    
    <div class="operation-section">
      <h3>Transfer</h3>
      <div class="input-group">
        <input v-model="transferAmount" placeholder="Transfer Amount" type="number" />
        <input v-model="transferTo" placeholder="Recipient Address" />
        <button @click="transfer">Transfer</button>
      </div>
    </div>
  </div>
</template>

<style scoped>
.container {
  max-width: 800px;
  margin: 0 auto;
  padding: 2rem;
  font-family: Arial, sans-serif;
}

button {
  background-color: #4CAF50;
  color: white;
  border: none;
  padding: 10px 20px;
  margin: 5px;
  border-radius: 4px;
  cursor: pointer;
  font-size: 16px;
  transition: background-color 0.3s;
  width: 120px;
}

button:hover {
  background-color: #45a049;
}

input {
  padding: 10px;
  margin: 5px;
  border: 1px solid #ddd;
  border-radius: 4px;
  font-size: 16px;
}

.input-group {
  margin: 15px 0;
  display: flex;
  align-items: center;
}

.input-group input {
  flex: 1;
}

.account-info {
  background-color: #f8f9fa;
  padding: 15px;
  border-radius: 4px;
  margin: 15px 0;
}

.balance {
  font-size: 18px;
  font-weight: bold;
  color: #2c3e50;
}

h1 {
  color: #2c3e50;
  margin-bottom: 20px;
}

.operation-section {
  background-color: #f8f9fa;
  padding: 15px;
  border-radius: 4px;
  margin: 15px 0;
}
</style>
