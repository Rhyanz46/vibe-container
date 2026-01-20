# 🛡️ Claude Code Container - Safety Guide

## ⚠️ CRITICAL SECURITY WARNINGS

### What Claude Code CAN and CANNOT do:

## ✅ SAFE - Claude Code CAN do these:

1. **Create and edit files in `/workspace/`**
   - Write, modify, delete project files
   - Safe because: Limited to project directory

2. **Create files in `/home/claude/`**
   - Create new files in home directory
   - Safe because: Isolated to container user

3. **Run normal development commands**
   - `npm install`, `go build`, `git clone`
   - Safe because: Normal operations

4. **Manage other Docker containers**
   - Start, stop, list containers
   - Build and deploy images
   - **RISKY** but necessary for development

5. **Install packages via npm/go**
   - `npm install package-name`
   - `go get package-name`
   - Safe because: Installs to isolated environment

## 🚨 DANGEROUS - Claude Code CAN do these (but SHOULD NOT):

### Via Docker Socket (The Real Danger):

```bash
# ⚠️ DANGEROUS - Can mount host filesystem
docker run --rm -v /:/mnt ubuntu cat /mnt/etc/shadow

# ⚠️ DANGEROUS - Can delete host files
docker run --rm -v /:/mnt ubuntu rm -rf /mnt/home/user/documents

# ⚠️ DANGEROUS - Can run privileged containers
docker run --rm --privileged alpine reboot

# ⚠️ DANGEROUS - Can escape to host
docker run --rm -it --pid=host --privileged ubuntu nsenter -t 1 -m -p
```

## 📋 Safety Rules for Development:

### ✅ DO:

1. **Review ALL code before running**
   ```bash
   # Don't just copy-paste and run
   # Read and understand first!
   ```

2. **Use version control**
   ```bash
   git add .
   git commit -m "Safe changes"
   # Can always revert if something goes wrong
   ```

3. **Regular backups**
   ```bash
   tar czf backup-$(date +%Y%m%d).tar.gz data/
   ```

4. **Monitor Docker containers**
   ```bash
   docker ps -a  # Check all containers
   docker images  # Check all images
   ```

5. **Use .dockerignore properly**
   ```bash
   # Exclude sensitive files
   echo "data/" >> .gitignore
   ```

### ❌ DON'T:

1. **Don't let Claude run without supervision**
   - Always review generated code
   - Don't use auto-run features blindly

2. **Don't mount sensitive host paths**
   ```bash
   # BAD:
   docker run -v /root/.ssh:/mnt ssh-key-stealer

   # GOOD:
   docker run -v ./workspace:/workspace myapp
   ```

3. **Don't use --privileged flag**
   ```bash
   # VERY BAD:
   docker run --privileged ubuntu evil-command
   ```

4. **Don't mount host root (/)**
   ```bash
   # CATASTROPHIC:
   docker run -v /:/host ubuntu rm -rf /host/*
   ```

5. **Don't ignore warning signs**
   - If Claude suggests suspicious commands
   - If code looks too complex to understand
   - If Claude wants to modify system files

## 🔒 Protection Layers (Already in Place):

