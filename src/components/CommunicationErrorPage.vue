<template>
  <div class="communication-error">
    <alert-circle-outline-icon class="shake animated" />
    <span class="message">Error communicating with the tahskr server!</span>
    <div class="button" @click="logout">
      <logout-variant-icon />
      <span>Exit to Login Screen</span>
    </div>
    <div class="button" @click="reload">
      <refresh-icon />
      <span>Reload</span>
    </div>
  </div>
</template>

<script>
import AlertCircleOutlineIcon from "icons/AlertCircleOutline.vue";
import EventBus from "../eventBus";
import LogoutVariantIcon from "icons/LogoutVariant.vue";
import RefreshIcon from "icons/Refresh.vue";

export default {
  components: {
    AlertCircleOutlineIcon,
    LogoutVariantIcon,
    RefreshIcon
  },

  methods: {
    reload: function() {
      location.reload();s
    },

    logout: function() {
      EventBus.$emit("logout");
    }
  }
};
</script>

<style lang="scss" scoped>
@import "../common";

.communication-error {
  height: 100%;
  color: $subduedColor;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;

  .alert-circle-outline-icon {
    font-size: 80px;
  }

  .message {
    margin: 36px 0;
    font-size: 20px;
    text-align: center;
  }

  .button {
    margin: 10px;
    cursor: pointer;
    font-size: 18px;
    color: $offWhite;
  }
}

.animated {
  animation-duration: 1s;
  animation-fill-mode: both;
}

@keyframes shake {
  from,
  to {
    transform: translate3d(0, 0, 0);
  }

  10%,
  30%,
  50%,
  70%,
  90% {
    transform: translate3d(-10px, 0, 0);
  }

  20%,
  40%,
  60%,
  80% {
    transform: translate3d(10px, 0, 0);
  }
}

.shake {
  animation-name: shake;
}
</style>