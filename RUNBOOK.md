# Runbook

This is the step-by-step procedure. Claude follows it phase by phase.

How to read it:
- **Goal** says what the phase produces.
- **Steps** are what you (Claude) do. Commands run from the kit's root folder.
- **YOU DO THIS** marks the part of a step only the person can do: sign in, type a password or two-step code, solve a CAPTCHA, enter card details, click the final Pay or Buy button, or click a button that reveals a secret (such as a new token). **You do every other click.** Drive the browser up to that point, hand over with "Your turn:" and the one thing to do, and wait for "done". Then take the browser back and carry on. Without a browser tool, see "If you have no browser tool" in CLAUDE.md.
- **Say:** gives wording for the person. Adapt it, but keep it short and plain.
- **Check** proves the phase worked. Do not move on until it passes. Then run `bash scripts/state.sh done <phase>`.
- **Known problems** lists what went wrong in a real run of this setup, and the fix.

Throughout:
- `<domain>` is the person's own domain for the app, such as `example.com`.
- `<host>` is `warmbly.<domain>`. The dashboard is `https://app.<host>`.
- Never print a secret. Never paste one into chat.

---

## Phase 0: Preflight

**Goal:** a working browser tool, the tools the scripts need, and the person's choices saved.

### Steps

1. Run `bash scripts/state.sh next`. If it prints a number above 0, read that phase and resume there.

2. Find a browser tool, in this order:
   1. **Claude in Chrome.** Look for tools named `mcp__claude-in-chrome__*`. If you only see their names as deferred tools, load them with ToolSearch (query `claude-in-chrome`). If a `chrome-browser` skill is listed, read it first. Open new tabs; do not take over the person's existing tabs.
   2. **Another browser tool,** such as `mcp__playwright__*` or a built-in browser tool.
   3. **gstack browse:** check `test -x ~/.claude/skills/gstack/browse/dist/browse`. Use it with `--headed` so the person can see and use the window. Start it in the background and keep it running; it closes when the command that started it ends.
   4. **None:** do not fall back to text yet. Follow "If you have no browser tool" in CLAUDE.md: tell the person how to turn browser control on, and wait. Only if they say no, open pages with `open "<url>"`, tell them what to click, and ask for a screenshot when you need to see the page.

   Save what you found: `bash scripts/state.sh set browser "<claude-in-chrome|playwright|gstack|none>"`.

3. Check the Mac's tools:
   ```
   bash scripts/preflight.sh
   ```
   If it says jq is missing, ask: "Can I install a small tool called jq with Homebrew? It reads data files. It's free." On yes, run `bash scripts/preflight.sh --install`. If Homebrew is missing too, the person installs it from https://brew.sh (it asks for their Mac password, which they type themselves).

4. Ask the person for their choices. Ask all at once.

   **Say:**
   > Before we start, I need a few choices from you.
   >
   > 1. Which domain do you own for Warmbly's web address? Example: if you say yourcompany.com, Warmbly will be at app.warmbly.yourcompany.com. This domain won't send email.
   > 2. Where is that domain's DNS managed? For example Cloudflare, GoDaddy, Namecheap or Squarespace. If you're not sure, I can check.
   > 3. The 10 sender names for your mailboxes, first and last name, and the part before the @ for each. Example: Jane Smith, jane.
   > 4. Optional: your business name. Warmbly uses it as the sender name on its own system emails.
   >
   > About sender names and the law:
   > - US law (CAN-SPAM) requires an honest sender name and subject line, your real postal address in every email, and a working unsubscribe link.
   > - Don't use domains that imitate someone else's brand.
   > - The names are your choice. Made-up names can cost trust when someone replies and later meets a real person. I'll go with what you choose.

   Say the compliance part once only.

   If they don't know where DNS is managed, check: `dig +short NS <domain>`. Names ending in `cloudflare.com` mean Cloudflare.

