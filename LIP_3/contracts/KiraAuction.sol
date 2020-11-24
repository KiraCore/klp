pragma solidity 0.6.2;

import 'openzeppelin-solidity/contracts/token/ERC20/ERC20.sol';
import 'openzeppelin-solidity/contracts/access/Ownable.sol';
import 'openzeppelin-solidity/contracts/math/SafeMath.sol';

/**
 * @title KiraAuction
 * @dev Liquidity Auction Contract for the final round of the KEX token distribution.
 *
 * The Liquidity Auction works in the similar fashion to the Polkadot Reverse Dutch auction
 * with the difference that in case of oversubscription all tokens that overflowed the hard
 * cap would be used to add liquidity to the uniswap or as MM war chest in case of listing
 * to support price on the market.
 *
 * Reverse Dutch auction starts with a very very high initial valuation that cannot possibly
 * be fulfilled and decreases towards predefined valuation at predefined rate. Auction ends
 * instantly if value of assets deposited is greater or equals to the valuation, or if auction
 * times out.
 */

contract KiraAuction is Ownable {
    using SafeMath for uint256;

    /* 
        Configurable
        P1, P2, P3, T1, T2, Auction Start, Tx rate limiting, Tx size per time limit, whitelist
    */

    struct UserInfo {
        bool whitelisted;
        uint256 claimed_wei;
        uint256 last_deposit_time;
        bool claimed;
        bool distributed;
    }

    uint256 public startTime;
    uint256 private P1;
    uint256 private P2;
    uint256 private P3;
    uint256 private T1;
    uint256 private T2;
    uint256 private MIN_WEI;
    uint256 private MAX_WEI;
    uint256 private INTERVAL_LIMIT;
    uint256 private totalWeiAmount;
    uint256 public latestPrice;

    address payable public wallet;
    bool public isFinished;
    ERC20 private kiraToken;
    mapping(address => UserInfo) private customers;
    address[] private arrayAddress;

    // Events
    event AuctionConfigured(uint256 _startTime);
    event WhitelistConfigured(address[] addrs, bool allow);
    event ProcessedBuy(address addr, uint256 amount);
    event ClaimedTokens(address addr, uint256 amount);
    event DistributeTokens(uint256 distributedAmount);
    event WithdrawedFunds(address _wallet, uint256 ethAmount, uint256 kexAmount);

    // MODIFIERS

    modifier onlyInProgress() {
        require(startTime != 0, 'KiraAuction: start time is not configured yet. So not in progress.');
        require((startTime <= now) && (now <= startTime + T1 + T2), 'KiraAuction: it is out of processing period.');
        uint256 cap = _getCurrentCap();
        require(cap >= totalWeiAmount, 'KiraAuction: overflowed the cap, so it is ended');
        _;
    }

    modifier onlyBeforeAuction() {
        require(startTime == 0 || (now < startTime), 'KiraAuction: should be before auction starts');
        _;
    }

    modifier onlyAfterAuction() {
        uint256 cap;
        if (isFinished == false) {
            cap = _getCurrentCap();
        }
        require(
            isFinished || (startTime != 0 && ((startTime + T1 + T2 < now) || (cap < totalWeiAmount))),
            'KiraAuction: should be after auction ends'
        );
        if (isFinished == false) {
            isFinished = true;
        }
        _;
    }

    // Constructor

    constructor(address _kiraTokenAddr) public {
        kiraToken = ERC20(_kiraTokenAddr);
        wallet = msg.sender;
    }

    // External Views

    function getTokenContractAddress() external view returns (address) {
        return address(kiraToken);
    }

    function totalDeposited() external view returns (uint256) {
        return totalWeiAmount;
    }

    function whitelisted(address addr) external view returns (bool) {
        return customers[addr].whitelisted;
    }

    function getCustomerInfo(address addr)
        external
        view
        returns (
            bool,
            uint256,
            uint256,
            bool,
            bool
        )
    {
        UserInfo storage customer = customers[addr];
        return (customer.whitelisted, customer.claimed_wei, customer.last_deposit_time, customer.claimed, customer.distributed);
    }

    function getAuctionConfigInfo()
        external
        view
        returns (
            uint256,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256
        )
    {
        return (startTime, P1, P2, P3, T1, T2, INTERVAL_LIMIT, MIN_WEI, MAX_WEI);
    }

    // Internal

    function _getCurrentAuctionPrice() internal returns (uint256) {
        /*     ^
            P1 |        *
               |        '*
               |        ' *
               |        '  *
            P2 |        '   *
               |        '   '   *
               |        '   '       *
               |        '   '           *
            P3 |        '   '               *
               |        '   '               '   
               |--------|---|---------------|------------------> Timeline
                          T1       T2
        */

        uint256 price = 0;

        if ((startTime <= now) && (now < startTime + T1)) {
            // Slope 1
            // y = p1 - (x * (p1 - p2) / t1)

            uint256 x = now - startTime;
            uint256 delta = x.mul(P1 - P2).div(T1);

            price = P1.sub(delta);
        } else if ((startTime + T1 <= now) && (now <= startTime + T1 + T2)) {
            // Slope 2
            // y = p2 - (x * (p2 - p3) / t2)
            uint256 x = now - startTime - T1;
            uint256 delta = x.mul(P2 - P3).div(T2);

            price = P2.sub(delta);
        }

        return price;
    }

    function _getCurrentCap() internal returns (uint256) {
        uint256 price = _getCurrentAuctionPrice();
        uint256 exp = 10**uint256(kiraToken.decimals());
        uint256 numberOfTokens = kiraToken.balanceOf(address(this)).div(exp);
        uint256 cap = price.mul(numberOfTokens);

        return cap;
    }

    function getAvailableClaimAmount() external onlyAfterAuction returns (uint256) {
        UserInfo memory customer = customers[msg.sender];
        require(customer.whitelisted && (customer.claimed_wei > 0), 'KiraAuction: you did not contribute.');
        require(!customer.claimed, 'KiraAuction: you already claimed.');
        require(!customer.distributed, 'KiraAuction: we already sent to your wallet.');

        uint256 exp = 10**uint256(kiraToken.decimals());
        uint256 amountToClaim = customer.claimed_wei.mul(exp).div(latestPrice);
        return amountToClaim;
    }

    // Auction Config Method only for owner. only before auction

    function setTokenContract(address _kiraTokenAddr) external onlyOwner onlyBeforeAuction {
        kiraToken = ERC20(_kiraTokenAddr);
    }

    function setWallet(address payable _wallet) external onlyOwner onlyBeforeAuction {
        wallet = _wallet;
    }

    function configAuction(
        uint256 _startTime,
        uint256 _p1,
        uint256 _p2,
        uint256 _p3,
        uint256 _t1,
        uint256 _t2,
        uint256 _txIntervalLimit,
        uint256 _txMinWeiAmount,
        uint256 _txMaxWeiAmount
    ) external onlyOwner onlyBeforeAuction {
        require(_startTime > now, 'KiraAuction: start time should be greater than now');
        require((_p1 > _p2) && (_p2 > _p3) && (_p3 >= 0), 'KiraAuction: price should go decreasing.');
        require(
            _t2 > _t1 && _t1 > 0,
            'KiraAuction: the first slope should have faster decreasing rate and the period of each slope should be greater than zero'
        );
        require(_txMaxWeiAmount > 0, 'KiraAuction: the maximum amount per tx should be valid');

        startTime = _startTime;
        P1 = _p1;
        P2 = _p2;
        P3 = _p3;
        T1 = _t1;
        T2 = _t2;
        INTERVAL_LIMIT = _txIntervalLimit;
        MIN_WEI = _txMinWeiAmount;
        MAX_WEI = _txMaxWeiAmount;

        emit AuctionConfigured(startTime);
    }

    function whitelist(address[] calldata addrs, bool allow) external onlyOwner onlyBeforeAuction {
        for (uint256 i = 0; i < addrs.length; i++) {
            address addr = addrs[i];
            require(addr != address(0), 'KiraAuction: not be able to whitelist/blacklist address(0).');

            customers[addr].whitelisted = allow;
        }

        emit WhitelistConfigured(addrs, allow);
    }

    // only in progress

    receive() external payable {
        _processBuy(msg.sender, msg.value);
    }

    function _processBuy(address beneficiary, uint256 weiAmount) private onlyInProgress {
        require(beneficiary != address(0), 'KiraAuction: Not zero address');
        require(beneficiary != owner(), 'KiraAuction: Not owner');
        require(customers[beneficiary].whitelisted, "KiraAuction: You're not whitelisted, wait a moment.");
        require(weiAmount >= MIN_WEI, 'KiraAuction: That is not enough.');
        require(weiAmount <= MAX_WEI, 'KiraAuction: That is too much.');
        require(now - customers[beneficiary].last_deposit_time >= INTERVAL_LIMIT, 'KiraAuction: it exceeds the tx rate limit');

        uint256 cap = _getCurrentCap();

        require(totalWeiAmount.add(weiAmount) < cap, 'KiraAuction: Your contribution overflows the hard cap!');

        if (customers[beneficiary].claimed_wei == 0) {
            arrayAddress.push(beneficiary);
        }

        customers[beneficiary].claimed_wei = customers[beneficiary].claimed_wei.add(weiAmount);
        customers[beneficiary].last_deposit_time = now;

        totalWeiAmount = totalWeiAmount.add(weiAmount);

        emit ProcessedBuy(beneficiary, weiAmount);

        uint256 exp = 10**uint256(kiraToken.decimals());
        uint256 numberOfTokens = kiraToken.balanceOf(address(this)).div(exp);
        latestPrice = totalWeiAmount.div(numberOfTokens);

        if (latestPrice < P3) {
            latestPrice = P3;
        }
    }

    // only after auction

    function distribute() external onlyOwner onlyAfterAuction {
        uint256 totalDistributed;
        uint256 exp = 10**uint256(kiraToken.decimals());
        uint256 numberOfContributors = arrayAddress.length;

        for (uint256 i = 0; i < numberOfContributors; i++) {
            address addr = arrayAddress[i];
            UserInfo storage customer = customers[addr];

            if (customer.claimed_wei > 0 && !customer.claimed && !customer.distributed) {
                uint256 tokensToSend = customer.claimed_wei.mul(exp).div(latestPrice);
                uint256 currentBalance = kiraToken.balanceOf(address(this));

                customer.distributed = true;

                if (currentBalance < tokensToSend) {
                    tokensToSend = currentBalance;
                }

                if (tokensToSend > 0) {
                    totalDistributed = totalDistributed.add(tokensToSend);
                    kiraToken.transfer(addr, tokensToSend);
                }
            }
        }

        require(totalDistributed > 0, 'KiraAuction: nothing to distribute. already claimed or distributed all!');

        emit DistributeTokens(totalDistributed);
    }

    function claimTokens() external onlyAfterAuction {
        UserInfo storage customer = customers[msg.sender];
        require(!customer.claimed, 'KiraAuction: you claimed already.');
        require(!customer.distributed, 'KiraAuction: we already sent to your wallet.');
        require(customer.whitelisted && (customer.claimed_wei > 0), 'KiraAuction: you did not contribute.');

        customer.claimed = true;

        uint256 exp = 10**uint256(kiraToken.decimals());
        uint256 amountToClaim = customer.claimed_wei.mul(exp).div(latestPrice);
        kiraToken.transfer(msg.sender, amountToClaim);

        emit ClaimedTokens(msg.sender, amountToClaim);
    }

    function withdrawFunds() external onlyOwner onlyAfterAuction {
        uint256 ethBalance = address(this).balance;
        uint256 kexBalance = kiraToken.balanceOf(address(this));
        require(ethBalance > 0 || kexBalance > 0, 'KiraAuction: nothing left to withdraw');

        if (ethBalance > 0) {
            wallet.transfer(ethBalance);
        }
        if (kexBalance > 0) {
            kiraToken.transfer(wallet, kexBalance);
        }

        emit WithdrawedFunds(wallet, ethBalance, kexBalance);
    }
}