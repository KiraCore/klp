import BigNumber from 'bignumber.js/bignumber'

export const SUBTRACT_GAS_LIMIT = 100000

const ONE_MINUTE_IN_SECONDS = new BigNumber(60)
const ONE_HOUR_IN_SECONDS = ONE_MINUTE_IN_SECONDS.times(60)
const ONE_DAY_IN_SECONDS = ONE_HOUR_IN_SECONDS.times(24)
const ONE_YEAR_IN_SECONDS = ONE_DAY_IN_SECONDS.times(365)

export const INTEGERS = {
  ONE_MINUTE_IN_SECONDS,
  ONE_HOUR_IN_SECONDS,
  ONE_DAY_IN_SECONDS,
  ONE_YEAR_IN_SECONDS,
  ZERO: new BigNumber(0),
  ONE: new BigNumber(1),
  ONES_31: new BigNumber('4294967295'), // 2**32-1
  ONES_127: new BigNumber('340282366920938463463374607431768211455'), // 2**128-1
  ONES_255: new BigNumber(
    '115792089237316195423570985008687907853269984665640564039457584007913129639935',
  ), // 2**256-1
  INTEREST_RATE_BASE: new BigNumber('1e18'),
}

// New Contract: 0x1De160a97879e4E8D98864219A2A32FdDaBf2851
// Old Contract: 0xa9C21f3201741b4d31C9b7934c21f671aA0Fd0B5
export const contractAddresses = {
  kira: {  // KEX Smart Contract Address
    42: '0x41379EF961492a594F91bB0F966c2CeD32B49544',
  },
  kiraAuction: {
    // 42: '0xa9C21f3201741b4d31C9b7934c21f671aA0Fd0B5',
    42: '0x1De160a97879e4E8D98864219A2A32FdDaBf2851'
  }
}
