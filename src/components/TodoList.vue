<template>
  <div>
    <h2>{{ dbItem.name }}</h2>
    <draggable
      :list="dbItem.todos"
      group="todos"
      @change="onAdd"
      @end="newTodoOrder"
      invert-swap="true"
    >
      <Todo
        v-for="(todo, index) in dbItem.todos"
        :list-index="listIndex"
        :todoIndex="index"
        :key="todo.id"
      />
    </draggable>
  </div>
</template>

<script>
import draggable from "vuedraggable";
import Todo from "./Todo.vue";
import EventBus from "../eventBus.js";
import api from "../api";

export default {
  components: {
    draggable,
    Todo
  },

  props: {
    listIndex: Number
  },

  data: function() {
    return {
      dbItem: this.$parent.$parent.db[this.listIndex]
    }
  },

  methods: {
    newTodoOrder: function() {
      this.$forceUpdate();
      EventBus.$emit("new-todo-order");
    },

    onAdd: function(evt) {
      if ("added" in evt) {
        this.$forceUpdate();
        var todoId = evt.added.element.id;
        var newListId;
        if (this.dbItem.id == 0) {
          newListId = null;
        } else {
          newListId = this.dbItem.id;
        }
        api.patch(`/api/todo/${todoId}`, { listId: newListId });
      }
    }
  }
};
</script>

<style scoped>
h2 {
  cursor: move;
}
</style>