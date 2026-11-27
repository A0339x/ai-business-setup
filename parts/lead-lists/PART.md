# Part: Verified lead lists

## What it does

- You describe your ideal customer: industry, company size, job title and location.
- Claude finds people who match, through Treg (https://treg.to). Treg is a pay-per-use marketplace of data tools.
- Claude checks each work email with an email verification service. Only emails that pass go on the list.
- You get a Google Sheet or a CSV file. A CSV file opens in Excel, Numbers or Google Sheets.
- Optional: a weekly refresh that adds new people who match.

Rules for every list:
- **Verified emails only.** An email marked risky, catch-all or unknown stays off the list.
- **Never guess an address.** No "firstname@company.com" made up from a pattern.
- **Skip anyone who declined, unsubscribed or asked not to be contacted.**

This part makes the list. It sends nothing.

## What it costs

- Treg bills per call from a prepaid balance. Its home page says it adds no markup to the data providers' prices.
- New verified Treg accounts get **$1.00 of credit once**.
- A verified lead usually costs a few cents. That is an estimate from Treg's catalog prices in November 2026:
  - finding people: free to about 2 cents per person, depending on the data source;
  - finding a work email: about 0.1 to 22 cents per email found, and nothing for a miss;
  - checking an email: about 0.1 to 3 cents per check.
- A 10-person test list usually costs less than $0.50, so the free credit covers it.
- When the credit runs out, the person adds funds to Treg with their card.

Claude reads the current prices with `treg catalog get` (free) and says the expected total before every paid run.

Sources: https://treg.to (sign-up, $1.00 credit, no markup); https://treg.to/llms.txt (setup paths, $1.00 once per verified account); prices from `treg catalog get treg.people.search`, `treg.people.email.find`, `treg.people.email.verify` and `treg.companies.search`, read 2026-11-26.

## What you need

- A Google account, a GitHub account, or an email address, to sign in to Treg.
- A card, if the list costs more than the free credit.
- A short description of your ideal customer.
- Optional: a list of people never to contact, such as unsubscribes exported from your email tool or CRM.

## If you already use…

Ask: "Do you use anything now to find leads or check emails? For example Apollo, ZoomInfo, Clay, LinkedIn Sales Navigator, HubSpot or an email checker. Do you pay for it and use it now, or did you only try it? And where do you keep your customers?"

How to use the table:
- **A tool counts only if they pay for it and use it now.** A tool they only tried, or use on a free plan, doesn't make you skip anything. Mention it once, then use Treg.
- **If they named Instantly,** ask whether they use Instantly's Lead Finder to find people, or only use Instantly to send. Only the Lead Finder counts here.
- **A finding tool and a CRM can both apply.** The finding tool's row decides how to find people. The CRM's row decides where the finished list goes. For example, Apollo plus HubSpot means: find people in Apollo, then import the list into HubSpot.
- Save the result: `bash scripts/progress.sh set lead_source "<treg|apollo|other tool name>"`.

| Tool they use | Recommendation | Why |
|---|---|---|
| Apollo, on a paid plan they use now | **Keep Apollo for finding people. Skip Treg's people search.** Follow step 2A: export from Apollo, then optionally re-check emails with Treg. | Apollo has its own contact database and marks emails "Verified". Apollo says its bounce guarantee is weaker for verified emails it gave you more than 6 months ago. Run 10 contacts both ways before paying for both. |
| HubSpot | **Keep HubSpot as your customer list. Use Treg to find new people. Connect them by importing the finished CSV into HubSpot.** | HubSpot can import contacts on every plan. Claude imports only with your yes and shows how HubSpot will match existing contacts first. If your HubSpot plan includes its own prospect data, compare 10 leads from each first. |
| ZoomInfo, Lusha, Seamless.AI, Cognism or another contact database you pay for | **Keep it. Skip Treg's people search.** Use Treg only to re-check emails if too many bounce. | You already pay for the data. Compare 10 leads from each before paying for both. |
| Clay | **Keep Clay.** Compare 10 rows before adding Treg. | If you already build lists in Clay, a second tool may only add cost. |
| LinkedIn Sales Navigator | **Keep it for finding people.** If your results don't include work emails, **connect** Treg to find and check emails from the profile links. | Treg's email finder accepts a LinkedIn profile link. |
| An email checker, such as ZeroBounce, NeverBounce or Hunter | **Keep it for checking emails.** Use Treg only for finding people. | Treg routes checks to some of the same services, so paying twice adds little. |
| Instantly, and they use its Lead Finder | **Keep the Lead Finder. Skip this part.** | Instantly's Lead Finder finds leads and fills in work emails. Its Lead Finder credits start at $47 a month. |
| Instantly, for sending only | **Use Treg to find people.** Then import the list into Instantly, if they also chose cold email. | Sending and finding are separate. They don't pay for finding yet. |
| Nothing | **Use Treg.** | Pay per use, no subscription. |

Sources: Apollo email status and 6-month note: https://knowledge.apollo.io/hc/en-us/articles/4423314404621 and https://knowledge.apollo.io/hc/en-us/articles/4409227148045. HubSpot import on all plans: https://knowledge.hubspot.com/import-and-export/import-objects. HubSpot sequences need Sales Hub or Service Hub Professional or Enterprise: https://knowledge.hubspot.com/sequences/create-and-edit-sequences. Instantly Lead Finder and prices: https://instantly.ai/pricing (checked 2026-11-26; its page showed conflicting numbers, so check again at setup). Treg email finder inputs: `treg catalog get treg.people.email.find`.

## Steps

Before step 3, read Treg's own skill if it is installed: `~/.claude/skills/treg/SKILL.md`. It explains prices, routed tools, verification and errors. Put `TREG_TELEMETRY=0` in front of every `treg` command, to turn off usage tracking.

### 1. Learn the ideal customer

Ask in one message:

**Say:**
> Tell me about the people you want on the list:
> 1. What industry are they in? Example: dental clinics, or software companies.
> 2. How big are their companies? A number of employees is best, like 10 to 50.
> 3. What job titles should they have? Example: owner, office manager, head of sales.
> 4. Where are they? A country, state or city.
> 5. How many people do you want on the first full list? 50 is a good start.
> 6. Who should be left off? For example your current customers, competitors, or anyone who unsubscribed from your emails. If you have that list as a file, tell me where it is. If they're in your CRM, such as HubSpot, I can export them for you.
> 7. Do you want a Google Sheet or a CSV file?

Save the answers. They are not secret:
```
bash scripts/progress.sh set-json icp '{"industry":"…","company_size":"…","titles":["…"],"location":"…","list_size":50,"output":"sheet"}'
```

If they gave a do-not-contact file, keep it where it is. Note its path: `bash scripts/progress.sh set suppression_file "<path>"`.

**If their customers and unsubscribes are in a CRM** and they want you to export them:
1. Open the CRM in the browser. **YOU DO THIS: sign in.** **Say:** "Your turn: sign in to <CRM>. Tell me "done" when you see your contacts."
2. Find the CRM's export for contacts. Export only the columns you need: email, name, company, and whether they unsubscribed or are a customer. Exporting changes nothing in the CRM.
3. The file lands in Downloads. Note its path as `suppression_file`, as above. Tell the person where it is. It holds their customers' details, so it stays on their Mac and never goes in this repo.

This part doesn't email anyone, so don't say the anti-spam rules here.

### 2. Set up Treg

1. Check whether Treg is already set up: `TREG_TELEMETRY=0 treg`. If it shows an account, a team and a balance, skip to step 3.

2. Ask before you install anything:

   **Say:**
   > Can I install Treg's free tool on your Mac? It adds a command called treg, plus Treg's instructions for me, in your user folder. It doesn't need your Mac password.

   On yes, download the installer and read the whole file before running it:
   ```
   curl -fsSL https://treg.to/install.sh -o "$TMPDIR/treg-install.sh"
   ```
   It should install the `treg` command with uv, pipx or pip, and install Treg's skill for Claude Code. If it does anything else, stop and tell the person. Then run it:
   ```
   TREG_TELEMETRY=0 sh "$TMPDIR/treg-install.sh"
   ```
   If it says it needs Python 3.12 or 3.13, or uv: ask "Can I install a free tool called uv with Homebrew? Treg needs it." On yes, run `brew install uv` and run the installer again. Use `~/.local/bin/treg` if `treg` isn't found right after.

3. **Sign in with a Treg key.** This way no sign-in code passes through the chat.
   1. Open https://treg.to in your browser. **YOU DO THIS: sign in.** **Say:** "Your turn: sign in to Treg with Google, GitHub or your email. The first sign-in creates your account. Tell me "done" when you see your Treg dashboard."
   2. Find the page for making an agent key or API key for their team. Stop before the click that reveals it.
   3. **YOU DO THIS: create and copy the key.** **Say:** "Your turn: click the button that creates the key, then its Copy button. Don't paste it anywhere. Tell me "done". I won't look at the page until you do."
   4. Save it and sign in with it, without printing it:
      ```
      bash scripts/save-secret.sh treg-token
      TREG_TELEMETRY=0 treg login --token "$(tr -d '\n' < ~/.config/ai-business-setup/secrets/treg-token)"
      ```

   If you can't find a key page, use Treg's email sign-in instead. The person runs it in their own Terminal, so they read the code themselves:
   - **Say:** "Your turn: open the Terminal app (press Cmd+Space, type Terminal, press Return). Type `~/.local/bin/treg login --email <your email>` and press Return. Treg emails you a 6-digit code. Type the code in the Terminal window, not here. Tell me "done" when it says you're signed in."
   - Never ask for the code in chat, and never read a sign-in code out to the person.

4. Check: `TREG_TELEMETRY=0 treg` shows the account, the team and a balance (a new account shows $1.00). Read `~/.claude/skills/treg/SKILL.md` now if you haven't.

### 2A. If they find people in Apollo

Follow this step instead of steps 3 to 5 when `lead_source` is `apollo`. For another paid tool, follow the same pattern in that tool.

1. Open https://app.apollo.io. **YOU DO THIS: sign in.** **Say:** "Your turn: sign in to Apollo. Tell me "done" when you see Apollo's home page."
2. Build a people search with the ideal customer from step 1: industry, company size, job titles and location. Use Apollo's email status filter to keep only verified emails.
3. Show the person how many people match. Exporting uses Apollo credits from their plan. Read how many credits the export needs and how many they have. **Say:** "Exporting <N> people uses about <N> of your Apollo credits. You have <M> left. Shall I export them?" Wait for a clear yes.
4. Export to a CSV file. Move it to `~/Documents/AI Business Setup/lead-lists/` and name it `<yyyy-mm-dd>-apollo.csv`.
5. Remove anyone in the do-not-contact file. Check with a script, not by eye.
6. Optional: re-check emails with Treg. Apollo says its bounce guarantee is weaker for verified emails it gave you more than 6 months ago. If they want a second check, do step 2 (Treg setup), read the price of `treg.people.email.verify`, and quote the total. On a yes, check each email and drop any that isn't valid.
7. Go on to step 6 (hand over the list).

Sources: Apollo email status filter: https://knowledge.apollo.io/hc/en-us/articles/4423314404621. Six-month note: https://knowledge.apollo.io/hc/en-us/articles/4409227148045.

### 3. Plan the list and quote the test

Read the current prices. These calls are free:
```
TREG_TELEMETRY=0 treg catalog get treg.companies.search
TREG_TELEMETRY=0 treg catalog get treg.people.search
TREG_TELEMETRY=0 treg catalog get treg.people.email.find
TREG_TELEMETRY=0 treg catalog get treg.people.email.verify
```

Plan the search in this order:
1. **Companies:** `treg.companies.search` with the industry, a free-text description (`q`) that includes the size, and the country. Ask for more rows than needed, since some won't fit.
2. **People:** `treg.people.search` with each company's `company_domain` and a `title`. Also try one free-text search (`q`) that describes the person, with `location` spelled out (for example "Texas, United States"). Merge both results and remove duplicates.
3. **Emails:**
   - A row that already has an email: check it with `treg.people.email.verify`.
   - A row without one: find it with `treg.people.email.find`, with the headers `X-Treg-Route-Verify: true` and `X-Treg-Route-Domain-Match: strict`.

Work out the expected cost of a 10-person test from the prices you read.

**Say** (with your numbers):
> First I'll make a test list of 10 people, so you can see if they fit before we spend more. I expect it to cost about $<amount>, paid from your Treg credit. Shall I run it?

Wait for a clear yes.

### 4. Make the test list

Rules for every call:
- Use `TREG_TELEMETRY=0 treg --json call …` so each answer comes back as one line with its charge.
- Send `X-Treg-Route-Max-Cost` on every routed call. Set it near the price you quoted.
- Send an `Idempotency-Key` on each call, so a retry after a timeout isn't billed twice.
- Add up `charged_micro` as you go. Stop before the total passes the amount the person agreed to.
- Run 2 or 3 calls first and check you can read the answers, before you run the rest.

Keep a row only when all of these hold:
- The email check's verdict (`_treg.verification.verdict`, or the verify tool's status) is **valid**. Drop `invalid`, `accept_all` (catch-all), `risky` and `unknown`.
- `_treg.domain_match` is not `false`. An email at a different domain is often an old employer.
- The person is not in the do-not-contact file, and not a current customer the person asked you to leave off.
- The company and title fit what the person described. If a filter came back in `X-Treg-Ignored-Filters`, check that field yourself.

