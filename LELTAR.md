# Claude Code pluginek és VS Code kiegészítők – leltár

Gép: benedekdozsa MacBook (macOS Darwin 24.6.0, Apple Silicon)
Készült: 2026-09-27

---

## 1. Claude Code pluginek

3 plugin telepítve, mind engedélyezett, mind `user` scope-ban (tehát minden projektben aktív).

| Plugin | Verzió | Forrás | Telepítve |
|---|---|---|---|
| `frontend-slides@frontend-slides` | 2.1.0 | helyi mappa: `~/.claude/skills/frontend-slides` | 2026-06-18 |
| `vercel-plugin@vercel` | 0.40.1 | GitHub `vercel/vercel-plugin` | 2026-05-03 |
| `vercel@claude-plugins-official` | 0.44.0 | GitHub `anthropics/claude-plugins-official` | 2026-07-04 |

### Regisztrált marketplace-ek

| Név | Típus | Hely |
|---|---|---|
| `vercel` | GitHub repo `vercel/vercel-plugin` | `~/.claude/plugins/marketplaces/vercel` |
| `claude-plugins-official` | GitHub repo `anthropics/claude-plugins-official` | `~/.claude/plugins/marketplaces/claude-plugins-official` |
| `frontend-slides` | helyi mappa | `~/.claude/skills/frontend-slides` |

### Megjegyzés: a Vercel plugin duplikált

Ugyanaz a Vercel plugin két külön marketplace-ről van fent, két különböző verzióban (0.40.1 és 0.44.0). Ezért jelennek meg duplikálva a Vercel skillek és agentek a Claude Code munkamenetekben (`vercel:deploy`, `vercel:env`, `vercel:nextjs`, `vercel:ai-architect` és a többi, mindegyik kétszer).

Javasolt: a régebbi, közösségi forrásból telepített példány eltávolítása, és csak az Anthropic official marketplace-ről származó maradjon:

```
claude plugin uninstall vercel-plugin@vercel
```

---

## 2. VS Code kiegészítők

VS Code telepítés: `/Applications/Visual Studio Code.app`
Aktív kiegészítők száma: **19**

### AI és kódasszisztens

| Kiegészítő | Verzió |
|---|---|
| `anthropic.claude-code` | 2.1.282 |
| `openai.chatgpt` | 26.917.62051 |
| `openai.codex-audio` | 26.917.62051 |
| `ms-vscode.vscode-chat-customizations-evaluations` | 1.0.9 |
| `21st-dev.21st-extension` | 0.0.11 |

### Design és Figma

| Kiegészítő | Verzió |
|---|---|
| `figma.figma-vscode-extension` | 0.4.7 |
| `sethford.mcp-figma-extension` | 1.0.0 |

### Python

| Kiegészítő | Verzió |
|---|---|
| `ms-python.python` | 2026.4.0 |
| `ms-python.vscode-pylance` | 2026.4.1 |
| `ms-python.debugpy` | 2026.6.0 |
| `ms-python.vscode-python-envs` | 1.38.0 |

### Dokumentum és LaTeX

| Kiegészítő | Verzió |
|---|---|
| `james-yu.latex-workshop` | 10.19.0 |
| `mathematic.vscode-latex` | 2.0.0 |
| `chrischinchilla.vscode-pandoc` | 1.2.1 |
| `tomoki1207.pdf` | 1.2.2 |

### Adat, web és infrastruktúra

| Kiegészítő | Verzió |
|---|---|
| `mechatroner.rainbow-csv` | 3.24.1 |
| `ritwickdey.liveserver` | 5.7.10 |
| `github.vscode-github-actions` | 0.32.3 |
| `ms-azuretools.vscode-containers` | 2.5.2 |

### Cursor

A Cursor szerkesztő telepítve van (`~/.cursor`), de nincs benne egyetlen kiegészítő sem. A Windsurf nincs telepítve.

---

## 3. Lemezterület: 9,5 GB felszabadítható

A `~/.vscode/extensions/` mappa mérete **11 GB**, pedig a 19 aktív kiegészítő ennek csak a töredéke. A frissítések után a régi verziók mappái nem törlődtek: összesen **42 elavult mappa, 9,5 GB**.

A `code --list-extensions` parancs csak az aktív verziókat írja ki, ezért ez a szemét normál használat közben láthatatlan.

### A legnagyobb tételek

| Kiegészítő | Mappák száma | Összméret | Ebből elavult |
|---|---|---|---|
| `openai.chatgpt` | 11 | 5,9 GB | 10 verzió |
| `anthropic.claude-code` | 20 | 4,2 GB | 19 verzió (2.1.245-től 2.1.280-ig) |
| `ms-python.vscode-pylance` | 2 | 222 MB | 1 verzió |
| `james-yu.latex-workshop` | 2 | 63 MB | 1 verzió |
| `figma.figma-vscode-extension` | 2 | 31 MB | 1 verzió |
| `ms-python.vscode-python-envs` | 2 | 21 MB | 1 verzió |
| `ms-azuretools.vscode-containers` | 3 | 13 MB | 2 verzió |
| `chrischinchilla.vscode-pandoc` | 3 | 11 MB | 2 verzió |
| `mathematic.vscode-latex` | 5 | 5,2 MB | 4 verzió |
| `ms-vscode.vscode-chat-customizations-evaluations` | 2 | 3,7 MB | 1 verzió |

Két kiegészítő adja a szemét 98 százalékát: a ChatGPT és a Claude Code, mert mindkettő gyakran frissül és mindkettő nagy natív bináris csomagot tartalmaz (verziónként 220-540 MB).

### Takarítás

A törölhető mappák pontos listája a `elavult-mappak.txt` fájlban. A VS Code-ot érdemes bezárni előtte. A parancs:

```bash
cd ~/.vscode/extensions
while read -r d; do rm -rf "$d"; done < /útvonal/elavult-mappak.txt
```

A takarítás nem érinti a beállításokat és a bejelentkezéseket, azok nem az extensions mappában vannak. Újraindítás után a VS Code mindent ugyanúgy talál.

Megjegyzés: ez a lista 2026-09-27-i állapot. Ha a Claude Code vagy a ChatGPT kiegészítő közben frissült, a listában szerepelhet olyan verzió, ami akkor még aktív volt. A parancs futtatása előtt ellenőrizni kell, hogy az aktuálisan aktív verzió nincs-e a listában.
