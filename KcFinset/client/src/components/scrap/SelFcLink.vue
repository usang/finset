<template>
  <div>
    <section>
      <div class="container mt30">
        <h3 v-if="isSingle!=true">연동 금융사를 선택해주세요.</h3>
        <div class="checks grid2 mt10" v-if="isSingle!=true">
          <p><input type="checkbox" id="chk1" :checked="isCheckBank" @click="clickCheck('bank')"><label for="chk1">은행</label></p>
          <p><input type="checkbox" id="chk2" :checked="isCheckCard" @click="clickCheck('card')"><label for="chk2">카드</label></p>
          <p class="mt10"><input type="checkbox" id="chk3" :checked="isCheckStock" @click="clickCheck('stock')"><label for="chk3">증권</label></p>
          <p class="mt10"><input type="checkbox" id="chk4" :checked="isCheckNts" @click="clickCheck('nts')"><label for="chk4">국세청</label></p>
        </div>

        <div class="cert-wrap" v-if="isCheckStock">
          <p class="mt40">증권사 연계를 위하여 이메일입력과 정보제공 동의가 필요합니다.</p>
          <h3 class="mt15">이메일</h3>
          <input type="text" class="mt15" v-model="emailtext" v-validate="'required'" autocomplete="off" placeholder="이메일을 입력하세요" data-vv-name='이메일'>
          <p class="warn" v-if="errors.has('이메일')">{{errors.first('이메일')}}</p>

          <div class="checks">
            <div class="box-agree solo">
              <p @click="clickShowCert()"><input type="checkbox" id="chk5" :checked="isCheckCert"><label for="chk5" @click="clickCheckCert($event)">[필수] 금융정보 제공동의서</label></p>
            </div>
          </div>
        </div>
      </div>

      <div class="btn-wrap float">
        <a href="#" class="btn-next" @click="clickNext()">다음</a>
      </div>
    </section>
    <vue-modal transitionName="zoom-in" name="my-modal" v-on:popclose="closePop()">
      <Terms slot="body" v-on:popclose="closePop()" :text="financeTermsText"></Terms>
    </vue-modal>
  </div>
</template>

<script>
import ko from "vee-validate/dist/locale/ko.js";
import Constant from "./../../assets/js/constant.js";
import Terms from "./Terms.vue";

