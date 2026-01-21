# Flutter Config Permission Fix

## Problem

Flutter menampilkan error saat dijalankan:

```
Unhandled exception:
Error: Flutter failed to create a directory at "/home/claude/.config/flutter".
Please ensure that the SDK and/or project is installed in a location that has read/write permissions for the current user.
```

## Root Cause

The `.config` directory is owned by `root` instead of user `claude`, preventing Flutter from creating its configuration files.

## Solution

### For Fresh Containers (Automatic)

The fix is now applied automatically via `entrypoint.sh`. When you start a fresh container, `.config/flutter` directory will be created with correct permissions automatically.

### For Existing Containers (Manual Fix)

If you're using an existing container that was built before the fix, apply this manual fix:

```bash
# From host machine
docker exec claude-code-container bash -c "
  sudo rm -rf ~/.config
  sudo -u claude mkdir -p ~/.config/flutter
  sudo -u claude chmod 755 ~/.config ~/.config/flutter
"
```

Or from within the container:

```bash
# Enter container
./shell.sh

# Fix permissions
sudo rm -rf ~/.config
mkdir -p ~/.config/flutter
chmod 755 ~/.config ~/.config/flutter
```

### Verification

After applying the fix, verify:

```bash
# Check directory exists and has correct ownership
ls -la ~/.config/
ls -la ~/.config/flutter/

# Should show:
# drwxr-xr-x 2 claude claude ... flutter

# Test Flutter
export PATH="\$HOME/flutter/bin:\$PATH"
flutter --version
```

## Technical Details

### What Changed in Dockerfile

Added automatic fix in `entrypoint.sh`:

```bash
# Fix .config directory ownership and create Flutter config directory
chown -R claude:claude /home/claude/.config 2>/dev/null || true
mkdir -p /home/claude/.config/flutter 2>/dev/null || true
chown -R claude:claude /home/claude/.config/flutter 2>/dev/null || true
chmod 755 /home/claude/.config 2>/dev/null || true
chmod 755 /home/claude/.config/flutter 2>/dev/null || true
```

And inside the `sudo -u claude` block:

```bash
# Fix .config directory for Flutter
mkdir -p ~/.config/flutter 2>/dev/null || true
chmod 755 ~/.config 2>/dev/null || true
chmod 755 ~/.config/flutter 2>/dev/null || true
```

### Why This Happened

1. During container build, `.config` directory was created as `root`
2. User `claude` couldn't create subdirectories in `/home/claude/.config`
3. Flutter failed when trying to write config files

### Prevention

The fix is now included in the Dockerfile and will be applied automatically:
- On every container startup via `entrypoint.sh`
- Before Flutter installation prompts appear
- Ensures `.config/flutter` is writable by user `claude`

## Related Files

- `Dockerfile` - Contains entrypoint.sh generation with fix
- `entrypoint.sh` - Auto-generated script that runs on container start
- `PATH_CORRUPTION_FIX.md` - Related fix for PATH environment variable
- `VPS-DEPLOYMENT-GUIDE.md` - Complete VPS deployment instructions

## Testing

After fix, Flutter should work without errors:

```bash
flutter --version
# Output: Flutter 3.x.x • channel stable
# No permission errors!
```

## Commit Information

- **Commit**: 9266d8c
- **Date**: 2026-01-22
- **Message**: Fix Flutter .config directory permission issue
