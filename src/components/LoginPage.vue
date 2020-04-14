<template>
  <div class="unauthenticated">
    <div id="inner-container">
      <logo />

      <div id="login-form">
        <form @submit.prevent="submit()">
          <!-- Username -->
          <input type="text" id="username" v-model="username" placeholder="Username" required />

          <!-- Password -->
          <input type="password" id="password" v-model="password" placeholder="Password" required />

          <!-- Server Address -->
          <input
            type="url"
            id="serverAddress"
            v-model="serverAddress"
            placeholder="Server Address"
            required
          />

          <div id="remember-me">
            <check-box
              class="check-box"
              :checked="remember"
              :dimWhenChecked="false"
              @toggled="toggleRemember"
            />
            <span @click="toggleRemember">Remember Me</span>
          </div>

          <div id="submit-button">
            <button type="submit">
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
import LoginVariantIcon from "icons/LoginVariant.vue";
import Logo from "./Logo.vue";

export default {
  components: {
    LoginVariantIcon,
    CheckBox,
    Logo
  },

  data: function() {
    return {
      serverAddress: "https://api.tahskr.com",
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

.logo {
  margin: 0 0 50px 0;
}

input[type="url"],
input[type="text"],
input[type="password"] {
  margin: 8px 0;
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

button {
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