Save the list in a folder the person can find, never in this repo:
```
mkdir -p ~/Documents/"AI Business Setup"/lead-lists
```
Name it `<yyyy-mm-dd>-test.csv` with these columns: `first_name,last_name,title,company,company_domain,email,email_status,linkedin_url,location,source,date_found`. Set `source` to the provider name from `_treg.served_by`.

**Say:**
> Here are the 10 people I found: <name, title, company, one per line>.
> All 10 emails passed the check. The test cost $<amount>. Your Treg balance is now $<balance>.
> Do these look like the people you want? If not, tell me what to change.

Adjust the description and run again if they say no. Each new run needs a new quote and a new yes.

### 5. Make the full list

1. Work out the cost for the full size from what the test really cost per kept lead. Add a margin, since some rows get dropped.
2. **Say:** "The full list of <N> people should cost about $<amount>. Shall I make it?" Wait for a clear yes.
3. If the balance is too low, say so first. **YOU DO THIS: add funds.** Run `TREG_TELEMETRY=0 treg topup <dollars>` or open Treg's billing page in the browser. The person enters the card and clicks to pay.
4. Run in batches of about 25. Report the running cost after each batch.
5. Save the list as `<yyyy-mm-dd>-<industry>.csv` in the same folder.

### 6. Hand over the list

