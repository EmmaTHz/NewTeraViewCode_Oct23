function output_data=teraview_point_main(sample_file,reference_file,baseline_file,...
    interp_multi,cut_point1,cut_point2,inci_angle,window_para,zerofill)

% This function is for processing the teraview point scan data

% sample file: String. Name of the sample data file. e.g.'sample_td.tprj'
% reference file: String. Name of the reference data file. e.g.'reference.tprj'
% baseline file: String. Name of the baseline data file. e.g.'baseline.tprj'
% interp_multi: the magnification of interpolation, usually 1/2/4/8...
% cut_point1: the position between the first two reflections.
% cut_point2: the position between the second and third reflections.
% inci_angle: incident angle from air to quartz window.
% window_para: A parameter for chebyshev window function; The larger the value, the
% narrower the window will be. Usually around 200(default);
% zerofill: Length of the data to do FFT.


%% Check input
if nargin < 8
    zerofill=0;
end
if nargin < 7
    window_para=200;
end

%% Read data
sample=readH5File(sample_file);
reference=readH5File(reference_file);
baseline=readH5File(baseline_file);

%% Interpolation
[mea_num,~]=size(reference);
data_str.time=linspace(reference{1, 1}(1),reference{1, 1}(end),interp_multi.*length(reference{1, 1}));
for p=1:mea_num
    data_str.reference_td(p,:)=spline(reference{p, 1},reference{p, 2},data_str.time);
    data_str.sample_td(p,:)=spline(sample{p, 1},sample{p, 2},data_str.time);
end
[mea_num_bl,~]=size(baseline);
for p=1:mea_num_bl
    data_str.baseline_td(p,:)=spline(baseline{p, 1},baseline{p, 2},data_str.time);
end
data_str.time=data_str.time-data_str.time(1);
clear sample reference baseline

%% Align the signal using the first reflection
data_str=align(data_str,cut_point1);

%% Substract baseline
data_str=substract_bsl(data_str);

%% Cut the signal (if can see the 3rd reflection)
data_str.sample_td_final=data_str.sample_td_sub(:,1:cut_point2);
data_str.reference_td_final=data_str.reference_td_sub(:,1:cut_point2);
data_str.time_final=data_str.time(:,1:cut_point2);

%% Window TD data
data_str=window(data_str,window_para);

%% FFT
data_str=fft_custom(data_str,zerofill);

%% Refractive index and absorption calculation
data_str=alpha_n(data_str,inci_angle);

%% Impulse function
data_str=impulse_ftn(data_str,zerofill);

%% Output
output_data=data_str;