<template>
  <div id="outer-container">
    <div id="inner-container">
      <div id="title">tahskr</div>
      <div id="subtitle">[noun] yet another todo app</div>

      <div id="login-form">
        <form @submit.prevent="submit()">
          <!-- <label for="email">Email Address</label> -->
          <input
            type="email"
            id="email"
            v-model="emailAddress"
            placeholder="Email Address"
            required
          />

          <!-- <label for="password">Password</label> -->
          <input type="password" id="password" v-model="password" placeholder="Password" required />

          <div id="buttons">
            <div>
              <input type="checkbox" id="remember" v-model="remember" />
              <label for="remember">Remember Me</label>
            </div>
            <button type="submit">
              <login-variant-icon />Log In
            </button>
          </div>
        </form>
        <p>{{ message }}</p>
      </div>
    </div>
  </div>
</template>

<script>
import axios from "axios";
import api from "../api";
import LoginVariantIcon from "icons/LoginVariant.vue";

export default {
  components: {
    LoginVariantIcon
  },

  data: function() {
    return {
      emailAddress: "adam@dullage.com",
      password: "password",
      remember: false,
      message: null
    };
  },

  methods: {
    submit: function() {
      var parent = this;

      api
        .post("/auth", {
          emailAddress: this.emailAddress,
          password: this.password
        })
        .then(function(r) {
          parent.$emit("update-token", r.data, parent.remember);
        })
        .catch(function(e) {
          if (e.response.status == 401) {
            parent.message = "Invalid username or password, please try again.";
          } else {
            parent.message = "An unknown error has occured.";
          }
        })
        .finally(function() {
          parent.emailAddress = null;
          parent.password = null;
        });
    }
  }
};
</script>

<style lang="scss" scoped>
@import "../main";

#outer-container {
  height: 100%;
  // width: 100%;
  display: flex;
  flex-direction: column;
  justify-content: center;
  align-items: center;
  color: $offWhite;
}

#inner-container {
  padding: 40px 30px;
  border: 1px solid $offWhite;
}

#title {
  font-family: $brandFontStack;
  font-size: 40px;
}

#subtitle {
  margin: 0 0 50px 0;
  font-style: italic;
}

input[type="email"],
input[type="password"] {
  margin: 8px 0;
  display: block;
  padding: 0 16px;
  border: none;
  width: 300px;
  height: 40px;
  background-color: $bgLightColor;
  color: $offWhite;
}

#buttons {
  padding: 0 2px;
  display: flex;
  justify-content: space-between;
  align-items: center;
}

button {
  border: none;
  background: none;
  color: $offWhite;
  font-size: 16px;
  cursor: pointer;
}
</style>