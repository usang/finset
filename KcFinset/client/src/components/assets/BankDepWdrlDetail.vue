<template>
  <section v-if="seen">
    <div class="inout-list">
      <ul class="flex">
        <li class="symbol"><img
            :src="depWdrlInfo.fcImg"
            alt=""
          />{{depWdrlInfo.nm_fc}}</li>
        <li class="num">{{depWdrlInfo.an}}</li>
      </ul>
      <ul class="flex">
        <li>거래시각</li>
        <li>{{formatDateDot(depWdrlInfo.dt_trd)}} {{depWdrlInfo.tm_trd}}</li>
      </ul>
      <ul class="flex">
        <li>거래구분</li>
        <li>{{depWdrlInfo.nm_trns}}</li>
      </ul>
      <ul class="flex">
        <li>적요</li>
        <li>{{depWdrlInfo.dealway1}}</li>
      </ul>
      <ul class="flex">
        <li>내용</li>
        <li>{{depWdrlInfo.doc1}}</li>
      </ul>
      <ul class="flex">
        <li>거래금액</li>
        <li>{{(depWdrlInfo.amt_dep!='0')? formatNumber(depWdrlInfo.amt_dep) : formatNumber(depWdrlInfo.amt_wdrl)}}</li>
      </ul>
      <ul class="flex">
        <li>거래후 금액</li>
        <li>{{formatNumber(depWdrlInfo.balance)}}</li>
      </ul>
    </div>

    <div class="inout-setting">
      <ul class="flex">
        <li>지출 설정</li>
        <li>
          <button
            class="btn-cate btn-search"
            @click="showCategory()"
            :disabled="rk!='0'"
          >{{csCategoryText}}</button>
        </li>
      </ul>
      <!--
      <ul class="flex">
        <li>공유차단</li>
        <li><button class="btn-onoff"></button></li>
      </ul>
      <p>차단시 상대방에게 입출금 내역을 보이지 않습니다.</p>
      -->
    </div>

    <div class="cs-top">
      <div class="links">
        <a
          @click="$router.push('')"
          class="kakao"
        >카카오톡 문의</a>
        <a
          @click="$router.push('')"
          class="copy"
        >복사</a>

      </div>
    </div>

    <aside
      class="search-wrap"
      :class="{'on':isShowCategory}"
    >
      <div
        class="top"
        @click="closeCategory()"
      >
        <button>카테고리</button>
        <a class="btn-setting"></a>
      </div>
      <div
        v-if="depWdrlInfo.cd_trns == '02'"
        class="select-cate"
      >
        <div class="cate-wrap">
          <ul>
            <li
              v-for="eachClass in consumeCategory"
              :key="eachClass.cd_class"
              :class="{'on':eachClass.cd_class==csCurClass}"
              @click="clickCategory('class', eachClass.cd_class, eachClass.nm_class)"
            >
              {{eachClass.nm_class}}
            </li>
          </ul>
        </div>
        <div
          class="cate-wrap"
          v-if="consumeCategory!={}"
        >
          <ul v-if="consumeCategory[csCurClass] != undefined">
            <li
              v-for="(eachType, index) in consumeCategory[csCurClass]['listCdType']"
              :key="index"
              :class="{'on':eachType.cd_type==csCurType}"
              @click="clickCategory('type', eachType.cd_type, eachType.nm_type)"
            >
              {{eachType.nm_type}}
            </li>
          </ul>
        </div>
      </div>
      <div
        v-else-if="depWdrlInfo.cd_trns == '01'"
        class="select-cate one"
      >
        <div class="cate-wrap">
          <ul>
            <li
              v-for="eachClass in consumeCategory"
              :key="eachClass.cd_class"
              :class="{'on':eachClass.cd_class==csCurClass}"
              @click="clickCategory('class', eachClass.cd_class, eachClass.nm_class)"
            >
              {{eachClass.nm_class}}
            </li>
          </ul>
        </div>
      </div>
      <div class="action btn1">
        <a
          @click="clickConfirm()"
          class="solid"
        >확인</a>
      </div>
    </aside>
  </section>
