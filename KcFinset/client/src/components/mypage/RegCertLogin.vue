<template>
  <div id="wrapper">
    <!-- Content -->
    <section>
      <div class="certcode-wrap">
        <p class="text">
          비밀번호를 입력해주세요.
        </p>
        <p class="textred" v-if="cntFailPwd > 0"> {{ errMsg }} </p>

        <div class="pass-wrap">
          <input type="password" v-bind:style="classPass1" v-model="classPass1" id="pass_number1" maxlength="1" readonly />
          <input type="password" v-bind:style="classPass2" v-model="classPass2" id="pass_number2" maxlength="1" readonly />
          <input type="password" v-bind:style="classPass3" v-model="classPass3" id="pass_number3" maxlength="1" readonly />
          <input type="password" v-bind:style="classPass4" v-model="classPass4" id="pass_number4" maxlength="1" readonly />
        </div>
        <div class="number">
          <a v-on:click="btnClick('1')">1</a>
          <a v-on:click="btnClick('2')">2</a>
          <a v-on:click="btnClick('3')">3</a>
          <a v-on:click="btnClick('4')">4</a>
          <a v-on:click="btnClick('5')">5</a>
          <a v-on:click="btnClick('6')">6</a>
          <a v-on:click="btnClick('7')">7</a>
          <a v-on:click="btnClick('8')">8</a>
          <a v-on:click="btnClick('9')">9</a>
          <a disabled="disabled">&nbsp;</a>
          <a v-on:click="btnClick('0')">0</a>
          <a class="del" v-on:click="backClick()"></a>
        </div>
      </div>
    </section>
  </div>

</template>

<script>
import Common from "./../../assets/js/common.js";
import Constant from "./../../assets/js/constant.js";

import ko from "vee-validate/dist/locale/ko.js";

export default {
  name: "certCodeLogin",
  data() {
    return {
      errMsg: "",
      cntFailPwd: 0,
      ynFingerprint: this.$store.state.user.ynFingerprint,
      password: "",
      //class
      classPass1: "",
      classPass2: "",
      classPass3: "",
      classPass4: ""
    };
  },
  component: {},
  // computed () {
  // },
  beforeCreate() {},
  created() {
    this.$store.state.title = "비밀번호 확인";
    this.$store.state.header.type = "sub";
    if (Constant.userAgent == "Android") {
      window.Android.setEndApp("Y");

      if (this.$store.state.user.ynFingerprint == "Y") {
        window.Android.initFingerPrint();
      }
    }
  },
  beforeMount() {},
  mounted() {
    this.errMsg = "입력값이 올바르지 않습니다.";
  },
  beforeUpdate() {},
  updated() {},
  beforeDestroy() {},
  destroyed() {},
  methods: {
    initClassPass: function() {
      var _this = this;
      _this.password = "";
      _this.classPass1 = "";
      _this.classPass2 = "";
      _this.classPass3 = "";
      _this.classPass4 = "";
    },
    btnClick: function(val) {
      var _this = this;
      if (_this.password.length < 4) {
        _this.password += val;
      }
      if (_this.password.length > 0) _this.classPass1 = "border-color: #111";
      if (_this.password.length > 1) _this.classPass2 = "border-color: #111";
      if (_this.password.length > 2) _this.classPass3 = "border-color: #111";
      if (_this.password.length > 3) {
        _this.classPass4 = "border-color: #111";

        _this.successStep();
      }
    },
    backClick: function() {
      var _this = this;
      this.initClassPass();
      _this.password = _this.password.substr(0, _this.password.length - 1);
      if (_this.password.length > 0) _this.classPass1 = "border-color: #111";
      if (_this.password.length > 1) _this.classPass2 = "border-color: #111";
      if (_this.password.length > 2) _this.classPass3 = "border-color: #111";
      if (_this.password.length > 3) _this.classPass4 = "border-color: #111";
    },
    successStep: function() {
      let url = "/m/person/fingerChkCode.json";
      let _this = this;
      let frm = new FormData();
      frm.append("currentPwd", _this.password);
      this.$http
        .post(url, frm)
        .then(response => {
          var result = response.data.result;
          if (result == "00") {
            this.$toast.center("지문인증이 설정되었습니다.");
            _this.$store.state.user.ynFingerprint = "Y";
            _this.$router.go(-1);
            _this.cntFailPwd = 0;
          } else {
            _this.cntFailPwd++;
            _this.initClassPass();
          }
        })
        .catch(e => {
          this.$toast.center(ko.messages.error);
        });
    }
  }
};
</script>