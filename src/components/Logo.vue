<template>
  <div class="logo">
    <div class="title">
      <span class="brand-oranges">tah</span><span class="brand-oranges">skr</span><span class="brand-orange" :class="{ cursor: blink }">_</span>
    </div>
    <div class="subtitle" v-if="showSubtitle">[task-er] n. yet another todo app</div>
  </div>
</template>

<script>
export default {
  props: {
    showSubtitle: {
      type: Boolean,
      default: true
    },
    blink: {
      type: Boolean,
      default: true
    }
  }
};
</script>

<style lang="scss" scoped>
@import "../common";

.logo {
  color: $offWhite;

  .brand-orange {
    color: $brandOrange;
  }

  .title {
    font-size: 40px;
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