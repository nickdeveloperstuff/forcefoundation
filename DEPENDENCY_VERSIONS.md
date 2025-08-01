# Dependency Version Lock Documentation

## Overview

This project uses exact version locking for all dependencies to ensure fully reproducible builds across all environments. All dependencies in `mix.exs` are specified with the `==` operator instead of version ranges.

## Purpose

- **Reproducibility**: Every developer and CI environment will use exactly the same versions
- **Stability**: No automatic updates that could introduce breaking changes
- **Predictability**: Dependencies won't change unless explicitly updated
- **Security**: Controlled update process allows for proper testing before adopting new versions

## Current Locked Dependencies

All dependencies have been locked to their exact versions as of the last update:

### Core Dependencies
- **Elixir**: == 1.15.0
- **ash**: == 3.5.33
- **phoenix**: == 1.8.0-rc.4 (override: true)
- **ecto_sql**: == 3.13.2
- **postgrex**: == 0.21.0

### Ash Framework Extensions
- **ash_admin**: == 0.13.13
- **ash_ai**: == 0.2.9
- **ash_authentication**: == 4.9.9
- **ash_authentication_phoenix**: == 2.10.5
- **ash_cloak**: == 0.1.6
- **ash_events**: == 0.4.3
- **ash_paper_trail**: == 0.5.6
- **ash_phoenix**: == 2.3.12
- **ash_postgres**: == 2.6.14
- **ash_state_machine**: == 0.2.12

### Phoenix & Web Dependencies
- **phoenix_ecto**: == 4.6.5
- **phoenix_html**: == 4.2.1
- **phoenix_live_dashboard**: == 0.8.7
- **phoenix_live_reload**: == 1.6.0 (only: :dev)
- **phoenix_live_view**: == 1.1.2

### Authentication & Security
- **bcrypt_elixir**: == 3.3.2
- **cloak**: == 1.1.4

### Frontend Build Tools
- **esbuild**: == 0.10.0 (runtime: Mix.env() == :dev)
- **tailwind**: == 0.3.1 (runtime: Mix.env() == :dev)
- **heroicons**: github: "tailwindlabs/heroicons", tag: "v2.2.0"

### Other Dependencies
- **bandit**: == 1.7.0
- **dns_cluster**: == 0.2.0
- **gettext**: == 0.26.2
- **igniter**: == 0.6.25
- **jason**: == 1.4.4
- **lazy_html**: == 0.1.3 (only: :test)
- **picosat_elixir**: == 0.2.3
- **req**: == 0.5.15
- **sourceror**: == 1.10.0
- **swoosh**: == 1.19.5
- **telemetry_metrics**: == 1.1.0
- **telemetry_poller**: == 1.3.0
- **tidewave**: == 0.2.0 (only: [:dev])
- **usage_rules**: == 0.1.23

## How to Update Dependencies

When you need to update a dependency, follow these steps:

1. **Identify the dependency** that needs updating and check for breaking changes in its changelog

2. **Update the version** in `mix.exs`:
   ```elixir
   # Change from:
   {:phoenix, "== 1.8.0-rc.4", override: true},
   # To:
   {:phoenix, "== 1.8.0", override: true},
   ```

3. **Clean and fetch dependencies**:
   ```bash
   mix deps.clean --all
   mix deps.get
   ```

4. **Test thoroughly**:
   ```bash
   mix test
   mix compile --warnings-as-errors
   ```

5. **Update this documentation** with the new version number

6. **Commit both files**:
   ```bash
   git add mix.exs mix.lock DEPENDENCY_VERSIONS.md
   git commit -m "Update [dependency_name] to version X.Y.Z"
   ```

## Important Notes

- The `mix.lock` file still exists and provides additional verification of exact versions
- Git-based dependencies (like heroicons) remain pinned to specific tags/commits
- Development and test-only dependencies are still marked with their appropriate environments
- Runtime conditions for build tools (esbuild, tailwind) are preserved

## Version History

- **Initial Lock**: All dependencies locked to exact versions as found in mix.lock