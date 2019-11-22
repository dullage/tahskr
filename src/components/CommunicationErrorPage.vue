<template>
  <div class="communication-error">
    <alert-circle-outline-icon class="shake animated" />
    <span class="message">Send help, something's gone wrong!</span>
  </div>
</template>

<script>
import AlertCircleOutlineIcon from "icons/AlertCircleOutline.vue";

export default {
  components: {
    AlertCircleOutlineIcon
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
    margin: 0 0 36px 0;
    font-size: 80px;
  }

  .message {
    font-size: 20px;
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