- **CSV:** tell the person where the file is, and open the folder: `open ~/Documents/"AI Business Setup"/lead-lists`.
- **Google Sheet:** open https://sheets.new in the browser. Import the CSV into the new sheet. If your browser tool can't upload a file, see "File uploads" in CLAUDE.md. Name the sheet "<Industry> leads <date>". Share it with nobody.
- **Their CRM (only with a yes):** if they keep customers in HubSpot or another CRM, offer to import the list. This adds records to their CRM, so show what will happen and ask first.
  1. Open the CRM in the browser. **YOU DO THIS: sign in.** **Say:** "Your turn: sign in to <CRM>. Tell me "done" when you see your contacts."
  2. Start a contacts import and upload the CSV. If your browser tool can't upload a file, see "File uploads" in CLAUDE.md.
  3. **HubSpot only:** leave the box that sets contacts as marketing contacts unticked. Imported contacts are then non-marketing, which is HubSpot's default. **Say:** "On some HubSpot plans, marketing contacts count toward your bill. I'll import these as non-marketing contacts, so they don't add to it. You can change that later in HubSpot."
  4. Take the import up to its final button. Show the person how columns match and how existing contacts are handled.
  5. **YOU DO THIS: finish the import.** **Say:** "Your turn: check the column matches, then click the button that finishes the import. Tell me "done"."
  6. Don't add the new contacts to any email sequence, workflow or campaign.

