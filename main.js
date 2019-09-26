const { app, BrowserWindow, ipcMain  } = require("electron");

function createWindow() {
  let win = new BrowserWindow({
    webPreferences: {
      nodeIntegration: true
    }
  });

  win.loadFile("index.html");
}

app.on("ready", createWindow);
