<template>
  <div :class="{ complete: completed, incomplete: !completed }" class="todo">
    <check-box class="check-box" :checked="completed" @toggled="toggleCompleted" />
    <span class="summary">{{ summary }}</span>
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
  margin: 8px 0;
  display: flex;
  align-items: center;
  cursor: grab;
  background-color: $bgLightColor;
  color: $offWhite;
  font-size: 17px;
}

.check-box {
  margin: 10px;
}

.complete {
  .summary {
    text-decoration: line-through;
    color: $disabledColor;
  }
}
</style>