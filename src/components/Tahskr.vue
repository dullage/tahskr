<template>
  <div id="app">
    <communication-error-page v-if="communicationError" />
    <main-app-page v-else-if="loggedIn" :auth="auth" />
    <login-page v-else @new-token="updateAuth" />
  </div>
</template>

<script>
import api from "../api";
import CommunicationErrorPage from "./CommunicationErrorPage.vue";
import EventBus from "../eventBus.js";
import LoginPage from "./LoginPage.vue";
import MainAppPage from "./MainAppPage.vue";

export default {
  components: {
    CommunicationErrorPage,
    LoginPage,
    MainAppPage
  },

  data: function() {
    return {
      auth: {
        userId: null,
        token: null
      },
      communicationError: false
    };
  },

  computed: {
    loggedIn: function() {
      return this.auth.token != null && this.auth.token != null;
    }
  },

  methods: {
    loadSavedAuth: function() {
      var storedToken = localStorage.getItem("token");
      var storedUserId = localStorage.getItem("userId");
      if (storedToken && storedUserId) {
        this.auth.token = storedToken;
        this.auth.userId = storedUserId;
        api.defaults.headers.common["x-token"] = storedToken;
      }
    },

    updateAuth: function(token, remember) {
      this.auth.token = token.token;
      this.auth.userId = token.userId;
      if (remember == true) {
        localStorage.setItem("token", token.token);
        localStorage.setItem("userId", token.userId);
      }
      api.defaults.headers.common["x-token"] = token.token;
    },

    logout: function() {
      localStorage.removeItem("token");
      localStorage.removeItem("userId");
      this.auth.token = null;
      this.auth.userId = null;
      delete api.defaults.headers.common["x-token"];
    }
  },

  created: function() {
    this.loadSavedAuth();

    var parent = this;
    EventBus.$on("communication-error", function() {
      parent.communicationError = true;
    });

    EventBus.$on("logout", this.logout);
  }
};
</script>

<style lang="scss" scoped>
@import "../common";

#app {
  max-width: $appWidth;
  flex: 1 1 auto;
}
</style>