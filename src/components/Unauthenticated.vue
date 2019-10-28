<template>
  <div>
    <form @submit.prevent="submit()">
      <label for="email">Email Address</label>
      <input type="email" id="email" v-model="emailAddress" />

      <label for="password">Password</label>
      <input type="password" id="password" v-model="password" />

      <input type="checkbox" id="remember" v-model="remember" />
      <label for="remember">Remember Me</label>

      <button type="submit">Log In</button>
    </form>
    <p>{{ message }}</p>
  </div>
</template>

<script>
import axios from "axios";
import api from "../api";

export default {
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
