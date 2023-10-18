function output_data=impulse_ftn(data_str,zerofill)

%Default lower and upper cut-off frequency is set as 0.1THz and 0.6THz
freq_low=0.1;
freq_up=0.6;

L=1/(freq_low*pi);
H=1/(freq_up*pi);

tmax=1/(data_str.freq(2)-data_str.freq(1));
freq=data_str.freq;
Dbl_filter=(exp(-(H*pi)^2.*freq.^2)-exp(-(L*pi)^2.*freq.^2)).*exp(1i.*tmax.*freq.*pi);

if zerofill>numel(data_str.sample_process(1,:))
    fft_length=zerofill;
else
    fft_length=numel(data_str.sample_process(1,:));
end

output_data=data_str;

m=numel(data_str.sample_process(:,1));
for i=1:m
    M_mag=data_str.sample_fd_mag(i,:)./data_str.reference_fd_mag(i,:);
    M_phase=exp(1i.*(data_str.sample_fd_phase(i,:)-data_str.reference_fd_phase(i,:)));
    M=M_mag.*M_phase;
    impulse_fd=M.*Dbl_filter;
    temp.impulse_ftn(i,:)=irfft(impulse_fd,fft_length);
end 

% Resize the impulse function to the length of original signal
orgn_length=numel(data_str.time);
if fft_length>orgn_length
    for i=1:m
        output_data.impulse_ftn(i,:)=temp.impulse_ftn(i,1+floor((fft_length-orgn_length)/2):floor((fft_length-orgn_length)/2)+orgn_length);
    end
else
    for i=1:m
        temp2.impulse_ftn(i,:)=[linspace(0,0,floor((orgn_length-fft_length)/2)),temp.impulse_ftn(i,:)];
        output_data.impulse_ftn(i,:)=[temp2.impulse_ftn(i,:),linspace(0,0,orgn_length-numel(temp2.impulse_ftn(i,:)))];
    end
end

% calculate peak to peak value of impulse function_add by Sarah
for i=1:m
    output_data.impulse_P2P(i,:)=max(output_data.impulse_ftn(i,:))-min(output_data.impulse_ftn(i,:));
end