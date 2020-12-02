import Web3 from 'web3'
import { provider } from 'web3-core'
import { AbiItem } from 'web3-utils'
import KiraAuctionAbi from '../kira/lib/abi/kira_auction.json'

export const getContract = (provider: provider, address: string) => {
  const web3 = new Web3(provider)
  const contract = new web3.eth.Contract(
    (KiraAuctionAbi as unknown) as AbiItem,
    address,
  )
  return contract
}

export const getAuctionConfig = async (
  provider: provider,
  contractAddress: string,
): Promise<string> => {
  const auctionContract = getContract(provider, contractAddress)
  try {
    const auctionConfig: string = await auctionContract.methods
      .getAuctionConfigInfo()
      .call()
    return auctionConfig
  } catch (e) {
    return '0'
  }
}

export const claimTokens = async (
  provider: provider,
  contractAddress: string,
): Promise<any> => {
  const auctionContract = getContract(provider, contractAddress)
  try {
    const result = await auctionContract.methods.claimTokens().call()
    return result;
  } catch (e) {
    console.log(e);
    return false;
  }
}

export const getBalanceData = async (
  oracle: string,
  networkId: string,
  address: string
): Promise<any> => {
  try { 
    const targetURL = `${oracle}/balances/eth/${networkId}/${address.toLowerCase()}/cache.json`;
    const response = await fetch(targetURL, {
      headers: {
        'Accept': 'application/json',
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Expose-Headers': 'Content-Length',
        'Content-Type': 'application/json',
      },
      method: 'GET',
    });
    
    return response.json()
  } catch (e) {
    return null
  }
}
