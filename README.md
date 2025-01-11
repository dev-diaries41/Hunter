# Hunter: Bug Bounty Recon and Analysis Script

## Overview

Hunter is an automated recon and bug bounty hunting script designed to streamline subdomain enumeration, HTTP response scanning, vulnerability scanning, and directory fuzzing. The script generates a comprehensive report, and the results can be uploaded to **ChatGPT** or **Hugging Face** for further insights and recommendations.

---

## Table of Contents
1. [Features](#features)
2. [Prerequisites](#prerequisites)
3. [Installing Required Tools](#installing-required-tools)
4. [Usage](#usage)
5. [Outputs](#outputs)
6. [Generating Insights and Next Steps](#generating-insights-and-next-steps)
7. [Disclaimer](#disclaimer)

---


## Features

- **Subdomain Enumeration**: Uses `amass`, `sublist3r`, and `subfinder` to discover subdomains for a target domain.
- **HTTP Response Scanning**: Scans subdomains for HTTP response details with `httpx`.
- **Vulnerability Scanning**: Detects vulnerabilities using `nuclei`.
- **Directory Fuzzing**: Performs directory fuzzing using `ffuf` with customizable wordlists.
- **Comprehensive Report Generation**: Summarizes the findings into a single report.
- **Insight Generation**: Upload the report to **ChatGPT** or **Hugging Face** for further analysis.

---

## Prerequisites

- Tools: `amass`, `sublist3r`, `subfinder`, `httpx`, `nuclei`, `ffuf`.
- Wordlist: Ensure a valid wordlist is available at `./wordlist.txt`.
- `jq`: Used for parsing JSON fuzzing results.

---

## Installing Required Tools

Use the `install_tools.sh` script to automatically install the required tools.

### Steps:
1. **Run the Script**:
   ```bash
   chmod +x install_tools.sh
   ./install_tools.sh
   ```

2. **Verify Installation**:
   ```bash
   amass -h
   sublist3r -h
   subfinder -h
   httpx -h
   nuclei -h
   ffuf -h
   ```

3. **Add Go Tools to PATH** (for Go-based tools):
The script will automatically do this but if you have any issues try doing this.
   ```bash
   export PATH=$PATH:$HOME/go/bin
   ```

---

## Usage

Run the script with the target domain:

```bash
./hunter.sh <domain>
```

Replace `<domain>` with the target domain (e.g., `example.com`).

The script will:
1. Check for required tools.
2. Create an output directory: `recon_<domain>`.
3. Perform subdomain enumeration, HTTP scanning, vulnerability scanning, and directory fuzzing.
4. Generate a final report at `recon_<domain>/final_report.txt`.

---

## Outputs

1. **subdomains.txt**: List of discovered subdomains.
2. **httpx.out**: HTTP response details for each subdomain.
3. **nuclei.out**: Vulnerabilities detected by `nuclei`.
4. **fuzz_<subdomain>.json**: Directory fuzzing results for each subdomain.
5. **final_report.txt**: Comprehensive report summarizing all findings.

---

## Generating Insights and Next Steps

After generating the final report, upload it to **ChatGPT** or **Hugging Face** for further analysis and insights:

1. **Generate Final Report**: The report will be saved at `recon_<domain>/final_report.txt`.
2. **Upload for Analysis**:
   - **ChatGPT**: Upload the report and ask for help with identifying critical vulnerabilities, HTTP misconfigurations, or further recon techniques.
   - **Hugging Face**: Upload the report to a relevant model for vulnerability analysis or suggestion generation.
   
### Example Prompt for ChatGPT:
```text
"I've completed a bug bounty recon on the domain example.com. Here's the final report. Can you help identify critical vulnerabilities and suggest further recon techniques?"
```

---

## Disclaimer

This script is intended for **ethical and educational purposes** only. Ensure you have proper authorization before testing any domain or system. Unauthorized use is prohibited.

---