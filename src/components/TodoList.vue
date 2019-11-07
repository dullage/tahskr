<template>
  <div class="list">
    <div class="list-title drag-handle">
      <span>
        <drag-icon  />
        {{ name }}
      </span>
    </div>

    <draggable
      :list="todos"
      group="todos"
      @change="onChange"
      @end="newTodoOrder"
      invert-swap="true"
    >
      <Todo
        v-for="(todo, todoIndex) in todos"
        v-show="showCompleted == true || todo.completedDatetime == null"
        :list-index="listIndex"
        :todo-index="todoIndex"
        :id="todo.id"
        :summary="todo.summary"
        :completed-datetime="todo.completedDatetime"
        :important="todo.important"
        :key="todo.id"
      />
    </draggable>
  </div>
</template>

<script>
import api from "../api";
import DragIcon from "icons/Drag.vue";
import draggable from "vuedraggable";
import EventBus from "../eventBus.js";
import Todo from "./Todo.vue";

export default {
  components: {
    draggable,
    Todo,
    DragIcon
  },

  props: {
    listIndex: { type: Number, required: true },
    id: { type: Number, required: true },
    name: { type: String, required: true },
    showCompleted: { type: Boolean, required: true }
  },

  data: function() {
    return {
      todos: this.$parent.$parent.db[this.listIndex].todos
    };
  },

  methods: {
    newTodoOrder: function() {
      this.$forceUpdate();
      EventBus.$emit("new-todo-order");
    },

    onChange: function(evt) {
      if ("added" in evt) {
        this.onAdd(evt);
      }
    },

    onAdd: function(evt) {
      this.$forceUpdate();
      var newListId = this.id;
      if (this.id == 0) {
        newListId = null;
      }
      EventBus.$emit("update-todo-by-id", evt.added.element.id, {
        listId: newListId
      });
    }
  }
};
</script>

<style lang="scss" scoped>
@import "../common";

.list {
  margin: 0 0 40px 0;
}

.list-title {
  display: inline-block;
  padding: 6px 10px 6px 6px;
  background-color: $bgLightColor;
  color: $offWhite;
  text-transform: uppercase;
}

.drag-handle {
  cursor: move;
}
</style>