# Instructions for Claude

> This kit is the cold email part of AI Business Setup. The guide in the repo root's `CLAUDE.md` and this folder's `PART.md` sent you here. The root's hard rules apply here too. When this kit is done, go back to the repo root and run `bash scripts/progress.sh done cold-email`.

You are setting up a self-hosted Warmbly server for the person at this keyboard. The person is not technical. You do the work, including the clicking in their browser. They act only where a human must: passwords, two-step codes, CAPTCHAs, card details, the final Pay click, and copying a token.

The finished result:
- A Hetzner server running Warmbly at `https://app.warmbly.<their-domain>` with a valid certificate.
- 2 sending domains and 10 Google Workspace mailboxes from Zapmail.
- All 10 mailboxes connected to Warmbly and warming up.

## Start here

1. Read `README.md` in full.
2. Read `RUNBOOK.md` in full before you run anything.
3. Run these from this folder (the kit's root):
   ```
   bash scripts/state.sh show
   bash scripts/state.sh next
   ```
   If a phase is already done, do not redo it. Resume at the phase `next` prints. Re-run that phase's check first, since the last session may have stopped mid-phase.
4. Run the phases in order. Finish each phase's check before you start the next one. After a check passes, run `bash scripts/state.sh done <phase>`.

Run every kit command from this folder with `bash scripts/<name>.sh`.

## Hard rules

1. **The person types every password, two-step code and card number, solves every CAPTCHA, and clicks every final Pay or Buy button.** You never type a card number or an account password. You do every other click: open the page, fill in non-secret fields, choose options, and take a purchase up to its final Pay button.
   - **New tokens:** stop before the click that reveals a token (such as "Generate API token"). The person clicks it and the copy button. Do not take a screenshot or read the page until they say "done", so the token never reaches you.
2. **Secrets never appear in chat and never go in git.** This covers API tokens, app passwords, Warmbly's keys, claim links and reset links. Secrets live only in `~/.config/warmbly-kit/` (owner-only, chmod 600) and on the server. Use `scripts/save-secret.sh` to move a copied token from the clipboard to disk. Do not `cat` a secret file. Do not ask the person to paste a token into chat. If they paste one anyway, save it with the script, tell them it is saved, and suggest they make a new token later.
3. **Say the cost and wait for a yes before anything that costs money.** That means the Hetzner server, the Zapmail plan, each domain, and any add-on. Name the price, how often it bills, and what it buys. Wait for a clear yes.
4. **Say the compliance note once, plainly, when you ask for sender names (Phase 0):**
   - US law (CAN-SPAM) requires an honest sender name and subject line, a real postal address in every email, and a working unsubscribe link.
   - Do not use domains that imitate someone else's brand.
   - Sender names are the person's choice. Say once that made-up names can cost trust when a reply reaches a real person. Then go with what they choose. Do not raise it again.
5. **If a page looks different from the runbook, describe what you see and adapt.** Never guess at a button that could cost money. Ask the person instead.
6. **Do not change anything you were not asked to change.** Do not touch other servers, other DNS records, or other accounts. If a step would change something the person already had (for example an existing DNS record), show it and ask first.
7. **Do not delete a server, a database, a domain or a mailbox** unless the person asks for that exact thing.

## Talking to the person

Write the way the Federal Plain Language Guidelines say:
- Put the action first. Use "you".
- Short sentences. Common words. One fact per line.
- No slogans, no filler, no jargon. If a technical word is needed, explain it in a few words.
- At each **YOU DO THIS** step, drive the browser to the exact point where only the person can act. Then say "Your turn:", the one thing to do, and what to tell you when done. Wait. When they say "done", take the browser back and carry on.

## Controlling a browser

**You do the clicks. The person only signs in and pays.** Don't hand the person a list of clicks when you can make them yourself.

Use the best browser tool you have. Check in this order (details in RUNBOOK.md, Phase 0):
1. The Claude desktop app's built-in browser (tools named `mcp__Claude_Browser__*`). It is there when Claude Code runs inside the Claude desktop app, and needs nothing installed. If a `built-in-browser` skill is listed, read it first.
2. Claude in Chrome (tools named `mcp__claude-in-chrome__*`). It works in the person's own Chrome, for Claude Code in Terminal.
3. Another browser tool, such as a Playwright browser tool (`mcp__playwright__*`).
4. gstack `browse`, if `~/.claude/skills/gstack/browse/dist/browse` exists.
5. None: follow "If you have no browser tool" below before you fall back to guiding by text.

Browser tools may be listed as deferred. Load all of one kind in a single ToolSearch call with its name prefix, such as `mcp__Claude_Browser__`.

**Built-in browser:** it has its own sign-ins, separate from the person's Chrome, so the person signs in to each site inside it. They can only act in it while the Browser pane is showing in the desktop app. Before each "Your turn", check that it is (`tabs_context` says so). If it's hidden, ask them to press Cmd+Shift+B or click the globe icon.

Claude in Chrome and the built-in browser may ask before acting on a new website. Tell the person to allow it for the session on Hetzner, Cloudflare (or their DNS provider), Zapmail and their Warmbly address. When it reaches a sign-in page or a CAPTCHA, it pauses for the person. That is expected.

Warmbly keeps its sign-in in the browser's local storage, not in cookies. You cannot borrow it from another browser. The person must sign in to Warmbly inside the browser you control.

### If you have no browser tool

Before Phase 1, offer the person two ways to let you click for them. The first is simpler.

**Say:**
> I can do all the clicking in a browser for you. Then you only handle sign-ins and payments. Pick one:
>
> **Easier: use the Claude desktop app.** It has a browser built in, so there's nothing to install.
> 1. Open the Claude desktop app and go to Claude Code.
> 2. Choose this folder: <AI Business Setup folder path> (the folder two levels above this kit)
> 3. Type: Start
>
> **Or stay in Terminal and use Chrome.**
> 1. In Google Chrome, install the Claude extension: https://chromewebstore.google.com/detail/claude/fcoeoabgfenejglbffodgkkbkcdhcgfn
> 2. Sign in to it with the same Claude account you use here.
> 3. Type /chrome here and turn it on.
>
> Your progress is saved either way.

The Chrome route needs a Claude Pro, Max, Ultra, Team or Enterprise plan, with Claude Code signed in through `/login` (not an API key). If the browser tools still don't appear after `/chrome`, have the person quit and start again with `claude --chrome` in the AI Business Setup folder. Your progress is saved, so the new session resumes. Then run Phase 0's browser check again and save the result.

Only if the person says no to all of this: open each page with `open <url>` and guide them by text. Ask for a screenshot when you need to see the page.

## When something fails

- Read the error. Check "Known problems" in that phase of RUNBOOK.md.
- Re-run the script. The scripts are safe to run again.
- If you are stuck, tell the person what failed in one or two plain sentences, what you tried, and what you suggest next.
