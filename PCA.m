clear;
fileList = readtable('Task_scenes_list.xlsx','Sheet','Sheet2');

folderPath = 'D:\work@CRNL\Lyon\stimuli\Christina_video_mat_and_scripts';
for i = 1:height(fileList)
    fileName = fileList.matlab_file{i};
    fullPath = fullfile(folderPath,fileName);
    data = load(fullPath);


    % compare the difference between lesxyz and lesxyzsauve --- either
    % lesxyzsauve does NOT exist, or lesxyz is the same as lesxyzsauve
    if isfield(data,'lesxyz')
        if isfield (data,'lesxyzsauve')

            lesxyz = data.lesxyz;
            lesxyzsauve = data.lesxyzsauve;
            fields = fieldnames(lesxyz);
            for s = 1:numel(fields)
                f = fields(s);

                if isfield(lesxyzsauve,f)
                    v1 = lesxyz.(f{1});
                    v2 = lesxyzsauve.(f{1});

                    if isequaln(v1,v2)
                        fprintf('field %s is the SAME \n',f{1})
                    else
                        fprintf('field %s is DIFFERENT \n',f{1})
                    end
                else
                    fprintf('field %s does not exist in lesxyzsauve \n',f);
                end
            end
        else
            fprintf('field lesxyzsauve does NOT exist in data \n');
        end
    else
        fprintf('field lesxyz does NOT exist in data \n');
    end
    % USE lesxyz in the following analysis


    n = length(data.lesxyz);
    coordinate = zeros(n,80);% using the 2D coordinates (or should I use 3D??)
    for s = 1:n
        t = data.lesxyz(s).table(:,1:2);
        coordinate(s,:) = reshape(t',1,[]);
    end

    % check the percentage of NaNs in coordinate
    NaNrows = any(isnan(coordinate),2);
    NaNpercent = (sum(NaNrows)/(size(coordinate,1)))*100;
    fprintf('scene %d: %d %% of the rows have NaNs \n',i,round(NaNpercent));

    % use linear interpolation to deal with NaNs, fill leading and trailing
    % missing values with the nearest nonmissing value in the column
    coordinate_filled = fillmissing(coordinate,'linear','EndValues','nearest');
   
    % PCA for 2 stimuli together
    % normalization before pca??
    [coeff_joint,score_joint,latent_joint] = pca(coordinate_filled);

    % PCA for 1 stimulus separately

end