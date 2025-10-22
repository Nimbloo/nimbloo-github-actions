#!/bin/bash
set +e  # Don't fail if notification fails

# All variables are passed via environment
# Required: STATUS, STAGE, PROJECT_NAME, VERSION, STACK_NAME, AWS_REGION
# Optional: SLACK_WEBHOOK, NOTIFICATION_EMAIL, NOTIFICATION_EMAIL_FROM, CUSTOM_MESSAGE
# GitHub vars: GITHUB_REPOSITORY, GITHUB_REF_NAME, GITHUB_ACTOR, GITHUB_SHA, GITHUB_RUN_ID

COMMIT_SHORT="${GITHUB_SHA:0:7}"

# Deploy timestamp
DEPLOY_TIMESTAMP=$(date '+%d/%m/%Y às %H:%M:%S %Z')

# Commit message (try to get from git, fallback to "N/A")
COMMIT_MESSAGE=$(git log -1 --format=%s 2>/dev/null || echo "Deploy via GitHub Actions")

# Calculate duration if STARTED_AT is provided
DEPLOY_DURATION="N/A"
if [ -n "$STARTED_AT" ]; then
  CURRENT_TIME=$(date +%s)
  DURATION_SECONDS=$((CURRENT_TIME - STARTED_AT))
  MINUTES=$((DURATION_SECONDS / 60))
  SECONDS=$((DURATION_SECONDS % 60))
  if [ $MINUTES -gt 0 ]; then
    DEPLOY_DURATION="${MINUTES}m ${SECONDS}s"
  else
    DEPLOY_DURATION="${SECONDS}s"
  fi
fi

# Nimbloo brand colors
NIMBLOO_PURPLE="#642878"
NIMBLOO_DEEP_PURPLE="#502364"
NIMBLOO_ORANGE="#F05A28"


#==============================================
# SLACK NOTIFICATION
#==============================================
if [ -n "$SLACK_WEBHOOK" ]; then
  echo "📱 Sending Slack notification..."

  # Determine emoji and status text
  case "$STATUS" in
    "started")
      EMOJI="🚀"
      STATUS_TEXT="Deploy Iniciado"
      ;;
    "success")
      if [ "$STAGE" == "prd" ]; then
        EMOJI="🎉"
      else
        EMOJI="✅"
      fi
      STATUS_TEXT="Deploy Concluído com Sucesso"
      ;;
    "failed")
      EMOJI="❌"
      STATUS_TEXT="Deploy Falhou"
      ;;
    *)
      EMOJI="ℹ️"
      STATUS_TEXT="Deploy Update"
      ;;
  esac

  # Build custom message field
  CUSTOM_FIELD=""
  if [ -n "$CUSTOM_MESSAGE" ]; then
    CUSTOM_FIELD=",{\"type\":\"section\",\"text\":{\"type\":\"mrkdwn\",\"text\":\"💬 *Mensagem:* $CUSTOM_MESSAGE\"}}"
  fi

  # URLs
  DASHBOARD_URL="https://console.aws.amazon.com/cloudwatch/home?region=${AWS_REGION}#dashboards:name=${STACK_NAME}"
  LAMBDA_URL="https://console.aws.amazon.com/lambda/home?region=${AWS_REGION}#/functions/${STACK_NAME}"
  LOGS_URL="https://github.com/${GITHUB_REPOSITORY}/actions/runs/${GITHUB_RUN_ID}"  
  # Mr. Shipper image (hosted on GitHub)
  MR_SHIPPER_URL="https://raw.githubusercontent.com/Nimbloo/nimbloo-github-actions/master/notify-deploy/mr.shipper.png"


  # Build actions based on status
  if [ "$STATUS" == "success" ]; then
    ACTIONS="\"type\":\"actions\",\"elements\":[{\"type\":\"button\",\"text\":{\"type\":\"plain_text\",\"text\":\"📊 Dashboard\"},\"url\":\"${DASHBOARD_URL}\"},{\"type\":\"button\",\"text\":{\"type\":\"plain_text\",\"text\":\"⚡ Lambda\"},\"url\":\"${LAMBDA_URL}\"},{\"type\":\"button\",\"text\":{\"type\":\"plain_text\",\"text\":\"📋 Logs\"},\"url\":\"${LOGS_URL}\"}]"
  else
    ACTIONS="\"type\":\"actions\",\"elements\":[{\"type\":\"button\",\"text\":{\"type\":\"plain_text\",\"text\":\"🔍 Ver Logs\"},\"url\":\"${LOGS_URL}\",\"style\":\"danger\"}]"
  fi

  curl -X POST "$SLACK_WEBHOOK" \
    -H 'Content-Type: application/json' \
    -d "{
      \"text\": \"${EMOJI} *${STATUS_TEXT} - ${PROJECT_NAME}*\",
      \"blocks\": [
        {
          \"type\": \"section\",
          \"text\": {
            \"type\": \"mrkdwn\",
            \"text\": \"${EMOJI} *${STATUS_TEXT}*\\n*Project:* \\\`${PROJECT_NAME}\\\`\\n*Environment:* \\\`${STAGE}\\\`\\n*Version:* \\\`${VERSION}\\\`\\n*Branch:* \\\`${GITHUB_REF_NAME}\\\`\\n*Actor:* ${GITHUB_ACTOR}\\n*Commit:* <https://github.com/${GITHUB_REPOSITORY}/commit/${GITHUB_SHA}|${COMMIT_SHORT}>\"
          }
        },
        {
          \"type\": \"section\",
          \"fields\": [
            {
              \"type\": \"mrkdwn\",
              \"text\": \"*Stack:* \\\`${STACK_NAME}\\\`\"
            },
            {
              \"type\": \"mrkdwn\",
              \"text\": \"*Region:* \\\`${AWS_REGION}\\\`\"
            }
          ]
        }${CUSTOM_FIELD},
        {
          ${ACTIONS}
        }
      ]
    }" && echo "✅ Slack notification sent" || echo "⚠️ Failed to send Slack notification (ignored)"
