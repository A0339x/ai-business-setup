# Part: Website and AI search check

## What it does

- **Checks your website** for what helps or hurts it in search. That covers search engine optimization (SEO), which means showing up in Google and Bing. It also covers answer engine optimization (AEO), which means being found and recommended by AI tools such as ChatGPT.
- **Gives you a report in plain words**, ranked from most to least important. Each item says what's wrong, why it matters, and how to fix it.
- **Adds your site to Google Search Console and Bing Webmaster Tools**, with your OK. These free tools tell Google and Bing about your site and show you how people find it.
- **Optional: builds a test copy of your site** on a separate address, hosted free on Netlify, so you can try changes without touching your real site.

This part changes nothing on your real website. Any fix is a draft until you approve it.

## What it costs

- **Free checks** that Claude runs itself: no cost.
- **The Treg audit:** pay per use. It usually costs less than $1 for a small site. That is an estimate from Treg's catalog prices in November 2026:
  - checking one page: from about $0.00015, and about 10 times that when the page needs JavaScript to load;
  - starting a crawl of the site: listed at about $0.018;
  - checking whether AI answers mention your business: about $0.10 per question.
  Claude reads the current prices with `treg catalog get` (free) and says the total before the audit runs.
- **Google Search Console and Bing Webmaster Tools:** free.
- **Optional test copy:** Netlify's Free plan costs $0. A new domain for the copy costs a yearly fee. Claude shows the price before you buy one. You can also use a free netlify.app address.

Sources: Treg prices from `treg catalog get dataforseo.web.page.audit` and `dataforseo.x.on-page-task-post`, and `treg catalog search "AI visibility"`, read 2026-11-26. Netlify Free plan ($0, custom domains with SSL): https://www.netlify.com/pricing/ (checked 2026-11-26).

## What you need

- Your website's address.
- A Google account, for Search Console.
- A way to sign in to wherever your domain's DNS is managed, such as Cloudflare, GoDaddy or Namecheap. Search Console uses a DNS record to confirm you own the site.
- A Treg account, which Claude sets up in step 3 if you don't have one.
- Optional, for the test copy: a Netlify account (free) and a card for a new domain.

## If you already use…

Ask: "Do you use any tool for your website's search results now? For example Semrush, Ahrefs, Yoast, Rank Math, Google Search Console, or an agency. And what is your site built with: WordPress, Shopify, Wix, Squarespace or something else?"

| Tool they use | Recommendation | Why |
|---|---|---|
| Semrush, Ahrefs or Moz | **Keep it for tracking rankings and links.** If its site audit ran in the last month, **skip Treg's paid audit**: export that report and Claude explains it in plain words. Still do the AI search check and the free tools. | You already pay for a site audit. |
| Yoast, Rank Math or All in One SEO (WordPress) | **Keep it.** Fixes for titles, descriptions and sitemaps go through its settings. If it has a field for Google or Bing verification codes, use that field. | The plugin already controls these settings. Changing them elsewhere causes conflicts. |
| Google Search Console, already set up | **Keep it. Skip adding the site.** Claude checks that a sitemap is submitted and uses its data in the report. | It's already done. |
| Bing Webmaster Tools, already set up | **Keep it. Skip that step.** | It's already done. |
| Shopify, Wix or Squarespace | **Keep its built-in SEO settings.** Fixes go there. Before connecting any app or agent to the store, list its automations (see step 8). | The platform controls titles, sitemaps and store emails. |
| An agency or freelancer handling SEO | **Keep them.** Claude makes the report. Send it to them. Claude changes nothing on the site. | Two people changing one site cause conflicts. |
| A tool that tracks AI search answers | **Keep it. Skip Treg's AI mention check.** | You already track it. |

Sources: Search Console property types and DNS verification: https://support.google.com/webmasters/answer/34592. Bing import from Search Console: https://blogs.bing.com/webmaster/september-2019/Import-sites-from-Search-Console-to-Bing-Webmaster-Tools.

## Steps

### 1. Learn about the site

**Say:**
> A few questions about your website:
> 1. What's its address?
> 2. What is it built with: WordPress, Shopify, Wix, Squarespace, or something else? If you're not sure, I can check.
> 3. What should people find you for? Give me 3 to 5 questions a customer might type into Google or ask ChatGPT. Example: "best dentist for kids in Austin".
> 4. Optional: which 2 or 3 competitors do you see in search results?

Save the answers (they are not secret):
```
bash scripts/progress.sh set-json website '{"url":"…","platform":"…","questions":["…"],"competitors":["…"]}'
```

### 2. Run the free checks

