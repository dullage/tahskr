<template>
  <div id="app">
    <communication-error v-if="communicationError == true" />
    <authenticated v-else-if="loggedIn" :auth="auth" />
    <unauthenticated v-else @update-token="updateAuth" />
  </div>
</template>

<script>
import Cookies from "js-cookie";

import api from "../api";
import EventBus from "../eventBus.js";
import Unauthenticated from "./Unauthenticated.vue";
import Authenticated from "./Authenticated.vue";
import CommunicationError from "./CommunicationError.vue";

export default {
  components: {
    Unauthenticated,
    Authenticated,
    CommunicationError
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
    updateAuth: function(token, remember) {
      this.auth.token = token.token;
      this.auth.userId = token.userId;
      if (remember == true) {
        Cookies.set("token", token.token, { expires: 30 });
        Cookies.set("userId", token.userId, { expires: 30 });
      }
      api.defaults.headers.common["x-token"] = token.token;
    }
  },

  created: function() {
    var parent = this;

    var cookieToken = Cookies.get("token");
    var cookieUserId = Cookies.get("userId");
    if (cookieToken && cookieUserId) {
      this.auth.token = cookieToken;
      this.auth.userId = cookieUserId;
      api.defaults.headers.common["x-token"] = cookieToken;
    }

    EventBus.$on("logout", function() {
      Cookies.remove("token");
      Cookies.remove("userId");
      parent.auth.token = null;
      parent.auth.userId = null;
      delete api.defaults.headers.common["x-token"];
    });

    EventBus.$on("communication-error", function() {
      parent.communicationError = true;
    });
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