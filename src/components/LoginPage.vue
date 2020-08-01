<template>
  <div class="unauthenticated">
    <div id="inner-container">
      <logo />

      <div id="login-form">
        <form @submit.prevent="submit()">
          <!-- Server Address -->
          <div class="server-address">
            <input
              type="url"
              id="server-address"
              v-model="serverAddress"
              placeholder="Server Address"
              required
            />
            <div
              v-if="serverAddress != null"
              class="button"
              title="Clear and forget Server Address"
              @click="clearServerAddress"
            >
              <link-variant-remove-icon title="Clear and forget Server Address" />
            </div>
          </div>

          <!-- Username -->
          <input type="text" id="username" v-model="username" placeholder="Username" required />

          <!-- Password -->
          <input type="password" id="password" v-model="password" placeholder="Password" required />

          <div id="remember-me">
            <check-box
              class="check-box"
              :checked="remember"
              @toggled="toggleRemember"
            />
            <span @click="toggleRemember">Remember Me</span>
          </div>

          <div id="submit-button">
            <button type="submit" class="button">
              <login-variant-icon />Log In
            </button>
          </div>
        </form>
        <p id="message">{{ message }}</p>
      </div>
    </div>
  </div>
</template>

<script>
import api from "../api";
import CheckBox from "./CheckBox.vue";
import LinkVariantRemoveIcon from "icons/LinkVariantRemove.vue";
import LoginVariantIcon from "icons/LoginVariant.vue";
import Logo from "./Logo.vue";

export default {
  components: {
    LinkVariantRemoveIcon,
    LoginVariantIcon,
    CheckBox,
    Logo
  },

  data: function() {
    return {
      serverAddress: null,
      username: null,
      password: null,
      remember: false,
      message: null
    };
  },

  methods: {
    toggleRemember: function() {
      this.remember = !this.remember;
    },

    clearServerAddress: function() {
      localStorage.removeItem("serverAddress");
      this.serverAddress = null;
    },

    submit: function() {
      var parent = this;
      api.defaults.baseURL = this.serverAddress;

      api
        .post("/auth", {
          username: this.username,
          password: this.password
        })
        .then(function(r) {
          parent.$emit("login", parent.serverAddress, r.data, parent.remember);
        })
        .catch(function(e) {
          if (typeof e.response !== "undefined" && e.response.status == 401) {
            parent.message = "Invalid username or password, please try again.";
          } else {
            parent.message =
              "Unable to communicate with the tahskr server, please check the 'Server Address' entered.";
          }
        })
        .finally(function() {
          parent.password = null;
        });
    }
  },

  created: function() {
    this.serverAddress = localStorage.getItem("serverAddress");
  }
};
</script>

<style lang="scss" scoped>
@import "../common";

.unauthenticated {
  height: 100%;
  display: flex;
  flex-direction: column;
  justify-content: center;
  align-items: center;
  color: $offWhite;
}

#inner-container {
  padding: 40px 30px;
  border: 1px solid $offWhite;
  @media #{$mobile} {
    border: none;
  }
}

input[type="url"],
input[type="text"],
input[type="password"] {
  margin-bottom: 8px;
  display: block;
  padding: 0 16px;
  border: none;
  width: 100%;
  height: 40px;
  background-color: $bgLightColor;
  color: $offWhite;
  &::placeholder {
    color: $subduedColor;
  }
  &:focus {
    outline: none;
    &::placeholder {
      color: transparent;
    }
  }
}

.server-address {
  display: flex;
  flex-direction: row;
  align-items: center;
  margin: 20px 0;
}

.link-variant-remove-icon {
  margin: 0 8px 8px 8px;
}

#remember-me {
  display: flex;
  align-items: center;
  span {
    cursor: pointer;
  }
}

.check-box {
  margin: 0 4px 0 0;
}

#submit-button {
  display: flex;
  justify-content: flex-end;
  margin: 12px 0;
}

.button {
  border: none;
  background: none;
  color: $offWhite;
  font-size: 18px;
  cursor: pointer;
}

#message {
  width: 300px;
  color: $errorRed;
  font-size: 12px;
  text-align: center;
}
</style>