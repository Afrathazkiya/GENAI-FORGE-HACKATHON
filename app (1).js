import express from 'express';
import multer from 'multer';
import cors from 'cors';
import XLSX from 'xlsx';
import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';
import { calculateRiskScore } from './src/utils/fraudEngine.js';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const app = express();
const PORT = 3001;

// Middleware
app.use(cors());
app.use(express.json());

// Create uploads directory if it doesn't exist
const uploadsDir = path.join(__dirname, 'uploads');
if (!fs.existsSync(uploadsDir)) {
    fs.mkdirSync(uploadsDir);
}

// Configure multer for file uploads
const storage = multer.diskStorage({
    destination: (req, file, cb) => {
        cb(null, uploadsDir);
    },
    filename: (req, file, cb) => {
        const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1E9);
        cb(null, file.fieldname + '-' + uniqueSuffix + path.extname(file.originalname));
    }
});

const upload = multer({
    storage: storage,
    fileFilter: (req, file, cb) => {
        const allowedTypes = ['.xlsx', '.xls', '.csv'];
        const ext = path.extname(file.originalname).toLowerCase();
        if (allowedTypes.includes(ext)) {
            cb(null, true);
        } else {
            cb(new Error('Invalid file type. Only Excel and CSV files are allowed.'));
        }
    }
});

// Helper: Clean currency strings
const cleanCurrency = (val) => {
    if (!val) return 0;
    if (typeof val === 'number') return val;
    let str = String(val).toLowerCase();
    if (str.includes('k')) {
        return parseFloat(str.replace(/[^0-9.-]+/g, '')) * 1000;
    }
    return parseFloat(str.replace(/[^0-9.-]+/g, '')) || 0;
};

// Helper: Case-insensitive column finder
const findColumn = (row, ...keys) => {
    const lowerKeys = keys.map(k => k.toLowerCase());
    const rowKeys = Object.keys(row);
    for (let rk of rowKeys) {
        const lowerRk = rk.toLowerCase().replace(/[^a-z0-9]/g, '');
        if (lowerKeys.includes(lowerRk)) return row[rk];
        for (let k of lowerKeys) {
            if (lowerRk.includes(k)) return row[rk];
        }
    }
    return undefined;
};

// Helper: Parse Excel dates
const parseExcelDate = (val) => {
    if (!val) return null;
    if (typeof val === 'number') {
        const date = new Date(Math.round((val - 25569) * 86400 * 1000));
        return date.toISOString().split('T')[0];
    }
    const date = new Date(val);
    if (!isNaN(date)) return date.toISOString().split('T')[0];
    return null;
};

// Convert uploaded file to CSV and save
const convertToCSV = (filePath, originalName) => {
    const workbook = XLSX.readFile(filePath);
    const sheetName = workbook.SheetNames[0];
    const worksheet = workbook.Sheets[sheetName];

    // Convert to CSV
    const csvData = XLSX.utils.sheet_to_csv(worksheet);

    // Save CSV file
    const csvFileName = originalName.replace(/\.(xlsx|xls)$/i, '.csv');
    const csvPath = path.join(uploadsDir, 'converted-' + Date.now() + '-' + csvFileName);
    fs.writeFileSync(csvPath, csvData);

    return csvPath;
};

