// The Vue build version to load with the `import` command
// (runtime-only or standalone) has been set in webpack.base.conf with an alias.

import Vue from 'vue'
import App from './App'
import VeeValidate from 'vee-validate'
import ko from 'vee-validate/dist/locale/ko.js'
import axios from 'axios'
import router from './comm/router'
import store from './comm/store'

import toast from 'vue2-toast'
import VueCarousel from 'vue-carousel'
import VueModal from './components/plugins/modal/index'
import Multiselect from './components/plugins/vue-multiselect/src/index'
import SlimDialog from 'v-slim-dialog'
import datepicker from 'vuejs-datepicker'

import 'jquery'

import './assets/js/jquery.js'
import './assets/js/jockey.js'
import './comm/message.js'

import 'chart.js'
import 'hchs-vue-charts'

import 'vue2-toast/lib/toast.css'
import './assets/css/v-slim-dialog.css'
import './assets/css/reset.css'
import './assets/css/style.css'

Vue.use(VeeValidate, {
  events: '',
  locale: 'ko',
  dictionary: {
    ko
  }
})

Vue.use(toast, {
  type: 'center',
  duration: 2000,
  wordWrap: true,
  width: '250px'
})
Vue.use(VueCarousel)
Vue.use(VueModal)
Vue.use(window.VueCharts)
Vue.use(SlimDialog)
Vue.component('multiselect', Multiselect)
Vue.component('datepicker', datepicker)

Vue.config.debug = true
Vue.config.devtools = false
Vue.config.productionTip = false

axios.interceptors.request.use(function (config) {
  config.headers.AJAX = true
  return config
})
axios.interceptors.response.use((response) => {
  return response
}, function (error) {
  if (error.response.status === 401) {
    console.log('unauthorized, logging out ...')
    router.push('/mypage/logout')
    return false
  } else if (error.response.status === 403) {
    console.log('unauthorized, logging out ...')
    router.push('/mypage/logout')
    return false
  }
  return Promise.reject(error.response)
})
Vue.prototype.$http = axios

/* eslint-disable no-new */
new Vue({
  el: '#app',
  router,
  store,
  components: {
    App
  },
  template: '<App/>'
})