</template>

<script>
import Common from "./../../assets/js/common.js";
import Constant from "./../../assets/js/constant.js";

import ko from "vee-validate/dist/locale/ko.js";

export default {
  name: "assetsBankDepWdrlDetail",
  data() {
    return {
      seen: false,
      no_person: "", //회원번호
      no_account: "", //계좌번호
      dt_trd: "", //거래일자
      tm_trd: "", //거래시각
      rk: "", //공유순서
      depWdrlInfo: "", //입출금 정보
      csCategoryText: "카테고리를 선택하세요", //카테고리text
      consumeCategory: [], //소비 - 카테고리
      csCurClass: "", //소비 - 카테고리
      csCurType: "", //소비 - 카테고리
      csNmClass: "", //소비 - 카테고리명
      csNmType: "", //소비 - 카테고리명
      csYnAuto: "N", //소비 - 자동적용여부
      isShowCategory: false, //카테고리 표시여부
      consumeInfo: "" //소비정보
    };
  },
  components: {},
  computed: {},
  beforeCreate() {
    this.$store.state.header.type = "sub";
    this.$store.state.title = "입출금상세";
  },
  created() {
    this.no_person = this.$route.query.no_person;
    this.no_account = this.$route.query.no_account;
    this.dt_trd = this.$route.query.dt_trd;
    this.tm_trd = this.$route.query.tm_trd;
    this.rk = this.$route.query.rk;

    this.getDepWdrlDetail();
  },
  beforeMount() {},
  mounted() {},
  beforeUpdate() {},
  updated() {},
  beforeDestroy() {},
  destroyed() {},
  methods: {
    //상세정보 조회
    getDepWdrlDetail: function() {
      var _this = this;

      console.log("no_person" + _this.no_person);

      var formData = new FormData();
      formData.append("no_person", _this.no_person);
      formData.append("no_account", _this.no_account);
      formData.append("dt_trd", _this.dt_trd);
      formData.append("tm_trd", _this.tm_trd);

      this.$http
        .post("/m/assets/getAssetsBankDepWdrlDetail.json", formData)
        .then(response => {
          var depWdrlInfo = response.data.depWdrlInfo;
          depWdrlInfo.fcImg =
            "/m/fincorp/getFinCorpIcon.crz?cd_fc=" + depWdrlInfo.cd_fc;
          _this.depWdrlInfo = depWdrlInfo;

          _this.setCsCategory();

          _this.seen = true;
        })
        .catch(e => {
          this.$toast.center(ko.messages.error);
        });
    },
    formatNumber: function(data) {
      return Common.formatNumber(data);
    },
    formatDateDot: function(data) {
      return Common.formatDateDot(data);
    },
    //소비 카테고리
    setCsCategory: function() {
      var _this = this;
      _this.csCurClass = "";
      _this.csCurType = "";
      if ("01" == _this.depWdrlInfo.cd_trns) {
        _this.listPersonIncomeClassInfo();
      } else {
        _this.listPersonConsumeClassInfo();
      }
    },
    listPersonIncomeClassInfo: function() {
      var _this = this;
      this.$http
        .get("/m/consume/listPersonIncomeClassInfo.json", {
          params: {
            no_person: _this.no_person
          }
        })
        .then(function(response) {
          var list = response.data.listPersonIncomeClassInfo;
          var listCdClass = new Object();
          for (var eachClass of list) {
            listCdClass[eachClass.cd_class] = eachClass;
          }
          _this.consumeCategory = listCdClass;
          _this.getConsumeInfo();
        });
    },
    listPersonConsumeClassInfo: function() {
      var _this = this;
      this.$http
        .get("/m/consume/listPersonConsumeClassInfo.json", {
          params: {
            no_person: _this.no_person
          }
        })
        .then(function(response) {
          var list = response.data.listPersonConsumeClassInfo;
          var listCdClass = new Object();
          for (var eachClass of list) {
            var cd_class = "";
            var nm_class = "";
            var listCdType = new Array();
            for (var idx in eachClass) {
              if (idx == 0) {
                cd_class = eachClass[idx].cd_class;
                nm_class = eachClass[idx].nm_class;
              }
              listCdType.push({
                cd_type: eachClass[idx].cd_type,
                nm_type: eachClass[idx].nm_type
              });
            }
            listCdClass[cd_class] = {
              cd_class: cd_class,
              nm_class: nm_class,
              listCdType: listCdType
            };
          }
          _this.consumeCategory = listCdClass;
          _this.getConsumeInfo();
        });
    },
    getConsumeInfo: function() {
      var _this = this;

      console.log("no_person" + _this.no_person);

      var formData = new FormData();
      formData.append("no_person", _this.no_person);
      formData.append("no_account", _this.no_account);
      formData.append("dt_trd", _this.dt_trd);
      formData.append("tm_trd", _this.tm_trd);

      this.$http
        .post("/m/assets/getAssetsDetailCsInfo.json", formData)
        .then(response => {
          var consumeInfo = response.data.consumeInfo;

          if (_this.depWdrlInfo.cd_trns == "02") {
            _this.csCurClass = consumeInfo.cd_class;
            _this.csNmClass = consumeInfo.nm_class;
            _this.csCurType = consumeInfo.cd_type;
            _this.csNmType = consumeInfo.nm_type;
          } else {
            _this.csCurClass = consumeInfo.cd_class;
            _this.csNmClass = consumeInfo.nm_class;
          }

          _this.consumeInfo = consumeInfo;
        });
    },
    setCsCategoryText: function() {
      var _this = this;
      if ((_this.csCurClass || "") == "") {
        if ((_this.consumeInfo || "") != "") {
          if (_this.depWdrlInfo.cd_trns == "02") {
            _this.csCategoryText =
              _this.consumeInfo.nm_class + "-" + _this.consumeInfo.nm_type;
          } else {
            _this.csCategoryText = _this.consumeInfo.nm_class;
          }
        } else {
          _this.csCategoryText = "카테고리를 선택하세요";
        }
      } else {
        if (_this.depWdrlInfo.cd_trns == "02") {
          _this.csCategoryText = _this.csNmClass + "-" + _this.csNmType;
        } else {
          _this.csCategoryText = _this.csNmClass;
        }
      }
    },
    showCategory: function() {
      var _this = this;
      this.isShowCategory = true;
    },
    closeCategory: function() {
      var _this = this;
      _this.isShowCategory = false;
      _this.csCurClass = "";
      _this.csNmClass = "";
      _this.csCurType = "";
      _this.csNmType = "";

      _this.setCsCategoryText();
    },
    clickCategory: function(key, code, nm) {
      var _this = this;
      if ("class" == key) {
        _this.csCurClass = code;
        _this.csNmClass = nm;
        _this.csCurType = "";
        _this.csNmType = "";
      } else if ("type" == key) {
        _this.csCurType = code;
        _this.csNmType = nm;
      }
    },
    clickConfirm: function() {
      var _this = this;
      _this.modifyConsume();
      //TODO confirm csYnAuto설정
      _this.setCsCategoryText();
      _this.isShowCategory = false;
    },
    modifyConsume: function() {
      var _this = this;

      console.log("cd_class" + _this.csCurClass);
      console.log("cd_type" + _this.csCurType);
      console.log("yn_auto" + _this.csYnAuto);

      var formData = new FormData();
      formData.append("no_account", _this.no_account);
      formData.append("dt_trd", _this.dt_trd);
      formData.append("tm_trd", _this.tm_trd);

      formData.append("cd_class", _this.csCurClass);
      formData.append("cd_type", _this.csCurType);
      formData.append("yn_auto", _this.csYnAuto);

      this.$http
        .post("/m/assets/updateAssetsDetailCsInfo.json", formData)
        .then(function(response) {});
    }
  }
};
</script>

<!-- Add 'scoped' attribute to limit CSS to this component only -->
<style lang="scss">
</style>
