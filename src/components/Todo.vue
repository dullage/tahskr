<template>
  <div
    class="todo"
    :class="{ complete: completed, incomplete: !completed, important: important, selected: selected }"
    @click="select"
  >
    <div class="todo-left">
      <check-box class="check-box" :checked="completed" @toggled="toggleCompleted" />
      <span class="summary">{{ summary }}</span>
    </div>

    <div class="todo-right">
      <div class="important-button" title="Important" @click.stop="toggleImportant">
        <alert-circle-outline-icon title="Important" />
      </div>
    </div>
  </div>
</template>

<script>
import api from "../api";
import CheckBox from "./CheckBox.vue";
import EventBus from "../eventBus.js";

// Icons
import AlertCircleOutlineIcon from "icons/AlertCircleOutline.vue";

export default {
  components: {
    AlertCircleOutlineIcon,
    CheckBox
  },

  props: {
    listIndex: { type: Number, required: true },
    todoIndex: { type: Number, required: true },
    id: { type: Number, required: true },
    summary: { type: String, required: true },
    completedDatetime: { type: Date },
    important: { type: Boolean, required: true },
    selectedTodoId: { type: Number }
  },

  computed: {
    completed: function() {
      if (this.completedDatetime == null) {
        return false;
      } else {
        return true;
      }
    },

    selected: function() {
      if (this.id == this.selectedTodoId) {
        return true;
      } else {
        return false;
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
    },

    select: function() {
      EventBus.$emit("select-todo", this.id);
    }
  }
};
</script>

<style lang="scss" scoped>
@import "../common";

// $importantButtonWidth: 12px;

.todo {
  height: $todoHeight;
  margin: 0 0 4px 0;
  display: flex;
  align-items: center;
  justify-content: space-between;
  cursor: grab;
  background-color: $bgLightColor;
  border-left: 3px solid $bgLightColor;
  color: $offWhite;
  font-size: 17px;
  div {
    display: flex;
    align-items: center;
  }
  &:hover {
    background-color: lighten($bgLightColor, 2%);
  }
}

.todo-left {
  flex: 1 1 auto;
}

.todo-right {
  flex: 1 1 auto;
  flex-direction: row-reverse;
  &:hover {
    .important-button {
      width: $todoHeight;
    }
  }
}

.important-button {
  background-color: $brandOrange;
  color: darken($brandOrange, 15%);
  width: 0;
  height: $todoHeight;
  transition: width 200ms;
  cursor: pointer;
  overflow: hidden;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 20px;
  .material-design-icon__svg {
    bottom: 0;
  }
}

.check-box {
  margin: 0 10px;
}

.selected {
  &.todo {
    background-color: lighten($bgLightColor, 10%);
    border-left-color: lighten($bgLightColor, 10%);
  }
}

.complete {
  .summary {
    text-decoration: line-through;
    color: $subduedColor;
  }
}

.important {
  &.todo {
    border-left-color: $brandOrange;
  }
}
</style>