//Author ; Veeramohan Veerapandian 
//Date; 5 June 2025
// Goal ; Quanfity Nuclei signals OSX, RUNX2 , DAPI, SP7 etc modify accordingly
//inputDir1 = /Volumes/SharedVestAd_LSM980_locAdams/   then your folder in server
//Output dir = Users/...../  your local folder where you want the out put 

// ===================================================================
// Fixed-Slice Projection + normalization macro (25-slice window):
// - Opens each OSX series (only series 0), crops, preprocesses
// - Otsu threshold with inspection + 2D Watershed
// - Determines middle 25 of nSlices, max-projects them
// - Analyze Particles with clear & summarize → Count & TotalArea
// - Normalizes Count per slice (÷ actual # slices used)
// - Writes File, Series, Count, NormCount, TotalArea to CSV  -- didnt work, Save the summary file
// ===================================================================
// Save directory /Users/vveerap/Documents/MPI_Data/Stainings/2025/6566_Dll4lox_Cdh5cre/DLL4_OSX_EMCN/10X_output/OSX_Channel_Quant/


#@ File (style="directory", label="Choose input folder")  inputDir
#@ File (style="directory", label="Choose output folder") saveDir

file_sep = File.separator;
outCSV   = saveDir + file_sep + "OSX_Fixed25norm_Results.csv";
// CSV header
File.saveString("fileName,seriesIndex,count,normC,totalArea\n", outCSV);

run("Bio-Formats Macro Extensions");
processAll(inputDir);
print("Fixed-slice (25 Stacks) Analysis complete save the summary file to output folder , So all went through smoothly - Say Thanks to Veera :P");
function processAll(inputDir) {
    list = getFileList(inputDir);
    for (i = 0; i < list.length; i++) {
        name = list[i];
        full = inputDir + file_sep + name;
        if (File.isDirectory(full) || indexOf(name, "Stitching") < 0) continue;
        Ext.setId(full);
        seriesCount = 0; Ext.getSeriesCount(seriesCount);
        // only process the full-res series (series 0)
        if (seriesCount > 0) {
            proj25norm(full, name, 0);
        }
    }
}

function proj25norm(path, fileName, seriesIndex) {
    // 1) Open & capture title
    run("Bio-Formats Importer",
        "open=["+path+"] view=Hyperstack stack_order=XYCZT series="+seriesIndex+" autoscale color_mode=Composite");
    originalTitle = getTitle();

    // 2) Split & select C2 whatever channels your OSX or RUNX or Nuclear Signal  ;Caution 
    run("Rotate 90 Degrees Right");  //1101-11004  C1 OSX
    run("Split Channels");
//    selectWindow("C2-" + originalTitle);  //1476_1509 C2 OSX
    selectWindow("C1-" + originalTitle); //1106-1109 C1 OSX
//    selectWindow("C4-" + originalTitle); //Von_698 &Von_701T C4 OSX
    // 3) Manual ROI & crop
    makeRectangle(1500,1400,1200,1500);   // 1500,1400 is location in the image you can change or move// 1200 is width 1500 is height
    waitForUser("Adjust ROI, then click OK");
    run("Crop", "stack");

    // 4) Preprocess stack  // Important factor to start with Know your Pixel size > Image ▶ Show Info (Scroll down to end to find the Voxel size and resolution any of them can be used to calculate)
    run("Subtract Background...", "rolling=10 stack"); // can also be determined my average size of the particles (formula is diameter=2× square root of Area(average size)/π if your average size is 25 then pixel size is 5.66 (~6 px) this means the feature average radius in pixel , rolling ball radius = 6 X Resolution ~ then start with 20-30% increased size value ~8-10 and inspect few files)
    run("Despeckle", "stack");
    run("Median...", "radius=1 stack");
    run("Unsharp Mask...", "radius=2 mask=0.60 stack");
    
    
    // 5) Determine middle 25 slices (note the image used  is with stack size 37 <to lower your number of stacks use values corresponding>)
    totalZ = nSlices;
    mid    = floor(totalZ / 2);
    // For 25 slices window, take 12 below and 12 above center slice
    startZ = mid - 12;
    if (startZ < 1) startZ = 1;
    endZ   = startZ + 24; // requried Z slices -1 (25-1=24)
    if (endZ > totalZ) {
        endZ = totalZ;
        startZ = max(1, endZ - 24); // requried Z slices -1 (25-1=24)
    }
    sliceCountUsed = endZ - startZ + 1;

    // 6) Z-Project that window
    run("Z Project...", "start="+startZ+" stop="+endZ+" projection=[Max Intensity]");
//    run("Z Project...", "projection=[Max Intensity]");
//	setMinAndMax(25, 75); //8bits
//	setMinAndMax(12000, 35000); //16bits
    saveAs("Tiff", saveDir + file_sep + fileName + "_S"+seriesIndex+"_proj25.tif");

    // 7) Clear old results
    run("Clear Results");

    // 8) Threshold & inspect
    run("8-bit"); // ensure correct type
    run("Enhance Contrast", "saturated=0.35");

	setAutoThreshold("Otsu dark");
    setOption("BlackBackground", true);
    run("Threshold...");

    waitForUser("Adjust threshold if needed. Red overlay should cover only OSX+ nucle and click OK");
    run("Convert to Mask");

    // 9) 2D watershed
    run("Watershed");
    
    // 10) Particle analysis: clear & summarize
    run("Set Measurements...", "area mean min shape area_fraction display redirect=None decimal=3");
    run("Analyze Particles...", "size=15-Infinity show=Outlines display summarize overlay add"); //display counts in numbers or 
    //run("Analyze Particles...", "size=10-100 show=Outlines display add"); //Display counts but dont summurize
    //run("Analyze Particles...", "size=10-200 show=Nothing clear summarize add");
    
     // 11) Draw the detected-object outlines onto the image
    roiManager("Select All");
	// Now save the TIFF (with outlines baked in)
    saveAs("Tiff", saveDir + file_sep + fileName + "_S"+seriesIndex+"_proj25_outlined.tif");
//    
//    count     = getResult("Count",      0);
//    totalArea = getResult("Total Area", 0);
//    normC     = count / sliceCountUsed;
	// Safely extract values
	if (nResults > 0) {
	    count     = getResult("Count", 0);  //Number of OSX-positive objects detected
	    totalArea = getResult("Total Area", 0);  //Sum of all particle areas (pixels²)
	    normC     = count / sliceCountUsed;   //total counts/25(total slices used in this analysis)
	} else {
  	  count = 0;
 	   totalArea = 0;
  	  normC = 0;
	}
    // 12) Append to CSV
    File.append(fileName + "," + seriesIndex + "," 
                + count + "," + normC + "," + totalArea + "\n", outCSV);

    // 13) Cleanup
    run("Close All");
    roiManager("Reset");
}
