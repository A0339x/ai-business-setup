# Part: Cold email sending

## What it does

This part gives you a way to send cold email that lands in inboxes. There are two routes:

- **You already pay for a sending tool,** such as Instantly, Smartlead or Lemlist: Claude helps you use it, checks your sending domains, and skips the new server.
- **You don't have one:** Claude sets up the Warmbly kit in this folder. You get:
  - your own server at Hetzner, running Warmbly, an open-source tool for cold email and inbox warmup;
  - 2 new domains for sending, so a sending problem never touches your main domain;
  - 10 Google Workspace mailboxes on those domains, from Zapmail;
  - all 10 mailboxes warming up. Warmup means the mailboxes email each other and reply, so Google learns to trust them. Plan on 3 to 4 weeks of warmup before you send real campaigns.

This part sends nothing to real people. Campaigns come later, with your yes.

## What it costs

**Warmbly route** (prices checked in November 2026; Claude shows each price again before you pay):

| Item | Price | Billed |
|---|---|---|
| Hetzner CX33 server | about $10.59 | monthly |
| Zapmail Starter plan, 10 mailboxes | $39 | monthly |
| 2 sending domains at Zapmail | about $12.99 each for a .com | yearly |

- First month: about $76.
- After that: about $50 a month, plus about $26 a year for the 2 domains.

**Existing tool route:** no new cost. You keep paying for the tool you have.

## What you need

For the Warmbly route:
- A domain you already own, with access to its DNS settings. Warmbly's web address goes under it, such as `app.warmbly.yourcompany.com`. This domain doesn't send email.
- A card.
- Your phone, for sign-in codes.
- About 1 to 2 hours with you nearby, then up to 3 hours of waiting while Zapmail creates the mailboxes. Plan for most of one day. You can stop and pick up later.

## If you already use…

Ask: "Do you already send cold email with a tool? For example Instantly, Smartlead, Lemlist, Apollo sequences or HubSpot sequences."

| Tool they use | Recommendation | Why |
|---|---|---|
| Instantly | **Keep Instantly. Skip Warmbly.** | Instantly sends, warms up mailboxes, and has a Lead Finder that finds leads. Its plans start at $47 a month. It's the paid option that also finds leads. |
| Smartlead or Lemlist | **Keep it. Skip Warmbly.** | You already pay for sending and warmup. A second sending setup adds cost and work. |
| Apollo sequences | **Keep Apollo. Skip Warmbly.** | Apollo includes email campaigns on every account. On Apollo's free plan you can connect only Gmail accounts. |
| HubSpot sequences | **Keep HubSpot if your plan includes sequences. Skip Warmbly.** | HubSpot sequences need Sales Hub or Service Hub Professional or Enterprise. |
| A newsletter tool, for people who signed up | **Keep it for those people. Don't use it for cold email.** Ask Claude to read its rules on lists before you import one. | Newsletter tools set their own rules on where contacts come from. |
| Nothing, and you want low monthly cost | **Use the Warmbly kit.** | About $50 a month for 10 mailboxes. |
| Nothing, and you want less setup and a lead finder | **Consider Instantly** (from $47 a month, plus mailboxes). | It's paid, but sending and lead finding are in one place. |

Sources: Instantly plans and Lead Finder: https://instantly.ai/pricing (checked 2026-11-26; the page showed conflicting numbers, so check again before you quote). Apollo campaigns on every account, Gmail only on free plans: https://www.apollo.io/pricing. HubSpot sequences tiers: https://knowledge.hubspot.com/sequences/create-and-edit-sequences.

## Steps

### 1. Pick the route

From the person's answer above, recommend one route in bold and wait for their choice. Save it:
```
bash scripts/progress.sh set cold_email_route "<existing-tool|warmbly>"
```

Say the anti-spam rules from CLAUDE.md (hard rule 6), unless `progress.sh get spam_rules_said` is already `yes`.

### 2a. Existing tool route

Claude checks the tool with the person, reads only, and changes nothing.

1. **Open their sending tool in the browser.** For Instantly, open https://app.instantly.ai. For another tool, open its sign-in page. **YOU DO THIS: sign in.** **Say:** "Your turn: sign in to <tool>. Tell me "done" when you see its dashboard."
2. **Check the sending mailboxes.** Open the page that lists the email accounts the tool sends from. For each account, note:
   - whether warmup is on;
   - its health or deliverability score, if the tool shows one;
   - any account marked with an error or paused.

   In Instantly, the Email Accounts page has a Health Score column. Instantly's help pages aim for a score above 90%, show warmup status as a flame icon (grey means paused), and recommend at least 2 weeks of warmup before campaigns. New accounts show a score of 0 until warmup has run.
