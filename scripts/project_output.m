% --- SCRIPT 2: REAL-TIME FINAL OUTPUT ---


videoSource = VideoReader('data/deneme_sample.mp4'); 
videoPlayer = vision.VideoPlayer('Name', 'Final Output: Moving Object Detection');


firstFrame = readFrame(videoSource);
backgroundModel = im2double(rgb2gray(firstFrame));
backgroundModel = medfilt2(backgroundModel, [3 3]);


alpha = 0.05;           
thresholdValue = 0.20;
while hasFrame(videoSource)
    colorFrame = readFrame(videoSource);
    
  
    grayFrame = im2double(rgb2gray(colorFrame)); 
    conditioned = medfilt2(grayFrame, [3 3]); 

    diffSignal = abs(conditioned - backgroundModel);
    backgroundModel = (1 - alpha) * backgroundModel + alpha * conditioned;
 
    motionMask = diffSignal > thresholdValue;
   
    cleanMask = imopen(motionMask, strel('disk', 1)); 
    cleanMask = imclose(cleanMask, strel('disk', 12)); 
    
    stats = regionprops(cleanMask, 'BoundingBox', 'Area');
    outFrame = colorFrame;
    
    for i = 1:length(stats)
        if stats(i).Area > 300;
            outFrame = insertShape(outFrame, 'Rectangle', stats(i).BoundingBox, ...
                                   'Color', 'green', 'LineWidth', 3);
        end
    end
    step(videoPlayer, outFrame);
end

release(videoPlayer);