5. Save the answers. Domains for the senders are chosen in Phase 6, so leave `domain` out of each sender for now.
   ```
   bash scripts/state.sh set domain "<domain>"
   bash scripts/state.sh set dns_provider "<cloudflare|other name>"
   bash scripts/state.sh set platform_email_name "<Business> Warmbly"     # or just Warmbly
   bash scripts/state.sh set-json senders '[{"first":"Jane","last":"Smith","username":"jane"}, ...]'
   ```

### Check

- `bash scripts/preflight.sh` prints no MISSING lines.
- `bash scripts/state.sh show` has `domain`, `dns_provider`, and 10 `senders`.

---

## Phase 1: Hetzner account and server

**Goal:** a CX33 server running Ubuntu 24.04, behind a firewall, reachable with `ssh warmbly`.

**Why Hetzner, not DigitalOcean.** If the person asks, say:
> Warmbly sends through Gmail's servers on port 587. DigitalOcean blocks all outgoing email ports on its servers, including 587. Hetzner blocks only ports 25 and 465, and leaves 587 open. Hetzner is also cheaper for the same size.

### Steps

1. **YOU DO THIS: create the Hetzner account.** Open https://accounts.hetzner.com/signUp.

   Fill in the non-secret fields yourself (name, address, company) once the person gives them. The person chooses the password, confirms the email, enters the card and passes the identity check.

   **Say:**
   > Your turn at Hetzner:
   > 1. Choose your password and finish sign-up. Confirm the email Hetzner sends you.
   > 2. Enter your card when it asks for a payment method.
   > 3. Finish any identity check. It may want a photo ID, or a small prepayment.
   >
   > I'll fill in everything else. Tell me "done" when you can see the Hetzner Cloud Console.

   Afterward, offer to open the two-step sign-in settings for them.

   Hetzner's identity check can take from minutes to a day. If it is pending, stop here. Tell the person to come back when Hetzner approves the account. The state file lets the next session resume.

2. **YOU DO THIS: create a project.** Open https://console.hetzner.com/projects.

   Click "New project" yourself, name it Warmbly, and open it. It is free. If the page asks the person to sign in, hand over for that only.

3. **YOU DO THIS: create the API token.** In the project, open **Security**, then **API tokens**, then **Generate API token**. The page address looks like `https://console.hetzner.com/projects/<number>/security/tokens`.

   Type the name `warmbly-kit` and choose "Read & Write" yourself. Stop before "Generate API token": the next page shows the token, and it must not reach your screenshots or this chat.

   **Say:**
   > Your turn: click "Generate API token", then click the copy button next to the token. Don't paste it anywhere. Hetzner shows it only once.
   >
   > Tell me "done" when you've copied it. I won't look at the page until you do.

4. Save the token from the clipboard. It never appears in chat:
   ```
   bash scripts/save-secret.sh hetzner-token
   bash scripts/hetzner.sh check
   ```

5. Get the price and ask:
   ```
   bash scripts/hetzner.sh price
   ```
   **Say** (use the numbers it printed):
   > The server costs about $10.59 a month: $9.99 for the server and $0.60 for its internet address. It has 4 processors, 8 GB of memory and an 80 GB disk. Hetzner bills by the hour and you can delete it anytime. Shall I create it?

   Wait for a clear yes.

6. Create the key, the firewall and the server:
   ```
   bash scripts/hetzner.sh ssh-key        # makes ~/.ssh/warmbly_ed25519 if needed, uploads it
   bash scripts/hetzner.sh firewall       # inbound 22, 80, 443 and ping only
   bash scripts/hetzner.sh create-server  # CX33, Ubuntu 24.04, fsn1 (then nbg1, hel1)
   bash scripts/hetzner.sh wait
   bash scripts/hetzner.sh ssh-config     # adds "Host warmbly" to ~/.ssh/config
   ```
   Use `--dry-run` after any of these to see the request without sending it.

### Check

```
ssh warmbly 'hostname; lsb_release -ds'
bash scripts/hetzner.sh status
```
The first prints `warmbly` and Ubuntu 24.04. The second shows status `running`.

### Known problems

