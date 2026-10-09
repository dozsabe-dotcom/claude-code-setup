# Claude Code átültetés új gépre: végrehajtható telepítőlista

Készült: 2026-10-09 | Forrásgép: benedekdozsa MacBook (macOS Darwin 24.6.0, Apple Silicon)

---

## Ezt add be a Claude Code-nak az új gépen

> Klónozd ezt a repót, olvasd be ezt a fájlt, és hajtsd végre az 1-tól a 8-ig minden szakaszt sorban.
> Minden szakasz végén ellenőrizd le a "Check" sort, és írd ki, hogy sikerült-e.
> A 9. szakasz az enyém, azt csak listázd ki a végén, ne próbáld megoldani.
> Ha egy lépés hibára fut, állj meg, írd le mi a hiba, és kérdezz.

---

## 0. Előfeltételek

```bash
# Homebrew (ha még nincs)
command -v brew || /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Node LTS (a forrásgépen v24.13.1 volt) és npm prefix
brew install node
npm config set prefix ~/.npm-global
grep -q '.npm-global/bin' ~/.zshrc || echo 'export PATH="$HOME/.npm-global/bin:$PATH"' >> ~/.zshrc
export PATH="$HOME/.npm-global/bin:$PATH"
```

**Check:** `node -v && npm -v && npm config get prefix`

---

## 1. CLI eszközök

```bash
brew install gh pandoc poppler potrace rclone ffmpeg cloudflared
brew install supabase/tap/supabase

npm install -g @anthropic-ai/claude-code vercel@latest firebase-tools@latest
```

Mire kell melyik: `gh` GitHub műveletek, `pandoc` + `poppler` + `potrace` dokumentum- és PDF-konverzió, `rclone` Google Drive feltöltés (a Drive MCP nem tölt fel PDF-et), `ffmpeg` média, `cloudflared` tunnel, `supabase` lokális migrációk, `vercel` és `firebase` deploy.

**Check:** `for c in gh pandoc rclone supabase vercel firebase claude; do printf "%-10s %s\n" $c "$(command -v $c || echo HIANYZIK)"; done`

---

## 2. Python csomagok

A rendszer-Python3 volt használatban (3.9.6). A gyakran használt csomagok:

```bash
python3 -m pip install --user \
  python-docx python-pptx openpyxl xlsxwriter xlrd pandas numpy \
  matplotlib seaborn reportlab pillow cairosvg qrcode \
  pypdf pdfplumber pymupdf pikepdf pdfminer.six \
  beautifulsoup4 lxml requests python-dotenv rapidfuzz \
  anthropic playwright replicate xlwings
```

> A `cairosvg` futásidőben a Homebrew cairo-ját keresi. Ha importhibát ad:
> `brew install cairo pango gdk-pixbuf libffi`, és a hívásoknál
> `DYLD_LIBRARY_PATH=/opt/homebrew/lib python3 ...`

**Check:** `python3 -c "import docx,pptx,openpyxl,pandas,matplotlib,reportlab,PIL,fitz,bs4; print('python ok')"`

---

## 3. Claude Code belépés és alapállapot

```bash
claude   # egyszer indítsd el, lépj be a Max előfizetéses fiókkal (dozsabe@gmail.com), aztán /exit
```

**Check:** `claude --version`

---

## 4. Pluginek és marketplace-ek

A forrásgépen 3 plugin futott, de **kettő ugyanaz a Vercel plugin** két marketplace-ről, két verzióban (0.40.1 és 0.44.0). Ez okozta, hogy minden Vercel skill duplán jelent meg. **Az új gépen csak az official változatot telepítsd.**

```bash
# marketplace-ek
claude plugin marketplace add anthropics/claude-plugins-official

# a frontend-slides plugin forrása egy lokális klón, ezért előbb klónozni kell
mkdir -p ~/.claude/skills
git clone https://github.com/zarazhangrui/frontend-slides.git ~/.claude/skills/frontend-slides
claude plugin marketplace add ~/.claude/skills/frontend-slides

# pluginek
claude plugin install vercel@claude-plugins-official
claude plugin install frontend-slides@frontend-slides
```

Amit a Vercel plugin ad: 28 skill, 6 agent, 11 slash command, 1 MCP szerver.
Amit a frontend-slides ad: 1 skill (HTML prezentációk, PPT konverzió).

> A `anthropics/claude-plugins-official` az Anthropic nyilvános katalógusa, 255 plugin van benne felsorolva. Ebből nálad eddig csak a `vercel` volt telepítve. A többi elérhető, de nem fut, és nem is kell.

