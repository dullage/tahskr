<template>
  <div id="container" @click="closeMenu">
    <div id="left-column">
      <div id="top-bar">
        <div @click.stop="menuOpen = !menuOpen">
          <menu-icon />
        </div>
        <logo :showIcon="true" :showPhonetic="false" :showSubtitle="false" />
      </div>

      <div id="menu" :class="{open: menuOpen}">
        <div class="button" @click="showCompleted = !showCompleted">
          <toggle-switch-off-outline-icon v-if="showCompleted == false" />
          <toggle-switch-outline-icon v-else />
          <span>Show Completed</span>
        </div>
        <div class="button" @click="refreshAll">
          <refresh-icon />
          <span>Refresh</span>
        </div>
        <div class="button" @click="logout">
          <logout-variant-icon />
          <span>Logout</span>
        </div>
        <!-- <button @click="refreshAll">Refresh</button>
        <button @click="logout">Log Out</button>
        <button @click="showCompleted = !showCompleted">Toggle Completed</button>-->
        <!-- <button @click="testMobile = !testMobile">Toggle Desktop / Mobile</button>
        <button @click="testOpen = !testOpen">Toggle Open / Close</button>-->
      </div>

      <p v-if="loading" style="color: white;">Loading...</p>

      <draggable v-else id="list-view" :list="db" @end="newTodoListOrder" handle=".drag-handle">
        <TodoList
          v-for="(list, index) in db"
          :listIndex="index"
          :id="list.id"
          :name="list.name"
          :show-completed="showCompleted"
          :key="list.id"
        />
      </draggable>

      <add-todo :auth="auth" @add-todo="addTodo"></add-todo>
    </div>

    <!-- <div
      id="right-column"
      :class="{ desktop: testDesktop, mobile: testMobile, open: testOpen, closed: testClosed }"
    >
      <p v-show="testOpen == true" @click="testOpen = !testOpen">Close</p>
    </div>-->
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
import Logo from "./Logo.vue";
import MenuIcon from "icons/Menu.vue";
import RefreshIcon from "icons/Refresh.vue";
import LogoutVariantIcon from "icons/LogoutVariant.vue";
import ToggleSwitchOutlineIcon from "icons/ToggleSwitchOutline.vue";
import ToggleSwitchOffOutlineIcon from "icons/ToggleSwitchOffOutline.vue";

