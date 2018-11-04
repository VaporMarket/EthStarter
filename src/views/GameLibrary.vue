<template>
  <div class="home">
    <h1>Games Library</h1>
   <el-row :gutter="20">
  <el-col :span="8">
    <el-card :body-style="{ padding: '0px' }">
      <img style="height: 200px; padding-top:20px" src="http://1stclockwork.com/wp-content/uploads/the-button_sticker.jpg">
      <div style="padding: 14px;">
        <span>THE Button</span>
        <div class="bottom clearfix">
          <time class="time">Last Played today</time>
          <br>
          <router-link type="text" class="button" to="/ValidateLicence">Play now</router-link>
        </div>
      </div>
    </el-card>
  </el-col>
  <el-col :span="8">
    <el-card :body-style="{ padding: '0px' }">
      <img style="height: 200px; padding-top:20px" src="https://upload.wikimedia.org/wikipedia/en/thumb/0/02/CoD_Black_Ops_cover.png/220px-CoD_Black_Ops_cover.png">
      <div style="padding: 14px;">
        <span>Call of Duty Black opps II</span>
        <div class="bottom clearfix">
          <time class="time">Last played 2018/08/22</time>
          <br>
          <el-button type="text" class="button">Play now</el-button>
        </div>
      </div>
    </el-card>
  </el-col>
    <el-col :span="8">
        <el-card :body-style="{ padding: '0px' }">
      <img style="height: 200px; padding-top:20px" src="https://pbs.twimg.com/profile_images/808475349671493632/nvi7WJf4_400x400.jpg">
      <div style="padding: 14px;">
        <span>Dota 2</span>
        <div class="bottom clearfix">
          <time class="time">Last played 2018/05/11</time>
          <br>
          <el-button type="text" class="button">Play now</el-button>
        </div>
      </div>
    </el-card>
  </el-col>
</el-row>
  </div>
</template>

<script>
// @ is an alias to /src
import {loadCampaignManager, validateLicence} from "../../utils/CampaignManagerInterface";

export default {
  name: 'home',
  data(){
    return {
      returnVerifyState: null
    }
  },
  methods:{
      async validate(){
          console.log("Validating licence...")
         this.returnVerifyState =  await validateLicence(0);
         console.log(this.returnVerifyState)
      }
  },
  async mounted() {
     await loadCampaignManager();  
  }
}

</script>

