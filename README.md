# GENAI-FORGE-HACKATHON
A Node.js + Express based **Insurance Fraud Detection** API that analyzes insurance claim data from Excel or CSV files and detects potential fraud using risk scoring.
This system allows users to upload claim data, automatically processes and cleans the data, calculates fraud risk scores, and returns detailed analytics including fraud percentage, high-risk users, and sector-wise statistics.
This project is useful for insurance companies, fraud detection systems, risk analysis, and academic research.

## Features
1) Upload Excel (.xlsx, .xls) or CSV files
2) Automatic Excel → CSV conversion
3) Data cleaning and preprocessing
4) Fraud risk score calculation
5) Claim approval / rejection prediction
6) High-risk user detection
7) Sector-wise fraud statistics
8) REST API endpoints
9) File download support
10) Real-time fraud analysis

## Tech Stack
Node.js — Backend runtime
Express.js — Web framework
Multer — File upload handling
XLSX — Excel/CSV processing
CORS — Cross-origin support
JavaScript (ES Modules)

## How the System Works
User uploads claim data file.
System reads Excel or CSV file.
Data is cleaned and normalized.
Fraud risk score calculated using fraud engine.
Claims classified into:
Approved (Low risk)
Pending Review (Medium risk)
Rejected / Fraud (High risk)
Statistics and analytics generated.

## Output Includes
Total claims processed
Fraud percentage
High-risk users list
Clean users list
Pending claims
Sector-wise fraud rate
Risk scores and reasons

## Use Cases
Insurance fraud detection
Risk analysis systems
Data analytics platforms
Financial monitoring systems
Academic projects
Backend API development practice

## Future Improvements
Machine learning fraud prediction
Web dashboard UI
Database integration
Authentication and authorization
Real-time monitoring
Advanced analytics visualization

## Conclusion
This project provides an automated solution for detecting fraudulent insurance claims using data analysis and risk scoring. It helps identify suspicious activities, reduce financial risks, and improve claim verification efficiency through intelligent fraud detection.
