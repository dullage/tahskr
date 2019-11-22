<template>
  <div class="detail-view">
    <close-icon @click="close" />
  </div>
</template>

<script>
import CloseIcon from "icons/Close.vue";

export default {
  components: {
    CloseIcon
  },

  methods: {
    close: function() {
      this.$emit("close");
    }
  }
};
</script>

<style lang="scss" scoped>
@import "../common";

.detail-view {
  background-color: $bgColor;
  color: $offWhite;
}
</style>