<template>
  <div class="add-todo">
    <hr />
    <input
      type="text"
      @keyup.enter="submit"
      v-model="summary"
      placeholder="Add to Inbox..."
    />
    <!-- <br /> -->
    <!-- <button type="button" @click="submit">Add</button> -->
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

<style lang="scss" scoped>
@import "../common";

.add-todo,
input {
  width: 100%;
  max-width: 1024px;
}

.add-todo {
  position: fixed;
  bottom: 0;
}

input {
  font-size: 17px;
  padding: 12px 16px;
  // border: 6px solid $bgLightColor;
  border: none;
  background-color: $bgColor;
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

hr {
  border: 2px solid $bgLightColor;
}
</style>