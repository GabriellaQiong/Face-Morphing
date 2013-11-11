% Run script of face morphing for Boys' Day :)
% Written by Qiong Wang at University of Pennsylvania
% Nov. 10th, 2013

% Clear up
clc;
close all;

% Parameters
method        = 'TPS';            % 'tps' or 'triangulation' method
verbose       = false;            % Flag to show intermediate details
morph_rate    = 1/20;             % Morphing rate

% Paths
fullpath        = mfilename('fullpath');
script_dir      = fileparts(fullpath);
images_dir      = fullfile(script_dir, '/headshots/');
points_dir      = fullfile(script_dir, '/points/');
videos_dir      = fullfile(script_dir, '/videos/');
if ~exist(points_dir, 'dir')
    mkdir(points_dir);
end
if ~exist(videos_dir, 'dir')
    mkdir(videos_dir);
end
cd(script_dir);
fid             = fopen([images_dir, 'headshots.txt']);
headshots_files = textscan(fid, '%s', 'delimiter', '\t');
fclose(fid);

for i = 1 : numel(headshots_files{1}) - 1
    % Define file string
    file_string = ['img', num2str(i, '%02d'),'Toimg', num2str(i+1, '%02d')];
    fprintf('Processing Headshots # %02d and # %02d ...\n', i, i + 1);
    
    % Parse the images
    im1 = imread([images_dir, num2str(i, '%02d'), '.jpg']);
    im2 = imread([images_dir, num2str(i + 1, '%02d'), '.jpg']);
    
    % Click correspondence points if there is no saved in the script directory
    pts_file  = fullfile(points_dir,['points_', file_string, '.mat']);
    
    if ~exist(pts_file, 'file')
        [im1_pts, im2_pts] = click_correspondences(im1, im2, verbose);
        im_pts = ( im1_pts + im2_pts ) / 2;
        save(pts_file, 'im1_pts', 'im2_pts', 'im_pts')
    end
    
    if ~exist('im1_pts', 'var') || ~exist('im2_pts', 'var')
        load(pts_file);
    end
    
    % Skip if the video is already exist
    video_file = [videos_dir, 'video_', file_string, '_', method, '.avi'];
    if exist(video_file, 'file')
        continue;
    end
    
    % Image morphing and iterative recording
    if strcmp(method, 'triangulation')
        tri = delaunay(im_pts);
    end
    writerObj = VideoWriter(video_file);
        
    writerObj.FrameRate = 5;
    open(writerObj);
    
    for frac = 0 : morph_rate : 1
        assert(morph_rate < 1 || morph_rate > 0, 'Morph rate should be real number from 0 to 1!')
        fprintf('   Processing step # %02d... \n', round(frac/morph_rate));
        warp_frac     = frac; % min(max(frac, 0), 1);
        dissolve_frac = frac; % min(max(frac, 0), 1);
        if strcmp(method, 'triangulation')
            morphed_im = morph(im1, im2, im1_pts, im2_pts, tri, warp_frac, dissolve_frac);
        else
            morphed_im = morph_tps_wrapper(im1, im2, im1_pts, im2_pts, warp_frac, dissolve_frac);
        end
        imshow(morphed_im); axis image; axis off; drawnow;
        writeVideo(writerObj, getframe(gcf));
    end
    close(writerObj);
    clear writerObj;
end