**Check:** `claude plugin list`

---

## 5. MCP szerverek

```bash
# böngészőautomatizálás
claude mcp add playwright --scope user -- npx @playwright/mcp@latest

# Claude Design szinkron (HTTP)
claude mcp add --transport http claude-design --scope user https://api.anthropic.com/v1/design/mcp

# Smartlead (az API-kulcsot lásd a 9. szakaszban, ne írd be fájlba)
claude mcp add smartlead --scope user -e SMARTLEAD_API_KEY=<IDE_A_KULCS> -- npx -y smartlead-mcp-by-leadmagic
```

A Vercel MCP szervert (`https://mcp.vercel.com`) a plugin hozza magával, nem kell külön felvenni. Első használatnál OAuth-ot kér a böngészőben.

A claude.ai connectorok (Gmail, Google Calendar, Drive, Docs, Microsoft 365, Notion, Supabase, Vercel, Canva, Miro, Stripe, Smartlead, Claude Docs) **a fiókhoz tartoznak, nem a géphez**, ezért automatikusan megjönnek. Nem kell telepíteni semmit.

> Figyelj: a Smartlead és a Vercel így duplán lesz elérhető, egyszer lokálisan, egyszer connectorként. Ha nem akarod, a lokális Smartlead szervert kihagyhatod, a connector a legtöbb műveletre elég.

**Check:** `claude mcp list`

---

## 6. settings.json: engedélyek, hookok, beállítások

Írd ki pontosan ezt a `~/.claude/settings.json`-ba. Ha már létezik a fájl, előbb mentsd `.bak`-ként.

```bash
mkdir -p ~/.claude && [ -f ~/.claude/settings.json ] && cp ~/.claude/settings.json ~/.claude/settings.json.bak
cat > ~/.claude/settings.json <<'JSON'
{
  "permissions": {
    "allow": [
      "Bash", "Edit", "Write", "Read",
      "Bash(*)", "Edit(*)", "Write(*)", "Read(*)",
      "mcp__playwright__*",
      "mcp__claude-design__*",
      "mcp__claude_ai_Gmail__*",
      "mcp__claude_ai_Google_Calendar__*",
      "mcp__claude_ai_Google_Drive__*",
      "mcp__claude_ai_Microsoft_365__*",
      "mcp__claude_ai_Notion__*",
      "mcp__claude_ai_Supabase__*",
      "mcp__claude_ai_Vercel__*",
      "mcp__smartlead__*",
      "WebFetch", "WebSearch", "Workflow"
    ],
    "ask": [],
    "defaultMode": "bypassPermissions",
    "additionalDirectories": [
      "/Users/benedekdozsa/Documents/AI code",
      "/Users/benedekdozsa/Documents/AI code/0. Claude SKILLS",
      "/Users/benedekdozsa/Library/CloudStorage/OneDrive-Med-EconLtd/Johnson&Johnson - Med-Econ project"
    ]
  },
  "model": "opus[1m]",
  "hooks": {
    "Stop": [
      { "matcher": "", "hooks": [ { "type": "command", "command": "~/.claude/notify-stop.sh" } ] }
    ],
    "PreToolUse": [
      { "matcher": "Bash", "hooks": [ { "type": "command", "command": "~/.claude/vercel-deploy-guard.sh", "statusMessage": "Vercel deploy-guard" } ] }
    ]
  },
  "effortLevel": "medium",
  "skipDangerousModePermissionPrompt": true,
  "skipWorkflowUsageWarning": true,
  "theme": "dark",
  "inputNeededNotifEnabled": true,
  "agentPushNotifEnabled": true,
  "skipAutoPermissionPrompt": true
}
JSON
```

> Az `enabledPlugins` és az `extraKnownMarketplaces` blokkot a 4. szakasz parancsai maguktól beírják, ezért nincs benne ebben a JSON-ban.
> Ha az új gépen más a felhasználónév, az `additionalDirectories` útvonalait írd át.
> A `defaultMode: bypassPermissions` azt jelenti, hogy a Claude Code nem kérdez rá a műveletekre. Ez volt a forrásgépen is.

**Check:** `python3 -c "import json;json.load(open('$HOME/.claude/settings.json'));print('settings ok')"`

---

## 7. A két hook script

### 7.1 Hangjelzés, ha a VS Code nincs előtérben

