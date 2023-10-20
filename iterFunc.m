function [status,opdata_out] = iterFunc(~,name,opdata_in)
    status = 0;
    
    opdata_out = [opdata_in;{name}];
    
    
%     while ismepty(opdata_in.name)
%         opdata_in.name
%     end
%     
%     if ~strcmp(name,'Current Reference')
%         opdata_out = opdata_in;
%     else
%         opdata_out = name;
%     end
    
end