3. **Check each sending domain's email records.** Ask which domains they send from, or read them from the account list. These checks are read-only and free:
   ```
   dig +short TXT <domain>            # look for v=spf1
   dig +short TXT _dmarc.<domain>     # look for v=DMARC1
   ```
   DKIM records have a name set by the mailbox provider. If a settings page shows it, check it with `dig +short TXT <selector>._domainkey.<domain>`.
4. **Report in plain words.**

   **Say** (fill in the values):
   > Here's how your sending looks in <tool>:
   > - Mailboxes: <N>. Warmup on for <N>.
   > - Health: <N> above 90%, <N> below. <names of any with errors>
   > - Domain records: <SPF, DKIM and DMARC found or missing, per domain>
   > - Ready for campaigns: <which mailboxes, and which need more warmup>
   >
   > I haven't changed anything.

   If something needs fixing, say what and why. Don't change settings or DNS. If they want a fix, show the exact change and wait for a yes.
5. **Offer to load a lead list,** only if they made one earlier in this setup. **Say:** "Do you want me to add your lead list to <tool> as a paused campaign? Nothing sends until you start it." On a yes, import the contacts into a new campaign and leave it paused or as a draft. Never start a campaign. The person starts it when they're ready.
6. Check: you reported each mailbox and domain, and the person knows what, if anything, to fix.
7. Back at the repo root: `bash scripts/progress.sh done cold-email`.

Sources: Instantly Health Score and flame icon: https://help.instantly.ai/en/articles/13939939-warmup-health-score. Readiness (2 weeks of warmup, score above 90%): https://help.instantly.ai/en/articles/13938078-when-your-email-account-is-ready-for-campaigns (both checked 2026-11-26). For other tools, follow the goal of each step and describe what you see.

### 2b. Warmbly route

The Warmbly kit lives in this folder (`parts/cold-email/`). It has its own instructions, its own scripts and its own progress file. Its scripts must run from this folder.

1. Move into the kit folder. Use the saved repo path:
   ```
   cd "$(bash scripts/progress.sh get repo_root)/parts/cold-email"
   ```
2. Read the kit's `README.md`, `CLAUDE.md` and `RUNBOOK.md` in full, in that order. Follow its `CLAUDE.md` from "Start here". Run every kit command from this folder as `bash scripts/<name>.sh`, for example:
   ```
   bash scripts/state.sh show
   bash scripts/state.sh next
   bash scripts/preflight.sh
   ```
3. The browser check is already done. Copy the result into the kit's progress, so Phase 0 doesn't redo it:
   ```
   bash scripts/state.sh set browser "$(bash ../../scripts/progress.sh get browser)"
   ```
4. If the anti-spam rules were already said in this setup, in Phase 0 say only the two sentences about brand-imitating domains and made-up sender names.
5. After each kit phase passes its check, record it in this setup's progress as well:
   ```
   bash ../../scripts/progress.sh step cold-email phase-<number>
   ```
6. The kit has long waits: Hetzner's identity check, DNS, about 3 hours for Zapmail's mailboxes, and a retry about 3 hours after the first import. The person may stop during any of them. When they come back and type "Start", this setup's `next` returns `cold-email`. Move into the kit folder and run `bash scripts/state.sh next` to find the phase.
7. When Phase 8's `bash scripts/verify.sh` prints `VERIFY_OK`, go back to the repo root and mark the part done:
   ```
   cd "$(bash ../../scripts/progress.sh get repo_root)"
   bash scripts/progress.sh done cold-email
   ```

The kit's own README says to start by saying "Read CLAUDE.md and set up Warmbly". Ignore that line here; the person already started from the repo root.

## Check

- **Existing tool route:** each mailbox's warmup and health, and each sending domain's records, were checked and reported.
- **Warmbly route:** the kit's `bash scripts/verify.sh` prints `VERIFY_OK`, with 10 mailboxes active and warming across 2 domains.

**Say** for the Warmbly route: use the kit's "Summary for the person" at the end of its RUNBOOK.md Phase 8. Add:
> Don't send real campaigns for 3 to 4 weeks, while the mailboxes warm up. When you're ready, ask me to help you set up your first campaign in Warmbly.

## Known problems

- **A kit script says it can't find `kit.conf` or `lib.sh`.** It ran from the wrong folder. Kit scripts run from `parts/cold-email/`. This setup's scripts run from the repo root.
- **`ssh-config` stops because `Host warmbly` already exists.** The Mac already has a server by that name. The kit stops on purpose. Show the person the existing entry and ask before changing anything.
- **Resetting this setup's progress doesn't reset the kit.** The kit keeps its own progress in `~/.config/warmbly-kit/state.json`.
- **Anything else in the kit:** see "Known problems" in that phase of the kit's RUNBOOK.md.
