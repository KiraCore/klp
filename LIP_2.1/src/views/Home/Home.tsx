import React, { useEffect, useState, useCallback } from 'react'
import { useWallet } from 'use-wallet'
import { provider } from 'web3-core'
import styled from 'styled-components'
import kira from '../../assets/img/kira.png'
import Button from '../../components/Button'
import Container from '../../components/Container'
import Page from '../../components/Page'
import PageHeader from '../../components/PageHeader'
import Spacer from '../../components/Spacer'
import Balances from './components/Balances'
import useFarms from '../../hooks/useFarms'
import useModal from '../../hooks/useModal'
import WalletProviderModal from '../../components/WalletProviderModal'
import useStakedLPBalance from '../../hooks/useStakedLPBalance'
import useTokenBalance from '../../hooks/useTokenBalance'

const Home: React.FC = () => {
  const [farms] = useFarms()
  const [poolId, setPoolId] = useState('');
  const { account }: { account: string; ethereum: provider } = useWallet()
  const [hasLP, setHasLP] = useState(true);

  const stakedLPBalance = useStakedLPBalance()          // USER'S LP TOKEN AMOUNT LOCED IN STAKING CONTRACT
  const tokenBalance = useTokenBalance(false) // GET LP AMOUNT IN USER'S METAMASK

  const [onPresentWalletProviderModal] = useModal(
    <WalletProviderModal />,
    'provider',
  )
  
  useEffect(() => {
    if (farms && farms[0]) {
      setPoolId(farms[0].id)
    }
  }, [farms])

  const handleUnlockClick = useCallback(() => {
    onPresentWalletProviderModal()
  }, [onPresentWalletProviderModal])

  useEffect(() => {
    console.log(`   User Staked LP: ${stakedLPBalance}`)
    console.log(`User Available LP: ${tokenBalance}`)
    setHasLP(!account || (stakedLPBalance.toNumber() > 0 || tokenBalance.toNumber() > 0) || (stakedLPBalance.toNumber() === -1 && tokenBalance.toNumber() === -1))
  }, [stakedLPBalance, tokenBalance])

  return (
    <Page>
      <PageHeader
        icon={<img src={kira} height={90} />}
        title="Kira Staking is Live!"
        subtitle={hasLP ? "Lock your KEX-ETH UNI-V2 LP tokens to earn extra APY!" : "You do not have any LP tokens yet, add ETH and KEX to the Uniswap Pool first!"}
        hasLP={hasLP}
      />
      <Container size="md">
        <Balances />
      </Container>
      <Spacer size="lg" />
      <div style={{ margin: '0 auto' }}>
        {!!account ? (
          <Button 
            text="Lock LP Tokens"
            to={`/pools/${poolId}`}
            variant="secondary"
            connected={true}
          />
        ) : (
          <Button 
            text="Connect Wallet" 
            variant="secondary"
            onClick={handleUnlockClick}
          />
        )}
      </div>
      <Spacer size="lg" />
      <div>
      {!!account ? (
        <StyledInfo>
          💡<b>Pro Tip</b>: Make sure you connected Metamask and selected "Ethereum Mainnet" network!
        </StyledInfo>
        ) : (
          <StyledInfo>
          💡<b>Pro Tip</b>: Your TVL equals to your liquidity share in the pool, the cumulative value of KEX and ETH in USD
        </StyledInfo>
          )}
      </div>
      
    </Page>
  )
}

const StyledInfo = styled.h3`
  color: ${(props) => props.theme.color.purple[500]};
  font-size: 16px;
  font-weight: 400;
  margin: 0;
  padding: 0;
  text-align: center;

  > b {
    color: ${(props) => props.theme.color.purple[600]};
  }
`

export default Home
