# Vapor Market
**Decentralised funding, marketplace and licensing (DRM) platform for Web3 games and applications.**

# Overview
Vapor market is a platform that allows teams/individuals to create funding campaigns and issue DRM licenses for their Web3 enabled games and applications. Fundraising and issuance of ERC721 licenses is done through Ethereum smart contracts, everything else that’s displayed in a store listing is hosted on IPFS.

In this version of Vapor Market, we have an ‘Early Access’ campaign deployed. This campaign is designed to allow content creators to issue discounted licenses to consumers in an effort to gauge interest in their product and project initial sales revenue. When the specified time period is up, the price increases to the regular sales price, the creator is able to withdraw funds from the contract and the campaign continues indefinitely. 

End users participate in the ‘Early Access’ stage of these campaigns in a similar fashion to a standard ICO however, when they contribute their ETH, it’s locked into the contract until this period is over. During this time, they’re able to return their license and get their ETH back in a ‘try before you buy’ fashion. This caveat incentivises active development during the early stages of the project and gives early supporters exit options incase development efforts are below their level of satisfaction. 

The license is issued to the user’s wallet and while they’re in possession of it, they’re able to access the content locked behind the Vapor Market DRM. Given the nature of the ERC721 standard, users are able to transfer these licenses between each other or sell them on third party markets.

## How to run the project
The smart contracts have been set up to compile and run with truffle. The front end was created with `vuejs` and `elementsUI`. The project has been tested on: Windows 10, Arch Linux and Ubuntu 16.04 and run successfully on all platforms without errors. 

**To interact with the dapp, you can skip the truffle steps and jump directly to `npm run serve` after `npm install` as the contracts have been deployed on the Rinkeby Testnet. No further configuration is required after pointing Metamask to the correct testnet.**

Requirements to run the project are: `Node>=8.11`,`npm` and `truffle`. To begin with, we need to install all required libraries and utilities. From the root of the repo, run:

    npm install

Contracts have been deployed to the Rinkeby. Addresses can be found in `deployed_addresses.txt` To interact with the contracts on the local machine, run a local test blockchain on 8545 and then:
  
    truffle compile
    truffle test
    truffle migrate

To test code coverage, from the root directory, run:
    
    npm run coverage

Lastly, to interact with Dapp, from the root directory, after running `npm install`, run:
      
    npm run serve

The Dapp(same as in screenshots below) should open up on your local machine.

## Why
We can approach this by looking at the two main components of Vapor Market.

**Marketplace**

A lot of distribution platforms take fees off the top, enable censorship, suffer from accessibility problems (region etc) or do not allow/have the tools available for developers to effectively raise funds during the early development stages. Vapor Market alleviates a lot of these problems through being a decentralised and transparent platform.

**DRM and Licensing**

This is problem that faces but developers and users. Developers want to protect their IP and to do that, users are often subjected to cumbersome or ineffective proprietary DRM solutions. Ontop of that, these licenses are often locked to one user and are non-transferable. Vapor Market’s DRM solution is both lightweight and allows for users to maintain ownership over their purchased content (in that if they decide to transfer or sell the license, it is entirely possible for them to do so).

## Benefits

**1. Novel p2p monetisation -** There are a lack of platforms beyond direct donation that enables funding of projects that do not present financial/economic value to the end user. Vapor Market provides monetisation avenues for less tangible forms of value in the Web3 space.

**2. Early gauging of market viability -** Developers are able to gain insight into the demand for their product, project initial sales revenue and gain an early userbase for testing and feedback prior to the full launch.

**3. Piracy deterrent -** Because a user’s private is used to store and validate the license, they’re dis-incentivised to share the key. If it’s shared, they risk having it stolen and potentially sold.

**4. Transferable -** The ERC721 standard enables the user to transfer or even resell their licenses if they so choose. Particularly in the context of games, this is a valuable trait as once a user has obtained all the value they can from the product, they’re able to recoup their costs and pass it onto someone else that can get value from it.

**5. Private -** There are no servers involved in the license validation process so the user can be assured they’re not being tracked. Ownership of the token is validated directly through their Web3 enabled wallet.

**6. Scarcity -** The number of licenses available for sale can be as plentiful or as limited as the product developer wants.

## Improvements

Given that this was developed over 24 hours, there are obviously a lot of improvements that can be made and quite a few features that we were not able to tackle.

**UX/UI**

Implementation of ENS domains through Universal Logins and possibly utilising Meta Transactions to reduce onboarding friction would be a hugely positive addition. Especially given that content producers shouldn’t have to be experts in the Ethereum ecosystem to derive value from Vapor Market.

Cleaner UI for both campaign management and the marketplace itself, bringing it more inline with other distribution platforms such as Steam.

Error displays.

**Features**

We wanted to implement some different funding mechanisms but unfortunately ran out of time. These included: straight to sale (users purchase a license at a set price) and scaling prices (as more licenses are purchased, the more expensive they become).

Community features such as forums, comments and ratings.

Curation (DAO styled voting) features to ensure that the content that is featured on the market is of high quality and bad actors can be removed from the equation. 

Non-Web3 implementation of license verification e.g. local video game is verified through an Metamask but the application is not hosted in the browser.

Marketplace for reselling of licenses and in game assets.

We basically wanted it to be the Web3 equivalent of Steam.
