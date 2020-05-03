import axios from "axios";
import EventBus from "./eventBus.js";

const api = axios.create();

api.interceptors.response.use(
  function(response) {
    EventBus.$emit("communication-error", false);
    return response;
  },
  function(error) {
    if (
      typeof error.response !== "undefined" &&
      error.response.status === 401
    ) {
      EventBus.$emit("logout");
    } else {
      EventBus.$emit("communication-error", true);
    }
    return Promise.reject(error);
  }
);

export default api;
