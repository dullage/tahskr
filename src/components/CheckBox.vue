<template>
  <div
    class="checkbox"
    :class="{ complete: checked, incomplete: !checked, dim: dim }"
    @click="toggled"
  >
    <check-bold-icon class="check-box-icon" />
  </div>
</template>

<script>
import CheckBoldIcon from "icons/CheckBold.vue";

export default {
  components: {
    CheckBoldIcon
  },

  props: {
    checked: { type: Boolean, required: true },
    dimWhenChecked: { type: Boolean, default: true }
  },

  computed: {
    dim: function() {
      return this.checked && this.dimWhenChecked;
    }
  },

  methods: {
    toggled: function() {
      this.$emit("toggled");
    }
  }
};
</script>

<style lang="scss">
@import "../common";

.checkbox {
  height: 16px;
  width: 16px;
  cursor: pointer;
  background-color: white;
  color: $bgColor;
  display: flex;
  justify-content: center;
  align-items: center;
  font-size: 12px;
  &.dim {
    background-color: $disabledColor;
  }
}

.check-box-icon {
  margin: 0 0 3px 0;
}

.incomplete {
  .check-box-icon {
    display: none;
  }
  .checkbox:hover {
    .check-box-icon {
      display: block;
      opacity: 50%;
    }
  }
}
</style>