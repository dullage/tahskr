<template>
  <div class="logo">
    <div class="title">
      <img v-if="showLogo" src="favicon.svg" />
      <span>tahskr</span>
      <span class="brand-orange" :class="{ cursor: blink }">_</span>
    </div>
    <div class="subtitle" v-if="showSubtitle">[task-er] n. the self-hosted todo app</div>
  </div>
</template>

<script>
export default {
  props: {
    showLogo: {
      type: Boolean,
      default: true,
    },
    showSubtitle: {
      type: Boolean,
      default: true,
    },
    blink: {
      type: Boolean,
      default: true,
    },
  },
};
</script>

<style lang="scss" scoped>
@import "../common";

.logo {
  color: $offWhite;
  user-select: none;

  .brand-orange {
    color: $brandOrange;
  }

  .title {
    font-size: 40px;
    display: flex;
    align-items: center;
  }

  img {
    height: 46px;
    margin-right: 6px;
  }

  @keyframes blink {
    50% {
      opacity: 0;
    }
  }
  .cursor {
    animation-name: blink;
    animation-duration: 1s;
    animation-iteration-count: infinite;
    animation-timing-function: step-start;
  }

  .subtitle {
    font-style: italic;
  }
}
</style>