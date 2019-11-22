const { app, BrowserWindow } = require("electron");

function createWindow() {
  let win = new BrowserWindow({
    width: 500,
    height: 800
  });

  win.setMenu(null);
  win.loadFile("./dist/index.html");
}

app.on("ready", createWindow);
