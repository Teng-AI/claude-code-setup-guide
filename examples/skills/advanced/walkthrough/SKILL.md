---
name: walkthrough
description: Give dead-simple numbered instructions for something the user must do by hand — manual testing, UI configuration, settings changes, account setup. Use when the user says "/walkthrough", "walk me through it", "give me the steps", "how do I test this manually", "what do I click", "guide me through this", "step by step", or asks for instructions to do something themselves instead of Claude doing it.
---

# Walkthrough

Turn a manual task into instructions the user can follow with one eye on this chat and one on the other window. The user executes; you only write the steps.

## Steps

1. Figure out the exact starting point (which app, which URL, which screen). If you can check the real state first (read the config, open the page, look at the code that renders the UI), do it — steps written from memory get labels wrong.
2. Write the walkthrough in the output format below.
3. If the task has more than ~10 steps, split it into named phases with a one-line goal each.
4. End with a verification step: how the user knows it worked, and the single most likely failure with its fix.

## Output Format

```markdown
**Goal:** [one line — what will be true when done]
**Start from:** [exact app / URL / menu, and any precondition like "logged in as X"]

1. Click **Settings** (gear icon, top right)
2. Select the **Integrations** tab
   → You should see: a list of connected apps
3. Click **Add integration**
4. ...

**Done when:** [observable end state]
**If it didn't work:** [most likely failure → fix]
```

Rules for the steps themselves:
- **One physical action per number.** "Open X and then click Y" is two steps.
- **Exact labels, bolded**, as they appear on screen — never "go to the settings area".
- Add a `→ You should see:` line after any step where the screen changes or the user could be lost. Not after every step.
- Commands go in their own `bash` fenced block, one per block, copy-paste ready — no placeholders unless unavoidable, and flag any placeholder loudly.
- No explanations inside the numbered list. If the why matters, one line above the list, not woven between steps.

## Gotchas

- Don't compress steps to look concise. Ten tiny steps beat five compound ones — the user is executing, not reading.
- Don't assume state ("your dev server is running", "you're on the right account"). Either make it a precondition in **Start from** or make checking it step 1.
- Don't describe UI from memory when you can look. If it's this machine or a file in a repo, verify the actual menu names, flags, or field names first.
- Don't end at the last click. The walkthrough ends when the user can confirm success.
