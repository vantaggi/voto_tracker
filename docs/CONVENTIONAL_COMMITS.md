# 📝 Conventional Commits — Voto Tracker

Ogni commit usa un **prefisso** che lo script di changelog mappa a una categoria.
Niente emoji nel messaggio: le aggiunge lo script (`scripts/bump_version.py`).

## Tabella prefissi → categoria changelog

| Prefisso | Categoria changelog |
|:--|:--|
| `feat` | 🚀 Nuove Funzionalità |
| `fix` | 🐞 Bug Fix |
| `ui` | 🎨 Interfaccia & Design |
| `perf` | ⚡ Prestazioni |
| `docs` | 📝 Documentazione |
| `refactor` | 🛠️ Refactoring |
| `test` | 🧪 Test |
| `chore` | ⚙️ Manutenzione (nascosto dal changelog) |

## Regole d'oro

1. Prefisso **minuscolo** + `: ` + descrizione chiara orientata all'utente finale.
   - ✅ `feat: aggiungi modalità proiettore a schermo intero`
   - ✅ `fix: correggi il calcolo del vincitore in caso di pareggio`
   - ❌ `Feat: 🚀 nuova feature` (maiuscola + emoji)
2. **Un solo prefisso per commit.** Un commit = un tema.
3. **Niente emoji nel messaggio** (le inserisce lo script nel CHANGELOG).
4. Lo **scope** è opzionale fra parentesi: `fix(provider): ...`, `ui(charts): ...`.
5. Collega il commit al BOARD citando l'ID dove utile:
   `test: copri il vote-log di ScrutinyProvider (TEST-001)`.

## Relazione con il BOARD

I prefissi dei task nel `docs/BOARD.md` mappano ai prefissi commit:

| ID task | Prefisso commit tipico |
|:--|:--|
| `FEAT-*` | `feat` |
| `FIX-*` | `fix` |
| `DOC-*` | `docs` |
| `TEST-*` | `test` |
| `PERF-*` | `perf` |
| `INFRA-*` | `chore` / `refactor` |

## Esempio di sessione

```bash
git commit -m "feat: aggiungi export PDF del report scrutinio"
git commit -m "ui(card): allinea lo swing al token outlineVariant"
git commit -m "docs: aggiorna BOARD con la Wave 2"
git commit -m "chore: bump dipendenza fl_chart"   # non comparirà nel changelog
```
