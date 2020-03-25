<template>
  <div class="todo-detail-view">
    <close-icon class="clickable" @click="close" />

    <!-- Top -->
    <div class="top">
      <!-- Summary -->
      <div class="row">
        <!-- View -->
        <span v-show="!editSummaryMode" class="summary">{{ summary }}</span>
        <div v-show="!editSummaryMode">
          <pencil-icon class="clickable edit-summary-button" @click="editSummary" />
        </div>

        <!-- Edit -->
        <input
          v-show="editSummaryMode"
          id="input-summary"
          class="summary"
          type="text"
          v-model="summaryInput"
        />
        <div v-show="editSummaryMode">
          <content-save-icon class="clickable" @click="saveSummary" />
        </div>
      </div>

      <!-- Completed -->
      <div class="row">
        <check-box :checked="completed" @toggled="toggleCompleted" />
        <span v-show="!completed" class="clickable" @click="toggleCompleted">Mark as completed</span>
        <span
          v-show="completed"
          class="clickable"
          @click="toggleCompleted"
        >Completed: {{ formattedCompletedDatetime }}</span>
      </div>

      <!-- Important -->
      <div class="row">
        <alert-circle-outline-icon class="clickable" @click="toggleImportant" />
        <span v-show="important" class="clickable" @click="toggleImportant">Unset as Important</span>
        <span v-show="!important" class="clickable" @click="toggleImportant">Set as Important</span>
      </div>

      <!-- Snooze -->
      <div class="row">
        <sleep-icon />
        <span>Snooze Until</span>
      </div>

      <date-picker is-dark color="yellow" v-model="snoozeDatetimeInput" />
    </div>

    <!-- Bottom -->
    <div class="bottom">
      <p class="created-timestamp">Created: {{ formattedCreated }}</p>
    </div>
  </div>
</template>

<script>
import CheckBox from "./CheckBox.vue";
import DatePicker from "v-calendar/lib/components/date-picker.umd";
import EventBus from "../eventBus";
import helpers from "../helpers";

// Icons
import AlertCircleOutlineIcon from "icons/AlertCircleOutline.vue";
import CloseIcon from "icons/Close.vue";
import SleepIcon from "icons/Sleep.vue";
import PencilIcon from "icons/Pencil.vue";
import ContentSaveIcon from "icons/ContentSave.vue";

export default {
  components: {
    AlertCircleOutlineIcon,
    CloseIcon,
    CheckBox,
    DatePicker,
    SleepIcon,
    PencilIcon,
    ContentSaveIcon
  },

  props: {
    todoId: { type: Number, required: true },
    summary: { type: String, required: true },
    completedDatetime: { type: Date },
    important: { type: Boolean, required: true },
    snoozeDatetime: { type: Date },
    created: { type: Date, required: true }
  },

  data: function() {
    return {
      summaryInput: null,
      snoozeDatetimeInput: null,
      editSummaryMode: false
    };
  },

  computed: {
    completed: function() {
      if (this.completedDatetime == null) {
        return false;
      } else {
        return true;
      }
    },

    formattedCompletedDatetime: function() {
      return helpers.formatDate(this.completedDatetime, true);
    },

    formattedCreated: function() {
      return helpers.formatDate(this.created, true);
    }
  },

  watch: {
    todoId: function() {
      this.inputInit();
    },
    snoozeDatetimeInput: function() {
      EventBus.$emit("update-todo-by-id", this.todoId, {
        snoozeDatetime: this.snoozeDatetimeInput
      });
    }
  },

  methods: {
    close: function() {
      this.$emit("close");
    },

    inputInit: function() {
      this.summaryInput = this.summary;
      this.snoozeDatetimeInput = this.snoozeDatetime;
    },

    editSummary: function() {
      this.editSummaryMode = true;

      // Wait for the input the be rendered then set focus.
      this.$nextTick(function() {
        document.getElementById("input-summary").select();
      });
    },

    saveSummary: function() {
      if (this.summaryInput != this.summary) {
        EventBus.$emit("update-todo-by-id", this.todoId, {
          summary: this.summaryInput
        });
      }
      this.editSummaryMode = false;
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
  },

  created: function() {
    this.inputInit();
  }
};
</script>

<style lang="scss" scoped>
@import "../common";

.todo-detail-view {
  background-color: $bgColor;
  color: $offWhite;
  width: 100%;
  height: 100%;
  padding: 10px;
  display: flex;
  flex-direction: column;
  justify-content: space-between;
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

.close-icon {
  position: absolute;
  top: 4px;
  right: 1px;
  font-size: 24px !important;
}

.row {
  margin-bottom: 10px;
  display: flex;
  align-items: center;
}

.checkbox {
  margin: 0 10px 0 2px;
}

.summary {
  font-size: 19px;
  font-weight: bold;
  margin-right: 4px;
  padding: 6px 0;
}

input.summary {
  background-color: $bgColor;
  color: $offWhite;
  border: 2px solid $bgLightColor;
  padding: 4px 12px;
  width: calc(100% - 60px);
  &:focus {
    outline: none;
  }
}

.edit-summary-button {
  color: $subduedColor;
  &:hover {
    color: $offWhite;
  }
}

.created-timestamp {
  color: $subduedColor;
  font-size: 0.8em;
  text-align: center;
}
</style>