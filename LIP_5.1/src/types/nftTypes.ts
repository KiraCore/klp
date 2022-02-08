import { BigNumber } from "@ethersproject/bignumber";

export interface NFT {
  id: number;
  staked?: boolean;
  stakedBalance?: number;
  unstakedBalance?: number;
}

export interface NFTAttributes {
  trait_type: string;
  value: string;
}

export interface NFTMetadata {
  name: string;
  description: string;
  image: string;
  animation_url?: string;
  attributes: NFTAttributes[];
}

export interface NFTCollection {
  title: string;
  description: string;
  nfts: NFT[];
}

export interface Card {
  metadata: NFTMetadata;
  quantity: number;
  sold: number;
  value: BigNumber;
}

export interface Owned {
  stakedBalance?: number;
  unstakedBalance?: number;
}