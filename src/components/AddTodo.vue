<template>
  <div>
    <input type="text" @keyup.enter="submit" v-model="summary" />
    <button type="button" @click="submit">Add</button>
  </div>
</template>

<script>
import axios from "axios";
import api from "../api";
import EventBus from "../eventBus.js";

export default {
  props: {
    auth: Object
  },

  data: function() {
    return {
      summary: null
    };
  },

  methods: {
    submit: function() {
      var parent = this;

      api
        .post("/api/todo", { summary: this.summary })
        .then(function(r) {
          parent.$emit("add-todo", r.data);
        })
        .catch(function(e) {
          if (e.response.status == 401) {
            EventBus.$emit("logout");
          } else {
            parent.message = "An unknown error has occured.";
            console.error(e);
          }
        })
        .finally(function() {
          parent.summary = null;
        });
    }
  }
};
</script>