### Layer 1: Non-Root User ✅
```bash
docker exec claude-code-container whoami
# Output: claude (not root!)
```
- Container runs as UID 1001
- Reduces (but doesn't eliminate) risk

### Layer 2: Sudo Requires Password ✅
```bash
docker exec claude-code-container sudo rm -rf /etc/passwd
# Will ask for password (stops accidental deletion)
```
- Password required for sudo commands
- Prevents accidental damage

### Layer 3: Filesystem Isolation ✅
```bash
# Can't directly access host filesystem:
ls -la /hostroot  # Doesn't exist
rm -rf /etc/passwd  # Only deletes container's file, not host's
```

### Layer 4: Process Isolation ✅
```bash
# Can't kill host processes:
ps aux  # Only shows container processes
```

## ⚠️ Layer 5: Docker Socket (The Necessary Evil)

**Why it's mounted:**
- Needed for Docker CLI functionality
- Allows building and deploying containers
- Essential for development workflow

**Risk:**
- Provides backdoor to host if misused
- Can mount host filesystem
- Can run privileged containers

**Mitigation:**
- Supervision required
- Code review mandatory
- No auto-execution

## 📊 Risk Assessment:

| Activity | Risk Level | Mitigation |
|----------|-----------|------------|
| **Writing code** | 🟢 Low | Version control, backups |
| **npm install** | 🟢 Low | Isolated to container |
| **go build** | 🟢 Low | Isolated to container |
| **docker ps** | 🟡 Medium | Review output |
| **docker build** | 🟡 Medium | Check Dockerfile |
| **docker run** | 🔴 High | Review command first! |
| **docker run -v /:/host** | 🔴🔴 CRITICAL | **NEVER DO THIS!** |

## 🎯 Best Practices:

### 1. The "Three-Check" Rule
Before running ANY Docker command suggested by Claude:

```bash
# Check 1: What does this command do?
# Example:
docker run -v /:/mnt ubuntu rm -rf /mnt/*
# ↑ This deletes ALL files on host! DON'T RUN!

# Check 2: Is it mounting host paths?
# -v /:/mnt  ← BAD! Mounts host root
# -v ./workspace:/workspace  ← GOOD! Mounts project only

# Check 3: Is it using --privileged?
# --privileged  ← BAD! Full host access
# (no flag)  ← GOOD! Normal container
```

### 2. Always Use Relative Paths
```bash
# BAD:
rm -rf /data  # Could delete important data

# GOOD:
rm -rf ./data  # Only deletes current directory
```

### 3. Test in Isolation First
```bash
# Create test directory first
mkdir -p /tmp/test-sandbox
cd /tmp/test-sandbox

# Then run commands there
# If something breaks, it's contained
```

### 4. Keep Docker Commands Simple
```bash
# COMPLEX - Hard to verify:
docker run --rm -v $(pwd):/app -w /app --entrypoint bash -u root alpine -c "userdel -r user && rm -rf /home/user/*"

# SIMPLE - Easy to understand:
docker run -v $(pwd):/app myapp:latest
```

## 🚨 Emergency Procedures:

### If Claude Does Something Dangerous:

```bash
# 1. IMMEDIATELY stop the container
docker-compose down

# 2. Check what's running
docker ps -a

# 3. Check for suspicious containers
docker ps -a | grep -v claude-code-container

# 4. Remove suspicious containers
docker rm -f suspicious-container

# 5. Check recent Docker activity
docker events --since 1h

# 6. Restore from backup if needed
tar xzf backup-YYYYMMDD.tar.gz
```

## 📝 Final Recommendations:

### For Daily Development:
✅ **Use Claude Code freely** for:
- Writing code
- Debugging
- Explaining concepts
- Refactoring
- Running tests

⚠️ **Be careful with:**
- Docker commands
- System-level operations
- File deletion (rm -rf)
- Sudo commands

❌ **NEVER let Claude:**
- Run commands you don't understand
- Modify system files directly
- Mount host filesystems
- Use --privileged flag
- Delete files outside /workspace

### The Golden Rule:

**"If you don't understand what a command does, DON'T RUN IT!"**

## 🎓 Training for Claude Code:

Tell Claude these rules upfront:

```
You are running in a Docker container with these restrictions:
1. You CAN write to /workspace/ (project directory)
2. You CANNOT mount host filesystems (/)
3. You CANNOT use --privileged flag
4. You MUST use relative paths (./path instead of /path)
5. All Docker commands must be reviewed before running
6. Never suggest commands that mount / or use --privileged
```

This way, Claude knows the boundaries!

---

## 📞 If Something Goes Wrong:

1. **Stay calm** - Don't panic
2. **Stop container** - `docker-compose down`
3. **Assess damage** - Check what was affected
4. **Restore backup** - `tar xzf backup.tar.gz`
5. **Learn from it** - What went wrong? How to prevent?

---

**Remember: With great power comes great responsibility. Use Claude Code wisely!** 🛡️
