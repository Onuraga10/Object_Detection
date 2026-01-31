% --- SCRIPT 1: GENERATING REPORT FIGURES ---

% 1. Setup
videoSource = VideoReader('data/traffic_sample1.mp4'); % Use your video file
videoSource.CurrentTime = 0; 
refFrame = readFrame(videoSource); % Initial frame B(x,y,t0)

% Move forward to find a frame with a car (e.g., at 2.0 seconds)
videoSource.CurrentTime = 2.0; 
currFrame = readFrame(videoSource);

% --- FIGURE 1: DIMENSIONALITY REDUCTION (RGB to Grayscale) ---
% Citation: "Stereo-to-mono conversion ensures computational efficiency" [cite: 14, 40, 51]
grayFrame = rgb2gray(currFrame);

figure('Name', 'Fig 1: Dimensionality Reduction', 'Position', [100, 100, 800, 400]);
subplot(1,2,1); imshow(currFrame); title('Original Signal (3-Channel RGB)');
subplot(1,2,2); imshow(grayFrame); title('Intensity Signal (1-Channel Grayscale)');

% --- FIGURE 2: SPATIAL FILTERING (Noise Suppression) ---
% Citation: "Median Filter suppresses spatial noise while preserving edges" [cite: 15]
% We add artificial noise just to demonstrate the filter's power for the report
noisyFrame = imnoise(grayFrame, 'salt & pepper', 0.02);
filteredFrame = medfilt2(noisyFrame, [3 3]);

figure('Name', 'Fig 2: Spatial Signal Conditioning', 'Position', [100, 100, 800, 400]);
subplot(1,2,1); imshow(noisyFrame); title('Noisy Signal (Simulated Interference)');
subplot(1,2,2); imshow(filteredFrame); title('Conditioned Signal (Median Filtered)');

% --- FIGURE 3: SUBTRACTION & MASKING (Detection Phase) ---
% Citation: "Temporal signal subtraction and adaptive thresholding" [cite: 17]

% A. Background Model (Simplified as first frame for this static demo)
bgModel = im2double(rgb2gray(refFrame));
bgModel = medfilt2(bgModel, [3 3]);

% B. Current Signal
currSignal = im2double(grayFrame);
currSignal = medfilt2(currSignal, [3 3]);

% C. Difference Signal (Mathematical Subtraction)
diffSignal = abs(currSignal - bgModel);

% D. Binary Mask (Thresholding)
thresholdValue = 0.22; % Tuned for shadow suppression
rawMask = diffSignal > thresholdValue;

% E. Clean Mask (Morphology)
cleanMask = imopen(rawMask, strel('disk', 2));
cleanMask = imclose(cleanMask, strel('disk', 10));

figure('Name', 'Fig 3: Detection Pipeline', 'Position', [50, 50, 1200, 400]);
subplot(1,3,1); imshow(diffSignal * 5); title('1. Temporal Difference Signal');
subplot(1,3,2); imshow(rawMask); title('2. Binary Motion Mask (Thresholded)');
subplot(1,3,3); imshow(cleanMask); title('3. Morphologically Cleaned Mask');