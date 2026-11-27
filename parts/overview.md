# Overview of the parts

Claude reads this at the start and says the "Say" block below. It explains the four parts in plain words, then asks which ones the person wants.

## Say

> Hi. I can set up four things for your business. You can pick one, several, or all of them.
>
> **1. Verified lead lists.** You tell me who your ideal customer is: their industry, company size, job title and location. I find people who match and check that each work email is real. You get a Google Sheet, or a CSV file, which is a simple spreadsheet file that opens in Excel or Numbers. It's pay per use through a service called Treg, usually a few cents per lead. New Treg accounts get $1.00 of credit, which covers a small test list.
>
> **2. Daily operations bots.** A team of bots in Grok, the AI assistant from xAI. Each morning they write you a short brief. They sort your inbox and draft replies, keep a to-do sheet, an orders sheet and a customer list, and alert you when a new lead writes in. They only draft. Nothing goes out until you say yes. This needs a paid Grok plan, and a file called "AI Bot System Template.zip" from the person who shared this folder with you.
>
> **3. Cold email sending.** Your own sending server with 2 new domains and 10 new mailboxes. The mailboxes warm up for 3 to 4 weeks, so your emails land in inboxes instead of spam. It costs about $76 the first month, then about $50 a month. If you already pay for a sending tool such as Instantly or Smartlead, I'll check its mailboxes and warmup with you and skip the new server.
>
> **4. Website and AI search check.** I check how your website shows up in Google and in AI tools such as ChatGPT, and give you a plain-words list of what to fix first. Then, with your OK, I add your site to Google's and Bing's free site tools. The check usually costs less than $1.
>
> **Or everything:** all four, plus a link so Claude can read what your Grok bots know.
>
> I'll ask what you already pay for, so you don't pay twice. Nothing costs money until I tell you the price and you say yes.
>
> **Which would you like?** You can answer with numbers, like "1 and 4", or say "everything".

## Notes for Claude

- Don't add features that aren't in the parts' PART.md files.
- If the person asks what a part needs before choosing, read that part's "What you need" and "What it costs" sections and answer from them.
- If the person asks which part to pick, ask what they want to get done this month. Then recommend one part in bold.
  - More customers to contact: **verified lead lists**.
  - Less time in email and admin: **daily operations bots**.
  - Sending to a list they already have: **cold email sending**.
  - More visitors from search: **website and AI search check**.
- The parts work on their own. Lead lists don't need cold email. A person who picks only lead lists gets only lead lists.
- Set-up order for several parts: daily operations, lead lists, website check, cold email. `progress.sh choose` keeps this order.
