<template>
  <div class="hello">
  <el-row>
    <el-col :span="16" :offset="4">
      <el-card>
<p>Vapor market is a platform that allows teams/individuals to create funding campaigns and issue DRM licenses for their Web3 enabled games and applications. Fundraising and issuance of ERC721 licenses is done through Ethereum smart contracts, everything else that’s displayed in a store listing is hosted on IPFS.
<br>
<br>
In this version of Vapor Market, we have an ‘Early Access’ campaign deployed. This campaign is designed to allow content creators to issue discounted licenses to consumers in an effort to gauge interest in their product and project initial sales revenue. When the specified time period is up, the price increases to the regular sales price, the creator is able to withdraw funds from the contract and the campaign continues indefinitely.
<br>
<br>
End users participate in the ‘Early Access’ stage of these campaigns in a similar fashion to a standard ICO however, when they contribute their ETH, it’s locked into the contract until this period is over. During this time, they’re able to return their license and get their ETH back in a ‘try before you buy’ fashion. This caveat incentivises active development during the early stages of the project and gives early supporters exit options incase development efforts are below their level of satisfaction.
<br>
<br>
The license is issued to the user’s wallet and while they’re in possession of it, they’re able to access the content locked behind the Vapor Market DRM. Given the nature of the ERC721 standard, users are able to transfer these licenses between each other or sell them on third party markets.</p>
      </el-card>
    </el-col>
  </el-row>
  </div>
</template>

<script>
export default {
  name: 'HelloWorld',
  props: {
    msg: String
  }
}
</script>

<!-- Add "scoped" attribute to limit CSS to this component only -->
<style scoped lang="scss">
h3 {
  margin: 40px 0 0;
}
ul {
  list-style-type: none;
  padding: 0;
}
li {
  display: inline-block;
  margin: 0 10px;
}
a {
  color: #42b983;
}
</style>
