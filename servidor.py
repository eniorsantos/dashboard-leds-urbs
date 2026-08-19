#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Servidor local do dashboard.
- Serve os arquivos estaticos (como o `python -m http.server`).
- Aceita POST em .../config.json para salvar as configuracoes do painel
  (ex.: planilhas do Google) em dashboard/config.json — sem usar localStorage.

Uso:  python servidor.py [porta]
"""
import json
import os
import sys
from http.server import HTTPServer, SimpleHTTPRequestHandler
from urllib.parse import urlparse

RAIZ = os.path.dirname(os.path.abspath(__file__))


class Handler(SimpleHTTPRequestHandler):
    def do_POST(self):
        parsed = urlparse(self.path)
        if parsed.path.endswith("config.json"):
            n = int(self.headers.get("Content-Length", 0) or 0)
            data = self.rfile.read(n) if n else b""
            try:
                obj = json.loads(data.decode("utf-8"))
            except Exception:
                body = json.dumps({"ok": False, "erro": "JSON invalido"}).encode("utf-8")
                self.send_response(400)
                self.send_header("Content-Type", "application/json")
                self.send_header("Content-Length", str(len(body)))
                self.end_headers()
                self.wfile.write(body)
                return
            alvo = os.path.join(RAIZ, "dashboard", "config.json")
            try:
                with open(alvo, "w", encoding="utf-8") as f:
                    json.dump(obj, f, ensure_ascii=False, indent=2)
            except OSError as e:
                body = json.dumps({"ok": False, "erro": str(e)}).encode("utf-8")
                self.send_response(500)
                self.send_header("Content-Type", "application/json")
                self.send_header("Content-Length", str(len(body)))
                self.end_headers()
                self.wfile.write(body)
                return
            body = json.dumps({"ok": True, "path": parsed.path}).encode("utf-8")
            self.send_response(200)
            self.send_header("Content-Type", "application/json")
            self.send_header("Content-Length", str(len(body)))
            self.end_headers()
            self.wfile.write(body)
            return
        self.send_response(404)
        self.send_header("Content-Type", "text/plain")
        self.end_headers()
        self.wfile.write(b"Not Found")

    def log_message(self, fmt, *args):
        sys.stdout.write(fmt % args + "\n")


if __name__ == "__main__":
    porta = int(sys.argv[1]) if len(sys.argv) > 1 else 8000
    print("=" * 65)
    print("  Servidor do dashboard:  http://localhost:%d/dashboard/" % porta)
    print("  Para parar: feche esta janela ou pressione Ctrl+C.")
    print("=" * 65)
    HTTPServer(("localhost", porta), Handler).serve_forever()