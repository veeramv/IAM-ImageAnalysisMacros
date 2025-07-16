//Author ; Veeramohan Veerapandian 
//Date; 5 June 2025
// Goal ; Adjust Contrast , Merge Channels Output Images with and with Scale bars
//inputDir1 = /Volumes/SharedVestAd_LSM980_locAdams/   then your folder in server
//Output dir = Users/...../  your local folder where you want the out put 

#@ File (style="directory", label="choose input folder") inputDir    //Creates a GUI file‑chooser in the Script Editor for selecting the input directory; 
#@ File (style="directory", label="choose ouput folder") saveDir     //stores result in

file_sep = File.separator;

OSX (inputDir, saveDir);


function OSX (inputDir, saveDir) {
	list = getFileList(inputDir); // get the list of files

	for (i = 0; i < list.length; i++) { //for the files read the filename
		fileName = list[i];
		path = inputDir + file_sep + fileName;  //and path 
		
		if ((indexOf(fileName, "Stitching") != -1)) { // only for the files ends with Stitching ************* Important place to change you file names
			
			//start Bio-Formats extensions and check for number of series
			run("Bio-Formats Macro Extensions");  //Loads the Bio‑Formats macro extensions library (needed for many commands below).
		  	Ext.setId(path); //Tells the Bio‑Formats extension which file to operate on.
			Ext.getSeriesCount(seriesCount);  //Retrieves the number of image series contained in the file into seriesCount (not further used here).
			
			series = 0; // Sets series to zero—i.e., we’ll work on the first image series.
			run("Bio-Formats Importer", "open=[" + path + "] autoscale color_mode=Composite rois_import=[ROI manager]  view=Hyperstack stack_order=XYCZT series_0"); //Imports the image with Bio‑Formats as a hyperstack, auto‑scaled, composite color, loading ROIs, in XYCZT order, series #0.
			
				nameOnly = File.nameWithoutExtension; 
//				run("Z Project...", "projection=[Max Intensity]");
				run("Rotate 90 Degrees Right"); //Rotates the projected image 90° clockwise
				a = getTitle();
				run("Split Channels");
				
				selectImage("C2-" + a); //CD31  
				run("Green");
				run("Despeckle");  //Applies a median‑filter despeckle to remove isolated noise pixels.
				setMinAndMax(6000, 20000);
//				setMinAndMax(20, 150);

				
				selectImage("C1-" + a); //OSX 			
				run("Grays");
				run("Subtract Background...", "rolling=10");  //Subtracts a rolling‑ball background with radius 10 pixels- play around (algorithm to estimate and subtract uneven background illumination)
    			run("Median...", "radius=1");  // Applies a 1‑pixel median filter. If your noise “blobs” are larger (say 2–3 px across), you can bump the radius to 2 or 3. But be cautious: larger radii soften small structures.
    			run("Unsharp Mask...", "radius=2 mask=0.60");  // Sharpens with Unsharp Mask (radius 2, mask 0.6). Estimate your feature width in µm (e.g. cell boundaries are ~2 µm thick).// Mask weight (0.6) can remain the same unless you see oversharpening:
			    //Lower to 0.4–0.5 if halos appear,   Raise toward 0.7–0.8 for stronger pop.
				setMinAndMax(10000, 25000);

				
				selectImage("C4-" + a);//EMCN 
				run("Red");
				run("Despeckle");
				
				setMinAndMax(3000, 12000);
//				setMinAndMax(10, 200);
				run("Enhance Local Contrast (CLAHE)", "blocksize=20 histogram=256 maximum=3 mask=*None*");	// Optional but enhances local contrast, good for 10X and 10 with 0.6x Zoom out
		
				selectImage("C3-" + a);//DAPI
				run("Blue");
				setMinAndMax(3000, 30000); 

//				run("Merge Channels...", "c1=[C1-MAX_"+fileName+"] c3=[C3-MAX_"+fileName+"] create keep");
//				customName1 = "OSXgry_DAPIb_" + nameOnly;
//				run("Scale Bar...", "width=100 height=20 font=100 color=White background=None location=[Lower Right] bold overlay");
//				saveAs("png", saveDir + customName1 + ".png");
//		
//				run("Merge Channels...", "c1=[C1-MAX_"+fileName+"] c4=[C4-MAX_"+fileName+"] create keep");
//				customName1 = "OSXgry_EMCNr_" + nameOnly;
//				run("Scale Bar...", "width=100 height=20 font=100 color=White background=None location=[Lower Right] bold overlay");
//				saveAs("png", saveDir + customName1 + ".png");
//		
//				run("Merge Channels...", "c4=[C4-MAX_"+fileName+"] c3=[C3-MAX_"+fileName+"] create keep");
//				customName1 = "EMCNr_DAPIb_" + nameOnly;
//				run("Scale Bar...", "width=100 height=20 font=100 color=White background=None location=[Lower Right] bold overlay");
//				saveAs("png", saveDir + customName1 + ".png");
//		
//				run("Merge Channels...", "c2=[C2-MAX_"+fileName+"] c3=[C3-MAX_"+fileName+"] create keep");
//				customName1 = "CD31grn_DAPIb_" + nameOnly;
//				run("Scale Bar...", "width=100 height=20 font=100 color=White background=None location=[Lower Right] bold overlay");
//				saveAs("png", saveDir + customName1 + ".png");
//		
				run("Merge Channels...", "c1=[C1-MAX_"+fileName+"] c4=[C4-MAX_"+fileName+"] c2=[C2-MAX_"+fileName+"] create keep");
				customName1 = "OSXgry_EMCNr_CD31grn_" + nameOnly;
				run("Scale Bar...", "width=100 height=20 font=100 color=White background=None location=[Lower Right] bold overlay");
				saveAs("png", saveDir + customName1 + ".png");
//		
//				run("Merge Channels...", "c1=[C1-MAX_"+fileName+"] c4=[C4-MAX_"+fileName+"] c3=[C3-MAX_"+fileName+"] create keep");
//				customName1 = "OSXgry_EMCNr_DAPIb_" + nameOnly;
//				run("Scale Bar...", "width=100 height=20 font=100 color=White background=None location=[Lower Right] bold overlay");
//				saveAs("png", saveDir + customName1 + ".png");
//		

//				run("Merge Channels...", "c1=[C1-MAX_"+fileName+"] c4=[C4-MAX_"+fileName+"] c2=[C2-MAX_"+fileName+"] c3=[C3-MAX_"+fileName+"] create keep");
//				customName1 = "OSXgry_EMCNr_CD31grn_DAPIb_" + nameOnly;
//				run("Scale Bar...", "width=100 height=20 font=100 color=White background=None location=[Lower Right] bold overlay");
//				saveAs("png", saveDir + customName1 + ".png");
		
				run("Merge Channels...", "c4=[C4-MAX_"+fileName+"] c2=[C2-MAX_"+fileName+"] create keep");
				customName1 = "EMCNr_CD31grn_" + nameOnly;
				run("Scale Bar...", "width=100 height=20 font=100 color=White background=None location=[Lower Right] bold overlay");
				saveAs("png", saveDir + customName1 + ".png");

				
				run("Close All");	
			
			}
		}
	}
exit("finished :P :P :P Cheers -Veera :D");	