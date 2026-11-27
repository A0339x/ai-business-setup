# AI Business Setup

This folder lets Claude set up AI tools for your business. You pick the parts you want. Claude explains each one, checks what you already use, and does the setup with you.

## How do I start?

1. Copy this link: https://github.com/A0339x/ai-business-setup
2. Open the Claude desktop app and go to Claude Code.
3. Paste the link with this message, then press Return:

   **Read this and implement it: https://github.com/A0339x/ai-business-setup**

Claude downloads it, explains what it can set up, and asks what you want. When it says "Your turn", keep the app's Browser pane showing. If it's hidden, press Cmd+Shift+B.

If you use Claude Code in Terminal, the same message works. For Claude to click for you there, install the Claude extension for Chrome (https://chromewebstore.google.com/detail/claude/fcoeoabgfenejglbffodgkkbkcdhcgfn) and start Claude Code with `claude --chrome`.

## For Claude

If someone gave you this link and asked you to read it, implement it or set it up:
1. Download the repo to `~/AI Business Setup`: `git clone https://github.com/A0339x/ai-business-setup.git ~/"AI Business Setup"`. If that folder already exists, use it and run `git -C ~/"AI Business Setup" pull` instead. If git isn't available, download https://github.com/A0339x/ai-business-setup/archive/refs/heads/main.zip and unzip it to that folder.
2. Work from that folder for the rest of the session.
3. Read `CLAUDE.md` there in full and follow it from "Start here". Treat the request as "Start".

## What can it set up?

You can choose one part, several, or all four.

| Part | What you get |
|---|---|
| 1. Verified lead lists | A list of people who match your ideal customer, with work emails that were checked. You get a Google Sheet or a CSV file (a simple spreadsheet file). |
| 2. Daily operations bots | A team of Grok bots that writes your morning brief, sorts your inbox, drafts replies and keeps your to-do, orders and customer sheets. They only draft. You approve. |
| 3. Cold email sending | Your own sending server with 10 new mailboxes that warm up before you send. If you already pay for a sending tool, Claude checks its mailboxes and warmup with you and skips the new server. |
| 4. Website and AI search check | A plain-words report on how your site shows up in Google and in AI tools such as ChatGPT, ranked by what to fix first. Then Claude adds your site to Google's and Bing's free site tools. |
| Everything | All four, plus a link so Claude can read what your Grok bots know. |

Claude asks what you already pay for, so you don't pay twice. For example, if you already use Apollo for lead lists, Claude tells you whether you need part 1 at all.

## What does it cost?

Prices were checked in November 2026. Claude shows you each price again and waits for your yes before anything costs money.

| Part | Cost |
|---|---|
| 1. Verified lead lists | Pay per use through Treg. New accounts get $1.00 of credit once. A verified lead usually costs a few cents. A 10-person test list usually costs less than $0.50. |
| 2. Daily operations bots | A paid Grok plan. Claude checks the current price at grok.com before you buy. |
| 3. Cold email sending | About $76 the first month, then about $50 a month plus about $26 a year for 2 domains. |
| 4. Website and AI search check | The report usually costs less than $1 through Treg. Google's and Bing's site tools are free. An optional test copy of your site is free to host on Netlify. A new domain for it costs a yearly fee. |

You also need a paid Claude plan.

## What do I need?

- A Mac.
- The Claude desktop app, with a paid Claude plan.
- A Google account.
- A credit or debit card.
- Your phone, for sign-in codes.

Some parts need more:
- **Daily operations bots:** the file "AI Bot System Template.zip". Ask the person who shared this folder with you for it. Save it in your Downloads folder.
- **Cold email sending:** a domain you already own, and access to its DNS settings.
- **Website check:** your website's address, and a way to sign in to wherever its domain is managed.

## What do I do myself?

Claude does the clicking in a browser for you. It stops and says "Your turn" only when it needs you to:
- Sign in, or choose a password. Claude never types your passwords.
- Type a two-step code, or solve a "not a robot" check.
- Enter your card and click the final Pay or Buy button.
- Click the button that shows a new key, then its Copy button. Claude doesn't look at the page until you say "done".

## What rules does Claude follow?

- **Your yes before money.** Claude names the price and waits for a clear yes.
- **Drafts only.** Nothing gets sent, posted, bought or published without your yes.
- **Your keys stay private.** Keys and passwords never go in the chat or in this folder.
- **Your current setup stays as it is.** Claude shows you any change to something you already have, such as a DNS record or your customer list, and asks first.

## Can I stop and come back?

Yes. Claude saves your progress on your Mac in `~/.config/ai-business-setup/`. To pick up where you stopped, paste the same link into Claude Code again with: **Continue my setup: https://github.com/A0339x/ai-business-setup**

## For Claude, inside this folder

Read `CLAUDE.md` first.