fi

#==============================================
# EMAIL NOTIFICATION
#==============================================
if [ -n "$NOTIFICATION_EMAIL" ] && [ -n "$NOTIFICATION_EMAIL_FROM" ]; then
  echo "📧 Sending Email notification..."

  # Determine subject and emoji
  case "$STATUS" in
    "started")
      EMOJI="🚀"
      SUBJECT="${EMOJI} ${PROJECT_NAME} [${STAGE}] v${VERSION} - Deploy Iniciado"
      ;;
    "success")
      if [ "$STAGE" == "prd" ]; then
        EMOJI="🎉"
      else
        EMOJI="✅"
      fi
      SUBJECT="${EMOJI} ${PROJECT_NAME} [${STAGE}] v${VERSION} - Deploy Sucesso"
      ;;
    "failed")
      EMOJI="❌"
      SUBJECT="${EMOJI} ${PROJECT_NAME} [${STAGE}] v${VERSION} - Deploy FALHOU"
      ;;
    *)
      EMOJI="ℹ️"
      SUBJECT="${EMOJI} ${PROJECT_NAME} [${STAGE}] v${VERSION} - Update"
      ;;
  esac

  # Determine badge color based on stage
  case "${STAGE}" in
    "dev") BADGE_COLOR="$NIMBLOO_PURPLE" ;;
    "hml") BADGE_COLOR="$NIMBLOO_ORANGE" ;;
    "prd") BADGE_COLOR="$NIMBLOO_DEEP_PURPLE" ;;
    *) BADGE_COLOR="#6b7280" ;;
  esac

  # URLs
  DASHBOARD_URL="https://console.aws.amazon.com/cloudwatch/home?region=${AWS_REGION}#dashboards:name=${STACK_NAME}"
  COMMIT_URL="https://github.com/${GITHUB_REPOSITORY}/commit/${GITHUB_SHA}"
  LOGS_URL="https://github.com/${GITHUB_REPOSITORY}/actions/runs/${GITHUB_RUN_ID}"  
  # Mr. Shipper image (hosted on GitHub)
  MR_SHIPPER_URL="https://raw.githubusercontent.com/Nimbloo/nimbloo-github-actions/master/notify-deploy/mr.shipper.png"


  # Build HTML email
  if [ "$STATUS" == "success" ]; then
    HTML=$(cat <<'HTMLEOF'
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
</head>
<body style="margin: 0; padding: 0; font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, 'Helvetica Neue', Arial, sans-serif; background-color: #f3f4f6;">
  <table width="100%" cellpadding="0" cellspacing="0" style="background-color: #f3f4f6; padding: 40px 20px;">
    <tr>
      <td align="center">
        <table width="600" cellpadding="0" cellspacing="0" style="background-color: #ffffff; border-radius: 12px; box-shadow: 0 10px 25px rgba(100, 40, 120, 0.15); overflow: hidden;">
          <!-- Header with gradient -->
          <tr>
            <td style="background: linear-gradient(135deg, NIMBLOO_PURPLE_PLACEHOLDER 0%, NIMBLOO_DEEP_PURPLE_PLACEHOLDER 100%); padding: 30px 40px; text-align: center;">
              <img src="MR_SHIPPER_URL_PLACEHOLDER" alt="Mr. Shipper" style="width: 80px; height: 80px; border-radius: 50%; border: 3px solid #ffffff; margin-bottom: 15px;">
              <h1 style="margin: 0; font-size: 28px; font-weight: 700; color: #ffffff;">
                EMOJI_PLACEHOLDER Deploy Concluído!
              </h1>
              <p style="margin: 10px 0 0 0; color: rgba(255, 255, 255, 0.9); font-size: 14px;">
                Mr. Shipper fez o ship com sucesso!
              </p>
            </td>
          </tr>
          <tr>
            <td style="padding: 40px;">
              <table width="100%" cellpadding="0" cellspacing="0">
                <tr>
                  <td style="padding-bottom: 25px;" align="center">
                    <div style="background-color: BADGE_COLOR_PLACEHOLDER; padding: 6px 16px; border-radius: 20px; display: inline-block;">
                      <span style="color: #ffffff; font-weight: 700; font-size: 13px; text-transform: uppercase; letter-spacing: 0.5px;">STAGE_PLACEHOLDER</span>
                    </div>
                  </td>
                </tr>
                <tr>
                  <td style="padding-bottom: 30px;">
                    <table width="100%" cellpadding="8" cellspacing="0" style="border: 1px solid #e5e7eb; border-radius: 6px;">
                      <tr style="background-color: #f9fafb;">
                        <td style="font-weight: 600; color: NIMBLOO_PURPLE_PLACEHOLDER; width: 140px; border-right: 1px solid #e5e7eb;">Project</td>
                        <td style="color: #6b7280;"><code style="background-color: #f3f4f6; padding: 2px 6px; border-radius: 3px; font-size: 13px;">PROJECT_NAME_PLACEHOLDER</code></td>
                      </tr>
                      <tr>
                        <td style="font-weight: 600; color: NIMBLOO_PURPLE_PLACEHOLDER; border-right: 1px solid #e5e7eb;">Version</td>
                        <td style="color: #6b7280;"><code style="background-color: #f3f4f6; padding: 2px 6px; border-radius: 3px; font-size: 13px;">VERSION_PLACEHOLDER</code></td>
                      </tr>
                      <tr style="background-color: #f9fafb;">
                        <td style="font-weight: 600; color: NIMBLOO_PURPLE_PLACEHOLDER; border-right: 1px solid #e5e7eb;">Stack</td>
                        <td style="color: #6b7280;"><code style="background-color: #f3f4f6; padding: 2px 6px; border-radius: 3px; font-size: 13px;">STACK_NAME_PLACEHOLDER</code></td>
                      </tr>
                      <tr>
                        <td style="font-weight: 600; color: NIMBLOO_PURPLE_PLACEHOLDER; border-right: 1px solid #e5e7eb;">Region</td>
                        <td style="color: #6b7280;"><code style="background-color: #f3f4f6; padding: 2px 6px; border-radius: 3px; font-size: 13px;">AWS_REGION_PLACEHOLDER</code></td>
                      </tr>
                      <tr style="background-color: #f9fafb;">
                        <td style="font-weight: 600; color: NIMBLOO_PURPLE_PLACEHOLDER; border-right: 1px solid #e5e7eb;">Branch</td>
                        <td style="color: #6b7280;"><code style="background-color: #f3f4f6; padding: 2px 6px; border-radius: 3px; font-size: 13px;">GITHUB_REF_NAME_PLACEHOLDER</code></td>
                      </tr>
                      <tr>
                        <td style="font-weight: 600; color: NIMBLOO_PURPLE_PLACEHOLDER; border-right: 1px solid #e5e7eb;">Deployed by</td>
                        <td style="color: #6b7280;">GITHUB_ACTOR_PLACEHOLDER</td>
                      </tr>
                      <tr style="background-color: #f9fafb;">
                        <td style="font-weight: 600; color: NIMBLOO_PURPLE_PLACEHOLDER; border-right: 1px solid #e5e7eb;">Commit</td>
                        <td style="color: #6b7280;"><a href="COMMIT_URL_PLACEHOLDER" style="color: #3b82f6; text-decoration: none;">COMMIT_SHORT_PLACEHOLDER</a></td>
                      </tr>
                      <tr>
                        <td style="font-weight: 600; color: NIMBLOO_PURPLE_PLACEHOLDER; border-right: 1px solid #e5e7eb;">Timestamp</td>
                        <td style="color: #6b7280; font-size: 13px;">DEPLOY_TIMESTAMP_PLACEHOLDER</td>
                      </tr>
                      <tr style="background-color: #f9fafb;">
                        <td style="font-weight: 600; color: NIMBLOO_PURPLE_PLACEHOLDER; border-right: 1px solid #e5e7eb;">Duration</td>
                        <td style="color: #6b7280;"><code style="background-color: #f3f4f6; padding: 2px 6px; border-radius: 3px; font-size: 13px;">DEPLOY_DURATION_PLACEHOLDER</code></td>
                      </tr>
                    </table>
                  </td>
                </tr>
                <tr>
                  <td style="padding-bottom: 30px;">
                    <div style="background-color: #f0f9ff; padding: 16px; border-radius: 6px; border-left: 3px solid NIMBLOO_PURPLE_PLACEHOLDER;">
                      <p style="margin: 0; color: NIMBLOO_PURPLE_PLACEHOLDER; font-weight: 600; font-size: 12px; text-transform: uppercase; letter-spacing: 0.5px;">💬 Commit Message</p>
                      <p style="margin: 8px 0 0 0; color: #374151; font-size: 14px; line-height: 1.5;">COMMIT_MESSAGE_PLACEHOLDER</p>
                    </div>
                  </td>
                </tr>
                <tr>
                  <td style="padding-top: 10px;" align="center">
                    <table cellpadding="0" cellspacing="0">
                      <tr>
                        <td style="padding: 0 8px;">
                          <a href="DASHBOARD_URL_PLACEHOLDER" style="display: inline-block; background-color: NIMBLOO_PURPLE_PLACEHOLDER; color: #ffffff; padding: 14px 28px; text-decoration: none; border-radius: 8px; font-weight: 600; font-size: 14px;">
                            📊 Dashboard
                          </a>
                        </td>
                        <td style="padding: 0 8px;">
                          <a href="LOGS_URL_PLACEHOLDER" style="display: inline-block; background-color: NIMBLOO_ORANGE_PLACEHOLDER; color: #ffffff; padding: 14px 28px; text-decoration: none; border-radius: 8px; font-weight: 600; font-size: 14px;">
                            📋 Logs
                          </a>
                        </td>
                      </tr>
                    </table>
                  </td>
                </tr>
              </table>
            </td>
          </tr>
          <tr>
            <td style="background-color: #f9fafb; padding: 20px; text-align: center; border-top: 2px solid #e5e7eb;">
              <p style="margin: 0; color: #6b7280; font-size: 12px;">
                <strong style="color: NIMBLOO_PURPLE_PLACEHOLDER;">Nimbloo Platform</strong> · Deploy Automation
              </p>
              <p style="margin: 8px 0 0 0; color: #9ca3af; font-size: 11px;">
                Shipped with ❤️ by Mr. Shipper
              </p>
            </td>
          </tr>
        </table>
      </td>
    </tr>
  </table>
</body>
</html>
HTMLEOF
)
  else
    HTML=$(cat <<'HTMLEOF'
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
</head>
<body style="margin: 0; padding: 0; font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, 'Helvetica Neue', Arial, sans-serif; background-color: #f3f4f6;">
  <table width="100%" cellpadding="0" cellspacing="0" style="background-color: #f3f4f6; padding: 40px 20px;">
    <tr>
      <td align="center">
        <table width="600" cellpadding="0" cellspacing="0" style="background-color: #ffffff; border-radius: 12px; box-shadow: 0 10px 25px rgba(220, 38, 38, 0.15); overflow: hidden;">
          <!-- Header with gradient -->
          <tr>
            <td style="background: linear-gradient(135deg, #dc2626 0%, #991b1b 100%); padding: 30px 40px; text-align: center;">
              <img src="MR_SHIPPER_URL_PLACEHOLDER" alt="Mr. Shipper" style="width: 80px; height: 80px; border-radius: 50%; border: 3px solid #ffffff; margin-bottom: 15px; filter: grayscale(30%);">
              <h1 style="margin: 0; font-size: 28px; font-weight: 700; color: #ffffff;">
                ❌ Deploy Falhou
              </h1>
              <p style="margin: 10px 0 0 0; color: rgba(255, 255, 255, 0.9); font-size: 14px;">
                Algo deu errado no ship...
              </p>
            </td>
          </tr>
          <tr>
            <td style="padding: 40px;">
              <table width="100%" cellpadding="0" cellspacing="0">
                <tr>
                  <td style="padding-bottom: 20px;">
                    <div style="background-color: #fef2f2; padding: 16px; border-radius: 6px; border-left: 3px solid #ef4444;">
                      <p style="margin: 0; color: #991b1b; font-weight: 600;">⚠️ Ação Necessária</p>
                      <p style="margin: 8px 0 0 0; color: #dc2626; font-size: 14px;">O deploy falhou. Verifique os logs para detalhes do erro.</p>
                    </div>
                  </td>
                </tr>
                <tr>
                  <td style="padding-bottom: 30px;">
                    <table width="100%" cellpadding="8" cellspacing="0" style="border: 1px solid #e5e7eb; border-radius: 6px;">
                      <tr style="background-color: #f9fafb;">
                        <td style="font-weight: 600; color: NIMBLOO_PURPLE_PLACEHOLDER; width: 140px; border-right: 1px solid #e5e7eb;">Project</td>
                        <td style="color: #6b7280;"><code style="background-color: #f3f4f6; padding: 2px 6px; border-radius: 3px; font-size: 13px;">PROJECT_NAME_PLACEHOLDER</code></td>
                      </tr>
                      <tr>
                        <td style="font-weight: 600; color: NIMBLOO_PURPLE_PLACEHOLDER; border-right: 1px solid #e5e7eb;">Environment</td>
                        <td style="color: #6b7280;"><code style="background-color: #f3f4f6; padding: 2px 6px; border-radius: 3px; font-size: 13px;">STAGE_PLACEHOLDER</code></td>
                      </tr>
                      <tr style="background-color: #f9fafb;">
                        <td style="font-weight: 600; color: NIMBLOO_PURPLE_PLACEHOLDER; border-right: 1px solid #e5e7eb;">Version</td>
                        <td style="color: #6b7280;"><code style="background-color: #f3f4f6; padding: 2px 6px; border-radius: 3px; font-size: 13px;">VERSION_PLACEHOLDER</code></td>
                      </tr>
                      <tr>
                        <td style="font-weight: 600; color: NIMBLOO_PURPLE_PLACEHOLDER; border-right: 1px solid #e5e7eb;">Branch</td>
                        <td style="color: #6b7280;"><code style="background-color: #f3f4f6; padding: 2px 6px; border-radius: 3px; font-size: 13px;">GITHUB_REF_NAME_PLACEHOLDER</code></td>
                      </tr>
                      <tr style="background-color: #f9fafb;">
                        <td style="font-weight: 600; color: NIMBLOO_PURPLE_PLACEHOLDER; border-right: 1px solid #e5e7eb;">Triggered by</td>
                        <td style="color: #6b7280;">GITHUB_ACTOR_PLACEHOLDER</td>
                      </tr>
                      <tr>
                        <td style="font-weight: 600; color: NIMBLOO_PURPLE_PLACEHOLDER; border-right: 1px solid #e5e7eb;">Commit</td>
                        <td style="color: #6b7280;"><a href="COMMIT_URL_PLACEHOLDER" style="color: #3b82f6; text-decoration: none;">COMMIT_SHORT_PLACEHOLDER</a></td>
                      </tr>
                      <tr style="background-color: #f9fafb;">
                        <td style="font-weight: 600; color: NIMBLOO_PURPLE_PLACEHOLDER; border-right: 1px solid #e5e7eb;">Timestamp</td>
                        <td style="color: #6b7280; font-size: 13px;">DEPLOY_TIMESTAMP_PLACEHOLDER</td>
                      </tr>
                      <tr>
                        <td style="font-weight: 600; color: NIMBLOO_PURPLE_PLACEHOLDER; border-right: 1px solid #e5e7eb;">Duration</td>
                        <td style="color: #6b7280;"><code style="background-color: #f3f4f6; padding: 2px 6px; border-radius: 3px; font-size: 13px;">DEPLOY_DURATION_PLACEHOLDER</code></td>
                      </tr>
                    </table>
                  </td>
                </tr>
                <tr>
                  <td style="padding-bottom: 20px;">
                    <div style="background-color: #f0f9ff; padding: 16px; border-radius: 6px; border-left: 3px solid NIMBLOO_PURPLE_PLACEHOLDER;">
                      <p style="margin: 0; color: NIMBLOO_PURPLE_PLACEHOLDER; font-weight: 600; font-size: 12px; text-transform: uppercase; letter-spacing: 0.5px;">💬 Commit Message</p>
                      <p style="margin: 8px 0 0 0; color: #374151; font-size: 14px; line-height: 1.5;">COMMIT_MESSAGE_PLACEHOLDER</p>
                    </div>
                  </td>
                </tr>
                <tr>
                  <td style="padding-top: 20px;">
                    <a href="LOGS_URL_PLACEHOLDER" style="display: inline-block; background-color: NIMBLOO_ORANGE_PLACEHOLDER; color: #ffffff; padding: 14px 28px; text-decoration: none; border-radius: 8px; font-weight: 600; font-size: 14px;">
                      🔍 Ver Logs de Erro
                    </a>
                  </td>
                </tr>
              </table>
            </td>
          </tr>
          <tr>
            <td style="background-color: #f9fafb; padding: 20px; text-align: center; border-top: 2px solid #e5e7eb;">
              <p style="margin: 0; color: #6b7280; font-size: 12px;">
                <strong style="color: NIMBLOO_PURPLE_PLACEHOLDER;">Nimbloo Platform</strong> · Deploy Automation
              </p>
              <p style="margin: 8px 0 0 0; color: #9ca3af; font-size: 11px;">
                Shipped with ❤️ by Mr. Shipper
              </p>
            </td>
          </tr>
        </table>
      </td>
    </tr>
  </table>
</body>
</html>
HTMLEOF
)
  fi

  # Replace placeholders
  HTML="${HTML//EMOJI_PLACEHOLDER/$EMOJI}"
  HTML="${HTML//BADGE_COLOR_PLACEHOLDER/$BADGE_COLOR}"
  HTML="${HTML//STAGE_PLACEHOLDER/$STAGE}"
  HTML="${HTML//NIMBLOO_PURPLE_PLACEHOLDER/$NIMBLOO_PURPLE}"
  HTML="${HTML//NIMBLOO_DEEP_PURPLE_PLACEHOLDER/$NIMBLOO_DEEP_PURPLE}"
  HTML="${HTML//NIMBLOO_ORANGE_PLACEHOLDER/$NIMBLOO_ORANGE}"
  HTML="${HTML//MR_SHIPPER_URL_PLACEHOLDER/$MR_SHIPPER_URL}"
  HTML="${HTML//PROJECT_NAME_PLACEHOLDER/$PROJECT_NAME}"
  HTML="${HTML//VERSION_PLACEHOLDER/$VERSION}"
  HTML="${HTML//STACK_NAME_PLACEHOLDER/$STACK_NAME}"
  HTML="${HTML//AWS_REGION_PLACEHOLDER/$AWS_REGION}"
  HTML="${HTML//GITHUB_REF_NAME_PLACEHOLDER/$GITHUB_REF_NAME}"
  HTML="${HTML//GITHUB_ACTOR_PLACEHOLDER/$GITHUB_ACTOR}"
  HTML="${HTML//COMMIT_URL_PLACEHOLDER/$COMMIT_URL}"
  HTML="${HTML//COMMIT_SHORT_PLACEHOLDER/$COMMIT_SHORT}"
  HTML="${HTML//DASHBOARD_URL_PLACEHOLDER/$DASHBOARD_URL}"
  HTML="${HTML//LOGS_URL_PLACEHOLDER/$LOGS_URL}"
  HTML="${HTML//DEPLOY_TIMESTAMP_PLACEHOLDER/$DEPLOY_TIMESTAMP}"
  HTML="${HTML//COMMIT_MESSAGE_PLACEHOLDER/$COMMIT_MESSAGE}"
  HTML="${HTML//DEPLOY_DURATION_PLACEHOLDER/$DEPLOY_DURATION}"

  # Create email JSON
  jq -n \
    --arg subject "$SUBJECT" \
    --arg html "$HTML" \
    '{"Subject": {"Data": $subject, "Charset": "UTF-8"}, "Body": {"Html": {"Data": $html, "Charset": "UTF-8"}}}' \
    > /tmp/email.json

  # Send email via SES
  aws ses send-email \
    --from "${NOTIFICATION_EMAIL_FROM}" \
    --destination "ToAddresses=${NOTIFICATION_EMAIL}" \
    --message file:///tmp/email.json \
    --region ${AWS_REGION} && echo "✅ Email notification sent" || echo "⚠️ Failed to send email notification (ignored)"

  rm -f /tmp/email.json
fi

echo "✅ Notification process completed"
