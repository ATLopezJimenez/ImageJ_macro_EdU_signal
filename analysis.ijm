//Ana Teresa Lopez Jimenez macro to quantify Click-IT EdU signal in a bacterial mask.
//Used in manuscript "Proximity biotinylation at the host-bacterial interface reveals UFMylation as an antibacterial pathway".
//Version from Dec 2025
//Serge Mostowy lab, London School of Hygiene and Tropical Medicine


//getting information about the image
dir = getDirectory("image")
name = getTitle()
newname=replace(name, ".tif", "")



//identification of channels
//threshold of DAPI channel was set manually per biological group to account for changes in DAPI fluorescence intensity, with minthreshold between 8000 and 16000
run("Set Measurements...", "area mean standard integrated area_fraction stack display redirect=None decimal=3");
run("Z Project...", "projection=[Max Intensity]");
run("Split Channels");

cDAPI=3;
minthreshold = 12000;
maxthreshold = 65535;
newcDAPI="C" + cDAPI;
print("DAPI channel " + newcDAPI);
print("min thresold " + minthreshold);
print("max threshold " + maxthreshold);
selectWindow(newcDAPI + "-MAX_" + newname + ".tif");
run("Duplicate...", " ");


//doing the mask on DAPI channel, identifying objects
setAutoThreshold("Default dark");
setThreshold(minthreshold, maxthreshold);

run("Convert to Mask");
saveAs("Tiff", dir + newname +"_mask.tif");
run("Analyze Particles...", "size=10-2000 circularity=0.0-1.00 pixel exclude clear add");

roiManager("Deselect"); 
roiManager("Save", dir + newname + "_ROI set.zip");


//selecting the EdU channel
cEdU = "C1"


print("EdU channel " + cEdU);

//create the array
array1 = newArray("0");; 
for (i=1;i<roiManager("count");i++){ 
       array1 = Array.concat(array1,i); 
//       Array.print(array1); 
} 

//measurement in EdU channel
imageEdU = cEdU + "-MAX_" + newname + ".tif";
print(imageEdU);

roiManager("select", array1); 
run("Set Measurements...", "area mean standard integrated area_fraction stack display redirect=[" + imageEdU + "] decimal=3");
roiManager("Measure");
saveAs("Results", dir + newname + "_ResultsEdU.csv");
run("Clear Results");


//measurement in DAPI channel
imageDAPI = newcDAPI + "-MAX_" + newname + ".tif";
print(imageDAPI);

roiManager("select", array1); 
run("Set Measurements...", "area mean standard integrated area_fraction stack display redirect=[" + imageDAPI + "] decimal=3");
roiManager("Measure");
saveAs("Results", dir + newname + "_ResultsDAPI.csv");
run("Clear Results");

//closing and saving remaining windows
run("Close All");
selectWindow("Results");
   run("Close");
selectWindow("ROI Manager");
   run("Close");
selectWindow("Log");
   saveAs("Text", dir + "Log " + newname + ".txt");
   run("Close");