- **The Hetzner sign-in page shows "Checking that you are not a robot".** That is Hetzner's bot check. The person waits a few seconds or signs in from their own browser.
- **"Hetzner already has this SSH key".** Fine. The script reuses it.
- **`create-server` says no CX33 is free.** It tries Falkenstein (fsn1), Nuremberg (nbg1), then Helsinki (hel1). If all fail, ask the person before choosing another size or region. Hetzner's US regions do not offer the CX line.
- **New accounts can have a server limit or need approval** before the first server. The API error says so. The person contacts Hetzner support or waits.
- **`ssh-config` stops because `Host warmbly` already exists** in `~/.ssh/config`. Show the person the existing entry and ask before changing it.

---

## Phase 2: Server setup

**Goal:** SSH accepts keys only, the system is updated, and Docker is installed from Docker's own package source.

### Steps

```
bash scripts/bootstrap-server.sh
```

It runs `scripts/remote/bootstrap.sh` on the server:
- writes `/etc/ssh/sshd_config.d/00-keys-only.conf` with `PasswordAuthentication no` and `KbdInteractiveAuthentication no`, then reloads SSH;
- runs `apt-get upgrade`;
- installs `docker-ce`, `docker-ce-cli`, `containerd.io`, `docker-buildx-plugin` and `docker-compose-plugin` from `download.docker.com`;
- reboots once if the updates need it, then waits for the server.

### Check

The script ends with "Bootstrap done". Also:
```
ssh warmbly "sshd -T | grep -E '^passwordauthentication'; docker compose version"
```
Expect `passwordauthentication no` and a Docker Compose version.

### Known problems

- A fresh Ubuntu 24.04 server at Hetzner allows password sign-in by default (`passwordauthentication yes`), even with an SSH key added. The drop-in file fixes this. Check it after any reboot.
- If SSH drops during the reboot, run the script again. It is safe to repeat.

---

## Phase 3: DNS for the app

**Goal:** `warmbly.<domain>` and `*.warmbly.<domain>` point at the server, without any proxy.

The wildcard covers the seven addresses Warmbly's HTTPS setup serves: `app`, `api`, `admin`, `ws`, `track`, `forms` and `portal`, each under `warmbly.<domain>`.

Get the server address: `bash scripts/state.sh get server_ip`.

### If the domain's DNS is on Cloudflare

Option A, preferred: a token that can edit only this domain's DNS.

1. **YOU DO THIS.** Open https://dash.cloudflare.com/profile/api-tokens.

   Do these clicks yourself: "Create Token", then "Use template" next to "Edit zone DNS", then under "Zone Resources" choose Include, Specific zone, and <domain>, then "Continue to summary". Stop there: the next page shows the token.

   **Say:**
   > This key can change DNS for this one domain only. Your turn: click "Create Token", then click the copy button. Don't paste it anywhere.
   >
   > Tell me "done" when you've copied it. I won't look at the page until you do.

2. Save it and add the records:
   ```
   bash scripts/save-secret.sh cloudflare-token
   bash scripts/cloudflare-dns.sh --dry-run
   bash scripts/cloudflare-dns.sh
   ```
   If the dry run shows it would change an existing record, show the person and ask first.

Option B: if the person prefers no token, drive the Cloudflare dashboard. Open the domain, then **DNS**, then **Records**, and add both records as below. Set the proxy status to **DNS only** (grey cloud).

### If the DNS is somewhere else

**YOU DO THIS: sign in only.** Open the provider's DNS page. The person signs in. Then you add the records yourself:

| Type | Name or host | Value | TTL |
|---|---|---|---|
| A | `warmbly` | `<server IP>` | lowest offered |
| A | `*.warmbly` | `<server IP>` | lowest offered |

Some providers want the full name (`warmbly.<domain>`). Follow what the page shows.

If the provider does not allow a wildcard, add seven A records instead: `app.warmbly`, `api.warmbly`, `admin.warmbly`, `ws.warmbly`, `track.warmbly`, `forms.warmbly`, `portal.warmbly`, all with the server IP.

### Check

```
bash scripts/check-dns.sh --wait
```
It checks all seven names on two public DNS servers, every 30 seconds for up to 30 minutes. Do not install until it passes. Caddy needs working DNS to get certificates.

### Known problems

