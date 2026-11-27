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

1. Ask which domains they send from. Check each one's email records. These checks are read-only and free:
   ```
   dig +short TXT <domain>            # look for v=spf1
   dig +short TXT _dmarc.<domain>     # look for v=DMARC1
   ```
   DKIM records have a name set by the sending tool. If the tool's settings page shows it, check it with `dig +short TXT <selector>._domainkey.<domain>`.
2. Tell the person in plain words what's missing, if anything. Don't change their DNS. If they want a fix, show the exact record and wait for a yes.
3. If they made a lead list earlier in this setup, offer to import it into their tool as contacts. Ask first. Put the contacts in a paused or draft campaign only. Never start a campaign without their yes.
4. Check: you reported the state of each domain's records, and the person knows what, if anything, to fix.
5. Back at the repo root: `bash scripts/progress.sh done cold-email`.

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

- **Existing tool route:** each sending domain's records were checked and reported.
- **Warmbly route:** the kit's `bash scripts/verify.sh` prints `VERIFY_OK`, with 10 mailboxes active and warming across 2 domains.

**Say** for the Warmbly route: use the kit's "Summary for the person" at the end of its RUNBOOK.md Phase 8. Add:
> Don't send real campaigns for 3 to 4 weeks, while the mailboxes warm up. When you're ready, ask me to help you set up your first campaign in Warmbly.

## Known problems

- **A kit script says it can't find `kit.conf` or `lib.sh`.** It ran from the wrong folder. Kit scripts run from `parts/cold-email/`. This setup's scripts run from the repo root.
- **`ssh-config` stops because `Host warmbly` already exists.** The Mac already has a server by that name. The kit stops on purpose. Show the person the existing entry and ask before changing anything.
- **Resetting this setup's progress doesn't reset the kit.** The kit keeps its own progress in `~/.config/warmbly-kit/state.json`.
- **Anything else in the kit:** see "Known problems" in that phase of the kit's RUNBOOK.md.
