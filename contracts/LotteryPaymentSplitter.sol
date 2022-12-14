// SPDX-License-Identifier: MIT
// An example of a consumer contract that relies on a subscription for funding.
pragma solidity ^0.8.7;

import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";
import "@openzeppelin/contracts/finance/PaymentSplitter.sol";

/**
 * THIS IS AN EXAMPLE CONTRACT THAT USES HARDCODED VALUES FOR CLARITY.
 * THIS IS AN EXAMPLE CONTRACT THAT USES UN-AUDITED CODE.
 * DO NOT USE THIS CODE IN PRODUCTION.
 */

contract LotteryPaymentSplitter is VRFConsumerBaseV2 {
  VRFCoordinatorV2Interface COORDINATOR;
  PaymentSplitter paymentSplitter;

  // Your subscription ID.
  uint64 s_subscriptionId;

  // Goerli coordinator. For other networks,
  // see https://docs.chain.link/docs/vrf-contracts/#configurations
  address vrfCoordinator = 0x2Ca8E0C643bDe4C2E08ab1fA0da3401AdAD7734D;

  // The gas lane to use, which specifies the maximum gas price to bump to.
  // For a list of available gas lanes on each network,
  // see https://docs.chain.link/docs/vrf-contracts/#configurations
  bytes32 keyHash = 0x79d3d8832d904592c0bf9818b621522c988bb8b0c05cdc3b15aea1b6e8db0c15;

  // Depends on the number of requested values that you want sent to the
  // fulfillRandomWords() function. Storing each word costs about 20,000 gas,
  // so 100,000 is a safe default for this example contract. Test and adjust
  // this limit based on the network that you select, the size of the request,
  // and the processing of the callback request in the fulfillRandomWords()
  // function.git 
  uint32 callbackGasLimit = 2000000;

  // The default is 3, but you can set this higher.
  uint16 requestConfirmations = 3;

  // For this example, retrieve 2 random values in one request.
  // Cannot exceed VRFCoordinatorV2.MAX_NUM_WORDS.
  uint32 numShares;

  address[] public payees; 
  uint256[] public shares;

  uint256[] public s_randomWords;
  uint256 public s_requestId;
  address s_owner;

  constructor(uint64 subscriptionId) VRFConsumerBaseV2(vrfCoordinator) {
    COORDINATOR = VRFCoordinatorV2Interface(vrfCoordinator);
    s_owner = msg.sender;
    s_subscriptionId = subscriptionId;
  }

  // Assumes the subscription is funded sufficiently.
  function handleDeployment(address[] memory _payees) external onlyOwner {
    // Will revert if subscription is not set and funded.
    payees = _payees;
    numShares = uint32 (_payees.length);
    s_requestId = COORDINATOR.requestRandomWords(
      keyHash,
      s_subscriptionId,
      requestConfirmations,
      callbackGasLimit,
      numShares
    );
  }

  function fulfillRandomWords(
    uint256, /* requestId */
    uint256[] memory randomWords
  ) internal override {
    s_randomWords = randomWords;
    for (uint256 i = 0; i < s_randomWords.length; i++) {
      uint256 share = s_randomWords[i] % 100;
      shares.push(share);
    }
    createPaymentSplitter();
  }

  function createPaymentSplitter() internal {
    paymentSplitter = new PaymentSplitter(payees, shares);
  }

  function release(address payable _payee) public {
   paymentSplitter.release(_payee);
  }

  function releaseERC20(IERC20 token, address account) public {
    paymentSplitter.release(token, account);
  }

  function addressPaymentSplitter() public view returns(address) {
    return address(paymentSplitter);
  }

  function getTotalShares() public view returns(uint) {
        uint totalShares;
        for (uint i = 0; i < shares.length; i++) {
            totalShares = totalShares + shares[i];
        }
        return totalShares;
    }

  modifier onlyOwner() {
    require(msg.sender == s_owner);
    _;
  }
}

// Couse of Action: In the requestRandomWords function,the user must also provide the addresses and the number of shares
// 