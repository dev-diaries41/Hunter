#!/bin/bash

DOMAIN=$1
OUT_DIR="recon_$DOMAIN"
SUBDOMAIN_LIST="$OUT_DIR/subdomains.txt"
HTTPX_OUT="$OUT_DIR/httpx.out"
NUCLEI_OUT="$OUT_DIR/nuclei.out"
REPORT="$OUT_DIR/final_report.txt"
WORDLIST_PATH="./wordlist.txt"


# Colors for formatting
RED="\e[31m"
GREEN="\e[32m"
CYAN="\e[36m"
ENDCOLOR="\e[0m"

# Ensure ~/go/bin is in PATH
if [[ ":$PATH:" != *":$HOME/go/bin:"* ]]; then
    export PATH=$PATH:$HOME/go/bin
    echo -e "${CYAN}[+] Added ~/go/bin to PATH.${ENDCOLOR}"
fi

check_tools() {
    TOOLS=("amass" "sublist3r" "subfinder" "httpx" "nuclei" "ffuf")
    missing_tools=()
    for tool in "${TOOLS[@]}"; do
        if ! command -v $tool &> /dev/null; then
            echo -e "${RED}[!] $tool is not installed.${ENDCOLOR}"
            missing_tools+=($tool)
        fi
    done

    if [ ${#missing_tools[@]} -gt 0 ]; then
        echo -e "${RED}[!] Missing tools: ${missing_tools[*]}${ENDCOLOR}"
        echo -e "${CYAN}[?] You can install the missing tools by running 'install_tools.sh'.${ENDCOLOR}"
        echo -e "${CYAN}[?] Do you want to continue without these tools? (y/n)${ENDCOLOR}"
        read -p "> " response
        if [[ ! $response =~ ^[Yy]$ ]]; then
            echo -e "${RED}[!] Exiting. Please install the required tools.${ENDCOLOR}"
            exit 1
        fi
    fi
}

setup() {
    mkdir -p $OUT_DIR
    echo -e "${CYAN}[+] Output directory created: $OUT_DIR${ENDCOLOR}"
}

enumerate_subdomains() {
    echo -e "${CYAN}[+] Enumerating subdomains for $DOMAIN...${ENDCOLOR}"
    amass enum -passive -d $DOMAIN > $SUBDOMAIN_LIST
    sublist3r -d $DOMAIN >> $SUBDOMAIN_LIST
    subfinder -d $DOMAIN >> $SUBDOMAIN_LIST
    sort -u $SUBDOMAIN_LIST -o $SUBDOMAIN_LIST
    process_subdomains $DOMAIN
    echo -e "${GREEN}[+] Subdomain enumeration completed. Results saved to $SUBDOMAIN_LIST${ENDCOLOR}"
}

scan_httpx() {
    if command -v httpx &> /dev/null; then
        echo -e "${CYAN}[+] Scanning HTTP responses with httpx...${ENDCOLOR}"
        httpx -l $SUBDOMAIN_LIST -sc -location -title -server -td -ip -t 100 -o $HTTPX_OUT
        echo -e "${GREEN}[+] HTTP scan completed. Results saved to $HTTPX_OUT${ENDCOLOR}"
    else
        echo -e "${CYAN}[+] Skipping HTTP scan. httpx not installed.${ENDCOLOR}"
    fi
}

run_nuclei() {
    if command -v nuclei &> /dev/null; then
        echo -e "${CYAN}[+] Scanning for vulnerabilities using nuclei...${ENDCOLOR}"
        nuclei -l $SUBDOMAIN_LIST -fr -sa -headless -c 100 -o $NUCLEI_OUT
        echo -e "${GREEN}[+] Nuclei vulnerability scan completed. Results saved to $NUCLEI_OUT${ENDCOLOR}"
    else
        echo -e "${CYAN}[+] Skipping Nuclei scan. nuclei not installed.${ENDCOLOR}"
    fi
}

fuzz_directories() {
    if command -v ffuf &> /dev/null; then
        echo -e "${CYAN}[+] Starting directory fuzzing using ffuf...${ENDCOLOR}"

        if [ ! -f "$WORDLIST_PATH" ]; then
            echo -e "${RED}[!] Wordlist not found at $WORDLIST_PATH. Directory fuzzing cannot proceed.${ENDCOLOR}"
            return 1
        fi

        for subdomain in $(cat $SUBDOMAIN_LIST); do
            ffuf -u "$subdomain/FUZZ" -w "$WORDLIST_PATH" -o "$OUT_DIR/fuzz_$(basename $subdomain).json" -mc 200,301,302
            echo -e "${GREEN}[+] Fuzzing results saved for $subdomain${ENDCOLOR}"
        done
    else
        echo -e "${CYAN}[+] Skipping directory fuzzing. ffuf not installed.${ENDCOLOR}"
    fi
}


generate_report() {
    echo -e "${CYAN}[+] Generating final report...${ENDCOLOR}"
    {
        echo "Bug Bounty Recon Report for $DOMAIN"
        echo "Generated on: $(date)"
        echo "======================================"
        echo ""
        echo "===[ Subdomains Found ]==="
        cat $SUBDOMAIN_LIST
        echo ""
        echo "===[ HTTP Responses ]==="
        if [ -f $HTTPX_OUT ]; then
            cat $HTTPX_OUT
        else
            echo "No HTTP scan results."
        fi
        echo ""
        echo "===[ Vulnerabilities Found (Nuclei) ]==="
        if [ -f $NUCLEI_OUT ]; then
            cat $NUCLEI_OUT
        else
            echo "No vulnerabilities found."
        fi
        echo ""
        echo "===[ Fuzzing Results ]==="
        for fuzz_file in $OUT_DIR/fuzz_*.json; do
            echo "Fuzzing results for $(basename $fuzz_file):"
            jq '.results[] | {url, status_code}' $fuzz_file 2>/dev/null || echo "No results found"
            echo ""
        done
    } > $REPORT

    echo -e "${GREEN}[+] Final report saved to $REPORT${ENDCOLOR}"
}

process_subdomains() {
    local domain=$1  # Accept the main domain as a parameter

    if [[ -z "$domain" ]]; then
        echo -e "${RED}[!] Main domain parameter is required!${ENDCOLOR}"
        return 1
    fi
    echo -e "${CYAN}[+] Processing subdomains for domain $domain...${ENDCOLOR}"
    grep -E "\.$domain" $SUBDOMAIN_LIST | sort -u > $OUT_DIR/processed_subdomains.txt
    echo -e "${GREEN}[+] Processed subdomains saved to $OUT_DIR/processed_subdomains.txt${ENDCOLOR}"
}


main() {
    if [ -z "$DOMAIN" ]; then
        echo -e "${RED}[!] Usage: $0 <domain>${ENDCOLOR}"
        exit 1
    fi

    check_tools
    setup
    enumerate_subdomains
    scan_httpx
    run_nuclei
    fuzz_directories
    generate_report

    echo -e "${GREEN}[+] Recon process completed. Check the report at $REPORT${ENDCOLOR}"
}

main