# Troubleshooting Guide

Common issues and solutions for smart_env.

## Ruby/Gem Issues

### "Ignoring gem because its extensions are not built"

**Symptoms:**
```
Ignoring bigdecimal-4.0.1 because its extensions are not built. Try: gem pristine bigdecimal --version 4.0.1
Ignoring json-2.18.0 because its extensions are not built. Try: gem pristine json --version 2.18.0
```

**Cause:** Your shell inherited `GEM_HOME` and `GEM_PATH` from another project or Ruby version. This commonly happens with:
- iTerm2 split panes (CMD+D, CMD+SHIFT+D)
- Terminal tabs opened from another directory
- Shells spawned from editors/IDEs

**Solution 1: Run the setup script**
```fish
fish ~/.config/omf/pkg/smart_env/scripts/setup_chruby.fish
```

**Solution 2: Manual fix**
```fish
# Reset Ruby environment
chruby_reset

# Re-activate your Ruby
chruby ruby-3.4.7  # or your version

# Verify
ruby --version
echo $GEM_HOME
```

**Solution 3: Fix your config.fish**

Ensure all chruby functions are sourced in the correct order:

```fish
# In ~/.config/fish/config.fish
source /opt/homebrew/opt/chruby-fish/share/fish/vendor_functions.d/chruby_reset.fish
source /opt/homebrew/opt/chruby-fish/share/fish/vendor_functions.d/chruby_use.fish
source /opt/homebrew/opt/chruby-fish/share/fish/vendor_functions.d/chruby.fish
source /opt/homebrew/opt/chruby-fish/share/fish/vendor_conf.d/chruby_auto.fish
chruby ruby-3.4.7  # your default version
```

### "You must use Bundler X or greater with this lockfile"

**Cause:** Same as above - wrong gem environment inherited.

**Solution:** Same as above - reset chruby and re-activate.

### chruby_reset: command not found

**Cause:** `chruby_reset.fish` is not being sourced in your config.

**Solution:**
```fish
# Add to ~/.config/fish/config.fish BEFORE other chruby sources:
source /opt/homebrew/opt/chruby-fish/share/fish/vendor_functions.d/chruby_reset.fish
```

Or run the setup script:
```fish
fish ~/.config/omf/pkg/smart_env/scripts/setup_chruby.fish
```

### Ruby environment wrong after opening new tab

**Cause:** The startup cleanup isn't running, or chruby isn't being re-applied.

**Solution:**

1. Check that smart_env is loaded:
   ```fish
   functions -q __smart_env_directory_watcher && echo "OK" || echo "Not loaded"
   ```

2. Check that chruby functions exist:
   ```fish
   functions -q chruby_reset && echo "OK" || echo "Missing"
   ```

3. Manually trigger cleanup:
   ```fish
   chruby_reset
   chruby ruby-3.4.7
   ```

---

## Environment Variable Issues

### Variables not loading automatically

**Symptoms:** `.env` file exists but variables aren't set when entering directory.

**Possible causes:**

1. **File not approved:** First-time files require approval. Check if you see a prompt.

2. **Protected variable:** Some variables are protected and won't be set from .env:
   - `RUBY_VERSION`, `RUBY_ENGINE`, `RUBY_ROOT`
   - `GEM_HOME`, `GEM_PATH`, `GEM_ROOT`
   - `CHRUBY_VERSION`, `CHRUBY_ROOT`
   - `SHELL`, `USER`, `HOME`, `TERM`

3. **Directory watcher not active:**
   ```fish
   functions -q __smart_env_directory_watcher && echo "Active" || echo "Not active"
   ```

**Solution:**
```fish
# Manually load the file
smart_env .env

# Or reload smart_env
omf reload
```

### Variables not unloading when leaving directory

**Symptoms:** Variables from previous directory persist.

**Check:**
```fish
# See what's tracked
smart_env_list

# Manually unset
smart_env_unset
```

### PATH getting polluted with duplicate entries

**Symptoms:** `echo $PATH` shows many duplicate or stale entries.

**Solution:**
```fish
# Check current PATH
printf '%s\n' $PATH

# Reset Ruby paths
chruby_reset
chruby ruby-3.4.7

# Check smart_env tracked paths
cat ~/.config/smart_env/variables/*.paths 2>/dev/null
```

---

## 1Password Issues

### "op: command not found"

**Solution:**
```fish
brew install 1password-cli
```

### "You are not currently signed in"

**Solution:**
```fish
op signin
```

### Item not found

**Check:**
```fish
# List available items
op item list

# Search for item
op item list | grep -i "your-item-name"
```

---

## General Issues

### smart_env functions not found

**Symptoms:**
```
fish: Unknown command: smart_env
```

**Solutions:**

1. **Reinstall:**
   ```fish
   omf remove smart_env
   omf install smart_env
   ```

2. **Reload:**
   ```fish
   omf reload
   ```

3. **Check installation:**
   ```fish
   ls ~/.config/omf/pkg/smart_env/
   ```

### Too many prompts to approve files

**Tip:** Use "a" (approve) instead of "y" (yes) when prompted. This saves the approval for future loads.

### Reset everything

If you need to start fresh:

```fish
# Reset all smart_env approvals and cached data
smart_env_reset

# Clear the storage directory
rm -rf ~/.config/smart_env

# Reload
omf reload
```

---

## Debugging

### Enable verbose output

Currently smart_env shows colored output for actions. For debugging:

```fish
# Check what files are tracked
ls -la ~/.config/smart_env/variables/

# Check approved files
ls -la ~/.config/smart_env/cache/

# Check hash files
ls -la ~/.config/smart_env/*.hash
```

### Check function definitions

```fish
# See how a function is defined
type smart_env
type __smart_env_directory_watcher
type chruby_reset
```

### Verify startup sequence

```fish
# In a new shell, these should all return "yes"
functions -q smart_env && echo "smart_env: yes" || echo "smart_env: no"
functions -q chruby_reset && echo "chruby_reset: yes" || echo "chruby_reset: no"
functions -q __smart_env_directory_watcher && echo "watcher: yes" || echo "watcher: no"
```

---

## Getting Help

- **GitHub Issues:** https://github.com/mhenrixon/smart_env/issues
- **Command help:** Add `--help` to any command (e.g., `smart_env_load --help`)

When reporting issues, please include:
1. Fish version: `fish --version`
2. OS: `uname -a`
3. chruby version (if applicable): `chruby --version`
4. The exact error message
5. Steps to reproduce
