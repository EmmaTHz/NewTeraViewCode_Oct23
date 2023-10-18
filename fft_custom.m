function output_data=fft_custom(data_str,zerofill)

if zerofill>numel(data_str.sample_process(1,:))
    fft_length=zerofill;
else
    fft_length=numel(data_str.sample_process(1,:));
end

deltaT=data_str.time_process(2)-data_str.time_process(1);
MaxFreq=1/deltaT;
DeltaFreq = MaxFreq/(fft_length-1);
freq = 0:DeltaFreq:MaxFreq;

output_data=data_str;

m=numel(data_str.sample_process(:,1));
for i=1:m
    sample_fd=rfft(data_str.sample_process(i,:),fft_length);
    output_data.sample_fd_mag(i,:)=abs(sample_fd);
    output_data.sample_fd_phase(i,:)=angle(sample_fd);
    reference_fd=rfft(data_str.reference_process(i,:),fft_length);
    output_data.reference_fd_mag(i,:)=abs(reference_fd);
    output_data.reference_fd_phase(i,:)=angle(reference_fd);
    output_data.freq=freq(1:numel(sample_fd));
end 