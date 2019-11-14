<template>
  <div id="container" @click="closeMenu">
    <div id="left-column">
      <div id="top-bar">
        <logo :showIcon="true" :showPhonetic="false" :showSubtitle="false" />
      </div>

      <div id="content-area">
        <div v-if="loading" class="loader">Loading...</div>

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
      </div>

      <div id="bottom-bar">
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
        </div>

        <div @click.stop="menuOpen = !menuOpen">
          <menu-icon />
        </div>
        <add-todo :auth="auth" @add-todo="addTodo"></add-todo>
      </div>
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
  @media #{$mobile} {
    justify-content: center;
  }
}

#left-column {
  flex: 1 1 auto;

  // Space for the bottom bar
  &::after {
    content: "";
    height: 12px;
    display: block;
  }
}

#content-area {
  width: 100%;
  height: 100%;
  display: flex;
  justify-content: center;
}

.loader,
.loader:before,
.loader:after {
  background: $subduedColor;
  -webkit-animation: load1 1s infinite ease-in-out;
  animation: load1 1s infinite ease-in-out;
  width: 1em;
  height: 4em;
}
.loader {
  color: $subduedColor;
  text-indent: -9999em;
  margin: 33% auto;
  position: relative;
  font-size: 11px;
  -webkit-transform: translateZ(0);
  -ms-transform: translateZ(0);
  transform: translateZ(0);
  -webkit-animation-delay: -0.16s;
  animation-delay: -0.16s;
}
.loader:before,
.loader:after {
  position: absolute;
  top: 0;
  content: "";
}
.loader:before {
  left: -1.5em;
  -webkit-animation-delay: -0.32s;
  animation-delay: -0.32s;
}
.loader:after {
  left: 1.5em;
}
@-webkit-keyframes load1 {
  0%,
  80%,
  100% {
    box-shadow: 0 0;
    height: 4em;
  }
  40% {
    box-shadow: 0 -2em;
    height: 5em;
  }
}
@keyframes load1 {
  0%,
  80%,
  100% {
    box-shadow: 0 0;
    height: 4em;
  }
  40% {
    box-shadow: 0 -2em;
    height: 5em;
  }
}

#list-view {
  flex: 1 1 auto;
  padding: 0 4px;
}

#bottom-bar {
  position: fixed;
  bottom: 0;
  width: 100%;
  max-width: $appWidth;
  border-top: 2px solid $bgLightColor;
  background-color: $bgColor;
  display: flex;
  align-items: center;
  .menu-icon {
    margin: 0 12px;
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
  bottom: 40px;
  left: 4px;
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
      width: $appWidth;
      transition: width 2s;
    }
    &.closed {
      width: 0px;
      transition: width 2s;
    }
  }
}
</style>