Run these yourself with `curl`. They cost nothing. Replace `<site>` with the address, such as `https://example.com`.
```
curl -sIL "<site>" | grep -iE '^(HTTP|location|x-robots-tag)'
curl -sL "<site>/robots.txt"
curl -sL "<site>/sitemap.xml" | head -50
curl -sL "<site>/llms.txt" | head -20
curl -sL "<site>" -o "$TMPDIR/home.html"
```
From these, note:
- Does the site load over HTTPS, and do other versions (http, www) redirect to one address?
- Does `robots.txt` block search engines or AI crawlers that the person wants to be found by?
- Is there a sitemap? Is it listed in `robots.txt`?
- Is there an `llms.txt` file? It's optional. Mention it as a small extra, not a must.
- On the home page: the title, the meta description, one main heading, a `noindex` tag (a problem if present), structured data (`application/ld+json`), and a mobile viewport tag.
- Does the home page say plainly what the business does, where, and for whom? AI tools quote pages that answer questions directly.

### 3. Set up Treg

Skip this step if `TREG_TELEMETRY=0 treg` already shows an account and a balance. Put `TREG_TELEMETRY=0` in front of every `treg` command.

1. Download the installer, read the whole file, then run it:
   ```
   curl -fsSL https://treg.to/install.sh -o "$TMPDIR/treg-install.sh"
   TREG_TELEMETRY=0 sh "$TMPDIR/treg-install.sh"
   ```
   It should only install the `treg` command and Treg's skill. If it does anything else, stop and tell the person. If it needs Python 3.12 or 3.13, ask to install uv (`brew install uv`, free) and run it again.
2. **YOU DO THIS: sign in.** Run `TREG_TELEMETRY=0 treg login` in the background. It opens Treg's sign-in page. **Say:** "Your turn: sign in to Treg with Google, GitHub or your email. The first sign-in creates your account. Tell me "done" when the page says you're signed in." If it can't open from here, ask the person to type `! treg login` in this chat's message box.
3. Check: `TREG_TELEMETRY=0 treg` shows the account and a balance. A new account has $1.00 of credit.
4. Read Treg's skill: `~/.claude/skills/treg/SKILL.md`.

### 4. Quote and run the Treg audit

1. Read the current prices (free):
   ```
   TREG_TELEMETRY=0 treg catalog get dataforseo.x.on-page-task-post
   TREG_TELEMETRY=0 treg catalog get dataforseo.web.page.audit
   TREG_TELEMETRY=0 treg catalog search "AI visibility brand mentions ChatGPT answers"
   ```
   The crawl's results are read with Treg's free on-page readers, such as `dataforseo.x.on-page-summary-id` and `dataforseo.x.on-page-pages`. Check each reader's price with `catalog get` before you use it.
2. Plan: a crawl of up to 50 pages (fewer for a small site), plus one AI mention check per question from step 1.

   **Say** (with your numbers):
   > The website audit will cost about $<amount> from your Treg credit. It checks up to <N> pages, and asks whether AI answers mention your business for your <K> questions. Shall I run it?

   Wait for a clear yes. If they already have a recent Semrush or Ahrefs audit, skip the crawl and quote only the AI mention check.
3. Run it. Send `X-Treg-Route-Max-Cost` on routed calls and an `Idempotency-Key` on each call. Keep a running total of the charges, and stop before it passes the amount quoted.

### 5. Write the report

Write the report in plain words. Save it outside this repo:
```
mkdir -p ~/Documents/"AI Business Setup"/website-check
```
Name it `<yyyy-mm-dd>-website-report.md`.

Rank the items in 3 groups:
1. **Fix first:** anything that stops Google or AI tools from reading the site. Examples: a `noindex` tag, a `robots.txt` block, broken pages, no HTTPS.
2. **Fix next:** anything that loses visitors or makes pages hard to understand. Examples: slow pages, missing titles or descriptions, pages that don't say plainly what you do.
3. **Nice to have:** smaller gains. Examples: structured data, an `llms.txt` file, more pages that answer customers' questions.

For each item, write:
- what's wrong, in one line;
- why it matters to the person;
- how to fix it, and who usually does it (the person, their web host, their agency, or Claude);
- how many pages it affects.

Also write what the AI mention check found: for each question, whether AI answers mention the business, and which competitors they mention instead.

**Say:**
> Your website report is ready: <path>. The 3 things to fix first:
> 1. …
> 2. …
> 3. …
> I haven't changed anything on your site.

### 6. Add the site to Google Search Console

Skip if they already use Search Console for this site.

