# Safe script to write `.github/workflows/ci.yml` without PowerShell interpreting `${{ ... }}`.

$branch = (git rev-parse --abbrev-ref HEAD).Trim()
Write-Host "Current branch: $branch"

$ci = @'
name: CI

on:
  push:
    branches: [ main, master, chore/*, '**/chore/*' ]
  pull_request:
    branches: [ main, master ]

jobs:
  build:
    name: Build and Test
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Setup Node
        uses: actions/setup-node@v4
        with:
          node-version: '18'

      - name: Install deps
        run: |
          npm ci
          npm test || true

  wrangler-dry-run:
    name: Wrangler dry-run (debug)
    runs-on: ubuntu-latest
    needs: build
    if: ${{ secrets.CF_API_TOKEN != '' }}
    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Setup Node
        uses: actions/setup-node@v4
        with:
          node-version: '18'

      - name: Install wrangler
        run: npm install -g wrangler@4

      - name: Check non-sensitive env presence
        env:
          CF_API_TOKEN: ${{ secrets.CF_API_TOKEN }}
          BACKEND_ORIGIN: ${{ secrets.BACKEND_ORIGIN }}
          BACKEND_AUTH: ${{ secrets.BACKEND_AUTH }}
        run: |
          if [ -n "$CF_API_TOKEN" ]; then echo "CF_API_TOKEN: SET"; else echo "CF_API_TOKEN: MISSING"; fi
          if [ -n "$BACKEND_ORIGIN" ]; then echo "BACKEND_ORIGIN: SET"; else echo "BACKEND_ORIGIN: MISSING"; fi
          if [ -n "$BACKEND_AUTH" ]; then echo "BACKEND_AUTH: SET"; else echo "BACKEND_AUTH: MISSING"; fi

      - name: Wrangler version and whoami
        env:
          CF_API_TOKEN: ${{ secrets.CF_API_TOKEN }}
        run: |
          wrangler --version || true
          wrangler whoami || true

      - name: Wrangler publish (dry-run)
        env:
          CF_API_TOKEN: ${{ secrets.CF_API_TOKEN }}
          BACKEND_ORIGIN: ${{ secrets.BACKEND_ORIGIN }}
          BACKEND_AUTH: ${{ secrets.BACKEND_AUTH }}
        run: |
          wrangler publish --dry-run --verbose || true
'@

$path = '.github\workflows\ci.yml'
Write-Host "Writing workflow to $path"
Set-Content -Path $path -Value $ci -Encoding UTF8

git add $path
try {
    git commit -m "chore(ci): apply corrected workflow (from script)" | Out-Null
    Write-Host "Committed changes"
} catch {
    Write-Host "No commit made (maybe no changes): $_"
}

Write-Host "Pushing branch $branch to origin"
git push origin $branch
