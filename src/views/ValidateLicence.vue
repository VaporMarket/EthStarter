<template>
  <div class="home">
    <h1>Introducing THE Button...</h1>
    <br>
    <el-button type="primary" @click="validate">Am I a winner?</el-button>
    <br>
    <br>
    
    <h1 class="success" v-if="returnVerifyState>0" style="background:green">I AM A WINNER!</h1>
    <h1 v-if="returnVerifyState==0" style="background:red">I AM A LOOSER!</h1>

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

