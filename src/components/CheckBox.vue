<template>
  <div
    class="checkbox"
    :class="{ complete: checked, incomplete: !checked, dim: dim }"
    @click.stop="toggled"
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
    dimWhenChecked: { type: Boolean, default: false }
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

<style lang="scss" scoped>
@import "../common";

.checkbox {
  height: 12px;
  min-width: 12px;
  cursor: pointer;
  background-color: white;
  color: $bgColor;
  display: flex;
  justify-content: center;
  align-items: center;
  font-size: 12px;
  &.dim {
    background-color: $subduedColor;
  }
}

.check-box-icon {
  margin: 0 0 3px 0;
}

.incomplete {
  .check-box-icon {
    display: none;
  }
  @media (hover: hover) {
    .checkbox:hover {
      .check-box-icon {
        display: block;
        opacity: 0.5;
      }
    }
  }
}
</style>