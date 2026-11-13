# Warmbly on Hetzner: setup kit

This kit lets Claude Code set up your own cold email server. Claude does the technical work. You sign up, pay, and approve a few things.

## What you get

- Your own server at Hetzner, running Warmbly. Warmbly is an open-source tool for cold email and inbox warmup.
- A web address for it: `https://app.warmbly.<your-domain>`.
- 2 new domains for sending email.
- 10 Google Workspace mailboxes on those domains, 5 on each.
- All 10 mailboxes connected to Warmbly and warming up.

Warmup means the mailboxes send ordinary emails to each other and reply, so Google learns to trust them. Plan on 3 to 4 weeks of warmup before you send real campaigns.

## What it costs

Prices as checked in November 2026. Claude shows you each price again before you pay.

| Item | Price | Billed |
|---|---|---|
| Hetzner CX33 server (4 CPUs, 8 GB memory) | about $10.59 ($9.99 server + $0.60 IPv4 address) | monthly |
| Zapmail Starter plan, 10 Google Workspace mailboxes | $39 | monthly |
| 2 sending domains at Zapmail | about $12.99 each for a .com | yearly |

- First month: about $76.
- After that: about $50 a month, plus about $26 a year for the 2 domains.
- Hetzner may add sales tax or VAT for your country.
- Skip the add-ons Zapmail offers. You do not need them for this setup.

## How long it takes

- About 1 to 2 hours with you nearby. Most of that is waiting on Claude.
- Then up to 3 hours while Zapmail creates the mailboxes. You can walk away.
- Some mailboxes may need a retry about 3 hours after they are first connected. Claude handles it.
- Plan for most of one day. You can stop and pick up later. Claude saves its progress.

## What you do yourself

Claude opens each page for you. You:
- Create a Hetzner account, add a card, and pass Hetzner's identity check.
- Create a Hetzner API token and click its Copy button.
- Add 2 DNS records for your domain, or create a Cloudflare token so Claude can add them.
- Create your Warmbly owner account and pick its password.
- Create a Zapmail account and pay for the plan and the 2 domains.
- Choose the 10 sender names and the 2 sending domain names.
- Sign in to Warmbly in the browser Claude controls.
- Type any password, card number, or two-step code. Claude never types these.

## What you need before you start

- A Mac with Claude Code installed.
- A credit or debit card.
- A domain you already own, with access to its DNS settings. Warmbly's web address lives under it, for example `app.warmbly.yourcompany.com`. This domain is not used to send email.
- Your phone, for sign-in codes.
- Google Chrome with the Claude in Chrome extension, if you have it. It lets Claude open pages in your own browser. Without it, Claude guides you step by step.

## What to know about sending

- US law (CAN-SPAM) requires an honest sender name and subject line, your real postal address in every email, and a working unsubscribe link.
- Do not use domains that imitate someone else's brand.
- Warmbly's own documents say warmup on a self-hosted server is weaker than on Warmbly's paid cloud service. Your 10 mailboxes warm up only with each other.
- Warmbly cannot send its own emails yet, such as password resets. If you forget your Warmbly password, ask Claude to reset it on the server.

## Where things are kept

- On your Mac: `~/.config/warmbly-kit/`. Only your user account can read it. It holds your tokens, the mailbox passwords, and a backup of Warmbly's two encryption keys.
- On the server: `/opt/warmbly`.
- **Keep the key backup safe.** If both copies of Warmbly's two encryption keys are lost, every mailbox password stored in Warmbly becomes unreadable.

## How to start

Open Claude Code in this folder and say: "Read CLAUDE.md and set up Warmbly."

## For Claude

Start with `CLAUDE.md`, then `RUNBOOK.md`.
