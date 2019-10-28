const { app, BrowserWindow } = require("electron");

function createWindow() {
  let win = new BrowserWindow({});

  win.setMenu(null);
  win.loadFile("./dist/index.html");
}

app.on("ready", createWindow);