- **Cloudflare proxy (orange cloud) is on.** Caddy cannot get a certificate. Switch both records to DNS only.
- **An AAAA or CNAME record already exists** at those names. It can send traffic elsewhere. Show the person and ask before removing it.
- **Old answers are cached.** A record that existed before can take up to its old TTL to change.

---

## Phase 4: Install Warmbly

**Goal:** all Warmbly containers healthy, `https://app.<host>` loads with a valid certificate, and the two unrecoverable keys backed up in two places.

The kit pins the release in `kit.conf` (`WARMBLY_VERSION`, now `v0.8.3`, the release this setup was proven on) and the installer's checksum (`WARMBLY_INSTALLER_SHA256`).

### Steps

1. Optional preview. It checks the installer and shows the settings file it would write, with secrets hidden:
   ```
   bash scripts/install-warmbly.sh --dry-run
   ```

2. Install:
   ```
   bash scripts/install-warmbly.sh
   ```
   What it does:
   - Downloads `install.sh` and `install.sh.sha256` from the warmbly/warmbly repository at the pinned tag. Stops if the file does not match the published checksum, or the checksum in `kit.conf`.
   - Copies it to the server and checks it again with `sha256sum -c`.
   - Runs `sh install.sh --yes --no-color --host <host> --tls caddy --version <pinned>`. The bundled Caddy gets certificates from Let's Encrypt.
   - Adds `GEODB_PATH` and `EMAIL_NAME` to `/opt/warmbly/.env` if missing, then restarts.
   - Waits until every container is up and the backend is healthy.
   - Deletes the install log, which holds secrets and the claim link.
   - Copies `/opt/warmbly/keys-backup.txt` to `~/.config/warmbly-kit/warmbly-keys-backup.txt` (owner-only).
   - Checks HTTPS on all seven addresses.

3. Tell the person what matters.

   **Say:**
   > Warmbly is installed at https://app.warmbly.<domain>.
   >
   > Important: Warmbly made two encryption keys. They protect every mailbox password it stores. I saved a copy on the server and a copy on your Mac in a private folder (~/.config/warmbly-kit). If both copies are lost, every stored mailbox password becomes unreadable. Consider also keeping a copy in your password manager. I can show you how without putting it in this chat.
   >
   > Two settings to know:
   > - Sign-up is invite-only. You'll create the owner account next.
   > - Warmbly can't send its own emails yet, such as password resets. They go to the server's log. I can set up an email service for this later.

### Check

- The script ends with "Warmbly is running at https://app.<host>".
- `ssh warmbly 'cd /opt/warmbly && docker compose ps'` shows every service up, and backend `(healthy)`.
- `ls -l ~/.config/warmbly-kit/warmbly-keys-backup.txt` shows `-rw-------`.

### Known problems

- **The installer exits with an error and the backend keeps restarting.** Warmbly's installer (unchanged through v0.8.4) does not write `GEODB_PATH` or `EMAIL_NAME`, and the backend refuses to start without them. The log shows `config GEODB_PATH not found` and then `config EMAIL_NAME not found`. The kit adds both lines automatically (`scripts/remote/env-fixes.sh`), so an installer exit code of 1 here is expected. If a later release fixes this, the fix step simply reports both as present.
- **Re-running Warmbly's installer may rewrite `.env`.** Do not use it to upgrade. Use `scripts/upgrade-warmbly.sh`. After any change, check that `GEODB_PATH` and `EMAIL_NAME` are still in `.env`.
- **No valid HTTPS after a few minutes.** Check DNS again (`bash scripts/check-dns.sh`). Check Caddy's log: `ssh warmbly 'cd /opt/warmbly && docker compose logs caddy --tail 50'`. Let's Encrypt limits failed attempts per hour; if the log mentions a rate limit, wait an hour.
- **The checksum check fails.** Stop. Do not run the installer. Tell the person the download did not match what Warmbly published.

---

## Phase 5: Claim the owner account

**Goal:** the person owns the Warmbly instance and is signed in, in the browser you control.

### Steps

