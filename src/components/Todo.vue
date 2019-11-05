<template>
  <div :class="{ complete: completed, incomplete: !completed }" class="todo">
    <div class="checkbox" @click="toggleCompleted">
      <check-bold-icon class="check-box-icon" />
    </div>

    <span class="summary">{{ summary }}</span>

    <!-- <span @click="toggleCompleted">
      Completed:
      <span v-show="completed">Yes</span>
      <span v-show="!completed">No</span>
    </span>-->

    <!-- <span @click="toggleImportant">
      Important:
      <span v-show="important">Yes</span>
      <span v-show="!important">No</span>
    </span>-->
  </div>
</template>

<script>
import api from "../api";
import CheckBoldIcon from "icons/CheckBold.vue";
import EventBus from "../eventBus.js";

export default {
  components: {
    CheckBoldIcon
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
@import "../main";

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

.checkbox {
  height: 16px;
  width: 16px;
  margin: 10px;
  background-color: white;
  cursor: pointer;
  color: $bgColor;
  display: flex;
  justify-content: center;
  align-items: center;
  font-size: 12px;
}

.check-box-icon {
  margin: 0 0 3px 0;
}

.complete {
  .checkbox {
    background-color: $disabledColor;
  }
  .summary {
    text-decoration: line-through;
    color: $disabledColor;
  }
}

.incomplete {
  .check-box-icon {
    display: none;
  }
  .checkbox:hover {
    .check-box-icon {
      display: block;
      opacity: 50%;
    }
  }
}
</style>