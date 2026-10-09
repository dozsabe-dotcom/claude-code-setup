# Claude Code setup

A teljes Claude Code környezetem újratelepítése egy új gépen: pluginek, MCP szerverek, engedélyek, hookok, CLI és Python függőségek.

## Használat

Klónozd a repót az új gépen, nyisd meg Claude Code-dal, és add be ezt:

```
Olvasd be az UJ-GEP-TELEPITES.md fájlt, és hajtsd végre az 1-tól a 8-ig minden
szakaszt sorban. Minden szakasz végén futtasd le a "Check" sort, és írd ki,
hogy sikerült-e. A 9. szakasz az enyém, azt csak listázd ki a végén. Ha egy
lépés hibára fut, állj meg, írd le a hibát, és kérdezz.
```

## Fájlok

| Fájl | Mit tartalmaz |
|---|---|
| `UJ-GEP-TELEPITES.md` | a végrehajtható telepítőlista, 8 automatizálható szakasz + ami kézi |
| `LELTAR.md` | a forrásgép leltára (3 plugin, 19 VS Code kiegészítő, lemezterület) |
| `vercel-deploy-guard.sh` | PreToolUse hook: megállítja az éles és a linkeletlen Vercel deployt |
| `notify-stop.sh` | Stop hook: hangjelzés, ha a VS Code nincs előtérben |

## Amit a telepítés beállít

- **Pluginek:** `vercel@claude-plugins-official` (28 skill, 6 agent, 11 command, 1 MCP), `frontend-slides@frontend-slides`
- **MCP szerverek:** playwright, claude-design, smartlead (a Vercel MCP-t a plugin hozza)
- **settings.json:** engedélyek, `bypassPermissions`, `opus[1m]`, két hook, `additionalDirectories`
- **CLI:** gh, pandoc, poppler, potrace, rclone, ffmpeg, cloudflared, supabase, vercel, firebase-tools
- **Python:** 25 csomag (docx, pptx, openpyxl, pandas, matplotlib, reportlab, PDF-eszközök)

## Amit nem tartalmaz

Titkok nincsenek a repóban. Az API-kulcsok, az OAuth belépések (claude, vercel, firebase, gh, supabase), az rclone konfig és az adatmappák átvitele a `UJ-GEP-TELEPITES.md` 9. szakaszában van felsorolva, kézi lépésként.
