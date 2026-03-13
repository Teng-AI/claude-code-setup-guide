---
name: debug-firebase
description: Firebase-specific debugging patterns. Diagnose permission errors, sync issues, data inconsistencies, and offline problems. Use when Firebase data isn't behaving as expected.
---

# Debug Firebase

A systematic approach to debugging Firebase Realtime Database issues. Focuses on diagnosis, not patterns (see `~/.claude/references/firebase-rtdb.md` for patterns).

## When to Use

- "Permission denied" errors
- Data not updating / syncing
- Unexpected data structure after write
- Transaction failures
- Offline sync issues
- Security rules not working as expected

## Quick Diagnosis Flowchart

```
Data not updating?
├── Check auth state → Is user signed in?
├── Check path → Are you reading/writing the right path?
├── Check rules → Does the rule allow this operation?
└── Check write method → Did you use set() when you meant update()?

Permission denied?
├── Check auth.uid → Is it what you expect?
├── Check rule path → Does it match your data path?
├── Multi-path update? → ALL paths must pass rules
└── Use Rules Simulator → Test in Firebase Console

Data looks wrong after write?
├── Used update() with nested object? → It REPLACED, not merged
├── Missing fields? → set() deleted them
└── Wrong path? → Check your ref() path
```

## Step 1: Check Authentication State

**First thing to verify - is the user authenticated?**

```javascript
import { getAuth, onAuthStateChanged } from 'firebase/auth';

// Add this debug snippet
onAuthStateChanged(getAuth(), (user) => {
  if (user) {
    console.log('[AUTH] Signed in as:', user.uid);
    console.log('[AUTH] Email:', user.email);
  } else {
    console.log('[AUTH] NOT signed in');
  }
});
```

**Common issues:**
- Auth state not ready when write attempted
- Anonymous auth expired
- Token refresh failed silently

## Step 2: Check Connection State

**Is the client connected to Firebase?**

```javascript
import { ref, onValue } from 'firebase/database';

onValue(ref(db, '.info/connected'), (snap) => {
  console.log('[CONNECTION]', snap.val() ? 'ONLINE' : 'OFFLINE');
});
```

**If offline:**
- Writes are queued locally
- Transactions won't complete (they wait for server)
- onDisconnect handlers haven't fired yet

## Step 3: Add Verbose Logging

**Log all reads/writes to the path you're debugging:**

```javascript
// Watch the exact path
function debugPath(db, path) {
  console.log(`[DEBUG] Watching: ${path}`);
  onValue(ref(db, path), (snap) => {
    console.log(`[${path}]`, JSON.stringify(snap.val(), null, 2));
  }, (error) => {
    console.error(`[${path}] ERROR:`, error.message);
  });
}

// Usage
debugPath(db, 'rooms/ABC123/game/phase');
debugPath(db, 'rooms/ABC123/game/pendingCalls');
```

**Log before/after writes:**

```javascript
async function debugWrite(dbRef, data) {
  const path = dbRef.toString();
  console.log(`[WRITE] Path: ${path}`);
  console.log('[WRITE] Data:', JSON.stringify(data, null, 2));

  try {
    await update(dbRef, data);
    console.log('[WRITE] Success');
  } catch (error) {
    console.error('[WRITE] Failed:', error.code, error.message);
  }
}
```

## Step 4: Diagnose Specific Issues

### Issue: Permission Denied

**Check 1: Auth state at time of write**
```javascript
const user = getAuth().currentUser;
console.log('Current user:', user?.uid || 'NONE');
```

**Check 2: Rule path matches data path**
```javascript
// Your code writes to:
ref(db, 'rooms/ABC123/game')

// Your rule must cover this path:
{
  "rooms": {
    "$roomId": {
      "game": {
        ".write": "..."  // This rule applies
      }
    }
  }
}
```

**Check 3: Multi-path update - ALL paths must pass**
```javascript
// This fails if ANY path is denied
await update(ref(db), {
  'rooms/ABC123/game/phase': 'playing',      // ✓ Allowed
  'rooms/ABC123/admin/log': 'game started'   // ✗ Denied → ENTIRE write fails
});
```

**Check 4: Use Firebase Rules Simulator**
1. Go to Firebase Console → Realtime Database → Rules
2. Click "Simulator" tab
3. Enter path, method (read/write), auth state
4. See exactly which rule failed

### Issue: Data Not Updating

**Check 1: Are you listening to the right path?**
```javascript
// Writing to:
update(ref(db, 'game/pendingCalls/seat0'), { ... });

// But listening to:
onValue(ref(db, 'game'), ...);  // Might have stale local cache

// Listen to specific path instead:
onValue(ref(db, 'game/pendingCalls/seat0'), ...);
```

