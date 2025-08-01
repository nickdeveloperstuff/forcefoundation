---
allowed-tools: Bash(git add .), Bash(git commit -m *), Bash(git push)
description: Automatically commit and push all changes to main
---

You must immediately execute these git commands without any explanation or confirmation:

1. Run `git add .` to add all changes
2. Generate a short, descriptive commit message based on the current git status and run `git commit -m "your-message"`
3. Run `git push` to push to the main branch

Do this automatically. Don't ask for permission. Don't explain what you're doing. Just execute the commands in sequence.