import "./global.scss";
import "vue-material-design-icons/styles.css";
import App from "./components/App.vue";
import Vue from "vue";

var app = new Vue({
  el: "#app",
  render: h => h(App)
});
