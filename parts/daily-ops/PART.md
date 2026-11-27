# Part: Daily operations bots

## What it does

This part sets up a team of bots in Grok (https://grok.com), the AI assistant from xAI. It uses a ready-made template, "AI Bot System Template.zip".

- **A Chief of Staff bot.** You talk to this one bot. It passes work to the others and reports back in short updates.
- **Specialist bots.** The first three:
  - Inbox Triage sorts your email and drafts replies.
  - CRM & Orders keeps your customer list and orders sheet.
  - Money & Bills tracks bills, subscriptions and receipts.
  You can add more later. The template has bots for websites, invoices, prospecting and more.
- **Routines that run on a schedule.** A morning brief, a daily check that every connection works, alerts when a new lead writes in, weekly follow-up drafts, and a nightly backup copy of your sheets.
- **A folder in your Google Drive** with a to-do sheet, an orders sheet, a customer list and a sync document.
- **Optional: Claude reads the same picture.** A Claude Project reads the sync document each morning, so Claude and Grok know the same things.

**Drafts only.** The bots never send, buy, post, pay or delete anything without your yes in the Grok chat.

## What it costs

- **A paid Grok plan.** Grok changed its plans in October 2026, and published prices disagree. Claude opens Grok's plans page, reads the current price, and tells you before you buy.
- **Google Drive, Gmail and Calendar:** free with a Google account.
- **The optional Claude Project:** part of your paid Claude plan.

## What you need

- **The file "AI Bot System Template.zip".** Ask the person who shared this folder with you for it. Save it in your Downloads folder, or tell Claude where it is.
- A Google account with the Gmail inbox and calendar you want the bots to read.
- A card, for the Grok plan.
- About 1 to 2 hours, mostly answering the setup questions.
- Optional: business files the bots should know, such as a price list, product sheet, FAQ or brand guide. Never passwords or keys.

## If you already use…

Ask: "Which email and calendar do you use: Gmail or Outlook? Where do you keep your customers and orders? Do you already have a paid Grok plan? Does any tool or assistant already sort your email or draft replies?"

| Tool they use | Recommendation | Why |
|---|---|---|
| A paid Grok plan | **Keep it. Skip buying.** Check it allows connectors and scheduled routines. | You already pay for it. |
| Gmail and Google Calendar | **Connect them.** | Grok has a built-in Gmail and Google Calendar connector. |
| Outlook and Microsoft 365 | **Connect Outlook Mail & Calendar.** Use a Google Drive folder for the sheets, or ask Grok to adapt the sheets to OneDrive. | Grok has built-in Outlook and OneDrive connectors. The template's sheets and sync document are written for Google Drive. |
| Salesforce | **Keep it as your customer list. Connect it, and tell the CRM & Orders bot that changes need your yes.** | Grok's Salesforce connector can create and update records. |
| HubSpot or another CRM | **Keep it as your customer list.** Tell Grok it's your CRM when it asks (setup question 3.1). Use the template's customer sheet only for what your CRM doesn't hold. | Grok's built-in connector list had no HubSpot connector in November 2026, so the bots can't read it directly. |
| Slack | **Skip Slack reports for now,** or ask Grok whether it can reach Slack. Reports still arrive in the Grok chat. | Slack wasn't in Grok's built-in connector list in November 2026. |
| A tool or assistant that already sorts email or drafts replies | **Keep what works. Skip the Inbox Triage bot.** | Two tools acting on one inbox draft twice and confuse each other. |
| QuickBooks, Xero or another accounting tool | **Keep it as your record.** The Money & Bills bot only reads bills and receipts from email. | Your accounting tool stays the source of truth. |

Source: Grok's connector list and how to add one: https://docs.x.ai/grok/connectors (checked 2026-11-26). If Grok's page shows a different list, go by what the page shows.

## Steps

The template is private. Never copy it, or any text from it, into this repo. Read it on the Mac and refer to its files by name.

### 1. Get and check the template

1. **Say:**
   > This part uses a template file called "AI Bot System Template.zip". Ask the person who shared this folder with you for it. Save it in your Downloads folder, or tell me where you saved it. Tell me "done" when you have it.

2. Check the file. The script finds it in Downloads, checks its sha256, and unpacks a reading copy:
   ```
   bash scripts/check-template.sh                      # looks in ~/Downloads
   bash scripts/check-template.sh "<path to the zip>"  # if they saved it elsewhere
   ```
   - **It prints `TEMPLATE_OK`:** note the `zip:` and `folder:` lines. Go on.
   - **It says the file is not the expected template:** stop this part. Don't open the file or upload it anywhere.
     ```
     bash scripts/progress.sh block daily-ops "template file did not match"
     ```
     **Say:** "The template file you have doesn't match the one this setup expects, so I've stopped this part. Ask the person who shared this folder with you for a fresh copy. We'll go on with your other parts." Then go on to the next part.

3. Read these files in the unpacked folder, in full: `README.md`, `setup-questions.md`, `routines.md`, `grok-bots/README.md`, `grok-bots/00-chief-of-staff.md`, `grok-bots/02-inbox-triage.md`, `grok-bots/08-crm-orders.md`, `grok-bots/03-money-bills.md`, `templates/README.md`, `skills/getting-started/SKILL.md` and `CLAUDE-BRAIN.md`. They tell you what Grok will ask and build. Don't paste them into the chat.

### 2. Get a paid Grok plan

1. Open https://grok.com and have the person sign in or create an account. **YOU DO THIS: sign in.**
2. If they don't have a paid plan, find Grok's plans or upgrade page. Read the price of the plan that includes connectors and scheduled tasks.

   **Say** (with the real numbers):
   > The bots need a paid Grok plan. The <plan name> plan costs $<price> a <month or year>. It includes connectors to your email, calendar and Drive, and scheduled routines. Shall I take you to checkout?

   Wait for a clear yes.
3. **YOU DO THIS: pay.** Take the purchase to the final Pay button. **Say:** "Your turn: check the total, enter your card, and click to pay. Tell me "done" when it's finished."

### 3. Upload the template and start the setup in Grok

1. Open a new Grok chat. Attach the zip from the `zip:` path. If your browser tool can't attach a file, see "File uploads" in CLAUDE.md.
2. Type this message into Grok and send it. It contains no secrets:
   > I attached a template for an AI operations system. Read every file in it first. Then set me up from it. Ask me the questions in setup-questions.md one at a time, and save each answer. Then help me connect Google Drive, Gmail, Google Calendar and any other connectors I need. Then build the folder, sheets and sync document from the templates folder. Create the Chief of Staff bot and its routines. Then create the Inbox Triage, CRM & Orders, and Money & Bills bots. Drafts only: never send, buy, post or delete anything without my yes.
3. **Pass Grok's setup questions to the person, and type their answers into Grok.** Grok asks one question at a time.
   - Read each question in Grok. Ask the person the same question here in plain words. Explain it from `setup-questions.md` if it isn't clear.
   - Type their answer into Grok and send it. If a question doesn't fit, type "skip".
   - Never type a password, key or card number into Grok. If Grok asks for one, say no and tell the person.

   **Say** (before the first question):
   > Grok will now ask setup questions one at a time, such as your business name, which inboxes to watch, and who never to contact. I'll ask you each one here and type your answers into Grok. Say "skip" for any that don't fit.

### 4. Connect Google Drive, Gmail and Calendar

Grok asks for connectors after the questions. If it doesn't, open https://grok.com/connectors yourself.
- Use the button that adds a new connector. Choose **Gmail & Google Calendar**, then **Google Drive**. Add Outlook or OneDrive instead if they use Microsoft.
- **YOU DO THIS: sign in to Google and review the access.** **Say:** "Your turn: sign in to Google and read what Grok asks to see. Allow only what it needs for email, calendar and Drive. Tell me "done" when you're back on the connectors page."
- Connect only the inboxes and calendars the person named. Skip connectors they didn't ask for.

### 5. Check what Grok built

When Grok says it built the folder and bots, check each item yourself. Open Google Drive and Grok in the browser.

1. **The Drive folder** has a tasks sheet, an orders sheet, a customer sheet, a sync document and an empty archive folder. `templates/README.md` lists them.
2. **The Chief of Staff bot** exists, with the instructions from `grok-bots/00-chief-of-staff.md` filled in. No `{{` placeholders are left.
3. **The routines** match the six core routines in `routines.md`, at the times the person chose.
4. **The first three specialist bots** exist: Inbox Triage, CRM & Orders, and Money & Bills.
5. **Nothing sends.** Read each routine's prompt. None of them sends, posts, buys or deletes. If Grok turned on anything the person didn't ask for, such as an automatic reply, show it to the person and turn it off with their yes.

If something is missing, ask Grok in the same chat to create it, and check again.

### 6. Add business files and rules

1. Ask: "Do you have files the bots should know, such as a price list, product sheet, FAQ or brand guide?" Upload the ones they choose to Grok. Never upload passwords, keys or card details.
2. Ask the rule questions here, and type the answers into Grok's chat for the Chief of Staff bot to save:

   **Say:**
   > A few rules for your bots:
   > 1. Is there anything you can't sell, or can't say, in some places? For example a product that can't appear on one website, or a claim you're not allowed to make.
   > 2. Is there anyone the bots must never contact?
   > 3. Are there topics they should never bring up?
   > 4. Is there anyone whose requests the bots should treat like yours, such as a partner or assistant?

3. Say the anti-spam rules from CLAUDE.md (hard rule 6), unless `progress.sh get spam_rules_said` is already `yes`. The bots draft follow-up emails that the person sends.

### 7. Run the Daily Health Check and a test brief

1. In Grok, ask the Chief of Staff bot: "Run the Daily Health Check now." Read the answer. Every source should say OK. For each FAILED or NOT CONNECTED source, reconnect it in step 4 and run the check again.
2. Ask: "Run a test Daily Brief now." Check that it lists today's calendar, recent email from each connected inbox, and a sources line.
3. **Say:** "Here's your first brief. Does anything look wrong or missing?" Pass their changes to Grok.

### 8. Optional: let Claude read what Grok knows

Do this step if the person chose "everything" (`progress.sh get claude_grok_sync` prints `yes`). Otherwise ask: "Do you also want Claude to read your bots' daily sync document, so you can ask Claude about your day too?" Skip it on no.

1. Make a filled copy of `CLAUDE-BRAIN.md` from the unpacked template. Replace each `{{PLACEHOLDER}}` with the person's answers. Ask for any you don't have. Delete optional sections they don't want. Save it outside this repo:
   ```
   mkdir -p ~/.config/ai-business-setup/daily-ops
   # write the filled copy to ~/.config/ai-business-setup/daily-ops/claude-brain.md
   ```
   Check that no `{{` is left.
2. Open https://claude.ai in the browser. **YOU DO THIS: sign in**, if needed.
3. Create a Project named "<Company> HQ". Paste the filled copy into the Project's instructions.
4. Connect Google Drive to Claude. **YOU DO THIS: sign in to Google and review the access.** Allow only what it needs.
5. In the Project, start a chat and send: "Read the sync document and give me my morning brief." Check that the answer uses today's sync document.
6. **Say:** "Each morning, open the <Company> HQ project in Claude and ask for your brief. Claude reads what your Grok bots wrote at 5 AM."

## Check

- `check-template.sh` printed `TEMPLATE_OK`.
- The Daily Health Check shows OK for every source the person connected.
- A test Daily Brief came back with real calendar and email items.
- The Drive folder, the Chief of Staff bot, its routines and the three specialist bots exist.
- No routine sends, posts, buys or deletes.
- If step 8 ran: the Claude Project answered from today's sync document.

Then `bash scripts/progress.sh done daily-ops`.

**Say** (fill in the values):
> Your bot team is set up in Grok.
> - Talk to: the Chief of Staff bot
> - Morning brief: <time> on weekdays
> - Your sheets and sync document: Google Drive, folder "<folder name>"
> - Bots: Chief of Staff, Inbox Triage, CRM & Orders, Money & Bills
> - Cost: Grok <plan>, $<price> a <month or year>
>
> The bots only draft. Nothing goes out until you say yes in Grok. To add more bots later, ask the Chief of Staff bot.

## Known problems

- **Grok won't accept the zip.** Unpack it for the person and upload the files instead. Copy the unpacked folder to `~/Documents/AI Business Setup/Daily ops template/`, open it in Finder, and have the person select all files in the upload dialog. Never put this copy in the repo.
- **A routine's hand-off to another bot fails**, for example with "aborted". The template's `routines.md` (Troubleshooting) says the routine should still deliver its own result in chat and say the hand-off failed. If results go missing, ask Grok to add that rule to the routine.
- **The health check says an inbox is empty.** Zero mail in a busy inbox usually means the connector failed. Reconnect it.
- **A placeholder like `{{COMPANY}}` is left in a bot's instructions.** Ask Grok to fill it from the saved answers, or give it the answer.
- **The Grok page looks different from these steps.** Grok changes often. Describe what you see and adapt. Never guess at a button that costs money or sends something.
