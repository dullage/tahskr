<template>
  <p>
    <span>
      <input type="checkbox" v-model="completed" @change="updateCompleted" />
    </span>
    {{ dbItem.summary }}
    <span>
      <input type="checkbox" v-model="important" @change="updateImportant" />
    </span>
  </p>
</template>

<script>
import api from "../api";

export default {
  props: {
    listIndex: Number,
    todoIndex: Number
  },

  data: function() {
    return {
      dbItem: this.$parent.$parent.$parent.$parent.db[this.listIndex].todos[
        this.todoIndex
      ],
      completed: false,
      important: false
    };
  },

  methods: {
    updateCompleted: function() {
      var completedDatetime = null;
      if (this.completed == true) {
        completedDatetime = new Date();
      }
      // TODO: This currently adds a Date object to the dbItem and not a string.
      this.dbItem.completedDatetime = completedDatetime;
      api.patch(`/api/todo/${this.dbItem.id}`, {
        completedDatetime: completedDatetime
      });
    },

    updateImportant: function() {
      this.dbItem.important = this.important;
      api.patch(`/api/todo/${this.dbItem.id}`, {
        important: this.important
      });
    }
  },

  created: function() {
    // Initialise the completed value
    if (this.dbItem.completedDatetime != null) {
      this.completed = true;
    }
    // Initialise the important value
    this.important = this.dbItem.important;
  }
};
</script>

<style scoped>
p {
  border: 1px solid grey;
  padding: 4px;
  margin: 4px;
  cursor: grab;
}
</style>