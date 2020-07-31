<template>
  <div class="list">
    <div class="list-title drag-handle">
      <span>
        <drag-icon />
        {{ name }}
      </span>
    </div>

    <div class="todos-container" :class="{empty: empty}">
      <p class="placeholder">EMPTY</p>

      <draggable
        :list="todos"
        group="todos"
        @change="onChange"
        @end="newTodoOrder"
        invert-swap="true"
        class="todos"
        delay="400"
        delay-on-touch-only="false"
        touch-start-threshold="3"
        force-fallback="true"
        filter=".no-drag"
      >
        <!-- <transition-group name="drag"> -->
        <Todo
          v-for="(todo, todoIndex) in todos"
          v-show="((showCompleted == true || todo.completedDatetime == null) && (showSnoozed == true || todo.snoozeDatetime == null || todo.snoozeDatetime < Date.now())) || todo.id == selectedTodoId"
          :list-index="listIndex"
          :todo-index="todoIndex"
          :id="todo.id"
          :summary="todo.summary"
          :completed-datetime="todo.completedDatetime"
          :important="todo.important"
          :snooze-datetime="todo.snoozeDatetime"
          :selected-todo-id="selectedTodoId"
          :key="todo.id"
        />
        <!-- </transition-group> -->
      </draggable>
    </div>
  </div>
</template>

<script>
import api from "../api";
import draggable from "vuedraggable";
import DragIcon from "icons/Drag.vue";
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
    showCompleted: { type: Boolean, required: true },
    showSnoozed: { type: Boolean, required: true },
    selectedTodoId: { type: Number }
  },

  data: function() {
    return {
      todos: this.$parent.$parent.db[this.listIndex].todos
    };
  },

  computed: {
    countTodos: function() {
      return this.todos.length;
    },
    countIncompleteTodos: function() {
      return this.todos.filter(todo => todo.completedDatetime == null).length;
    },
    empty: function() {
      if (this.showCompleted == true) {
        return this.countTodos == 0;
      } else {
        return this.countIncompleteTodos == 0;
      }
    }
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
  margin-bottom: $todoListBottomMargin;
}

.list-title {
  margin: 0 0 4px 0;
  display: inline-block;
  padding: 6px 10px 6px 6px;
  background-color: $bgLightColor;
  color: $offWhite;
  text-transform: uppercase;
}

.drag-handle {
  cursor: move;
}

.todos-container {
  position: relative;
}

.placeholder {
  position: absolute;
  width: 100%;
  height: $todoMinHeight;
  color: $subduedColor;
  text-align: center;
  font-size: 0.8em;
  border: $bgLightColor 2px dashed;
  line-height: 30px;
  opacity: 0;
  transition: opacity 100ms;
  pointer-events: none;
}

.empty .placeholder {
  opacity: 1;
}

.todos {
  min-height: $todoMinHeight;
}

// .drag-move {
//   transition: transform 0.5s;
// }
</style>