1. Open the single-use claim page in the browser you control. The link is never printed.
   - Claude in Chrome: `bash scripts/claim-link.sh --app "Google Chrome"`
   - Default browser: `bash scripts/claim-link.sh`
   - gstack browse, or a browser `open` cannot reach: have the person claim in their own browser now (`bash scripts/claim-link.sh`). In Phase 7 they sign in again inside your browser window.

2. **YOU DO THIS.**

   Ask for their name and email, and type them in yourself. Leave the password fields empty.

   **Say:**
   > Your turn: type a new password for Warmbly in both password boxes, then click the button to finish. Save the password in your password manager. Tell me "done" when you see the Warmbly dashboard.

3. If a tour appears, the person may skip it.

   If the dashboard offers to connect to Warmbly Cloud, skip it. Warmbly's documents say Warmbly Cloud no longer links new self-hosted servers.

### Check

```
bash scripts/claim-link.sh --status
```
It should show that an account and a platform admin exist. Running `bash scripts/claim-link.sh` again should say no link was issued.

### Known problems

- **The link expired or was used.** Run `claim-link.sh` again for a fresh one. It works only while no account exists.
- **The person forgets the password later.** Warmbly cannot email a reset link. On the server, `ssh warmbly 'cd /opt/warmbly && docker compose exec -T backend warmblyctl user reset-password --help'` shows how to make a one-time reset link. Open it with `open`; do not print it.

---

## Phase 6: Zapmail mailboxes

**Goal:** 2 sending domains and 10 active Google Workspace mailboxes, and their export file saved privately on the Mac.

Zapmail allows at most 5 mailboxes per domain. That is why there are 2 domains.

### Steps

1. **Cost.** Say:
   > Next is Zapmail. It creates the 10 mailboxes.
   > - Starter plan: $39 a month for 10 Google Workspace mailboxes.
   > - 2 domains: about $12.99 a year each for a .com. Zapmail shows the exact price before you pay.
   > - You don't need any add-ons.
   >
   > Shall we go ahead?

   Wait for a clear yes.

2. **YOU DO THIS: create the Zapmail account.** Open https://app.zapmail.ai.

   **Say:**
   > Your turn: create your Zapmail account. Signing in with Google is fine. Then open the email Zapmail sends and click "Confirm Email Address". I'll do everything after that. Tell me "done" when you see the Zapmail dashboard.

   An unconfirmed email can hold up mailbox setup later.

3. **Wallet prompt.** Zapmail may ask you to prepay a wallet balance and suggest an amount such as $500. Skip it yourself: click "Skip to Domain Purchase" and leave "Auto Top Up" off. Tell the person you skipped it, because they pay only for the plan and the domains.

4. **YOU DO THIS: pay for the Starter plan.** Find the plan under onboarding or **Billing** and take it to the checkout page yourself. Check the page says Starter, $39 a month, 10 Google Workspace mailboxes. Then hand over: "Your turn: check the total, enter your card if asked, and click to pay."

5. **Choose the 2 sending domains.** Ask the person for two names. Suggest names close to their own brand, and different from their main website domain, so a problem with sending never touches their main domain. Do not suggest names that imitate another company.

6. **Buy the domains.** Open https://app.zapmail.ai/setup/domains/purchase (or **Domains**, then "Buy a New Domain"). Search each name and add the exact match to the cart.
   - Zapmail fills the registration contact form from the account. If a required field is empty (for example State), ask the person for the real value.
   - Zapmail may pre-select **ZapShield** ($3 a month per domain). Turn it off unless the person wants it.
   - **YOU DO THIS: pay.** You take the cart to checkout. The person checks the total, enters the card if asked, and clicks to pay. Stripe may text them a code.
   - Repeat for the second domain if they were not in one cart.

   Save them:
   ```
   bash scripts/state.sh set-json sending_domains '["<first-domain>","<second-domain>"]'
   ```
   Zapmail sets up each domain's DNS (SPF, DKIM, DMARC) itself. It emails "Domains are ready" when done.

