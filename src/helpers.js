function zeroPadDateAttr(num) {
  return ("00" + num).slice(-2);
}

export default {
  formatDate: function(date, includeTime = false) {
    if (date == null) {
      return null;
    } else {
      let year = date.getFullYear();
      let month = zeroPadDateAttr(date.getMonth() + 1);
      let day = zeroPadDateAttr(date.getDate());
      let hour = zeroPadDateAttr(date.getHours());
      let minute = zeroPadDateAttr(date.getMinutes());

      if (includeTime == true) {
        return `${year}-${month}-${day} at ${hour}:${minute}`;
      } else {
        return `${year}-${month}-${day}`;
      }
    }
  }
};
