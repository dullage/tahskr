<template>
  <div class="bottom-bar">
    <div class="menu" :class="{open: menuOpen}">
      <div class="menu-button" @click="$emit('toggle-completed')">
        <toggle-switch-off-outline-icon v-if="showCompleted == false" />
        <toggle-switch-icon v-else />
        <span>Show Completed</span>
      </div>

      <div class="menu-button" @click="$emit('refresh')">
        <refresh-icon />
        <span>Refresh</span>
      </div>

      <div class="menu-button" @click="$emit('logout')">
        <logout-variant-icon />
        <span>Logout</span>
      </div>
    </div>

    <div @click.stop="menuOpen = !menuOpen">
      <menu-icon />
    </div>

    <input
      type="text"
      class="todo-input"
      @keyup.enter="submit"
      v-model="inputContent"
      placeholder="Add to Inbox..."
    />
  </div>
</template>

<script>
import api from "../api";
import EventBus from "../eventBus";

import MenuIcon from "icons/Menu.vue";
import RefreshIcon from "icons/Refresh.vue";
import LogoutVariantIcon from "icons/LogoutVariant.vue";
import ToggleSwitchIcon from "icons/ToggleSwitch.vue";
import ToggleSwitchOffOutlineIcon from "icons/ToggleSwitchOffOutline.vue";

export default {
  components: {
    MenuIcon,
    RefreshIcon,
    LogoutVariantIcon,
    ToggleSwitchIcon,
    ToggleSwitchOffOutlineIcon
  },

  props: {
    showCompleted: { type: Boolean, required: true }
  },

  data: function() {
    return {
      menuOpen: false,
      inputContent: null
    };
  },

  methods: {
    closeMenu: function() {
      if (this.menuOpen == true) {
        this.menuOpen = false;
      }
    },

    submit: function() {
      var parent = this;

      api.post("/api/todo", { summary: this.inputContent }).then(function(r) {
        EventBus.$emit("add-todo", r.data);
        parent.inputContent = null;
      });
    }
  },

  created: function() {
    EventBus.$on("close-menu", this.closeMenu);
  }
};
</script>

<style lang="scss" scoped>
@import "../common";

.bottom-bar {
  z-index: 1;
  position: fixed;
  bottom: 0;
  width: 100%;
  max-width: $appWidth;
  height: $bottomBarHeight;
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

.menu {
  z-index: 2;
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
}

.menu-button {
  cursor: pointer;
  font-size: 18px;
  margin: 10px;
  color: $offWhite;
}

.todo-input {
  width: 100%;
  font-size: 17px;
  padding: 12px 4px;
  border: none;
  background-color: $bgColor;
  color: $offWhite;
  &::placeholder {
    color: $subduedColor;
  }
  &:focus {
    outline: none;
    &::placeholder {
      color: transparent;
    }
  }
}
</style>