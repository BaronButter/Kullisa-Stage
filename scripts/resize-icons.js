/**
 * Kullisa Labs - Icon Resizer
 * Konvertiert das 500x500 PNG in 150x150 und 70x70 Varianten
 */

const fs = require('fs');
const path = require('path');

// Using sharp for high-quality image resizing
const sharp = require('sharp');

async function resizeImage(inputPath, outputPath, width, height) {
    try {
        await sharp(inputPath)
            .resize(width, height, {
                fit: 'contain',
                background: { r: 0, g: 0, b: 0, alpha: 0 }
            })
            .png()
            .toFile(outputPath);
        
        console.log(`✓ Created: ${outputPath} (${width}x${height})`);
    } catch (error) {
        console.error(`✗ Error creating ${outputPath}:`, error.message);
        process.exit(1);
    }
}

async function main() {
    const inputFile = 'kullisa logo 500x500.png';
    const outputDir = 'src/stable/resources/win32';
    
    // Ensure output directory exists
    if (!fs.existsSync(outputDir)) {
        fs.mkdirSync(outputDir, { recursive: true });
    }
    
    console.log('Resizing Kullisa logo...');
    console.log(`Input: ${inputFile}`);
    
    // Create 150x150
    await resizeImage(inputFile, path.join(outputDir, 'code_150x150.png'), 150, 150);
    
    // Create 70x70
    await resizeImage(inputFile, path.join(outputDir, 'code_70x70.png'), 70, 70);
    
    console.log('\n✓ All icons resized successfully!');
}

main();
