<template>
  <div>
    <add-todo :auth="auth" @add-todo="addTodo"></add-todo>

    <br />

    <draggable :list="db" @end="newTodoListOrder" invert-swap="true">
      <TodoList v-for="(list, index) in db" :listIndex="index" :key="list.id" />
    </draggable>

    <br />

    <button @click="refreshAll">Refresh</button>
    <button @click="logout">Log Out</button>
    <button @click="showCompleted = !showCompleted">Toggle Completed</button>
  </div>
</template>

<script>
import axios from "axios";
import draggable from "vuedraggable";
import api from "../api";
import EventBus from "../eventBus";
import AddTodo from "./AddTodo.vue";
import TodoList from "./TodoList.vue";
import configSchema from "../configSchema";

export default {
  components: {
    AddTodo,
    draggable,
    TodoList
  },

  props: {
    auth: Object
  },

  data: function() {
    return {
      user: null,
      stagedTodoLists: null,
      stagedTodos: null,
      loading: true,
      db: [],
      showCompleted: false
    };
  },

  watch: {
    showCompleted: function() {
      this.refreshAll();
    }
  },

  methods: {
    getUser: function() {
      var parent = this;
      api.get(`/api/user/${this.auth.userId}`).then(function(r) {
        r.data.config = configSchema.validate(r.data.config).value;
        parent.user = r.data;
        parent.dataLoadedCheck();
      });
    },

    getTodoLists: function() {
      var parent = this;
      api.get("/api/todolist").then(function(r) {
        parent.stagedTodoLists = r.data.slice();
        parent.dataLoadedCheck();
      });
    },

    getTodos: function() {
      var parent = this;
      var completedOption = null;

      if (this.showCompleted == false) {
        this.completedOption = false;
      }

      api
        .get("/api/todo", { headers: { completed: completedOption } })
        .then(function(r) {
          parent.stagedTodos = r.data.slice();
          parent.dataLoadedCheck();
        });
    },

    refreshAll: function() {
      this.loading = true;
      this.db.splice(0, this.db.length);
      this.getUser();
      this.getTodoLists();
      this.getTodos();
    },

    dataLoadedCheck: function() {
      if (
        this.user != null &&
        this.stagedTodoLists != null &&
        this.stagedTodos != null
      ) {
        this.processStagedData();
      }
    },

    processStagedData: function() {
      var parent = this;

      // Add default Inbox list
      this.stagedTodoLists.push({ id: 0, name: "Inbox", todos: [] });

      // Order todos
      this.order(this.stagedTodos, this.user.config.todoOrder);

      // Order todo lists
      this.order(this.stagedTodoLists, this.user.config.todoListOrder);

      // Add user lists
      this.stagedTodoLists.forEach(function(value) {
        value.todos = [];
        parent.db.push(value);
      });

      // Add todos
      this.stagedTodos.forEach(function(value) {
        var listIndex;
        if (value.listId != null) {
          listIndex = parent.listIndexById(value.listId);
        } else {
          listIndex = parent.listIndexById(0);
        }
        parent.db[listIndex].todos.push(value);
      });

      this.loading = false;
      this.stagedTodoLists = null;
      this.stagedTodos = null;
    },

    listIndexById: function(targetId) {
      return this.db.findIndex(function(list) {
        return list.id == targetId;
      });
    },

    order: function(toSort, order) {
      toSort.sort(function(a, b) {
        return order.indexOf(a.id) - order.indexOf(b.id);
      });
    },

    getTodoListOrder: function() {
      var order = [];
      this.db.forEach(function(list) {
        order.push(list.id);
      });
      return order;
    },

    getTodoOrder: function() {
      var order = [];
      this.db.forEach(function(list) {
        list.todos.forEach(function(todo) {
          order.push(todo.id);
        });
      });
      return order;
    },

    postConfig: function() {
      var parent = this;
      api.patch(`/api/user/${this.auth.userId}`, {
        config: this.user.config
      });
    },

    newTodoListOrder: function() {
      this.user.config.todoListOrder = this.getTodoListOrder();
      this.postConfig();
    },

    newTodoOrder: function() {
      this.user.config.todoOrder = this.getTodoOrder();
      this.postConfig();
    },

    addTodo: function(todo) {
      this.db[this.listIndexById(0)].todos.push(todo);
    },

    logout: function() {
      EventBus.$emit("logout");
    }
  },

  created: function() {
    EventBus.$on("new-todo-order", this.newTodoOrder);
    this.refreshAll();
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

h2 {
  cursor: grab;
}
</style>