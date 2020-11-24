<div align="center">
  <h1>Kira Liquidity Program</h1>
  <h2>Improvement Proposals & Documentation</h2>
  <br/>  
</div>

## LIP_1

**Ethereum ERC20 KEX Placeholder Token for easy market access**

_NOTE: The owner of the contract has the privilege of whitelisting and blacklisting accounts, effectively enabling or disabling them from sending and receiving tokens. The operator also has the option of freezing token transfers for all accounts that are not explicitly whitelisted. To learn more about Transaction Ordering Dependence and    Allowance Double-Spend possibility see attached Audit Report_

* [Deployment Documentation](./LIP_1/README.md)
* [Application Binary Interface](./LIP_1/ABI.json)
* [Improvement Proposal](https://github.com/KiraCore/docs/blob/master/spec/liquidity-program/lip_1.md)
* [Token Logo 256x256](./LIP_1/doc/KEX-256x256.png)
* [Audit Report](./LIP_1/audit.pdf)

![picture 1](./LIP_1/doc/KEX-256x256.png)  

### Contract Address

```
-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA512

KIRA Network Token Contract Address:
0x16980b3B4a3f9D89E33311B5aa8f80303E5ca4F8

 Network: Ethereum
    Type: ERC20
  Symbol: KEX
Decimals: 6

ABI SHA256 Checksum:
fb5e62096b77a189c980629af882281de55f330ada0eae544c7df5adb086f560  ABI.json

NOTE: 
* This token will be swapped for the mainnet KIRA Network Token 
* Before interacting with the contract verify signature of the kiracore user at https://keybase.io/verify
-----BEGIN PGP SIGNATURE-----
Version: Keybase OpenPGP v2.1.13
Comment: https://keybase.io/crypto

wsBcBAABCgAGBQJfihOJAAoJEMd1XMN/y97LjYoH/i0dUWOzAA03Ij128A88IBW8
UnqnG1F6pVqIoJEQ5W6mMktn2OXa6Z37utGdY53sLZDSvI25kTzT6HxLf7g6L2/F
g3tUoyXLKP8N0mfrjWLDZTF6Trk6K4wspQfjnK+jYEmJP0Zi9W78NMbMgBy0kK+Q
2wKinOVCj5A3/gbcs4pG45KWPwrDIHXT2k0HaIc2qeGO3qsNaJqZusZsb86llqqv
qFniFaFo7S/n7tbPmu6rAcd9o3AjZoZ74M5wa7LpL0WK6KAdPbQXXvhDQFIDD1bx
RWTopxNIGH2njxWuafRX8gi0AYlSTBmOaFtR9ztTZCVVWXTDrTIn73hkeNiBJAY=
=a0YF
-----END PGP SIGNATURE-----

```

## LIP_3

**Liquidity Auction**

* [Deployment Documentation](./LIP_3/README.md)
* [Application Binary Interface](./LIP_3/ABI.json)
* [Improvement Proposal](https://github.com/KiraCore/docs/blob/master/spec/liquidity-program/lip_3.md)
* [Audit Report](./LIP_3/audit.pdf)
  
### Contract Address

```
-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA512

KIRA Network Liquidity Auction Contract Address:
0x297fF490bdd3bc80eB30397108823D2D6aB53Db6

         Network: Ethereum
    Auction Type: Hard & Soft CAP LastBid Dutch Auction with Whitelist
   Auction Start: 25/11/2020 15:00:00 UTC
 Accepted Tokens: ETH
Available Tokens: 4'000'000 ERC20 KEX (0x1698...a4F8)
        Soft CAP: $300'000 (fixed rate)
  Whitelist Form: https://whitelist.kira.network

ABI SHA256 Checksum:
d7e25c736a66a1c22f7dd3aff0e972025eee0fe5cbbffb820951b4fd0d78fe28  ABI.json
-----BEGIN PGP SIGNATURE-----
Version: Keybase OpenPGP v2.1.13
Comment: https://keybase.io/crypto

wsBcBAABCgAGBQJftu0VAAoJEMd1XMN/y97L2JIH/1GRsOPDzMx2ryggcjM1meQ/
W/jW3Avp9mkAYwUhhMqh+r1jtAK8LHwyPgCysyxFpshMEXfVyWVvDt3/fDtfOwt7
IujS5sJUOD4omV7lQBldH8W2MtjpPo9kCxhOgJ9aoclvwzmI81bXtemapUriORQ+
qye8WTpPtFLUhFE8mxqbR8ffMlxGOpylgcUT8iHPwLbBcagXI5rj6Pk0zt2oMQ13
0+n2rnjjneHMQg6duopjJnBPZzvlDQe+rFgpVsEAyyOtuBM5+VitAdGHNC48kLG+
yGJXeQ6ROtU8klONsrg5R33L7ooAjNcqZoR3nnt2jLVFfjrz8WG3W0dK/PHAEgg=
=3qNY
-----END PGP SIGNATURE-----
```

## LIP_3.2

**Ethereum Address Balance Caching Service**

_NOTE: Caching service is an AWS lambda function which stores information regarding ethereum account balances in the function of block height and time. Intended use of this service is the LIP_3.1 which must operate as static page without dependency on any API._

* [Deployment Documentation](./LIP_3.2/README.md)
* [Public S3 Bucket](https://oracle.kira.network/)
* [Configuration File](https://github.com/KiraCore/cfg/blob/main/EthereumOracle/env-mainnet)
* [Improvement Proposal](https://github.com/KiraCore/docs/blob/master/spec/liquidity-program/lip_3.2.md)