const { app, BrowserWindow } = require("electron");

function createWindow() {
  let win = new BrowserWindow({
    frame: false,
    width: 500,
    height: 800,
    webPreferences: {
      nodeIntegration: true
    }
  });

  win.loadFile("main.html");

  // Open dev tools in separate window.
  // win.webContents.openDevTools({mode:'undocked'});
}

app.on("ready", createWindow);