export default {
  components: {
    AddTodo,
    draggable,
    TodoList,
    Logo,
    MenuIcon,
    RefreshIcon,
    LogoutVariantIcon,
    ToggleSwitchOutlineIcon,
    ToggleSwitchOffOutlineIcon
  },

  props: {
    auth: { type: Object, required: true }
  },

  data: function() {
    return {
      user: null,
      stagedTodoLists: null,
      stagedTodos: null,
      loading: true,
      db: [],
      showCompleted: false,
      menuOpen: false,
      testMobile: false,
      testOpen: false
    };
  },

  computed: {
    testDesktop: function() {
      return !this.testMobile;
    },
    testClosed: function() {
      return !this.testOpen;
    }
  },

  watch: {
    showCompleted: function(newValue) {
      if (newValue == true) {
        this.refreshAll();
      }
    }
  },

  methods: {
    closeMenu: function() {
      if (this.menuOpen == true) {
        this.menuOpen = false;
      }
    },

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
        parent.stagedTodoLists = r.data;
        parent.dataLoadedCheck();
      });
    },

    getTodos: function() {
      var parent = this;
      var completedOption = false;

      if (this.showCompleted == true) {
        completedOption = null;
      }

      api
        .get("/api/todo", { params: { completed: completedOption } })
        .then(function(r) {
          r.data.forEach(function(todo) {
            if (todo.completedDatetime != null) {
              todo.completedDatetime = new Date(todo.completedDatetime);
            }
          });
          parent.stagedTodos = r.data;
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
      this.sortTodos(this.stagedTodos, this.user.config.todoOrder);

      // Order todo lists
      this.sortTodoLists(this.stagedTodoLists, this.user.config.todoListOrder);

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

    todoIndexById: function(targetId) {
      for (var [listIndex, list] of Object.entries(this.db)) {
        for (var [todoIndex, todo] of Object.entries(list.todos)) {
          if (todo.id == targetId) {
            return [listIndex, todoIndex];
          }
        }
      }
    },

    sortTodoLists: function(toSort, order) {
      toSort.sort(function(a, b) {
        let aIndex = order.indexOf(a.id);
        let bIndex = order.indexOf(b.id);
        // Both ordered
        if (aIndex > -1 && bIndex > -1) {
          return aIndex - bIndex;
        }
        // Neither ordered
        if (aIndex == -1 && bIndex == -1) {
          return 0;
        }
        // One ordered - Prioritise ordered over unordered
        else {
          if (aIndex == -1) {
            return 1;
          } else {
            return -1;
          }
        }
      });
    },

    sortTodos: function(toSort, order) {
      toSort.sort(function(a, b) {
        // TODO: This is a duplication of the above.
        // Order incomplete by user config
        if (a.completedDatetime == null && b.completedDatetime == null) {
          let aIndex = order.indexOf(a.id);
          let bIndex = order.indexOf(b.id);
          // Both ordered
          if (aIndex > -1 && bIndex > -1) {
            return aIndex - bIndex;
          }
          // Neither ordered
          if (aIndex == -1 && bIndex == -1) {
            return 0;
          }
          // One ordered - Prioritise ordered over unordered
          else {
            if (aIndex == -1) {
              return 1;
            } else {
              return -1;
            }
          }
        }
        // Order complete by completedDatetime DESC
        else if (a.completedDatetime != null && b.completedDatetime != null) {
          return b.completedDatetime - a.completedDatetime;
        }
        // Order incomplete above complete
        else {
          if (a.completedDatetime == null) {
            return -1;
          } else {
            return 1;
          }
        }
      });
    },

    sortListByIndex: function(listIndex) {
      this.sortTodos(this.db[listIndex].todos, this.user.config.todoOrder);
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
          if (todo.completedDatetime == null) {
            order.push(todo.id);
          }
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
    },

    updateTodoByIndex: function(listIndex, todoIndex, updates) {
      var todo = this.db[listIndex].todos[todoIndex];
      Object.assign(todo, updates);
      api.patch(`/api/todo/${todo.id}`, updates);
      this.sortListByIndex(listIndex);
    },

    updateTodoById: function(id, updates) {
      var [listIndex, todoIndex] = this.todoIndexById(id);
      this.updateTodoByIndex(listIndex, todoIndex, updates);
    }
  },

  created: function() {
    EventBus.$on("new-todo-order", this.newTodoOrder);
    EventBus.$on("update-todo-by-id", this.updateTodoById);
    EventBus.$on("update-todo-by-index", this.updateTodoByIndex);
    this.refreshAll();
  }
};
</script>

<style lang="scss" scoped>
@import "../common";

#container {
  width: 100%;
  height: 100%;
  display: flex;
  flex-direction: row;
  position: relative;
}

#top-bar {
  margin: 0 0 20px 0;
  padding: 0 4px;
  display: flex;
  align-items: center;
  .menu-icon {
    margin: 0 18px 0 6px;
    font-size: 24px;
    color: $offWhite;
    cursor: pointer;
  }
}

#menu {
  z-index: 1;
  margin: 3px;
  height: 0px;
  transition: height 300ms;
  position: absolute;
  top: 50px;
  left: 8px;
  background-color: $bgColor;
  overflow: hidden;
  &.open {
    margin: 0;
    height: 114px;
    border: 3px solid $bgLightColor;
  }
  .button {
    cursor: pointer;
    font-size: 18px;
    margin: 10px;
    color: $offWhite;
  }
}

#left-column {
  flex: 1 1 auto;

  // Space for the AddTodo component
  &::after {
    content: "";
    height: 16px;
    display: block;
  }
}

#list-view {
  padding: 0 4px;
}

#right-column {
  background-color: lightgray;
  &.desktop {
    width: 400px;
    flex: 0 0 auto;
  }
  &.mobile {
    position: absolute;
    right: 0;
    height: 100%;
    transition: width 2s;
    &.open {
      width: 1024px;
      transition: width 2s;
    }
    &.closed {
      width: 0px;
      transition: width 2s;
    }
  }
}
</style>