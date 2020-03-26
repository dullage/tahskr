import axios from "axios";
import EventBus from "./eventBus.js";

const api = axios.create({
  baseURL: `https://api.tahskr.com`
});

api.interceptors.response.use(
  function(response) {
    return response;
  },
  function(error) {
    if ((error.response.status = 401)) {
      EventBus.$emit("logout");
    } else {
      EventBus.$emit("communication-error");
    }
    return Promise.reject(error);
  }
);

export default api;
