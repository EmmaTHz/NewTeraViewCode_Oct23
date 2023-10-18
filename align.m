function output_data=align(data_str,cut_point)

%% use the maximum point of the first reflection to align the signal
% % align baseline
% for p=1:length(data_str.baseline_td(:,1))
%     pos_bl(p)=find(data_str.baseline_td(p,1:cut_point)...
%         ==max(data_str.baseline_td(p,1:cut_point)));
%     diff_bl(p)=pos_bl(p)-pos_bl(1);
%     if diff_bl(p)<0
%         data_str.baseline_td_aligned(p,:)=[zeros(1,-diff_bl(p)),...
%             data_str.baseline_td(p,1:end+diff_bl(p))];
%     else
%         data_str.baseline_td_aligned(p,:)=...
%             [data_str.baseline_td(p,diff_bl(p)+1:end),zeros(1,diff_bl(p))];
%     end
% end
% data_str.pos_bl=pos_bl;
% % align the reference
% for p=1:length(data_str.reference_td(:,1))
%     pos_ref(p)=find(data_str.reference_td(p,1:cut_point)...
%         ==max(data_str.reference_td(p,1:cut_point)));
%     diff_ref(p)=pos_ref(p)-pos_bl(1);
%     if diff_ref(p)<0
%         data_str.reference_td_aligned(p,:)=[zeros(1,-diff_ref(p)),...
%             data_str.reference_td(p,1:end+diff_ref(p))];
%     else
%         data_str.reference_td_aligned(p,:)=...
%             [data_str.reference_td(p,diff_ref(p)+1:end),zeros(1,diff_ref(p))];
%     end
% end
% data_str.pos_ref=pos_ref;
% % align the sample
% for p=1:length(data_str.sample_td(:,1))
%     pos_sample(p)=find(data_str.sample_td(p,1:cut_point)...
%         ==max(data_str.sample_td(p,1:cut_point)));
%     diff_sample(p)=pos_sample(p)-pos_bl(1);
%     if diff_sample(p)<0
%         data_str.sample_td_aligned(p,:)=[zeros(1,-diff_sample(p)),...
%             data_str.sample_td(p,1:end+diff_sample(p))];
%     else
%         data_str.sample_td_aligned(p,:)=...
%             [data_str.sample_td(p,diff_sample(p)+1:end),zeros(1,diff_sample(p))];
%     end
% end
% data_str.pos_sample=pos_sample;
% % output
% output_data=data_str;

%% align the signal by substraction the first reflection
mov_range=-100:100;  % how many points that the signal moves
compar_point=100; % compare this range: |max-comparing_range|to|max+comparing_range|
p=1;
data_str.baseline_td_aligned(p,:)=data_str.baseline_td(p,:);
% use the first baseline measurement as the benchmark
pos_bl(p)=find(data_str.baseline_td(p,1:cut_point)...
    ==max(data_str.baseline_td(p,1:cut_point))); % find where the pulse is
compar_range1=pos_bl(p)-compar_point;
compar_range2=pos_bl(p)+compar_point;
compar_signal0=data_str.baseline_td(p,compar_range1:compar_range2); % cut the first reflectin out

% align baseline
for p=2:length(data_str.baseline_td(:,1))
    for q=1:length(mov_range)
        if mov_range(q)<0
            signal_td_aligned_tem(q,:)=[zeros(1,-mov_range(q)),...
                data_str.baseline_td(p,1:end+mov_range(q))];
        else
            signal_td_aligned_tem(q,:)=...
                [data_str.baseline_td(p,mov_range(q)+1:end),zeros(1,mov_range(q))];
        end
        compar_signal(q,:)=signal_td_aligned_tem(q,compar_range1:compar_range2);
        diff_signal(q)= sum(abs(compar_signal(q,:)-compar_signal0));
    end
    [~,index(p)]=min(diff_signal);
    data_str.baseline_td_aligned(p,:)=signal_td_aligned_tem(index(p),:);
    data_str.move_bsl(p)=mov_range(index(p));
end

% align reference
for p=1:length(data_str.reference_td(:,1))
    for q=1:length(mov_range)
        if mov_range(q)<0
            signal_td_aligned_tem(q,:)=[zeros(1,-mov_range(q)),...
                data_str.reference_td(p,1:end+mov_range(q))];
        else
            signal_td_aligned_tem(q,:)=...
                [data_str.reference_td(p,mov_range(q)+1:end),zeros(1,mov_range(q))];
        end
        compar_signal(q,:)=signal_td_aligned_tem(q,compar_range1:compar_range2);
        diff_signal(q)= sum(abs(compar_signal(q,:)-compar_signal0));
    end
    [~,index(p)]=min(diff_signal);
    data_str.reference_td_aligned(p,:)=signal_td_aligned_tem(index(p),:);
    data_str.move_ref(p)=mov_range(index(p));
end

% align the sample
for p=1:length(data_str.sample_td(:,1))
    for q=1:length(mov_range)
        if mov_range(q)<0
            signal_td_aligned_tem(q,:)=[zeros(1,-mov_range(q)),...
                data_str.sample_td(p,1:end+mov_range(q))];
        else
            signal_td_aligned_tem(q,:)=...
                [data_str.sample_td(p,mov_range(q)+1:end),zeros(1,mov_range(q))];
        end
        compar_signal(q,:)=signal_td_aligned_tem(q,compar_range1:compar_range2);
        diff_signal(q)= sum(abs(compar_signal(q,:)-compar_signal0));
    end
    [~,index(p)]=min(diff_signal);
    data_str.sample_td_aligned(p,:)=signal_td_aligned_tem(index(p),:);
    data_str.move_sample(p)=mov_range(index(p));
end
% output
output_data=data_str;