### 7. Optional: weekly refresh

Ask: "Do you want new people added to this list every week?"

If yes, offer these options:
- **A weekly reminder in Google Calendar (recommended).** Open https://calendar.google.com in the browser. The person signs in if asked (**YOU DO THIS**). Show the event, and on their yes create a weekly event: "Lead list refresh: open the AI Business Setup folder in Claude Code and type: refresh my lead list." When they type that, follow "Refresh the list" below.
- **If they already use Grok:** a Grok routine can run the refresh by itself. First check that their Grok plan allows custom connectors and scheduled routines. Add Treg to Grok as a custom connector. Grok's connectors page has a button to add a new connector; choose the custom kind and enter `https://treg.to/mcp/`. The person signs in to Treg and chooses which Treg team pays. Then create a weekly routine that finds, verifies and appends new rows to the Google Sheet. Write the spending limit the person agreed to into the routine, for example "stop at $2 per week". Treg's skill says routed calls can be capped with `X-Treg-Route-Max-Cost`.

Save the choice: `bash scripts/progress.sh set lead_refresh "<calendar|grok|none>"`.

### Refresh the list

Use this when the person types "refresh my lead list", in any later session.
1. Read the saved description: `bash scripts/progress.sh get icp`. Ask: "Has anything changed about who you want on the list?"
2. Read the current prices (free) and quote the cost of the new rows. Wait for a clear yes.
3. Make the new rows as in steps 4 and 5. Leave out anyone already on an earlier list in `~/Documents/AI Business Setup/lead-lists/`, and anyone in the do-not-contact file.
4. Save them as `<yyyy-mm-dd>-refresh.csv`, or add them to the Google Sheet. Report the count and the cost.