// Process data and perform fraud analysis
const processFraudAnalysis = (data) => {
    let totalClaims = 0;
    let fraudCount = 0;
    let approvedCount = 0;
    let pendingCount = 0;
    let highRiskList = [];
    let cleanList = [];
    let pendingList = [];
    let sectorMap = {};

    data.forEach((row, index) => {
        // Universal column mapping
        const rawAmount = findColumn(row, 'amount', 'cost', 'value', 'claim', 'total', 'bill', 'expense', 'loss', 'payout', 'totalclaimamount');
        const rawIncome = findColumn(row, 'income', 'salary', 'annual', 'earnings', 'gains', 'capital', 'pay', 'revenue', 'wealth', 'capitalgains');
        const rawPolicyStart = findColumn(row, 'policystart', 'start', 'bind', 'inception', 'effective', 'joined', 'member', 'enroll', 'since', 'policybinddate');
        const rawIncidentDate = findColumn(row, 'date', 'incident', 'accident', 'loss', 'occurred', 'event', 'happened', 'reported', 'incidentdate');
        const rawTime = findColumn(row, 'time', 'hour', 'when', 'tod', 'clock', 'incidenthouroftheday');
        const rawSector = findColumn(row, 'sector', 'type', 'category', 'insurance', 'module', 'line', 'incidenttype') || 'General';
        const rawZip = findColumn(row, 'zip', 'postal', 'pin', 'location', 'area', 'zone', 'city', 'insuredzip');

        // Data cleaning
        const cleanAmt = cleanCurrency(rawAmount);
        const cleanInc = cleanCurrency(rawIncome);
        const cleanStart = parseExcelDate(rawPolicyStart);
        const cleanDate = parseExcelDate(rawIncidentDate);

        const claimData = {
            vehicleNumber: findColumn(row, 'vehicle', 'number', 'id', 'policynumber') || 'N/A',
            claimAmount: cleanAmt,
            annualIncome: cleanInc || 50000,
            incidentLocation: findColumn(row, 'location', 'city', 'zone', 'incidentcity') || 'Urban',
            zipCode: String(rawZip || '00000'),
            incidentTime: rawTime || '12:00',
            policyStartDate: cleanStart || '2023-01-01',
            incidentDate: cleanDate || '2024-01-01',
            history: findColumn(row, 'history', 'prior', 'claims', 'previous') || 'Clean',
            coverageType: findColumn(row, 'coverage', 'policy', 'plan', 'tier', 'policycsl') || 'Standard',
            preExistingDiseases: findColumn(row, 'medical', 'history', 'preexisting', 'condition') || 'None',
            treatmentType: findColumn(row, 'treatment', 'procedure', 'surgery') || 'General',
            isOccupied: findColumn(row, 'occupied', 'vacant', 'home') || 'Yes'
        };

        const normalizedSector = rawSector.charAt(0).toUpperCase() + rawSector.slice(1).toLowerCase();

        if (!sectorMap[normalizedSector]) {
            sectorMap[normalizedSector] = { name: normalizedSector, total: 0, fraud: 0, pending: 0 };
        }

        const riskResult = calculateRiskScore(claimData, rawSector);

        const resultEntry = {
            id: index,
            name: row['Name'] || row['User'] || findColumn(row, 'name', 'user', 'customer') || `User ${index + 1}`,
            sector: normalizedSector,
            amount: claimData.claimAmount,
            score: riskResult.score,
            riskLevel: riskResult.riskLevel,
            reasons: riskResult.reasons,
            status: riskResult.status,
            color: riskResult.color
        };

        sectorMap[normalizedSector].total++;
        totalClaims++;

        if (riskResult.status === 'Rejected') {
            fraudCount++;
            sectorMap[normalizedSector].fraud++;
            highRiskList.push(resultEntry);
        } else if (riskResult.status === 'Pending Review') {
            pendingCount++;
            sectorMap[normalizedSector].pending++;
            pendingList.push(resultEntry);
        } else {
            approvedCount++;
            cleanList.push(resultEntry);
        }
    });

    const sectorChartData = Object.values(sectorMap).map(s => ({
        name: s.name,
        Fraud: s.fraud,
        Pending: s.pending,
        Clean: s.total - s.fraud - s.pending,
        Total: s.total,
        FraudRate: s.total > 0 ? ((s.fraud / s.total) * 100).toFixed(1) : 0
    }));

    const fraudPercentage = totalClaims > 0 ? ((fraudCount / totalClaims) * 100).toFixed(1) : 0;

    return {
        stats: {
            total: totalClaims,
            fraud: fraudCount,
            approved: approvedCount,
            pending: pendingCount,
            fraudPercent: fraudPercentage
        },
        highRiskUsers: highRiskList,
        cleanUsers: cleanList,
        pendingUsers: pendingList,
        sectorStats: sectorChartData
    };
};

// API Routes

// Health check
app.get('/api/health', (req, res) => {
    res.json({ status: 'ok', message: 'Fraud Detection API is running' });
});

// File upload and analysis endpoint
app.post('/api/upload-analyze', upload.single('file'), (req, res) => {
    try {
        if (!req.file) {
            return res.status(400).json({ error: 'No file uploaded' });
        }

        const filePath = req.file.path;
        const originalName = req.file.originalname;
        const fileExt = path.extname(originalName).toLowerCase();

        console.log(`📁 File received: ${originalName}`);

        let csvPath = filePath;

        // Convert to CSV if it's an Excel file
        if (fileExt === '.xlsx' || fileExt === '.xls') {
            console.log('🔄 Converting Excel to CSV...');
            csvPath = convertToCSV(filePath, originalName);
            console.log(`✅ CSV created: ${csvPath}`);
        }

        // Read the file (CSV or converted CSV)
        const workbook = XLSX.readFile(fileExt === '.csv' ? filePath : csvPath);
        const sheetName = workbook.SheetNames[0];
        const worksheet = workbook.Sheets[sheetName];
        const data = XLSX.utils.sheet_to_json(worksheet);

        console.log(`📊 Processing ${data.length} records...`);

        // Perform fraud analysis
        const analysisResult = processFraudAnalysis(data);

        console.log(`✅ Analysis complete: ${analysisResult.stats.fraud} frauds detected out of ${analysisResult.stats.total} claims`);

        // Clean up uploaded files (optional - keep for audit trail)
        // fs.unlinkSync(filePath);
        // if (csvPath !== filePath) fs.unlinkSync(csvPath);

        res.json({
            success: true,
            fileName: originalName,
            csvPath: csvPath,
            ...analysisResult
        });

    } catch (error) {
        console.error('❌ Error processing file:', error);
        res.status(500).json({ error: 'Failed to process file', details: error.message });
    }
});

// Download CSV endpoint
app.get('/api/download-csv/:filename', (req, res) => {
    try {
        const filename = req.params.filename;
        const filePath = path.join(uploadsDir, filename);

        if (!fs.existsSync(filePath)) {
            return res.status(404).json({ error: 'File not found' });
        }

        res.download(filePath);
    } catch (error) {
        res.status(500).json({ error: 'Failed to download file' });
    }
});

// Start server
app.listen(PORT, () => {
    console.log(`🚀 Fraud Detection API Server running on http://localhost:${PORT}`);
    console.log(`📁 Upload directory: ${uploadsDir}`);
    console.log(`\n📌 Available endpoints:`);
    console.log(`   GET  /api/health`);
    console.log(`   POST /api/upload-analyze`);
    console.log(`   GET  /api/download-csv/:filename`);
});
