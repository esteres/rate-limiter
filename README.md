# README

# Rate Limiter API — Assessment Guide

This project demonstrates a simple rate-limiting mechanism for authenticated API requests using **Ruby on Rails** and **Redis**.

## Requirements

- Ruby (3.x)
- Rails (6 or 7)
- Redis (running locally)
- curl

---

## Running with Dev Containers (VS Code)

This project includes a [**Development Container**](https://code.visualstudio.com/docs/devcontainers/containers) configuration, so you can get up and running instantly using **Visual Studio Code**.

### What You Need

- [Visual Studio Code](https://code.visualstudio.com/)
- [Dev Containers extension](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers)
- [Docker](https://www.docker.com/) installed and running

### How to Run

1. Open the project folder in Visual Studio Code.
2. When prompted, click **“Reopen in Container”**.
3. VS Code will build the development environment using the included `.devcontainer` configuration.
4. Once it's ready, you can start testing the api.

## Manual Setup (Without Dev Container)

If you're **not using the Dev Container**, you can set up and run the API locally by executing the following command:

```bash
bin/setup
```

### Goal

Limit users to **3 requests per 30 seconds**, using a **sliding time window** — meaning the limit is evaluated over a moving time frame, not fixed blocks.

---

### How It Works

I used **Redis sorted sets (`ZSET`)** to implement the sliding window logic. Here's the step-by-step breakdown of what happens when a request is made:

1. **Store current timestamp**
   Each time a user sends a request, the current time (as a float) is added to a sorted set:
   ```ruby
   $redis.zadd("rate_limit:user:#{user.id}", Time.now.to_f, Time.now.to_f)
   ```

2. **Remove expired entries**
   I remove all entries older than 30 seconds from the set:
   ```ruby
   $redis.zremrangebyscore("rate_limit:user:#{user.id}", 0, Time.now.to_f - 30)
   ```

3. **Check how many requests remain**
   I count how many entries are still in the set — this represents how many requests the user has made in the last 30 seconds:
   ```ruby
   request_count = $redis.zcard("rate_limit:user:#{user.id}")
   ```

4. **Allow or block the request**

  - If the count is 3 or fewer, the request is allowed.

  - If the count is more than 3, the request is blocked with:

  - HTTP status: 429 Too Many Requests

  - JSON error message: { "error": "Rate limit exceeded" }


### How to test it

## 1. Create a User Account (Sign Up)

Before testing rate limits, you need to create a user account.

```bash
curl --header "Content-Type: application/json" \
  --data '{"user": {"username": "username", "password": "SecurePassword!1@"}}' \
  http://localhost:3000/api/v1/signup -v
```

## 2. Authenticate and Get Your Token

Use your credentials to obtain a JWT token.

```bash
curl --header "Content-Type: application/json" \
  --data '{"username": "username", "password": "SecurePassword!1@"}' \
  http://localhost:3000/api/v1/authenticate -v
```

Sample response:

```json
{
  "token": "your.jwt.token.here"
}
```

Copy this token for the next step.


## 3. Test the Rate-Limited Endpoint

First 3 Requests — Allowed

```bash
curl -H "Authorization: Bearer your jwt.token.here" \
  http://localhost:3000/api/v1/rate_limit_test
```

Repeat the request 3 times within 30 seconds.

Expected response:

```json
{
  "status": "allowed"
}
```

4th Request — Blocked

Send a 4th request (within the same 30-second window):

```bash
curl -H "Authorization: Bearer your.jwt.token.here" \
  http://localhost:3000/api/v1/rate_limit_test
```

Expected response:

```json
{ "error": "Rate limit exceeded" }
```

HTTP status: 429 Too Many Requests

