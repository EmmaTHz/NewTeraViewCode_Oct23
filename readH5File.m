function [ samples, references, sampleNameList, metadataStruct, baselines ] ...
    = readH5File( path_to_file, skipSamples )
%READH5FILE This function read an H5, which was acquired by the Terapulse
%4000. 

% Define list of attributes to skip
% Especially define attributes which are null to avoid an error during the
% reading of the attribute.
metaDataSkipList = {'DataType','DbMeasID','HasRef','IsRef','MeasStatus',...
    'OldSettings','TagName','MeasToken','scanner_config','scanner_name',...
    'SystemScanSettings','ClassName','MotorPosition',...
    'UniqueID','module_name','split_directions','XAxisUnits',...
    'RSDLAmp','SplitDirections','EncoderPosition','id','coaverages',...
    'CurrRsdlUnits','repeats','delay','sweep_speed','sample_spacing'};

% Define list of attributes which should be converted to character.
metaDataCharList = {'ClassName','EncoderPosition','MotorPosition',...
    'OrigSampleName','SampleName',...
    'SystemScanSettings','UniqueName','UserScanSettings'};

% Check if the file exists
if exist(path_to_file,'file')

    % open the file
    fid = H5F.open(path_to_file);

    % open the group
    gid = H5G.open(fid,['TerapulseDocument/Measurements/Spectra Data']);
%     gid = H5G.open(fid,['TerapulseDocument',filesep,'Measurements',filesep,'Spectra Data']);
    
    % Get list of sample names
    [~,~,opdata_out] = H5L.iterate(gid,'H5_INDEX_NAME','H5_ITER_INC',[],@iterFunc,{[]});
    
    % Remove the empty cells
    sampleList = opdata_out(~cellfun('isempty',opdata_out));
    
    % Get number of samples
    nSamples = length(sampleList);
    
    % Create the cell for the data
    samples = cell(nSamples,2);
    references = cell(nSamples,2);
    baselines = cell(nSamples,2);
    
%     attrWfmLength = 'WfmLength';

    sampleNameList = cell(nSamples,1);
    metaDataList = cell(nSamples,1);
    
%     if nargin > 1
%         nSamples = 1;
%     end
    
    for sample_i = 1:nSamples
        
        if nargin > 1
            sample_i = nSamples;
        end
        
        % Open sample group
        gid = H5G.open(fid,...
            ['TerapulseDocument/Measurements/Spectra Data/',...
            cell2mat(sampleList(sample_i))]);
        
        [~,~,opdata_out] = H5L.iterate(gid,'H5_INDEX_NAME', 'H5_ITER_INC',[],@iterFunc,{[]});
        
        % Get the list of measurements
        measurementList = opdata_out(~cellfun('isempty',opdata_out));  
        referenceFlag = strcmp(measurementList,'reference');
        baselineFlag = strcmp(measurementList,'baseline');
        
        measurementList = measurementList(~strcmp(measurementList,...
            'Current Reference'));
        measurementList = measurementList(~strcmp(measurementList,...
            'reference'));
        
        measurementList = measurementList(~strcmp(measurementList,...
            'baseline'));
        
        sampleNameList{sample_i} = measurementList;

        % Get number of measurements
        nMeasurements = length(measurementList);
      
        % TODO: What happens when we have more than one measurement?
        for measurement_i = 1:nMeasurements
            %MIKE CHANGE - GET NAMES AND PUT THEM IN DATASET
            %ADJUST CELL INDEX FOR OTHER VALUES (X AND Y)
            samples{sample_i,1} = measurementList(measurement_i);
            
            % Read measurements
            dset_id = H5D.open(gid,...
                [cell2mat(measurementList(measurement_i)),'/xdata']);
            samples{sample_i,2} = H5D.read(dset_id);

            dset_id = H5D.open(gid,...
                [cell2mat(measurementList(measurement_i)),'/ydata']);
            samples{sample_i,3} = H5D.read(dset_id);

            % Read measurements
            dset_id = H5D.open(gid,...
                [cell2mat(measurementList(measurement_i)),'/xdata']);
            samples{sample_i,1} = H5D.read(dset_id);

