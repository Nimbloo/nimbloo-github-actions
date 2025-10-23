# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a GitHub Actions repository containing reusable composite actions for Nimbloo deployments. The primary action is `notify-deploy`, which sends branded deployment notifications via Slack and AWS SES email.

## Architecture

### Repository Structure

```
nimbloo-github-actions/
├── notify-deploy/          # Main composite action
│   ├── action.yml          # Action definition with inputs/steps
│   ├── notify.sh           # Notification logic (Slack + Email)
│   └── tommy_*.png         # Mascot images for different states
└── README.md               # User-facing documentation
```

### notify-deploy Action

**Core Mechanism:**
- Composite action defined in `notify-deploy/action.yml`
- Two-step execution:
  1. **Setup step**: Auto-detects environment variables (project, stage, version, status)
  2. **Notification step**: Executes `notify.sh` to send Slack/Email notifications

**Auto-Detection Logic:**
- **Project name**: Extracted from `github.repository` basename
- **Stage**: Mapped from branch name (master→prd, staging→hml, develop→dev)
- **Version**: Parsed from `pom.xml` (Java) or `package.json` (Node.js)
- **Status**: Derived from `job.status` if not explicitly provided

**Environment Variables Flow:**
All inputs are converted to environment variables in the setup step and consumed by `notify.sh`:
- `PROJECT_NAME`, `STAGE`, `VERSION`, `STATUS`, `STACK_NAME`, `AWS_REGION`
- `SLACK_WEBHOOK`, `NOTIFICATION_EMAIL`, `NOTIFICATION_EMAIL_FROM`
- `STARTED_AT` (for duration calculation), `CUSTOM_MESSAGE`
- GitHub context: `GITHUB_REPOSITORY`, `GITHUB_REF_NAME`, `GITHUB_ACTOR`, `GITHUB_SHA`, `GITHUB_RUN_ID`

## Branding Guidelines

**Nimbloo Colors** (defined in `notify.sh`):
- Primary Purple: `#642878`
- Deep Purple: `#502364`
- Orange: `#F05A28`

**Mascot**: Capt. Tommy (ship captain character)
- Images: `tommy_success_dev.png`, `tommy_success_staging.png`, `tommy_success_prod.png`, `tommy_fail.png`, `tommy_progress.png`
- Hosted on GitHub, embedded via raw URLs in email templates

**Email Headers**:
- Started: Orange gradient
- Success: Purple gradient
- Failed: Red gradient

**Slack Emojis**:
- Started: 🚀
- Success (dev/hml): ✅
- Success (prd): 🎉 (celebration emoji for production)
- Failed: ❌

## Key Technical Details

### Duration Calculation
- `STARTED_AT` input accepts epoch timestamp
- Calculation: `current_time - STARTED_AT`
- Format: "3m 45s" or "25s"

### Slack Notifications
- Uses Block Kit format with `mrkdwn` type
- Payload saved to `/tmp/slack-payload.json` to preserve UTF-8 encoding
- Content-Type: `application/json; charset=utf-8`
- Technical fields wrapped in backticks for inline code style

### Email Notifications
- AWS SES via `aws ses send-email`
- HTML template with inline CSS (no external files)
- JSON constructed with `jq` for proper escaping
- UTF-8 charset in Subject and HTML Body

### Error Handling
- Script uses `set +e` to prevent action failure on notification errors
- Individual notification failures are logged but don't break the workflow

## Development Workflow

### Testing Changes
Since this is a GitHub Actions repository, testing requires:
1. Make changes to `action.yml` or `notify.sh`
2. Commit and push to a branch
3. Reference the branch in a test workflow: `uses: Nimbloo/nimbloo-github-actions/notify-deploy@branch-name`

### Common Tasks

**Add new notification channel:**
- Edit `notify.sh` and add new section after Slack/Email blocks
- Add required inputs to `action.yml` if needed
- Update environment variable mapping in setup step

**Modify email template:**
- Find HTML template generation in `notify.sh` (search for `aws ses send-email`)
- HTML is inline - edit the heredoc sections
- Test with actual SES credentials

**Update auto-detection logic:**
- Edit the setup step in `action.yml`
- Add new branch patterns, version file types, etc.
- Ensure variables are exported to `$GITHUB_ENV`

**Change branding:**
- Update color hex codes in `notify.sh` variables
- Replace `tommy_*.png` images in `notify-deploy/` directory
- Update image URLs in email template sections

## Important Notes

- Always use `@master` in examples (as per README convention)
- AWS credentials must be configured BEFORE the action runs (for SES)
- Commit messages should not reference Claude (per user global CLAUDE.md)
- All inputs are optional - action relies heavily on auto-detection
- The action uses `if: always()` pattern to send notifications even on failure
