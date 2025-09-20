# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Rails 8.0 application called "VibeCoffee" that uses modern Rails patterns and architecture:

- **Framework**: Rails 8.0.2+ with Ruby
- **Database**: SQLite3 with Solid Cache, Solid Queue, and Solid Cable
- **Frontend**: Hotwire (Turbo + Stimulus), Importmap for JavaScript, Propshaft for assets
- **Styling**: Rubocop Rails Omakase for code style
- **Deployment**: Kamal for containerized deployment
- **Testing**: Rails default testing framework with parallel test execution

## Common Development Commands

### Server and Development
- `bin/rails server` or `bin/rails s` - Start development server
- `bin/rails console` or `bin/rails c` - Rails console
- `bin/rails generate` or `bin/rails g` - Generate code (controllers, models, etc.)

### Testing
- `bin/rails test` or `bin/rails t` - Run all tests except system tests
- `bin/rails test:system` - Run system tests
- Run tests in parallel automatically (configured in test/test_helper.rb)

### Database
- `bin/rails db:create` - Create database
- `bin/rails db:migrate` - Run migrations
- `bin/rails db:seed` - Run seeds
- `bin/rails dbconsole` or `bin/rails db` - Database console

### Code Quality
- `bundle exec rubocop` - Run linter (uses Rubocop Rails Omakase)
- `bundle exec brakeman` - Security vulnerability scanner

### Assets
- `bin/rails assets:precompile` - Compile assets for production

## Architecture Notes

### Modern Rails Stack
- Uses Rails 8.0 defaults and modern browser requirements (webp, web push, import maps, CSS nesting)
- Configured for Solid Queue in Puma process (`SOLID_QUEUE_IN_PUMA: true`)
- Uses Importmap for JavaScript dependencies
- Hotwire (Turbo + Stimulus) for SPA-like experience

### Key Configuration
- Application module: `VibeCoffee`
- Autoloads lib directory (ignores assets, tasks subdirectories)
- Modern browser requirement enforced in ApplicationController
- Parallel test execution enabled

### Deployment
- Containerized deployment with Kamal
- Docker image built for amd64 architecture
- Uses persistent volumes for storage
- SSL enabled via Let's Encrypt
- Configured aliases: `console`, `shell`, `logs`, `dbc`

### File Structure
- Standard Rails 8.0 structure
- PWA support available (manifest and service worker views)
- Uses modern Rails conventions throughout

## Development Workflow

When making changes:
1. Run tests with `bin/rails test`
2. Check code style with `bundle exec rubocop`
3. Run security scan with `bundle exec brakeman`
4. Test in browser if UI changes