```bash
cat > ~/.claude/notify-stop.sh <<'SH'
#!/bin/bash
# Csak akkor szólal meg, ha a VS Code (Code) nincs előtérben
TERMINAL_APP="Code"
FRONTMOST=$(osascript -e 'tell application "System Events" to get name of first application process whose frontmost is true' 2>/dev/null)
if [ "$FRONTMOST" != "$TERMINAL_APP" ]; then
    afplay /System/Library/Sounds/Glass.aiff
fi
SH
chmod +x ~/.claude/notify-stop.sh
```

### 7.2 Vercel deploy-guard

Ez a legfontosabb védelem: megállítja az éles deployt és a linkeletlen mappából induló első deployt, mert az megkerülné a `--prod` kapcsolót és egyenesen production lenne. A teljes script ebben a repóban van, `vercel-deploy-guard.sh` néven. Másold be:

```bash
# a repo gyökeréből futtatva
cp vercel-deploy-guard.sh ~/.claude/vercel-deploy-guard.sh
chmod +x ~/.claude/vercel-deploy-guard.sh
```

**Check:** `echo '{"tool_input":{"command":"vercel deploy --prod"}}' | ~/.claude/vercel-deploy-guard.sh` – a válaszban `"permissionDecision":"ask"` kell, hogy legyen.

---

## 8. Memória és skill-könyvtár átvitele

### 8.1 Auto-memória (54 fájl, 452 KB)

Ez a legértékesebb, nem újraépíthető rész: 54 memóriafájl az összes projektről és munkamódszerről.

```bash
mkdir -p ~/.claude/projects/-Users-benedekdozsa/memory
# a forrásgépről (külső meghajtó, AirDrop, vagy OneDrive-ra előre kimásolva):
cp -R "<FORRAS>/memory/" ~/.claude/projects/-Users-benedekdozsa/memory/
```

> Ha az új gépen más a felhasználónév, a mappa neve is más lesz: a projektmappa a munkakönyvtár útvonalából képződik, kötőjelekkel. Ilyenkor a `-Users-<uj-nev>` nevű mappába kell tenni.

### 8.2 Skill-könyvtár

A skillek mester példányai a `~/Documents/AI code/0. Claude SKILLS/` mappában vannak, az az `AI code` mappával együtt jön át. Projektbe mindig **másolat** megy, soha nem symlink, a `telepit.sh` scripttel.

**Check:** `ls ~/.claude/projects/-Users-benedekdozsa/memory | wc -l` – 54 körül kell lennie.

---

## 9. Amit csak én tudok megtenni (ne próbáld automatizálni)

1. **Claude Code belépés** a Max fiókkal (3. szakasz).
2. **Smartlead API-kulcs** az MCP szerverhez. A régi gépen a `~/.claude.json` `mcpServers.smartlead.env.SMARTLEAD_API_KEY` értéke, vagy a Smartlead felületén újragenerálva. Ne kerüljön OneDrive-ra vagy repóba.
3. **Vercel MCP OAuth**: első használatnál böngészős engedélyezés.
4. **`vercel login`, `firebase login`, `gh auth login`, `supabase login`.**
5. **rclone újrakonfigurálás** a Google Drive remote-hoz (`rclone config`).
6. **OneDrive kliens** telepítése és szinkron bevárása (a Med-Econ és a J&J anyagok ott vannak).
7. **Adatmappák átvitele:** `~/Documents/AI code` (a teljes munkakönyvtár), `~/personal-os`, `~/echo-brizzagency-com`, és a `~/.claude/projects/.../memory`.
8. **launchd ütemezés a Personal OS szinkronhoz**, ha az új gépen is kell: `~/Library/LaunchAgents/hu.dozsa.personal-os.sync.plist` és a `scripts/sync-agent.sh`.
9. **VS Code kiegészítők** (19 db, a lista a `LELTAR.md`-ben). Gyors út: `code --install-extension <id>` soronként.

---

## Mi nem jött át szándékosan

- **`vercel-plugin@vercel` (0.40.1):** a duplikált Vercel plugin, ez okozta a kétszeres skill-listát. Az official 0.44.0 mindent tud, amit ez, plusz három skillt (`microfrontends`, `vercel-connect`, `vercel-firewall`).
- **`settings.local.json`:** kb. 60 egyedi, projektspecifikus Bash-engedély a régi gépről. A `bypassPermissions` mód miatt nincs rá szükség, és a legtöbb útvonal amúgy is elavult.
- **A 255 plugin a katalógusból:** elérhető marad a `/plugin > Discover` alatt, de egyik sem volt telepítve, és nem is kellett.
