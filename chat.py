#!/usr/bin/env python3
"""Tiny streaming chat client. Usage: BASE_URL=http://HOST:8080/v1 API_KEY=... python3 chat.py"""
import json, os, sys, urllib.request

base = os.environ["BASE_URL"].rstrip("/")
key = os.environ["API_KEY"]
history = []

while True:
    try:
        user = input("you> ")
    except (EOFError, KeyboardInterrupt):
        break
    history.append({"role": "user", "content": user})
    req = urllib.request.Request(
        f"{base}/chat/completions",
        data=json.dumps({"model": "local", "messages": history, "stream": True}).encode(),
        headers={"Authorization": f"Bearer {key}", "Content-Type": "application/json"},
    )
    reply = ""
    with urllib.request.urlopen(req) as r:
        for line in r:
            line = line.decode().strip()
            if not line.startswith("data: ") or line.endswith("[DONE]"):
                continue
            delta = json.loads(line[6:])["choices"][0]["delta"].get("content") or ""
            reply += delta
            print(delta, end="", flush=True)
    print()
    history.append({"role": "assistant", "content": reply})