7. **Assign the mailboxes.** Put 5 senders on each domain. Add a `domain` to each sender, then save the list again:
   ```
   bash scripts/state.sh set-json senders '[{"first":"Jane","last":"Smith","username":"jane","domain":"<first-domain>"}, ...]'
   bash scripts/zapmail-csv.sh upload-file
   ```
   That writes `~/Desktop/zapmail-mailboxes-upload.csv` (names only, no passwords).

   Open https://app.zapmail.ai/setup/mailboxes/details ("Assign New Mailboxes"). Choose **Bulk Upload** and upload that file. If your browser tool cannot upload files, the person clicks the upload button and picks the file on their Desktop.
   - Skip "Generate AI profile pictures".
   - Check all 10 rows, then click **Assign Mailboxes**. If it asks for payment again, stop and check with the person: the plan should already cover 10.

8. **Wait for activation.** Zapmail says mailboxes can take up to about 3 hours. Their status shows "Creating Password", then "Active".

   **Say:**
   > Zapmail is creating your 10 mailboxes. This can take up to 3 hours. You can walk away. When you're back, tell me "continue" and I'll pick up from here.

   ```
   bash scripts/state.sh set zapmail_ordered_at "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
   ```
   If the session stays open, check https://app.zapmail.ai/mailboxes about every 30 minutes. Do not refresh more often. If 3 hours pass with no change, ask the person whether they confirmed their Zapmail email address.

   Zapmail also promotes its own warmup service, Zapwarm. Skip it. Two warmup services on the same mailboxes work against each other. Warmbly does the warmup.

9. **Export the mailbox logins.** When all 10 show Active:
   - Open **Mailboxes**. Tick the checkbox at the top of the list, then "Select all 10 mailboxes".
   - Click **Export**. Choose **CSV File**, type **SMTP IMAP (.csv)**.
   - Tick the **Manual Export Warning** box. Download the file. If Zapmail shows a download link instead, click it.

   Then move it into the private folder. This prints only the addresses:
   ```
   bash scripts/zapmail-csv.sh stash
   ```
   If the file went somewhere other than Downloads, pass its path: `bash scripts/zapmail-csv.sh stash "<path>"`.

### Check

- `bash scripts/zapmail-csv.sh emails` lists 10 addresses, 5 on each domain.
- The file has IMAP host `imap.gmail.com` port 993 and SMTP host `smtp.gmail.com` port 587. Check without printing passwords:
  ```
  cut -d, -f6,7,11,12 ~/.config/warmbly-kit/zapmail-mailboxes.csv | sort -u
  ```

### Known problems

- **The bulk upload fills only one row.** Zapmail has two file inputs on that page (one for profile pictures, one for the CSV). Upload to the one that accepts `.csv`.
- **"5 per domain" error.** Zapmail caps each domain at 5 mailboxes. Fix the sender list so each domain has 5.
- **Zapmail warns Google may ask for phone verification** when the mailboxes are first used from a new place. If Warmbly reports sign-in failures in Phase 7, follow the retry steps there first.

---

## Phase 7: Connect the mailboxes to Warmbly

**Goal:** all 10 mailboxes connected and warmup on.

Use Google app passwords over IMAP and SMTP. Do not use "Sign in with Google": on a self-hosted server it needs your own Google sign-in app, which this kit does not set up.

### Steps

1. **YOU DO THIS: sign in to Warmbly in your browser.** Open `https://app.<host>`.

   **Say:**
   > Your turn: sign in to Warmbly in this window with the email and password you chose. I'll do the rest of the import. Tell me "done" when you see the dashboard.

   Warmbly keeps the sign-in in this browser's storage. Signing in elsewhere does not help.

2. Put a copy of the export where the upload dialog can reach it:
   ```
   bash scripts/zapmail-csv.sh stage
   ```
   This writes `~/Desktop/warmbly-import.csv`. **Keep it until the import says it finished.** Warmbly reads the file again when you click Import. In a real run, deleting it early caused "Network Error".

3. Open the Accounts page: `https://app.<host>/app/emails`. Click **Add account**, then **Import mailboxes**. Upload `~/Desktop/warmbly-import.csv`. If your browser tool cannot upload, the person picks the file on their Desktop. Click **Continue**.

   Warmbly recognizes Zapmail's export format. The review should show **Ready 10**, Google Workspace, sending on port 587.

