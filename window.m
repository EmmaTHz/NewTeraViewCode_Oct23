function output_data=window(data_str,window_para)

data_l=numel(data_str.reference_td_final(1,:))
normal_pos=find(data_str.reference_td_final(1,:)==max(data_str.reference_td_final(1,:)));
window_ftn=chebwin(2*(data_l-normal_pos)+1,window_para);
2*(data_l-normal_pos)+1
2*normal_pos-data_l
size(data_str.sample_td_final(1,2*normal_pos-data_l:end))
output_data=data_str;

m=numel(data_str.sample_td_final(:,1));
for i=1:m
    output_data.sample_process(i,:)=data_str.sample_td_final(i,2*normal_pos-data_l:end);
    output_data.sample_process(i,:)=window_ftn'.*output_data.sample_process(i,:);
    output_data.reference_process(i,:)=data_str.reference_td_final(i,2*normal_pos-data_l:end);
    output_data.reference_process(i,:)=window_ftn'.*output_data.reference_process(i,:);
end 
output_data.time_process=data_str.time(1:2*(data_l-normal_pos)+1);
