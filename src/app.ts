import * as express from "express";
import * as websocket from "express-ws";
import { readFileSync } from "fs";

import * as markdown from "markdown-it";
import * as nunjucks from "nunjucks";
import * as os from "os";
import * as path from "path";
import * as pty from "pty.js";



const PERSONA = os.userInfo().username;
const contentRoot = process.env.CONTENT_ROOT || path.join(__dirname,"..","content");

const content = path.join(contentRoot, PERSONA);
const cfg = JSON.parse(
  readFileSync(path.join(contentroot, "cfg.json"), "utf8")
);

const infomd = readFileSync(path.join(contentRoot, cfg.info), "utf8");

const md = markdown();
cfg.info = md.render(infomd);

const app = express();
const expressWs = websocket(app);
nunjucks.configure(path.join(__dirname, "..", "views"), {
  autoescape: true,
  express: app
});
// Serve static assets from ./static
app.use(express.static(`${__dirname}/../static`));

// tslint:disable-next-line:variable-name
app.get("/", (_req, res) => {
  res.render("index", cfg);
});

// view engine setup
app.set("views", path.join(__dirname, "..", "views"));
app.set("view engine", "njk");

// Instantiate shell and set up data handlers
expressWs.app.ws("/shell", ws => {
  // Spawn the shell
  // Compliments of http://krasimirtsonev.com/blog/article/meet-evala-your-terminal-in-the-browser-extension
  const shell = pty.spawn("/bin/bash", [], {
    cwd: `/home/${PERSONA}`,
    env: process.env,
    name: "xterm-color"
  });
  // For all shell data send it to the websocket
  shell.on("data", (data: any) => {
    ws.send(data);
  });
  // For all websocket data send it to the shell
  ws.on("message", msg => {
    shell.write(msg);
  });
});

// // Start the application

const port = normalizePort(process.env.PORT || "3000");
app.listen(port);

/**
 * Normalize a port into a number, string, or false.
 */

function normalizePort(val: string) {
  const p = parseInt(val, 10);

  if (isNaN(p)) {
    // named pipe
    return val;
  }

  if (p >= 0) {
    // port number
    return p;
  }

  return false;
}