export default {
  name: "",
  data() {
    return {
      isCheckBank: true,
      isCheckCard: true,
      isCheckStock: true,
      isCheckNts: true,
      isCheckCert: false,
      isGetCertContent: false,
      emailtext: "",
      uuid: "",
      financeTerms: "",
      financeTermsText: "",
      //단일 금융사 관련
      isSingle: this.$route.params.isSingle,
      agency: this.$route.params.agency,
      cd_coocon: this.$route.params.cd_coocon
    };
  },
  components: {
    Terms: Terms
  },
  computed: {},
  beforeCreate() {
    this.$store.state.header.type = "sub";
    this.$store.state.title = "금융사 연동";
  },
  created() {
    window.resultCheckDevicesUUID = this.resultCheckDevicesUUID;
    window.resultCertSignInfo = this.resultCertSignInfo;
    this.checkUUID();
  },
  beforeMount() {},
  mounted() {
    if (this.isSingle) {
      this.isCheckBank = false;
      this.isCheckCard = false;
      this.isCheckEtc = false;
      this.isCheckStock = true;
    }
  },
  beforeUpdate() {},
  updated() {},
  beforeDestroy() {},
  destroyed() {},
  methods: {
    clickCheck: function(type) {
      switch (type) {
        case "bank":
          this.isCheckBank = !this.isCheckBank;
          break;
        case "card":
          this.isCheckCard = !this.isCheckCard;
          break;
        case "stock":
          this.isCheckStock = !this.isCheckStock;
          break;
        case "nts":
          this.isCheckNts = !this.isCheckNts;
          break;
      }
    },
    clickCheckCert: function(event) {
      event.stopPropagation();
      console.log(event);
      var _this = this;
      this.$validator.validateAll().then(res => {
        if (res) {
          this.isCheckCert = !this.isCheckCert;
          if (_this.isCheckCert && !_this.isGetCertContent) {
            _this.getTermsContent(false);
          }
        } else {
          this.$toast.center(ko.messages.require);
        }
      });
    },
    clickShowCert: function() {
      var _this = this;
      this.$validator.validateAll().then(res => {
        if (res) {
          if (_this.isCheckCert && !_this.isGetCertContent) {
            _this.getTermsContent(true);
          } else {
            _this.openPop();
          }
        } else {
          this.$toast.center(ko.messages.require);
        }
      });
    },
    clickNext: function() {
      var _this = this;
      this.$validator.validateAll().then(res => {
        if (res) {
          // 증권 연동이 아닐경우 로딩페이지로 이동
          if (_this.isCheckStock == false) {
            _this.nextStep();
          }
          // 증권연동 - 동의서 체크여부
          else if (_this.isCheckCert) {
            // 증권연동 - 동의서 다운여부
            if (_this.isGetCertContent) {
              _this.getCertSignInfo();
            } else {
              this.$toast.center("금융정보 제공동의서를 가져오지 못했습니다.");
            }
          } else {
            this.$toast.center("금융정보 제공동의서를 체크해주세요.");
          }
        } else {
          this.$toast.center(ko.messages.require);
        }
      });
    },
    //금융정보제공동의서 조회
    getTermsContent: function(isShow) {
      var _this = this;
      var formData = new FormData();
      formData.append("no_person", this.$store.state.user.noPerson);
      formData.append("uuid", this.uuid);
      formData.append("dn", this.$route.params.dn);
      formData.append("email", this.emailtext);
      //단일 금융사 조회 일 경우에만 추가
      if (this.isSingle) {
        formData.append("cd_fc", this.cd_coocon);
      }
      _this.$store.state.isLoading = true; // 시작시 Spinner 보여주기
      this.$http
        .post("/m/scrap/getTermsContent.json", formData)
        .then(function(response) {
          if (response.data) {
            _this.isGetCertContent = true;
            _this.financeTerms = response.data.financeTerms;
            var financeTerms = JSON.parse(_this.financeTerms);
            _this.financeTermsText = financeTerms.text;
            _this.$store.state.isLoading = false;
            if (isShow) {
              _this.openPop();
            }
          } else {
            this.$toast.center(ko.messages.error);
          }
        })
        .catch(e => {
          this.$toast.center(ko.messages.error);
        });
    },
    sendTermsContent: function(jwsInfo) {
      var _this = this;
      var formData = new FormData();
      formData.append("no_person", this.$store.state.user.noPerson);
      formData.append("uuid", this.uuid);
      formData.append("dn", this.$route.params.dn);
      formData.append("email", this.emailtext);
      formData.append("financeTerms", this.financeTerms);
      formData.append("jwsInfo", jwsInfo);

      this.$http
        .post("/m/scrap/sendTermsContent.json", formData)
        .then(function(response) {
          console.log(response.data);
          _this.nextStep();
        })
        .catch(e => {
          this.$toast.center(ko.messages.error);
        });
    },
    nextStep: function() {
      var _this = this;
      this.$router.push({
        name: "scrapLoading",
        params: {
          dn: this.$route.params.dn,
          cn: this.$route.params.cn,
          normalMessage: "연동 가능한 금융사를<br>확인 중 입니다.",
          smallMessage: "잠시만 기다려주세요.",
          isCheckBank: _this.isCheckBank,
          isCheckCard: _this.isCheckCard,
          isCheckStock: _this.isCheckStock,
          isCheckNts: _this.isCheckNts,
          //단일 금융사 관련
          isSingle: _this.isSingle,
          agency: _this.agency,
          cd_coocon: _this.cd_coocon
        }
      });
    },
    closePop: function() {
      var _this = this;
      _this.$modals.hide("my-modal");
    },
    openPop: function() {
      var _this = this;
      _this.$modals.show("my-modal");
    },
    // 인증정보 가져오기
    getCertSignInfo: function() {
      var _this = this;
      var financeTerms = JSON.parse(this.financeTerms);
      if (Constant.userAgent == "iOS") {
        //공인인증서 유무 체크 결과 콜백 이벤트
        Jockey.on("resultCertSignInfo", function(param) {
          _this.resultCertSignInfo(param.jwsInfo);
        });
        Jockey.send("getCertSignInfo", {
          payload: financeTerms.text
        });
      } else if (Constant.userAgent == "Android") {
        window.Android.getCertSignInfo(financeTerms.text);
      }
    },
    //공인인증서 유무 결과 (모바일에서 호출)
    resultCertSignInfo: function(jwsInfo) {
      this.sendTermsContent(jwsInfo);
    },
    // UUID 체크
    checkUUID: function() {
      var _this = this;
      if (Constant.userAgent == "iOS") {
        //공인인증서 유무 체크 결과 콜백 이벤트
        Jockey.on("resultCheckDevicesUUID", function(param) {
          _this.resultCheckDevicesUUID(uuid);
        });
        Jockey.send("checkDevicesUUID");
      } else if (Constant.userAgent == "Android") {
        window.Android.checkDevicesUUID();
      }
    },
    // UUID 체크 결과(모바일에서 호출)
    resultCheckDevicesUUID: function(uuid) {
      this.uuid = uuid;
    }
  }
};
</script>

<!-- Add 'scoped' attribute to limit CSS to this component only -->
<style lang="scss">
</style>
