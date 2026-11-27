# AI Business Setup

This folder lets Claude set up AI tools for your business. You pick the parts you want. Claude explains each one, checks what you already use, and does the setup with you.

## How do I start?

1. Open the Claude desktop app.
2. Go to Claude Code.
3. Choose this folder.
4. Type **Start**.

Claude takes it from there. Keep the app's Browser pane showing when Claude says "Your turn". If it's hidden, press Cmd+Shift+B.

**If you use Claude Code in Terminal instead:**
1. In Google Chrome, install the Claude extension: https://chromewebstore.google.com/detail/claude/fcoeoabgfenejglbffodgkkbkcdhcgfn
2. Sign in to it with your Claude account.
3. Open Terminal in this folder and run: `claude --chrome`
4. Type **Start**.

If Claude asks whether it may act on a website, allow it for this session.

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

Yes. Claude saves your progress on your Mac in `~/.config/ai-business-setup/`. Open this folder in Claude Code again and type **Start**. Claude picks up where you stopped.

## For Claude

Read `CLAUDE.md` first.