1. **Say:** "Next I'll add your site to Google Search Console. It's free. It tells Google about your site and shows you which searches bring visitors. Shall I go ahead?" Wait for a yes.
2. Open https://search.google.com/search-console. **YOU DO THIS: sign in to Google.**
3. Add a **Domain** property for the site's domain. It covers every version of the site (http, https, www and others). Google verifies it with a DNS record only.
4. Search Console shows a TXT record to add. Open the DNS provider's page. **YOU DO THIS: sign in there.**
5. Show the person the record before you add it: "I'll add one new TXT record. It doesn't change your existing records." Wait for a yes. Then add it yourself.
6. Back in Search Console, start the check. DNS can take from minutes to a few hours. If it fails, wait and try again later.
7. If DNS access isn't possible, use a **URL prefix** property instead, which offers other ways to verify, such as an HTML tag. On WordPress with an SEO plugin, use the plugin's verification field. Adding the tag changes the site, so ask first.
8. After it's verified, submit the sitemap address from step 2.

### 7. Add the site to Bing Webmaster Tools

Skip if they already use Bing Webmaster Tools for this site.

1. Open https://www.bing.com/webmasters. **YOU DO THIS: sign in.**
2. Choose the option to import sites from Google Search Console. **YOU DO THIS: sign in to Google and allow access.** Bing's blog says the import gives Bing access to the site and its sitemaps, not to your Search Console data.
3. Pick this site and finish the import. It's free.

### 8. Check automations and access

Connecting an app or an agent to a website or store can switch things on. In one real setup, connecting an agent to a store turned on abandoned-cart emails nobody asked for.

- Before any app, plugin or agent is connected to the site or store, list its current automations, such as store emails, popups and redirects.
- After connecting, list them again. Show the person anything new, and turn it off with their yes.
- When a site asks what to allow, choose the smallest access that does the job, such as read-only. Tell the person what you chose.

### 9. Optional: draft fixes

Ask: "Do you want me to draft fixes for the top items?" If yes:
- Draft each fix and show it before anything is published. The person approves each one.
- Never apply one AI-made change to many pages at once without a page-by-page review. In one real setup, a bulk SEO fix wanted to add long text blocks to 108 category pages.
- Write fixes in the person's voice. Keep them short and factual.

### 10. Optional: a test copy on Netlify

Ask: "Do you want a test copy of your site at a separate address, so you can try the fixes first?"

If yes:
1. Ask which address: a free `<name>.netlify.app` address, or a new domain. A new domain costs a yearly fee: find the price and quote it, then wait for a yes.
2. Build the copy in `~/Documents/AI Business Setup/website-test-copy/`, from the person's own pages, with the approved fixes applied. Copy only content the person owns.
3. Keep the test copy out of search results, so it doesn't compete with the real site:
   - add `<meta name="robots" content="noindex">` to every page;
   - add a `_headers` file with `/*` and `X-Robots-Tag: noindex`.
4. Open https://app.netlify.com. **YOU DO THIS: sign up or sign in.** Choose the Free plan.
5. Open Netlify's drag-and-drop deploy page, and open the copy's folder in Finder with `open ~/Documents/"AI Business Setup"/website-test-copy`. **Say:** "Your turn: drag the website-test-copy folder from Finder onto the Netlify page. Tell me "done" when it shows a link."
6. For a new domain: **YOU DO THIS: pay** for it, then connect it to the Netlify site. This touches only the new domain, never the person's main domain.
7. Open the test copy and check each page loads.

## Check

- The report file exists and starts with the "fix first" items.
- The person has read the top 3 items.
- If step 6 ran: Search Console shows the property as verified, and the sitemap as submitted.
- If step 7 ran: Bing Webmaster Tools lists the site.
- Nothing on the real site changed without the person's yes.
- If step 10 ran: the test copy loads, and its pages carry `noindex`.

Then `bash scripts/progress.sh done website-check`.

**Say** (fill in the values):
> Your website check is done.
> - Report: <path>
> - Fix first: <one line>
> - Google Search Console: <added, or already set up>
> - Bing Webmaster Tools: <added, or already set up>
> - Test copy: <address, or none>
> - Cost: $<amount> from your Treg credit
>
> Search Console shows data after a few days. Ask me to check it again in a week.

## Known problems

- **Search Console says the TXT record isn't found.** DNS changes take time. Wait an hour and try again. Check the record has no extra quotes or spaces.
- **The site blocks the free checks or the crawl.** Some hosts block automated visits. Note it in the report, and check those pages in the browser instead.
- **The crawl results aren't ready.** A site crawl runs in the background. Read its results with the on-page readers after a few minutes. Don't start another paid crawl.
- **A page needs JavaScript to show its content.** Plain checks see an empty page. Use the page audit with JavaScript on, which costs about 10 times more. Quote it first.
- **A Google, Bing or Netlify page looks different from these steps.** Describe what you see and adapt. Never guess at a button that costs money or changes the site.
