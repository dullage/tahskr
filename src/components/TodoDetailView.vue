<template>
  <div class="todo-detail-view">
    <close-icon class="clickable" @click="close" />

    <!-- Summary -->
    <div class="row">
      <!-- View -->
      <span v-show="!editSummaryMode" class="summary" @click="summaryClick">{{ summary }}</span>
      <div v-show="!editSummaryMode">
        <pencil-icon class="clickable edit-button hover-button" @click="editSummary" />
      </div>

      <!-- Edit -->
      <input
        v-show="editSummaryMode"
        id="input-summary"
        class="summary"
        type="text"
        v-model="summaryInput"
        @keyup.enter="saveSummary"
        @blur="saveSummary"
      />
      <div v-show="editSummaryMode">
        <content-save-icon class="clickable save-button" @click="saveSummary" />
      </div>
    </div>

    <!-- Completed -->
    <div class="row">
      <check-box :dimWhenChecked="true" :checked="completed" @toggled="toggleCompleted" />
      <span v-show="!completed" class="clickable" @click="toggleCompleted">Mark as completed</span>
      <span
        v-show="completed"
        class="clickable"
        @click="toggleCompleted"
      >Completed: {{ formattedCompletedDatetime }}</span>
    </div>

    <!-- Important -->
    <div class="row important-row">
      <check-box :checked="important" @toggled="toggleImportant" />
      <span class="clickable" @click="toggleImportant">Important</span>
      <alert-circle-outline-icon class="clickable" @click="toggleImportant" />
    </div>

    <!-- Snooze -->
    <div class="header-row snooze-row">
      <check-box :checked="snoozeDatetimeInput != null" @toggled="toggleSnooze" />
      <span class="clickable" @click="toggleSnooze">Snooze</span>
      <sleep-icon class="clickable" @click="toggleSnooze" />
    </div>

    <div class="row">
      <date-picker
        class="date-picker"
        is-dark
        color="yellow"
        v-model="snoozeDatetimeInput"
        :popover="{ placement: 'bottom-start', visibility: 'click' }"
      />
    </div>

    <!-- Notes -->
    <div class="header-row">
      <span>Notes</span>
      <div v-show="!editNotesMode">
        <pencil-icon class="clickable edit-button hover-button" @click="editNotes" />
      </div>
      <div v-show="editNotesMode">
        <content-save-icon class="clickable save-button" @click="saveNotes" />
      </div>
    </div>

    <span v-show="!editNotesMode" class="notes" @click="notesClick">{{ notes }}</span>
    <textarea
      v-show="editNotesMode"
      v-model="notesInput"
      class="notes"
      id="input-notes"
      @blur="saveNotes"
      @keyup.ctrl.enter="saveNotes"
    ></textarea>

    <!-- Created Date -->
    <p class="created-timestamp">Created: {{ formattedCreated }}</p>

    <!-- Delete Button -->
    <trash-can-outline-icon class="clickable hover-button" @click="deleteTodo" />
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
import TrashCanOutlineIcon from "icons/TrashCanOutline.vue";

