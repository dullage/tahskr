<template>
  <div class="logo">
    <checkbox-multiple-marked-outline-icon />
    <span class="title">tahskr</span>
    <span class="phonetic" v-if="showPhonetic">[task-er]</span>
    <div class="subtitle" v-if="showSubtitle">(noun) yet another todo app</div>
  </div>
</template>

<script>
import CheckboxMultipleMarkedOutlineIcon from "icons/CheckboxMultipleMarkedOutline.vue";

export default {
  components: {
    CheckboxMultipleMarkedOutlineIcon
  },

  props: {
    showIcon: {
      type: Boolean,
      default: true
    },
    showPhonetic: {
      type: Boolean,
      default: true
    },
    showSubtitle: {
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
}

.checkbox-multiple-marked-outline-icon {
  margin: 0 4px 1px 0;
  font-size: 28px;
  color: #fbdd87;
}

.title {
  font-family: $brandFontStack;
  font-size: 40px;
}

.subtitle {
  font-style: italic;
}
</style>