<template>
  <div :class="{ complete: completed, incomplete: !completed, important: important }" class="todo">
    <div id="left">
      <check-box class="check-box" :checked="completed" @toggled="toggleCompleted" />
      <span class="summary">{{ summary }}</span>
    </div>
    <div id="right">
      <div class="important-button" @click="toggleImportant">
        <span>!</span>
      </div>
    </div>
  </div>
</template>

<script>
import api from "../api";
import CheckBox from "./CheckBox.vue";
import EventBus from "../eventBus.js";

export default {
  components: {
    CheckBox
  },

  props: {
    listIndex: { type: Number, required: true },
    todoIndex: { type: Number, required: true },
    id: { type: Number, required: true },
    summary: { type: String, required: true },
    completedDatetime: { type: Date },
    important: { type: Boolean, required: true }
  },

  computed: {
    completed: function() {
      if (this.completedDatetime == null) {
        return false;
      } else {
        return true;
      }
    }
  },

  methods: {
    toggleCompleted: function() {
      var newCompletedDatetime = null;
      if (this.completed == false) {
        newCompletedDatetime = new Date();
      }
      EventBus.$emit("update-todo-by-index", this.listIndex, this.todoIndex, {
        completedDatetime: newCompletedDatetime
      });
    },

    toggleImportant: function() {
      EventBus.$emit("update-todo-by-index", this.listIndex, this.todoIndex, {
        important: !this.important
      });
    }
  }
};
</script>

<style lang="scss" scoped>
@import "../common";

.todo {
  height: 36px;
  margin: 0 0 4px 0;
  display: flex;
  align-items: center;
  justify-content: space-between;
  cursor: grab;
  background-color: $bgLightColor;
  color: $offWhite;
  font-size: 17px;
  div {
    display: flex;
    align-items: center;
  }
}

.check-box {
  margin: 10px;
}

.important-button {
  width: 16px;
  text-align: center;
  float: right;
  cursor: pointer;
  font-weight: bold;
}

.complete {
  .summary {
    text-decoration: line-through;
    color: $disabledColor;
  }
}

.important {
  .important-button {
    color: red;
  }
}
</style>