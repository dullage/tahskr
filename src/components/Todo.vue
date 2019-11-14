<template>
  <div :class="{ complete: completed, incomplete: !completed, important: important }" class="todo">
    <div id="left">
      <div class="important-button" @click="toggleImportant"></div>
      <check-box class="check-box" :checked="completed" @toggled="toggleCompleted" />
      <span class="summary">{{ summary }}</span>
    </div>
    <div id="right">
      <!-- <div class="important-button" @click="toggleImportant">
        <span>!</span>
        <alert-box-icon />
      </div>
      <div class="block"></div>-->
    </div>
  </div>
</template>

<script>
import api from "../api";
import CheckBox from "./CheckBox.vue";
import EventBus from "../eventBus.js";
import AlertBoxIcon from "icons/AlertBox.vue";

export default {
  components: {
    CheckBox,
    AlertBoxIcon
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

$todoHeight: 36px;
$importantButtonWidth: 12px;

.todo {
  height: $todoHeight;
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

#left {
  &:hover {
    .important-button {
      width: $importantButtonWidth;
    }
  }
}

.check-box {
  margin: 10px;
}

// .important-button {
//   margin: 0 6px 0 0;
//   cursor: pointer;
//   color: rgb(59, 59, 78);
//   font-size: 28px;
//   svg {
//     position: static;
//   }
// }

.important-button {
  background-color: $brandOrange;
  width: 0px;
  height: $todoHeight;
  transition: width 200ms;
  cursor: pointer;
}

.complete {
  .summary {
    text-decoration: line-through;
    color: $subduedColor;
  }
}

.important {
  .important-button {
    color: $brandOrange;
  }
  .important-button {
    width: $importantButtonWidth;
  }
  // .block {
  //   width: 46px;
  //   height: $todoHeight;
  //   background-color: $brandOrange;
  // }
  &.todo {
    // color: $brandOrange;
    // border-left: 12px solid $brandOrange;
  }
}
</style>