export default {
  components: {
    AlertCircleOutlineIcon,
    CloseIcon,
    CheckBox,
    DatePicker,
    SleepIcon,
    PencilIcon,
    ContentSaveIcon,
    TrashCanOutlineIcon,
  },

  props: {
    todoId: { type: Number, required: true },
    summary: { type: String, required: true },
    completedDatetime: { type: Date },
    important: { type: Boolean, required: true },
    snoozeDatetime: { type: Date },
    created: { type: Date, required: true },
    notes: { type: String },
  },

  data: function () {
    return {
      summaryInput: null,
      editSummaryMode: false,
      notesInput: null,
      editNotesMode: false,
      snoozeDatetimeInput: null,
    };
  },

  computed: {
    completed: function () {
      if (this.completedDatetime == null) {
        return false;
      } else {
        return true;
      }
    },

    formattedCompletedDatetime: function () {
      return helpers.formatDate(this.completedDatetime, true);
    },

    formattedCreated: function () {
      return helpers.formatDate(this.created, true);
    },
  },

  watch: {
    todoId: function () {
      this.init();
    },
    snoozeDatetimeInput: function () {
      EventBus.$emit("update-todo-by-id", this.todoId, {
        snoozeDatetime: this.snoozeDatetimeInput,
      });
    },
  },

  methods: {
    close: function () {
      this.$emit("close");
    },

    init: function () {
      this.summaryInput = this.summary;
      this.notesInput = this.notes;
      this.editSummaryMode = false;
      this.editNotesMode = false;
      this.snoozeDatetimeInput = this.snoozeDatetime;
    },

    summaryClick: function () {
      if (window.getSelection().toString().length == 0) {
        this.editSummary();
      }
    },

    editSummary: function () {
      this.editSummaryMode = true;

      // Wait for the input the be rendered then set focus.
      this.$nextTick(function () {
        document.getElementById("input-summary").select();
      });
    },

    saveSummary: function () {
      if (this.summaryInput != this.summary) {
        EventBus.$emit("update-todo-by-id", this.todoId, {
          summary: this.summaryInput,
        });
      }
      this.editSummaryMode = false;
    },

    notesClick: function () {
      if (window.getSelection().toString().length == 0) {
        this.editNotes();
      }
    },

    editNotes: function () {
      this.editNotesMode = true;

      // Wait for the input the be rendered then set focus.
      this.$nextTick(function () {
        document.getElementById("input-notes").select();
      });
    },

    saveNotes: function () {
      if (this.notesInput != this.notes) {
        EventBus.$emit("update-todo-by-id", this.todoId, {
          notes: this.notesInput,
        });
      }
      this.editNotesMode = false;
    },

    toggleCompleted: function () {
      var newCompletedDatetime = null;
      if (this.completed == false) {
        newCompletedDatetime = new Date();
      }
      EventBus.$emit("update-todo-by-id", this.todoId, {
        completedDatetime: newCompletedDatetime,
      });
    },

    toggleImportant: function () {
      EventBus.$emit("update-todo-by-id", this.todoId, {
        important: !this.important,
      });
    },

    toggleSnooze: function () {
      if (this.snoozeDatetimeInput == null) {
        var tomorrow = new Date();
        tomorrow.setDate(tomorrow.getDate() + 1);
        this.snoozeDatetimeInput = tomorrow;
      } else {
        this.snoozeDatetimeInput = null;
      }
    },

    deleteTodo: function () {
      if (window.confirm("Are you sure you want to delete this tahsk?")) {
        EventBus.$emit("delete-todo-by-id", this.todoId);
      }
    },
  },

  created: function () {
    this.init();
  },
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
}

@keyframes fadein {
  from {
    opacity: 0;
  }
  to {
    opacity: 1;
  }
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

.header-row {
  margin-bottom: 2px;
  display: flex;
  align-items: center;
}

.checkbox {
  margin: 0 10px 0 2px;
}

.summary {
  font-size: 19px;
  font-weight: bold;
  padding: 6px 0;
}

input.summary {
  width: calc(100% - 60px);
  &:focus {
    outline: none;
  }
}

.notes {
  overflow: auto;
  flex: 1 1 auto;
  white-space: pre-wrap;
  cursor: text;
  padding: 4px 10px;
  border: solid 2px $bgLightColor;
  font-size: 14px;
}

input.summary,
textarea.notes {
  background-color: $bgColor;
  color: $offWhite;
  border: none;
  border-bottom: 2px solid $bgLightColor;
}

textarea.notes {
  flex: 1 1 auto;
  resize: none;
  outline: none;
  padding: 4px 10px;
  border: solid 2px lighten($bgLightColor, 10%);
}

.hover-button {
  color: $subduedColor;
  @media (hover: hover) {
    &:hover {
      color: $offWhite;
    }
  }
}

.edit-button {
  margin-left: 6px;
}

.save-button {
  margin-left: 6px;
  color: $offWhite;
}

.created-timestamp {
  color: $subduedColor;
  font-size: 0.8em;
  text-align: center;
  margin-top: 14px;
}

.trash-can-outline-icon {
  position: absolute;
  bottom: 14px;
  right: 6px;
}

.important-row .material-design-icon {
  margin: 0 0 5px 3px;
}

.snooze-row .material-design-icon {
  margin: 0 0 5px 6px;
}
</style>