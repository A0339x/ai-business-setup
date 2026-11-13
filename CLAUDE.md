# Instructions for Claude

You are setting up a self-hosted Warmbly server for the person at this keyboard. The person is not technical. You do the work. They act only where a human must: sign-ups, payments, passwords, two-step codes, CAPTCHAs, and copying a token.

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

1. **The person does every sign-up, payment, card entry, password, two-step code and CAPTCHA.** You never type a card number or an account password. You may open the page, fill in non-secret fields, and point to the right button.
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
- At each **YOU DO THIS** step, say exactly what to click or type, where, and what to tell you when done. Then wait.

## Controlling a browser

Use the best browser tool you have. Check in this order (details in RUNBOOK.md, Phase 0):
1. Claude in Chrome (tools named `mcp__claude-in-chrome__*`; they may need loading with ToolSearch). It works in the person's own Chrome, which suits this job: they sign in there themselves.
2. Another browser tool, such as a Playwright browser tool (`mcp__playwright__*`) or a built-in browser.
3. gstack `browse`, if `~/.claude/skills/gstack/browse/dist/browse` exists.
4. None: open each page with `open <url>` and guide the person by text. Ask for a screenshot when you need to see the page.

Warmbly keeps its sign-in in the browser's local storage, not in cookies. You cannot borrow it from another browser. The person must sign in to Warmbly inside the browser you control.

## When something fails

- Read the error. Check "Known problems" in that phase of RUNBOOK.md.
- Re-run the script. The scripts are safe to run again.
- If you are stuck, tell the person what failed in one or two plain sentences, what you tried, and what you suggest next.
