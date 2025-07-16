# 🧬 IAM – Image Analysis Macros

**Author:** Veeramohan Veerapandian  
**Date:** 5 June 2025  

---

## 📋 Repository Contents

- **macros/**
  - `merge_channels.ijm` – Adjust contrast and merge multi-channel images
  - `quantify_nuclei.ijm` – Quantify OSX/RUNX2/DAPI/SP7-like nuclear signals
- **examples/** – Optional: sample input images (upload `.tif` files)
- **results/** – Example outputs (merged PNGs or TIFFs and quantification CSV in `.csv`)
- **README.md** – This documentation file

---

## 1️⃣ Merge Channels Macro (`merge_channels.ijm`)

**Purpose:**  
- Adjust contrast, clean up images per channel (OSX, EMCN, CD31, DAPI)  
- Merge selected channels and add a scale bar  
- Save composite outputs

**Workflow Highlights:**
1. Prompts for **input** and **output** directories  
2. Imports only files with `"Stitching"` in the name using Bio‑Formats  
3. Rotates, splits, enhances each channel:
   - **C1 (OSX)** → Grayscale, sharpened  
   - **C2 (CD31)** → Green, despeckled  
   - **C4 (EMCN)** → Red, local contrast enhanced  
   - **C3 (DAPI)** → Blue  
4. Generates merged output channels like `OSX/EMCN/CD31` and `EMCN/CD31` with scale bar  
5. Saves PNGs to output folder

---

## 2️⃣ Quantify Nuclei Macro (`quantify_nuclei.ijm`)

**Purpose:**  
- Quantify nuclear signals (e.g., OSX, RUNX2, DAPI, SP7) from stacked image series

**Workflow Highlights:**
1. Prompts for **input** and **output** directories  
2. Iterates over files with `"Stitching"`  
3. Uses Bio‑Formats to import series 0  
4. Crops a user-selected ROI and preprocessing:
   - Background subtraction, despeckle, median + unsharp mask  
5. Selects the **middle 25 slices**, performs a maximum-Z projection  
6. Saves the projection TIFF  
7. Converts to 8-bit, enhances contrast, applies Otsu threshold, then watershed  
8. Detects particles, outlines them, saves outlined TIFF  
9. Counts objects, calculates normalized counts, and total area per slice  
10. Logs metrics (`fileName, seriesIndex, count, normC, totalArea`) into `OSX_Fixed25norm_Results.csv` in the output folder

---

## 🧮 Usage Guide

1. Open either macro in **Fiji/ImageJ** (Plugins → Macros → Run… or Script Editor → Run)
2. Select the **input directory** (network or shared folder)
3. Select the **output directory** (local)
4. Let the script process images:
   - *merge_channels* → PNG images with scale bars
   - *quantify_nuclei* → TIFFs and a CSV summary

---

## 📄 Example Outputs

*(Upload these once you have sample data)*

- `merge_channels` results:  
  - `OSXgry_EMCNr_CD31grn_filename.png`  
  - `EMCNr_CD31grn_filename.png`

- `quantify_nuclei` results:  
  - TIFF projection: `_proj25.tif`  
  - Outlined TIFF: `_proj25_outlined.tif`  
  - CSV summary: `OSX_Fixed25norm_Results.csv`

---

## ⚙️ Requirements & Setup

- **Fiji (ImageJ)** with **Bio-Formats Macro Extensions** plugin installed  
- Customize channel selection logic (`selectWindow("C1-…")`, etc.) and thresholds as needed  
- Adjust `'Stitching'` filename filter if your naming convention differs  
- For `quantify_nuclei`, modify ROI size and slice-window parameters based on your data

---

## 📝 Tips & Troubleshooting

- Before running in batch, **run on one image** to validate results  
- Adjust `rolling`, `median`, and `unsharp` values to match your image quality  
- For `quantify_nuclei`, examine the overlay to ensure nuclei are correctly detected before saving

---

## 📜 License & Citation

This work is shared for academic and research use only. Please credit the author if used or modified in published work.

---

## 🙋‍♂️ Contact
**Veeramohan Veerapandian**  
Social: www.linkedin.com/in/dr-veeramohan-veerapandian-388b3217 | https://bsky.app/profile/veeramp.bsky.social |  https://x.com/VeeramohanV 