4. Open **Settings for every mailbox** and set:
   - Warmup: **On**
   - Start: **10** a day
   - Daily increase: **1**
   - Maximum: **40** a day
   - Reply rate: **30%**

   Leave the daily limit and time between sends as they are.

5. Click **Import 10 mailboxes**. Wait until it says it finished.

6. Read the result. In a real run, only the first mailbox on each domain (Zapmail's admin mailbox) connected at first. The other 8 failed with Google error **534 5.7.14** ("sign in through a web browser"). That is common for brand-new Google mailboxes and usually clears on its own.

   **Say** (if some failed):
   > X of 10 mailboxes are connected and warming. Google refused the others for now, which is normal for brand-new mailboxes. I'll retry in about 3 hours. You don't need to do anything.

   ```
   bash scripts/state.sh set import_first_try_at "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
   bash scripts/zapmail-csv.sh unstage
   ```
   The retry does not need the file. Warmbly keeps failed rows' passwords sealed for 7 days.

7. **Retry after about 3 hours.** The person must be signed in to Warmbly in your browser (repeat step 1 if needed).
   - Open the Accounts page (`/app/emails`).
   - Click the **Imports** button near the top.
   - Click the import.
   - Click **Retry these** for the failed group.

   The import has no web address of its own. A direct link to `/app/emails/imports/<id>` shows "page not found". Always go through the Imports button.

   If a row times out, retry it once more. In a real run, all but one of the failed mailboxes connected on the first retry. The last one connected on a second retry. No web sign-ins were needed.

8. **Only if retries keep failing** over several hours: each failing mailbox needs a one-time sign-in in a web browser. Describe the situation to the person. Options:
   - Ask Zapmail support to sign in once for those mailboxes.
   - The person signs in at https://mail.google.com in a private window with the mailbox address and its sign-in password from Zapmail. Google may ask for a phone number; the person handles that.
   Then retry from the Imports menu again. Warmbly v0.8.3 and later switch off a mailbox whose server keeps refusing sign-in. After the fix, turn it back on from the Accounts page.

### Check

- The Accounts page shows 10 mailboxes, each marked as warming.
- `bash scripts/verify.sh` shows 10 total, 10 active, 10 warming across the 2 domains.

### Known problems

- **"Network Error" when you click Import.** The upload file was deleted or moved. Run `bash scripts/zapmail-csv.sh stage` again, reload the page, and start the import again.
- **A row says the tracking domain is waiting for its DNS record.** That is optional link tracking for a sending domain. The mailbox still works. Leave it for later.
- **The import is visible but you cannot find it again.** Use the Imports button on the Accounts page. Imports are kept for 7 days.

---

## Phase 8: Final check and summary

**Goal:** prove the end state and tell the person where everything is.

### Steps

```
bash scripts/verify.sh
```

It checks SSH, password sign-in off, HTTPS on all seven addresses, the certificate's end date, the key backup on the Mac, every container, the `.env` fixes, mailboxes per domain, and warmup sends so far.

First warmup emails go out during the next working hours. Zero sends on day one is normal.

### Check

- `VERIFY_OK` at the end.
- 2 domains, 5 mailboxes each, all active and warming.

Then `bash scripts/state.sh done 8`.

### Summary for the person

**Say** (fill in the values):
> Your Warmbly setup is done.
>
> - Dashboard: https://app.warmbly.<domain>
> - Sign in with: the email and password you chose
> - Mailboxes: 10, on <first-domain> and <second-domain>, all warming
> - Warmup: starts at 10 emails a day per mailbox, adds 1 a day, up to 40. The mailboxes only email each other.
> - Wait 3 to 4 weeks before real campaigns.
>
> Monthly cost:
> - Hetzner server: about $10.59
> - Zapmail: $39
> - Domains: about $12.99 each per year
>
> Where things are:
> - Server: Hetzner project "Warmbly". From this Mac: ssh warmbly
> - Private files on this Mac: ~/.config/warmbly-kit (tokens, mailbox passwords, key backup)
> - Warmbly's two encryption keys: on the server and in that folder. Keep both safe.
>
> Before your first campaign:
> - Add your postal address and an unsubscribe link to every email.
> - Use honest sender names and subject lines.
>
> Still to do later, if you want:
> - An email service so Warmbly can send invites and password resets.
> - Two-step sign-in on your Hetzner and Zapmail accounts.

---

## Phase 9: Maintenance

Use these when the person asks later. None of them run during setup.

### Check health

```
bash scripts/verify.sh
```

### Upgrade Warmbly

Warmbly shows "Update to vX" in the dashboard when a release is out. Read the release notes at https://github.com/warmbly/warmbly/releases first. Ask the person before upgrading.

```
bash scripts/upgrade-warmbly.sh <new-tag> --dry-run
bash scripts/upgrade-warmbly.sh <new-tag>
bash scripts/verify.sh
```

What it does:
1. Backs up `.env` and a full database dump (`pg_dump -Fc`) to `/root/warmbly-backups/` on the server.
2. Sets `WARMBLY_TAG=<new-tag>` in `.env` and runs `docker compose pull`.
3. Compares each pulled image's digest with the release's `images.json`. On any mismatch it puts the old tag back and stops. The running version is not touched.
4. Runs `docker compose up -d` and waits for health. The backend runs database migrations on start.

It never re-runs Warmbly's installer, so `.env` is not rewritten and the `GEODB_PATH` and `EMAIL_NAME` lines stay. Afterward, check the Accounts page: every mailbox should still be warming.

Do not use the dashboard's own update button for releases that add new services. Warmbly's docs say it pulls the new release but does not add services to the compose file.

### If an upgrade goes wrong

1. Look at the backend log: `ssh warmbly 'cd /opt/warmbly && docker compose logs backend --tail 80'`. Hide long values before showing the person.
2. To go back to the old images, set the old tag and start:
   ```
   ssh warmbly "cd /opt/warmbly && sed -i 's/^WARMBLY_TAG=.*/WARMBLY_TAG=<old-tag>/' .env && docker compose up -d"
   ```
3. If the new release already changed the database and the old version will not start, restore the dump taken before the upgrade. This replaces the database, so ask the person first:
   ```
   ssh warmbly 'ls -l /root/warmbly-backups/'
   ssh warmbly 'cd /opt/warmbly && docker compose stop backend worker consumer \
     && docker compose exec -T postgres sh -c "pg_restore -U \$POSTGRES_USER -d \$POSTGRES_DB --clean --if-exists" < /root/warmbly-backups/<db-file>.dump \
     && docker compose up -d'
   ```

### Let Warmbly send its own emails

Warmbly starts with `MAIL_TRANSPORT=log`: invites and password resets go to the backend log, not to anyone's inbox. To send them, the person needs an SMTP relay, such as their email provider's SMTP service or a transactional email service. Ask which one they want and get its details. Then add to `/opt/warmbly/.env` (secrets go in by script or by editing on the server, never through chat):

```
MAIL_TRANSPORT=smtp
EMAIL_ADDRESS=<sender address on a domain the relay allows>
SMTP_HOST=<relay host>
SMTP_PORT=587
SMTP_USERNAME=<user>
SMTP_PASSWORD=<password>
SMTP_SECURITY=starttls
```

Remove or change the old `MAIL_TRANSPORT=log` line so it appears once. Use port 587: Hetzner blocks 25 and 465. Then `docker compose up -d` in `/opt/warmbly` and check the backend log for "mail transport".

### Reset a forgotten Warmbly password

```
ssh warmbly 'cd /opt/warmbly && docker compose exec -T backend warmblyctl user reset-password --help'
```
Follow its help to make a one-time reset link. Open the link in the browser with `open`; do not print it.

### Stop paying

- Hetzner bills until the server is deleted. Deleting it destroys Warmbly and its data. Ask twice. Copy anything the person wants first.
- Zapmail bills monthly until the plan is cancelled in Zapmail's Billing page. Domains renew yearly unless renewal is turned off.