Sources: Grok custom connectors: https://docs.x.ai/grok/connectors. Treg connector URL: https://treg.to/llms.txt.

## Check

- The list file exists and has the number of rows the person asked for, or you told them why it has fewer.
- Every row's `email_status` is valid.
- No row matches the do-not-contact file. Check with a script, not by eye.
- `TREG_TELEMETRY=0 treg balance` shows the spend you reported.
- The person has opened the list and said it looks right.

Then `bash scripts/progress.sh done lead-lists`.

**Say** (fill in the values):
> Your lead list is ready.
> - File: <path or Sheet name>
> - People: <N>, all with checked work emails
> - Cost: $<amount>. Treg balance left: $<balance>
> - Refresh: <weekly reminder on your calendar, Grok routine, or none>

## Known problems

- **A routed call charged for a miss.** Some providers bill a miss. Treg tries the next provider until it finds an answer or reaches `X-Treg-Route-Max-Cost` (default $1 per call). Always send that header with a low value.
- **An email belongs to a different company.** A LinkedIn-based provider often returns a former employer. Check `_treg.domain_match` and drop the row if it's `false`.
- **A filter was ignored.** The provider couldn't apply it. `X-Treg-Ignored-Filters` names it. Filter the rows yourself, or send `X-Treg-Route-Strict-Filters: 1` to be refused instead, for free.
- **Company size is missing for many rows.** Many sources don't return it. Ask the person whether to keep rows with unknown size.
- **402 insufficient_balance.** The balance is too low. Nothing was charged. Quote the top-up and follow step 5.3.
- **A timeout.** The provider may have answered and charged. Repeat the call with the same `Idempotency-Key`; Treg returns the stored answer and charges nothing.
- **The installer stops on Python.** Treg needs Python 3.12 or 3.13. `brew install uv` fixes it, because uv fetches a matching Python by itself.
- **HubSpot marketing contacts.** Marketing contacts need a Marketing Hub plan, and each one counts toward the billable contact tier. Imported contacts are non-marketing unless the import's marketing box is ticked. Source: https://knowledge.hubspot.com/records/set-contacts-as-marketing (checked 2026-11-26). If HubSpot's screen looks different, check the person's plan page before importing.
- **The Treg page looks different from these steps.** Describe what you see and adapt. Never guess at a button that costs money.
