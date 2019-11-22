import "./global.scss";
import "vue-material-design-icons/styles.css";
import Tahskr from "./components/Tahskr.vue";
import Vue from "vue";

var app = new Vue({
  el: "#app",
  render: h => h(Tahskr)
});
