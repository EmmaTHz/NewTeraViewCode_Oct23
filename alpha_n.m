function output_data=alpha_n(data_str,inci_angle)

n_air=1;
n_window=2.12; 
theta_i=sqrt(1-(sin(inci_angle/180*pi)/n_window)^2); % cos theta topas
theta_air=sqrt(3)/2; % cos theta air
c=299792458; % speed of light in m/s
freq=data_str.freq;

output_data=data_str;

m=numel(data_str.sample_process(:,1));
for i=1:m
    M_mag=data_str.sample_fd_mag(i,:)./data_str.reference_fd_mag(i,:);
%     sigma=25.*10.^(-6);
%     rough_fac=exp(-1/2.*(4.*pi.*sigma.*theta_i.*freq.*10.^12./c).^2);
%     M_mag=data_str.sample_fd_mag(i,:)./data_str.reference_fd_mag(i,:)./rough_fac; %considering the roughness factor
    M_phase=exp(1i.*(data_str.sample_fd_phase(i,:)-data_str.reference_fd_phase(i,:)));
    M=M_mag.*M_phase;
    X=((1+M).*n_air.*n_window.*theta_i.*theta_air+(1-M)*n_window^2*theta_i^2)./((1+M).*n_window.*theta_i+(1-M)*n_air*theta_air);
    % Below are the old equations in Shuting's thesis
%     output_data.n(i,:)=sqrt((real(X)).^2+0.25);
%     theta_sample=real(X)./sqrt(0.25+real(X).^2);
%     output_data.alpha(i,:)=-2*freq*2*pi*10^10/c.*imag(X)./theta_sample;
%     output_data.extinction(i,:)=-imag(X)./theta_sample;
    % These equations are updated by Swench:
    output_data.n(i,:)=real(sqrt(X.^2+0.25));
    output_data.alpha(i,:)=-2*freq*2*pi*10^10/c.*imag(sqrt(X.^2+0.25));
    output_data.M(i,:)=M;
    output_data.M_mag(i,:)=M_mag;
    output_data.M_phase_double(i,:)=data_str.sample_fd_phase(i,:)-data_str.reference_fd_phase(i,:);
end 