<template>
  <div class="todo-detail-view">
    <!-- Top -->
    <div class="top">
      <p class="summary">{{ summary }}</p>

      <div class="row">
        <check-box :checked="completed" @toggled="toggleCompleted" />
        <span v-show="!completed">Mark as completed</span>
        <span v-show="completed">Completed: {{ completedDatetime }}</span>
      </div>
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
import CloseIcon from "icons/Close.vue";
import CheckBox from "./CheckBox.vue";
import EventBus from "../eventBus";

export default {
  components: {
    CloseIcon,
    CheckBox
  },

  props: {
    todoId: { type: Number, required: true },
    summary: { type: String, required: true },
    completedDatetime: { type: Date }
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
}

@keyframes fadein {
    from { opacity: 0; }
    to   { opacity: 1; }
}

.top {
  margin-bottom: 100px;
}

.close-button-container {
  text-align: left;
}

.close-button {
  cursor: pointer;
  font-size: 17px;
}

p,
.row {
  margin-bottom: 6px;
}

.row {
  display: flex;
  align-items: center;
}

.checkbox {
  margin-right: 8px;
}

.summary {
  font-size: 17px;
  font-weight: bold;
}
</style>