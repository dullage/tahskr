<template>
  <div class="main-app" @click="closeMenu">
    <div class="top-bar">
      <logo :showIcon="true" :showPhonetic="false" :showSubtitle="false" />
    </div>

    <div class="content-area" :class="{ 'detail-view-open': detailViewOpen }">
      <div class="left-column">
        <div v-if="loading" class="loader">Loading...</div>

        <draggable v-else class="todos" :list="db" @end="newTodoListOrder" handle=".drag-handle">
          <TodoList
            v-for="(list, index) in db"
            :listIndex="index"
            :id="list.id"
            :name="list.name"
            :show-completed="showCompleted"
            :selected-todo-id="selectedTodoId"
            :key="list.id"
          />
        </draggable>
      </div>

      <div class="detail-view">
        <todo-detail-view
          v-if="selectedTodoId != null"
          @close="selectedTodoId = null"
          :todo-id="selectedTodo.id"
          :summary="selectedTodo.summary"
          :completed-datetime="selectedTodo.completedDatetime"
          :important="selectedTodo.important"
        />
      </div>
    </div>

    <bottom-bar
      :show-completed="showCompleted"
      @toggle-completed="showCompleted = !showCompleted"
      @refresh="refreshAll"
      @logout="logout"
    />
  </div>
</template>

<script>
import api from "../api";
import BottomBar from "./BottomBar.vue";
import configSchema from "../configSchema";
import TodoDetailView from "./TodoDetailView.vue";
import draggable from "vuedraggable";
import EventBus from "../eventBus";
import Logo from "./Logo.vue";
import TodoList from "./TodoList.vue";

export default {
  components: {
    BottomBar,
    TodoDetailView,
    draggable,
    Logo,
    TodoList
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
      selectedTodoId: null
    };
  },

  computed: {
    detailViewOpen: function() {
      return this.selectedTodoId != null;
    },

    selectedTodo: function() {
      if (this.selectedTodoId == null) {
        return null;
      } else {
        var [listIndex, todoIndex] = this.todoIndexById(this.selectedTodoId);
        return this.db[listIndex].todos[todoIndex];
      }
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
      EventBus.$emit("close-menu");
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
      this.selectedTodoId = null;
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
    },

    selectTodo: function(selectedTodoId) {
      this.selectedTodoId = selectedTodoId;
    }
  },

  created: function() {
    EventBus.$on("new-todo-order", this.newTodoOrder);
    EventBus.$on("update-todo-by-id", this.updateTodoById);
    EventBus.$on("update-todo-by-index", this.updateTodoByIndex);
    EventBus.$on("select-todo", this.selectTodo);
    EventBus.$on("add-todo", this.addTodo);
    this.refreshAll();
  }
};
</script>

<style lang="scss" scoped>
@import "../common";
@import "../loader";

.main-app {
  width: 100%;
  height: 100%;
  display: flex;
  flex-direction: column;
  position: relative;
}

.top-bar {
  position: fixed;
  z-index: 1;
  flex: 1 1 auto;
  width: 100%;
  height: $topBarHeight;
  max-width: $appWidth;
  padding: 0 4px;
  background-color: $bgColor;
  border-bottom: 2px solid $bgLightColor;
  display: flex;
  align-items: flex-start;
  @media #{$mobile} {
    justify-content: center;
  }
}

.left-column {
  flex: 1 1 auto;
  transition: margin 500ms;
}

.content-area {
  display: flex;
  justify-content: center;
  padding: calc(#{$topBarHeight} + 10px) 0 11px 0;
}

.todos {
  flex: 1 1 auto;
  padding: 0 4px;
}

$detailViewVerticalMargin: 10px;

.detail-view {
  z-index: 1;
  position: fixed;
  top: $topBarHeight + $detailViewVerticalMargin;
  right: calc((100% - #{$appWidth}) / 2);
  // height: calc(
  //   100% - #{$topBarHeight} - #{$bottomBarHeight} - #{$detailViewVerticalMargin *
  //     2}
  // );
  background-color: $bgColor; ///////////////////
  overflow: hidden;
  // width: 0px;
  // transition: width 500ms;
  opacity: 0;
  transition: opacity 300ms linear 400ms;

  @media #{$mobile} {
    position: fixed;
    right: 0;
    top: 0;
    height: 100%;
    padding-top: 0;
    &.open {
      width: 100%;
    }
  }
}

.detail-view-open {
  $detailViewOpenWidth: 400px;
  .left-column {
    margin-right: $detailViewOpenWidth + 10px;
  }
  .detail-view {
    width: $detailViewOpenWidth;
    opacity: 1;
  }
}
</style>