%            dset_id = H5D.open(gid,...
            % Read measurements
            dset_id = H5D.open(gid,...
                [cell2mat(measurementList(measurement_i)),'/xdata']);
            samples{sample_i,1} = H5D.read(dset_id);

            dset_id = H5D.open(gid,...
                [cell2mat(measurementList(measurement_i)),'/ydata']);
            samples{sample_i,2} = H5D.read(dset_id);
                 
            % Read attributes
            % Open group to read the number of attrbutes
            gidLoc = H5G.open(fid,...
                ['TerapulseDocument/Measurements/Spectra Data/',...
                cell2mat(sampleList(sample_i)),'/',cell2mat(measurementList(measurement_i))]);

            info = H5O.get_info(gidLoc);
            
            % Open parent group to iterate all attributes 
            gidLoc = H5G.open(fid,...
                ['TerapulseDocument/Measurements/Spectra Data/',...
                cell2mat(sampleList(sample_i))]);
            
            % Save all attributes in the metadata struct
            metadata = struct();
            
            % Iterate the attributes
            for idx = 0:info.num_attrs-1
                attr_id = ...
                    H5A.open_by_idx(gidLoc,...
                    cell2mat(measurementList(measurement_i)),...
                    'H5_INDEX_NAME','H5_ITER_DEC',idx);
                
                strSkipList = strfind(metaDataSkipList,H5A.get_name(attr_id));
                strCharList = strfind(metaDataCharList,H5A.get_name(attr_id));

                % Skip some tags
                if all(cellfun('isempty',strSkipList))                        
                    % Convert some attributes to char (given as ASCII)
                    if any(~cellfun('isempty',strCharList))
                        if strcmp(H5A.get_name(attr_id),'UserScanSettings')
                            tmpStr = char(H5A.read(attr_id));
    %                         quotMark = strfind(tmpStr,'"');
                            comma = strfind(tmpStr,',');
                            colon = strfind(tmpStr,':');

                            for attr_i = 1:length(comma)
                                if attr_i == 1
                                    eval(['metadata.',...
                                        tmpStr(3:...
                                        colon(attr_i)-2),...
                                        ' = ',tmpStr(colon(attr_i)+1:...
                                        comma(attr_i)-1),';']);    
                                else                                  
                                    attr = tmpStr(comma(attr_i-1)+1:...
                                        comma(attr_i)-1);
                                    idxQuotMark = strfind(attr,'"');
                                    
                                    if length(idxQuotMark) < 2
                                       continue; 
                                    end
                                    attrName = attr(idxQuotMark(1)+1:idxQuotMark(2)-1);

                                    strSkipListAtt = strfind(metaDataSkipList,attrName);
                                    if all(cellfun('isempty',strSkipListAtt))
                                        value = attr(idxQuotMark(2)+2:end);
                                        if length(idxQuotMark) < 3
                                            bracketStr = strfind(value,'}');
                                            idx = [1 length(value)];
                                            if ~isempty(bracketStr)
                                                idx(2) = idx(2)-1;
                                            end
                                            bracketStr = strfind(value,'{');
                                            if ~isempty(bracketStr)
                                                idx(1) = idx(1)+1;
                                            end
                                            eval(['metadata.',attrName,...
                                                ' = ',value(idx(1):idx(2)),';']);
                                        else
                                            eval(['metadata.',attrName,...
                                                ' = value(2:end-1);']);
                                        end    
                                    end
                                end
                            end    
                        else    
                            eval(['metadata.',H5A.get_name(attr_id),' = char(H5A.read(attr_id));']);
                            if strcmp(H5A.get_name(attr_id),'SampleName')
                                sampleName = char(H5A.read(attr_id));
                            end
                        end
                    end
                end
                H5A.close(attr_id);
            end
            
            metaDataList{sample_i} = metadata;
            sampleNameList{sample_i} = {sampleName};
            
            H5G.close(gidLoc);
        end
        
        % Close group
        H5G.close(gid);
        
        % Read the reference
        if any(referenceFlag)
            % Open sample group
            gid = H5G.open(fid,...
                ['TerapulseDocument/Measurements/Spectra Data/',...
                cell2mat(sampleList(sample_i)),'/reference']);

            [~,~,opdata_out] = H5L.iterate(gid,'H5_INDEX_NAME', ...
                'H5_ITER_INC',[],@iterFunc,{[]});
            
            refList = opdata_out(~cellfun('isempty',opdata_out));
            if length(refList) > 1
                warning(['There is more than one reference for sample ',...
                    cell2mat(sampleList(sample_i))]);
            end
            
            dset_id = H5D.open(gid,...
                [cell2mat(refList(1)),'/xdata']);
            references{sample_i,1} = H5D.read(dset_id);

            dset_id = H5D.open(gid,...
                [cell2mat(refList(1)),'/ydata']);
            references{sample_i,2} = H5D.read(dset_id);
            
            % Close group
            H5G.close (gid);
%         else
%             warning(['There is no reference for sample ',...
%                     cell2mat(sampleList(sample_i))]);
        end
    end
    
    % Read the reference
    if any(baselineFlag)
        % Open sample group
        gid = H5G.open(fid,...
            ['TerapulseDocument/Measurements/Spectra Data/',...
            cell2mat(sampleList(sample_i)),'/baseline']);
        
        [~,~,opdata_out] = H5L.iterate(gid,'H5_INDEX_NAME', ...
            'H5_ITER_INC',[],@iterFunc,{[]});
        
        baseList = opdata_out(~cellfun('isempty',opdata_out));
        if length(baseList) > 1
            warning(['There is more than one baseline for sample ',...
                cell2mat(sampleList(sample_i))]);
        end
        
        dset_id = H5D.open(gid,...
            [cell2mat(baseList(1)),'/xdata']);
        baselines{sample_i,1} = H5D.read(dset_id);
        
        dset_id = H5D.open(gid,...
            [cell2mat(baseList(1)),'/ydata']);
        baselines{sample_i,2} = H5D.read(dset_id);
        
        % Close group
        H5G.close (gid);
    else
        warning(['There is no baseline for sample ',...
            cell2mat(sampleList(sample_i))]);
    end
    
    metadataStruct = struct();

    for sample_i = 1:length(metaDataList)
        eval(['metadataStruct.',matlab.lang.makeValidName(char(sampleNameList{sample_i})),...
            ' = metaDataList{sample_i};']);   
    end   
       
    % Close file
    H5F.close (fid);
else
    error('File does not exist!')
end

end

%% OLD
    %  Read reference
%     gid = H5G.open(fid,['TerapulseDocument',filesep,'Measurements',filesep,'Ref Data']);
%     
%     [status,idx_out,opdata_out] = H5L.iterate(gid,'H5_INDEX_NAME', 'H5_ITER_INC',[],@iterFunc,{[]});
%     
%     % Get the list of measurements
%     refList = opdata_out(~cellfun('isempty',opdata_out));
    
    % Reference
%     reference = cell(1,2);
%     
%     if ~isempty(refList)
%         gid = H5G.open(fid,['TerapulseDocument',filesep,'Measurements',filesep,'Ref Data']);
% 
%         dset_id = H5D.open(gid,[cell2mat(refList(1)),filesep,'REF_0',filesep,'xdata']);
%         reference{1,1} = H5D.read(dset_id);
% 
%         dset_id = H5D.open(gid,[cell2mat(refList(1)),filesep,'REF_0',filesep,'ydata']);
%         reference{1,2} = H5D.read(dset_id);
%     else
%         warning('No reference was found!')
%         reference{1,1} = nan(1,1);
%         reference{1,2} = nan(1,1);
%     end
