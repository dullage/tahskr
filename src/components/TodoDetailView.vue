<template>
  <div class="todo-detail-view">
    <!-- Top -->
    <div class="top">
      <p class="summary">{{ summary }}</p>

      <div class="row">
        <check-box :checked="completed" @toggled="toggleCompleted" />
        <span v-show="!completed" class="clickable" @click="toggleCompleted">Mark as completed</span>
        <span v-show="completed" class="clickable" @click="toggleCompleted">Completed: {{ completedDatetime }}</span>
      </div>

      <div class="row">
        <alert-circle-outline-icon class="clickable" @click="toggleImportant" />
        <span v-show="important" class="clickable" @click="toggleImportant">Unset as Important</span>
        <span v-show="!important" class="clickable" @click="toggleImportant">Set as Important</span>
      </div>

      <div class="row">
        <sleep-icon />
        <p>Snooze Until</p>
      </div>
      <input type="date" />
    </div>

    <!-- Bottom -->
    <div class="bottom">
      <div class="close-button-container">
        <span class="close-button" @click="close">
          <!-- <close-icon /> -->
          Close
        </span>
      </div>
    </div>
  </div>
</template>

<script>
import CheckBox from "./CheckBox.vue";
import EventBus from "../eventBus";

// Icons
import AlertCircleOutlineIcon from "icons/AlertCircleOutline.vue";
import CloseIcon from "icons/Close.vue";
import SleepIcon from "icons/Sleep.vue";

export default {
  components: {
    AlertCircleOutlineIcon,
    CloseIcon,
    CheckBox,
    SleepIcon
  },

  props: {
    todoId: { type: Number, required: true },
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
    close: function() {
      this.$emit("close");
    },

    toggleCompleted: function() {
      var newCompletedDatetime = null;
      if (this.completed == false) {
        newCompletedDatetime = new Date();
      }
      EventBus.$emit("update-todo-by-id", this.todoId, {
        completedDatetime: newCompletedDatetime
      });
    },

    toggleImportant: function() {
      EventBus.$emit("update-todo-by-id", this.todoId, {
        important: !this.important
      });
    }
  }
};
</script>

<style lang="scss" scoped>
@import "../common";

.todo-detail-view {
  background-color: $bgLightColor;
  color: $offWhite;
  width: 100%;
  // height: 100%;
  padding: 10px;
  display: flex;
  flex-direction: column;
  justify-content: space-between;
  // opacity: 0;
  // animation-name: fadein;
  // animation-duration: 300ms;
  // animation-delay: 500ms;
  // animation-fill-mode: forwards;
  .material-design-icon {
    font-size: 17px;
    margin-right: 8px;
  }
}

@keyframes fadein {
  from {
    opacity: 0;
  }
  to {
    opacity: 1;
  }
}

.top {
  margin-bottom: 20px;
}

.close-button-container {
  text-align: left;
}

.close-button {
  cursor: pointer;
  font-size: 17px;
}

.row {
  margin-bottom: 8px;
  display: flex;
  align-items: center;
}

.checkbox {
  margin: 0 10px 0 2px;
}

.summary {
  font-size: 19px;
  font-weight: bold;
  margin-bottom: 10px;
}
</style>