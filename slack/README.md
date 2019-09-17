# Slack integration for niployments

Integrates `niployments` into NIAEFEUP's Slack via `niployments-bot`.

`messaging.sh` exports some useful functions to send Slack messages as this bot.

## Requirements

- `curl`
- [`jq`](https://stedolan.github.io/jq/))

Both are available in `apt`.

## Configuration

Insert the `Bot User OAuth Access Token` in `niployments-bot.slack.token` (which is gitignored, obviously, no secret leaks please).

Using this token instead of the `OAuth Access Token` ensures the messages are sent as the bot and not as the user that allowed the app.

