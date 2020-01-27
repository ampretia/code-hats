import * as express from "express";
import * as websocket from "express-ws";
import { readFileSync } from "fs";

import * as markdown from "markdown-it";
import * as nunjucks from "nunjucks";

import * as path from "path";
import * as pty from "pty.js";

const contentRoot =
  process.env.CONTENT_ROOT || path.join(__dirname, "..", "content");

console.log(`Content root: ${contentRoot}`);

// const content = path.join(contentRoot, PERSONA);
const cfg = JSON.parse(
  readFileSync(path.join(contentRoot, "cfg.json"), "utf8")
);

const personas = cfg.personas;
const md = markdown();
let key: string;
let value: any;

for ([key, value] of Object.entries(personas)) {
  const infomd = readFileSync(path.join(contentRoot, value.info), "utf8");
  personas[key].info = md.render(infomd);
  value.wspath = key;
}

const app = express();
const expressWs = websocket(app);
nunjucks.configure(path.join(__dirname, "..", "views"), {
  autoescape: true,
  express: app
});
// Serve static assets from ./static
app.use(express.static(`${__dirname}/../static`));

// tslint:disable-next-line:variable-name
app.get("/:persona", (req, res) => {
  res.render("index", personas[req.params.persona]);
});

app.get("/", (_req, res) => {
  res.render("personas", cfg);
});
// view engine setup
app.set("views", path.join(__dirname, "..", "views"));
app.set("view engine", "njk");

// Instantiate shell and set up data handlers
expressWs.app.ws("/shell/:persona", (ws, req) => {
  // Spawn the shell
  const env = process.env;
  Object.assign(env, personas[req.params.persona].env);

  const e = personas[req.params.persona].env;
  const stringArg = ["--login", `--user=${req.params.persona}`];
  
  for (const keyid in e) {
    if (e.hasOwnProperty(keyid)) {
      const element = e[keyid];
      stringArg.push(`${keyid}=${element}`);
    }
  }

  // tslint:disable-next-line: no-console
  console.log(stringArg);

  // Compliments of http://krasimirtsonev.com/blog/article/meet-evala-your-terminal-in-the-browser-extension
  const shell = pty.spawn("sudo", stringArg, {
    // "--preserve-env=CORE_PEER_ADDRESS",
    cwd: `/home/${req.params.persona}`,
    env,
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

  // eg....... shell.write('ls -l');
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