**Check 2: Did you use the wrong write method?**
```javascript
// WRONG: Nested object in update() REPLACES
await update(ref(db, 'game'), {
  pendingCalls: { seat0: 'pass' }  // Replaces ALL of pendingCalls!
});

// CORRECT: Path string
await update(ref(db), {
  'game/pendingCalls/seat0': 'pass'  // Only updates seat0
});
```

**Check 3: Verify the write succeeded**
```javascript
try {
  await update(ref(db, path), data);
  console.log('Write succeeded');

  // Immediately read back to verify
  const snap = await get(ref(db, path));
  console.log('Read back:', snap.val());
} catch (e) {
  console.error('Write failed:', e);
}
```

### Issue: Data Looks Wrong After Write

**The #1 cause: `update()` with nested objects**

```javascript
// Before write:
game = {
  phase: 'calling',
  pendingCalls: { seat0: null, seat1: null, seat2: null, seat3: null }
}

// Your write:
await update(ref(db, 'game'), {
  pendingCalls: { seat0: 'pass' }
});

// After write (WRONG - other seats deleted):
game = {
  phase: 'calling',
  pendingCalls: { seat0: 'pass' }  // seat1, seat2, seat3 GONE!
}
```

**Fix: Use path strings**
```javascript
await update(ref(db), {
  'game/pendingCalls/seat0': 'pass'
});
```

### Issue: Transaction Keeps Retrying

**Check 1: Are you handling null?**
```javascript
// WRONG
runTransaction(ref, (current) => {
  return current.count + 1;  // Fails if current is null!
});

// CORRECT
runTransaction(ref, (current) => {
  if (current === null) {
    return { count: 1 };  // Initialize if doesn't exist
  }
  return { ...current, count: current.count + 1 };
});
```

**Check 2: Is there high contention?**
- Multiple clients writing same path rapidly
- Transaction scope too broad
- Solution: Narrow the transaction scope or use `increment()`

**Check 3: Are you offline?**
- Transactions wait for server connection
- They won't complete offline

### Issue: Offline Writes Not Syncing

**Check 1: Did the app close before sync?**
- Writes are queued but lost if app closes
- No built-in way to guarantee offline write persistence in web

**Check 2: Is the write blocked by a rule?**
- Writes may succeed locally but fail when syncing
- Check console for delayed permission errors

**Check 3: Transaction while offline?**
- Transactions don't work offline - they wait for connection

## Debugging Utilities

### State Validator

```javascript
function validateGameState(game) {
  const errors = [];

  // Required fields
  if (!game) errors.push('Game is null');
  if (!game?.phase) errors.push('Missing phase');

  // Valid values
  const validPhases = ['setup', 'playing', 'calling', 'ended'];
  if (game?.phase && !validPhases.includes(game.phase)) {
    errors.push(`Invalid phase: ${game.phase}`);
  }

  // Seat bounds
  if (game?.currentPlayerSeat !== undefined) {
    if (game.currentPlayerSeat < 0 || game.currentPlayerSeat > 3) {
      errors.push(`Invalid seat: ${game.currentPlayerSeat}`);
    }
  }

  // Tile count (if applicable)
  // Add your game-specific validations

  return errors.length ? errors : null;
}
```

### Write Interceptor (Development Only)

```javascript
// Wrap update to log all writes
const originalUpdate = update;
window.firebaseUpdate = async (ref, data) => {
  console.group('[Firebase Write]');
  console.log('Path:', ref.toString());
  console.log('Data:', data);
  console.trace('Called from:');
  console.groupEnd();
  return originalUpdate(ref, data);
};
```

### Rules Tester

```javascript
// Test if a write would succeed (without actually writing)
async function testWrite(db, path, data, authUid) {
  // This actually writes, so use emulator only
  try {
    await update(ref(db, path), data);
    console.log('✓ Write allowed');
    // Rollback in emulator if needed
  } catch (e) {
    console.log('✗ Write denied:', e.message);
  }
}
```

## Common Mistakes Checklist

- [ ] Using `update()` with nested object (should use path strings)
- [ ] Not handling `null` in transactions
- [ ] Assuming auth is ready (use onAuthStateChanged)
- [ ] Multi-path update where one path fails (all fail)
- [ ] Rule path doesn't match data path exactly
- [ ] Expecting transactions to work offline
- [ ] Not checking `.info/connected` before critical writes
- [ ] Security rules cascade - parent allows, child deny is ignored

## Quick Fixes

| Symptom | Likely Cause | Fix |
|---------|--------------|-----|
| Permission denied | Auth not ready | Wait for onAuthStateChanged |
| Fields disappeared | `update()` with nested object | Use path strings |
| Transaction retries forever | Not handling null | Add null check |
| Write seems to succeed but no update | Listening to wrong path | Verify ref path |
| Intermittent permission errors | Token expired | Re-authenticate |

## Reference

For patterns and best practices, see:
- `~/.claude/references/firebase-rtdb.md` - Full reference doc
- Project-specific skills for your Firebase projects
