#!/usr/bin/env python3
"""
Maestro local setup server.
Opens a browser form, user fills it, server writes all config files.

Usage:
    python3 setup/server.py [target-directory]
    python3 setup/server.py .
"""

import http.server
import json
import os
import shutil
import subprocess
import sys
import webbrowser
from pathlib import Path
from urllib.parse import parse_qs, urlparse

SCRIPT_DIR = Path(__file__).parent
MAESTRO_DIR = SCRIPT_DIR.parent
PORT = 8642

HTML_SUCCESS = """<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>Maestro — Setup Complete</title>
  <style>
    body {{ font-family: -apple-system, sans-serif; background: #0f1117; color: #e1e4e8;
           display: flex; align-items: center; justify-content: center; min-height: 100vh; }}
    .card {{ background: #161b22; border: 1px solid #30363d; border-radius: 12px;
             padding: 2.5rem; max-width: 500px; width: 100%; text-align: center; }}
    h1 {{ color: #3fb950; margin-bottom: 0.5rem; }}
    p {{ color: #8b949e; font-size: 0.9rem; line-height: 1.6; margin-top: 0.75rem; }}
    code {{ background: #0d1117; padding: 0.2rem 0.4rem; border-radius: 4px;
            font-family: monospace; color: #79c0ff; }}
    .tools {{ margin-top: 1.5rem; text-align: left; background: #0d1117;
              border-radius: 8px; padding: 1rem; }}
    .tools p {{ margin: 0.25rem 0; color: #c9d1d9; }}
  </style>
</head>
<body>
<div class="card">
  <h1>✓ Maestro Ready</h1>
  <p>Your project <strong>{project_name}</strong> has been set up.</p>
  <div class="tools">{tool_instructions}</div>
  <p>Edit <code>CLAUDE.md</code> to describe your project, then start exploring.</p>
  <p style="margin-top:1.5rem; font-size: 0.78rem; color: #484f58;">
    This server has stopped. You can close this tab.
  </p>
</div>
<script>setTimeout(() => window.close(), 8000);</script>
</body>
</html>"""


class SetupHandler(http.server.BaseHTTPRequestHandler):
    target_dir: Path = Path(".")

    def log_message(self, format, *args):
        pass  # suppress default logging

    def do_GET(self):
        parsed = urlparse(self.path)
        if parsed.path in ("/", "/index.html"):
            content = (SCRIPT_DIR / "index.html").read_bytes()
            self.send_response(200)
            self.send_header("Content-Type", "text/html; charset=utf-8")
            self.send_header("Content-Length", str(len(content)))
            self.end_headers()
            self.wfile.write(content)
        else:
            self.send_response(404)
            self.end_headers()

    def do_POST(self):
        if self.path != "/setup":
            self.send_response(404)
            self.end_headers()
            return

        length = int(self.headers.get("Content-Length", 0))
        body = self.rfile.read(length)
        data = json.loads(body)

        try:
            html = self._run_setup(data)
            content = html.encode()
            self.send_response(200)
            self.send_header("Content-Type", "text/html; charset=utf-8")
            self.send_header("Content-Length", str(len(content)))
            self.end_headers()
            self.wfile.write(content)
        except Exception as e:
            error = f"Setup failed: {e}".encode()
            self.send_response(500)
            self.send_header("Content-Type", "text/plain")
            self.end_headers()
            self.wfile.write(error)

        # Shutdown server after responding
        import threading
        threading.Timer(1.0, self.server.shutdown).start()

    def _run_setup(self, data: dict) -> str:
        project_name = data.get("project_name", "my-project").strip() or "my-project"
        mode = data.get("mode", "solo")
        tools = data.get("tools", ["claude-code"])
        scope = data.get("scope", "core")
        target = self.__class__.target_dir

        # Build env for install.sh
        tools_map = {"claude-code": "1", "cursor": "2", "codex": "3"}
        if set(tools) == {"claude-code", "cursor", "codex"}:
            tools_str = "4"
        else:
            tools_str = " ".join(tools_map[t] for t in tools if t in tools_map)

        scope_map = {"core": "1", "full": "2", "minimal": "3"}
        scope_num = scope_map.get(scope, "1")

        env = os.environ.copy()
        env.update({
            "PROJECT_NAME": project_name,
            "MODE": mode,
            "TOOLS": tools_str,
            "SCOPE": scope_num,
        })

        install_script = MAESTRO_DIR / "install.sh"
        result = subprocess.run(
            ["bash", str(install_script), str(target), "--preconfigured"],
            env=env,
            capture_output=True,
            text=True,
        )

        if result.returncode != 0:
            raise RuntimeError(result.stderr or result.stdout)

        # Build tool instructions
        instructions = []
        if "claude-code" in tools:
            instructions.append("<p>🔵 <strong>Claude Code:</strong> Open new conversation → type <code>/mae-explore</code></p>")
        if "cursor" in tools:
            instructions.append("<p>🟣 <strong>Cursor:</strong> Open project → AI chat → type <code>/mae-explore</code></p>")
        if "codex" in tools:
            instructions.append("<p>🟢 <strong>Codex:</strong> Instructions auto-loaded → type <code>/mae-explore</code></p>")

        return HTML_SUCCESS.format(
            project_name=project_name,
            tool_instructions="\n".join(instructions),
        )


def main():
    target = Path(sys.argv[1]).resolve() if len(sys.argv) > 1 else Path(".").resolve()
    SetupHandler.target_dir = target

    print(f"\n╔══════════════════════════════════════╗")
    print(f"║    Maestro Setup Wizard              ║")
    print(f"╚══════════════════════════════════════╝")
    print(f"\nTarget directory: {target}")
    print(f"Opening browser at http://localhost:{PORT} ...")
    print("Fill in the form and click 'Install'.")
    print("(Press Ctrl+C to cancel)\n")

    server = http.server.HTTPServer(("localhost", PORT), SetupHandler)
    webbrowser.open(f"http://localhost:{PORT}")

    try:
        server.serve_forever()
    except KeyboardInterrupt:
        print("\nSetup cancelled.")

    print("\n✓ Done. Server stopped.")


if __name__ == "__main__":
    main()
