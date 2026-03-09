# Backend Test Task – Rails API

Small Rails 8 API that synchronizes GitHub issues from the `rails/rails` repository, stores them in Postgres, and exposes them via a paginated JSON API.

## Tech stack
- **Ruby**: 4.0.1  
- **Rails**: 8.1  
- **Database**: PostgreSQL
- **Cache**: Redis
- **Background jobs**: Sidekiq  
- **Pagination**: Pagy (keyset)  
- **Tests**: RSpec

## 1. Local setup (without Docker)

**Prerequisites**
- Ruby 4.0.1 installed (e.g. via `rbenv` or `rvm`)
- PostgreSQL running locally
- Redis running locally
- Sidekiq running locally

**Install dependencies**

```bash
bundle install
```

**Configure database**

Create the development and test databases in Postgres:

- `backend_test_development`
- `backend_test_test`

Either:
- Export `DATABASE_URL` / standard Rails env vars, **or**
- Edit `config/database.yml` to match your local credentials.

Then run:

```bash
bin/rails db:setup   # or: bin/rails db:create db:migrate db:seed
```

**Run the test suite**

```bash
bundle exec rspec
```

**Run the server**

```bash
bin/rails server
```

API will be available at `http://localhost:3000`.


## 2. Running with Docker / Docker Compose

From the project root:

```bash
add .env file
docker-compose up --build
```

This will start:
- `web` (Rails API) on port **3001**
- `db` (Postgres)
- `redis`
- `sidekiq` (background jobs)

Once up, the API will be reachable at `http://localhost:3001`.

## 3. Background synchronization job

The job responsible for fetching and storing GitHub issues is:

- `GithubIssuesSynchronizerJob`

It:
- Reads the last processed GitHub issue ID from Redis (`last_issue_id`)
- Fetches issues from the GitHub API via `Github::RailsRepo::Client`
- Parses the payload with `GithubRepoData::ParsingService`
- Persists users and issues with `GithubRepoData::PersistingService`
- Updates `last_issue_id` in Redis

You can enqueue it from the Rails console:

```ruby
GithubIssuesSynchronizerJob.perform_now
```

Sidekiq must be running (see Docker section or run it locally with `bundle exec sidekiq`).


## 4. Issues API

**Endpoint**

```text
GET /api/v1/issues
```

**Query params**
- `state` – optional, filter by GitHub issue state (e.g. `open`, `closed`)

**Response body**
- `issues` – serialized issues with associated user
- `metadata` – Pagy pagination metadata (keyset-based)

**Response header**
- `issues_count` – number of total issues in DB

Example:

```json
{
  "issues": [
    {
      "id": "123",
      "number": 1,
      "state": "open",
      "title": "Issue title",
      "body": "Issue body",
      "user": {
        "id": 1,
        "login": "user1",
        "avatar_url": "https://example.com/avatar",
        "url": "https://api.github.com/users/user1",
        "type": "User"
      },
      "created_at": "2024-01-01T00:00:00Z",
      "updated_at": "2024-01-02T00:00:00Z"
    }
  ],
  "metadata": {
    "...": "pagy metadata fields"
  }
}
```

## 5. Tricks
  
  ### - Github has two kinds of pagination:
  - page pagination based.
  - cursor pagination based.

  By using page pagination based only, you can't get more than 99 pages. if you want page #100 you will get this error.
  ```bash
  result = HTTParty.get("#{BASE_URL}/issues?state=all&page=#{100}&per_page=100", headers: auth_headers)

  => "{\"message\":\"Pagination with the page parameter is not supported for large datasets, please use cursor based pagination (after/before)\",\"documentation_url\":\"https://docs.github.com/rest/issues/issues#list-repository-issues\",\"status\":\"422\"}"
  ```

  So in our case since the issues can be more than that, we need to use page & cursor pagination based.

  ### - Updated rows will not be synced:

  Our system get the old issues first time and then just pull the new issues after that every 5 mins but if any old issue being updated, we will not get this update, so to do that we need to activate the webhook or at least create a job to run once a day to fetch all the issues again and update them.


## 6. Trades off

### Using cron job to get the issues instead of real time due to
- **Api rate limit in github (5k Req/hr).**
- **response time will be longer due to the http call and processing the data to persist into DB.**
- **our api shouldn't depend on the status of github servers.**
- **In real time, user can't jump to page 100 directly(discussed in tricks section).**

## 7. Screenshots

- **GitHub pull request description template**

  ![GitHub PR description template](assets/Screenshot_2.png)

- **CI jobs (lint, security scan, tests)**

  ![CI checks status](assets/Screenshot_3.png)

- **Code coverage (SimpleCov report)**

  ![SimpleCov code coverage report](assets/Screenshot_1.png)

- **Api Call for listing issues**

  ![SimpleCov code coverage report](assets/Screenshot_4.png)

  - **Total count of issues in response header**

  ![SimpleCov code coverage report](assets/Screenshot_5.png)


## 8. Useful commands

- **Run tests**
  ```bash
  bundle exec rspec
  ```

- **Run RuboCop**
  ```bash
  bundle exec rubocop
  ```

- **Run Sidekiq (non‑Docker)**
  ```bash
  bundle exec sidekiq
  ```

## Author

**Mohamed Nabil**

- <https://www.linkedin.com/in/mohamed-nabil-a184125b>
- <https://github.com/mohamednabil00000>
- <https://leetcode.com/mohamednabil00000/>
