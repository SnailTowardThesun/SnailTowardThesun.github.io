#!/bin/bash

# Jekyll Blog Development Script

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if bundle is installed
if ! command -v bundle &> /dev/null; then
    echo -e "${RED}Error: bundler is not installed. Please install it first with:${NC}"
    echo "  gem install bundler"
    exit 1
fi

# Check if gems are installed
if [ ! -f "Gemfile.lock" ]; then
    echo -e "${YELLOW}Installing dependencies...${NC}"
    bundle install
fi

case "${1:-dev}" in
    dev)
        echo -e "${GREEN}Starting development server with LiveReload...${NC}"
        echo -e "${YELLOW}Access: http://localhost:4000${NC}"
        echo -e "${YELLOW}Admin:  http://localhost:4000/admin${NC}"
        bundle exec jekyll serve --livereload --incremental
        ;;
    build)
        echo -e "${GREEN}Building site...${NC}"
        bundle exec jekyll build
        ;;
    clean)
        echo -e "${GREEN}Cleaning build files...${NC}"
        bundle exec jekyll clean
        ;;
    serve)
        echo -e "${GREEN}Starting server...${NC}"
        echo -e "${YELLOW}Access: http://localhost:4000${NC}"
        bundle exec jekyll serve
        ;;
    help)
        echo "Usage: ./bootstrap.sh [command]"
        echo ""
        echo "Commands:"
        echo "  dev     - Start development server with LiveReload (default)"
        echo "  build   - Build the site"
        echo "  serve   - Start server without LiveReload"
        echo "  clean   - Clean build files"
        echo "  help    - Show this help"
        ;;
    *)
        echo -e "${RED}Unknown command: $1${NC}"
        echo "Use './bootstrap.sh help' for usage."
        exit 1
        ;;
esac

