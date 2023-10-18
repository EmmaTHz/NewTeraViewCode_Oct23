function output_data=substract_bsl(data_str)

baseline_mean=mean(data_str.baseline_td_aligned);

for p=1:length(data_str.reference_td(:,1))
    data_str.reference_td_sub(p,:)=data_str.reference_td_aligned(p,:)-baseline_mean;
    data_str.sample_td_sub(p,:)=data_str.sample_td_aligned(p,:)-baseline_mean;
end

output_data=data_str;