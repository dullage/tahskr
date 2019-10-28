import Vue from "vue";

import App from "./components/App.vue";
import "./stylesheet.css";

var app = new Vue({
  el: "#app",
  render: h => h(App)
});
